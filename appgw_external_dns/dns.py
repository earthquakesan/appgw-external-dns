import os

from azure.mgmt.dns import DnsManagementClient
from azure.mgmt.dns.models import RecordSet
from azure.identity import DefaultAzureCredential

# Replace this with your subscription id
CREDENTIAL = DefaultAzureCredential()
SUBSCRIPTION_ID = os.environ.get("SUBSCRIPTION_ID")

DNS_CLIENT = DnsManagementClient(
	CREDENTIAL,
    SUBSCRIPTION_ID
)

def create_dns_record(
    resource_group_name: str,
    dns_zone_name: str,
    record_set_name: str,
    ttl: int,
    ip_address: str) -> RecordSet:
    record_set = DNS_CLIENT.record_sets.create_or_update(
        resource_group_name,
        dns_zone_name,
        record_set_name,
        'A',
        {
                "ttl": ttl,
                "arecords": [
                    {
                    "ipv4_address": ip_address
                    }
                ]
        }
    )
    return record_set

def delete_dns_record(
    resource_group_name: str,
    dns_zone_name: str,
    record_set_name: str) -> None:
    DNS_CLIENT.record_sets.delete(
        resource_group_name,
        dns_zone_name,
        record_set_name,
        'A'
    )

def get_dns_record(
    resource_group_name: str,
    dns_zone_name: str,
    record_set_name: str) -> RecordSet:
    return DNS_CLIENT.record_sets.get(
        resource_group_name,
        dns_zone_name,
        record_set_name,
        'A'
    )