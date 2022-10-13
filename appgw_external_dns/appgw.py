import os

from azure.identity import DefaultAzureCredential
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.network.models import ApplicationGateway
from azure.mgmt.resource import ResourceManagementClient

CREDENTIAL = DefaultAzureCredential()
SUBSCRIPTION_ID = os.environ.get("SUBSCRIPTION_ID")
API_VERSION = ""

NETWORK_CLIENT = NetworkManagementClient(
    CREDENTIAL,
    SUBSCRIPTION_ID
)

RESOURCE_CLIENT = ResourceManagementClient(
    CREDENTIAL,
    SUBSCRIPTION_ID
)

def get_app_gw_ip_address(
    resource_group_name: str,
    application_gateway_name: str
    ) -> ApplicationGateway:
    appgw = NETWORK_CLIENT.application_gateways.get(
        resource_group_name,
        application_gateway_name
    )
    public_ip_id = appgw.frontend_ip_configurations[0].public_ip_address.id
    public_ip = RESOURCE_CLIENT.resources.get_by_id(
        public_ip_id,
        "2022-07-01"
    )
    return public_ip.properties['ipAddress']
