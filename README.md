# Azure VPN

Deployes a virtual network gateway in Azure as Vpn, does not support Expressroute setup. Since the vpn has to be deployed in same resource group as the virtual network it will not create any resource groups (and also not try to delete resource group if destroying vpn module). Vpn can be configured in active-active mode with optional point-to-site configuration activated.

## Usage

Deploying a vpn without any local connections is possible, but for a more complete example see `examples/local_networks`.

Example uses [tau](https://github.com/avinor/tau) and a key vault data source to retrieve the shared_key.

```terraform
data "azurerm_key_vault_secret" "shared_key" {
  name         = "vpn_shared_key"
  key_vault_id = "KEYVAULT_ID"
}

module {
    source = "avinor/vpn/azurerm"
    version = "1.1.0"
}

inputs {
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
            shared_key = data.azurerm_key_vault_secret.shared_key.outputs.value
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
| ipsec_policy    | (Optional) Custom IPSec Policy, see description below

## IPSec Policy

Microsoft has set the default policy sets to maximize interoperability with a wide range of third-party VPN devices in default configurations. Thus, the default configurations are focusing on compatibility, not security.
Note: The on-premise VPN device must match the parameters we choose. Since we are using RouteBased VPN, it is important that Azure Gateway acts as responder. This provides more IPsec SA offers.

Regarding the protocols, IKEv2 sets up a secure channel between hosts (Main mode/Phase 1). The channel is then used as a base to securely initiate the IPsec security association (SA) which is used to encrypt and decrypt application data (Quick mode/Phase 2).  A SA consists of attributes like cryptographic algorithms and mode. IPsec encapsulates the packets sent over an IPv4 or IPv6 network, and provides authenticity, integrity (hash functions), and confidentiality(encryption).

### dh_group

**Do not use:** DHGroup2(1024-bit), DHGroup1(768-bit), None.

### ike_encryption

**Do not use:** DES3 (brute-force attacks), DES (brute-force attacks).

### ike_integrity

**Do not use:** SHA1 (SHAttered), MD5 (collision attacks).

### ipsec_encryption

**Do not use:** DES3 (brute-force attacks), DES (brute-force attacks), None.

### ipsec_integrity

**Do not use:** SHA1 (SHAttered), MD5 (collision attacks).

### pfs_group

**Do not use:** PFS2, PFS1, None.

### sa_lifetime

IKEv2 corresponds to Main Mode or Phase 1. IKEv2 Main Mode SA lifetime is fixed at 28,800 seconds (8 hours) on the Azure VPN gateways.
