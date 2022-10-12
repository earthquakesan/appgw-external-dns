from setuptools import setup, find_packages

setup(
    name='appgw_external_dns',
    version='0.1.0',
    packages=find_packages(include=['appgw_external_dns', 'appgw_external_dns.*']),
    install_requires=[
        'kopf',
        'azure-mgmt-dns',
        'azure-identity'
    ]
)
