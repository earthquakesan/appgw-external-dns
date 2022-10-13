# Test Scaffold On Azure

The terraform is used to create test infra on Azure:
* Azure DNS
* Application Gateway
* Service Principal in AD with access to Azure DNS (read/write) and Application Gateway (write only)

# Initialization of Azure Storage for TF state

```
./init-storage-account.sh
```

# Notes

* Average time to create resources: ~20 mins (appgw creation is slow)
