module "simple" {
    source = "../../"

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