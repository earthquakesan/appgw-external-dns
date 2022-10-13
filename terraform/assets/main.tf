# Create a resource group
resource "azurerm_resource_group" "test_rg" {
  name     = var.rg.name
  location = var.rg.location
}

resource "azurerm_dns_zone" "test_zone" {
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.test_rg.name
}

#######################
# Application Gateway #
#######################

# We don't care about appgw configuration as the application is only fetching its' public IP

resource "azurerm_virtual_network" "appgw" {
  name                = "appgw-vnet"
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = azurerm_resource_group.test_rg.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.test_rg.name
  virtual_network_name = azurerm_virtual_network.appgw.name
  address_prefixes     = ["10.254.0.0/24"]
}

resource "azurerm_public_ip" "appgw_pip" {
  name                = "appgw-pip"
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = azurerm_resource_group.test_rg.location
  allocation_method   = "Dynamic"
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.appgw.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.appgw.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.appgw.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.appgw.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.appgw.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.appgw.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.appgw.name}-rdrcfg"
}

resource "azurerm_application_gateway" "test_appgw" {
  name                = "test-appgateway"
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = azurerm_resource_group.test_rg.location

  # Take the cheapest tier - 3 euro cent per hour
  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

######################################
# Service Principal for The Operator #
######################################

resource "azuread_application" "appgw_external_dns" {
  display_name = "AppgwExternalDns"
}

resource "azuread_service_principal" "appgw_external_dns_sp" {
  application_id = azuread_application.appgw_external_dns.application_id
}

resource "azuread_application_password" "appgw_external_dns_sp_passwd" {
  application_object_id = azuread_application.appgw_external_dns.object_id
}

resource "azurerm_role_assignment" "test_zone_sp_ra" {
  scope                = azurerm_dns_zone.test_zone.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.appgw_external_dns_sp.id
}

resource "azurerm_role_assignment" "test_appgw_sp_ra" {
  scope                = azurerm_application_gateway.test_appgw.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.appgw_external_dns_sp.id
}

resource "azurerm_role_assignment" "test_appgw_pip_sp_ra" {
  scope                = azurerm_public_ip.appgw_pip.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.appgw_external_dns_sp.id
}
