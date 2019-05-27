# Azure VPN

Deployes a virtual network gateway in Azure as Vpn, does not support Expressroute setup. Since the vpn has to be deployed in same resource group as the virtual network it will not create any resource groups (and also not try to delete resource group if destroying vpn module). Vpn can be configured in active-active mode with optional point-to-site configuration activated.

## Usage

Deploying a vpn without any local connections is possible, but for a more complete example see `examples/local_networks`:

```terraform
module "simple" {
    source = "avinor/vpn/azurerm"
    version = "1.0.0"

    name = "vpn"
    resource_group_name = "simple-vpn-rg"
    location = "westeurope"
    subnet_id = "/subscriptions/00000"
    sku = "VpnGw1"

    local_networks = [
        {
            name = "onpremise"
            gateway_address = "8.8.8.8"
            type = "IPsec"
            address_space = [
                "10.0.0.0/8"
            ]
            shared_key = "TESTING"
        },
    ]
}
```

## Input

This describes the more complicated input parameters that do not have a full description in variables file.

### client_configuration

Configuration for setting up point-to-site.

| Variable      | Description
|---------------|-------------
| address_space | Address space of the clients connecting. All clients connecting will be assigned an address in this space
| protocols     | Vpn protocols to support. The supported values are `SSTP`, `IkeV2` and `OpenVPN`.
| certificate   | The public certificate of the root certificate authority. The certificate must be provided in Base-64 encoded X.509 format (PEM)

To generate a certificate follow the [Microsoft guidelines for generating certificates.](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site-linux)

### local_networks

List of local networks to connect to vpn.

| Variable        | Description
|-----------------|-------------
| name            | Name of the local connection, must be unique
| gateway_address | The IP address of the gateway to which to connect.
| address_space   | The list of string CIDRs representing the address spaces the gateway exposes.
| shared_key      | The shared IPSec key.
