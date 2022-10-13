output "service_principal_application_id" {
  value = azuread_service_principal.appgw_external_dns_sp.application_id
  sensitive = true
}

output "service_principal_tenant_id" {
  value = azuread_service_principal.appgw_external_dns_sp.application_tenant_id
  sensitive = true
}

output "service_principal_secret" {
  value = azuread_application_password.appgw_external_dns_sp_passwd.value
  sensitive = true
}
