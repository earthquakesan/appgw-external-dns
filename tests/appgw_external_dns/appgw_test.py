from ipaddress import ip_address
from appgw_external_dns.appgw import *

RESOURCE_GROUP_NAME = os.environ.get("RESOURCE_GROUP_NAME", "")
APPGW_NAME = os.environ.get("APPGW_NAME", "")

def test_create_dns_record():
    ip_address = get_app_gw_ip_address(
        RESOURCE_GROUP_NAME,
        APPGW_NAME
    )
    assert len(ip_address.split('.')) == 4
