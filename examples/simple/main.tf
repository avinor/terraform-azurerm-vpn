module "simple" {
    source = "../../"

    name = "vpn"
    resource_group_name = "simple-vpn-rg"
    location = "westeurope"
}