import os
import kopf
import logging

from appgw_external_dns.dns import create_dns_record

# Setup is done via environment variables
RESOURCE_GROUP_NAME = os.environ.get("RESOURCE_GROUP_NAME", "")
DNS_ZONE_NAME = os.environ.get("DNS_ZONE_NAME", "")
APPGW_IP_ADDRESS = os.environ.get("APPGW_IP_ADDRESS", "")

@kopf.on.create('ingresses')
@kopf.on.update('ingresses')
def create_fn(spec, name, namespace, logger, **kwargs):
    logging.info(f"A handler is called with spec: {spec}")
    logging.info(f"A handler is called with name: {name}")
    logging.info(f"A handler is called with namespace: {namespace}")

    rules = spec.get('rules')
    hosts = [rule['host'] for rule in rules]
    for host in hosts:
        if DNS_ZONE_NAME in host:
            record_set_name = host.split(DNS_ZONE_NAME)[0].split('.')[0]
            ttl = 360
            logging.info(f"Adding {record_set_name} record in {RESOURCE_GROUP_NAME} for {DNS_ZONE_NAME} zone with {ttl} TTL and {APPGW_IP_ADDRESS} ip address.")
            create_dns_record(
                RESOURCE_GROUP_NAME,
                DNS_ZONE_NAME,
                record_set_name,
                ttl,
                APPGW_IP_ADDRESS
            )
        else:
            logging.info(f"{host} host is not sub domain of {DNS_ZONE_NAME}, skipping...")

