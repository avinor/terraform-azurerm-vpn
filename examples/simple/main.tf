module "simple" {
    source = "../../"

    name = "vpn"
    resource_group_name = "simple-vpn-rg"
    location = "westeurope"
    subnet_id = "/subscriptions/00000"
    sku = "VpnGw1"
}