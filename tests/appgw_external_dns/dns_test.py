from appgw_external_dns.dns import *

RESOURCE_GROUP_NAME = os.environ.get("RESOURCE_GROUP_NAME", "")
DNS_ZONE_NAME = os.environ.get("DNS_ZONE_NAME", "")
APPGW_IP_ADDRESS = os.environ.get("APPGW_IP_ADDRESS", "")

def test_create_dns_record():
    record_set_name = "example"
    ttl = 360
    record_set = create_dns_record(
        RESOURCE_GROUP_NAME,
        DNS_ZONE_NAME,
        record_set_name,
        ttl,
        APPGW_IP_ADDRESS
    )
    assert record_set.name == record_set_name
    assert record_set.fqdn == f"{record_set_name}.{DNS_ZONE_NAME}."
    assert record_set.a_records[0].ipv4_address == APPGW_IP_ADDRESS
    
    retrieved_record_set = get_dns_record(
        RESOURCE_GROUP_NAME,
        DNS_ZONE_NAME,
        record_set_name
    )

    assert retrieved_record_set == record_set

    delete_dns_record(
        RESOURCE_GROUP_NAME,
        DNS_ZONE_NAME,
        record_set_name
    )
