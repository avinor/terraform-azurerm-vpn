module "simple" {
    source = "../../"

    name = "vpn"
    resource_group_name = "simple-vpn-rg"
    location = "westeurope"
    subnet_id = "/subscriptions/00000"
    sku = "VpnGw1"

    client_configuration = {
        address_space = "172.16.0.0/24"
        protocols = ["SSTP","IkeV2"]
        certificate = "BASE64_PEM_CERTIFICATE"
    }
}