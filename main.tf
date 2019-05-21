terraform {
  required_version = ">= 0.12.0"
  backend "azurerm" {}
}


#
# Resource group
#

resource "azurerm_resource_group" "gw" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

#
# Gateway
#

module "vpn_key" {
  source     = "../../secrets/cert"
  name       = "vpn"
  vault_name = "${data.terraform_remote_state.setup.vault_name}"
  vault_id   = "${data.terraform_remote_state.setup.vault_id}"
}

resource "azurerm_public_ip" "gw" {
  name                = "${var.name}-gw-pip"
  location            = azurerm_resource_group.gw.location
  resource_group_name = azurerm_resource_group.gw.name

  allocation_method = "Static"
  domain_name_label = "${var.name}-gw"
  sku               = "Standard"

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "gw_pip" {
  count                      = "${var.create_gateway}"
  name                       = "gw-pip-log-analytics"
  target_resource_id         = "${azurerm_public_ip.gw.id}"
  log_analytics_workspace_id = "${data.terraform_remote_state.setup.log_resource_id}"

  log {
    category = "DDoSProtectionNotifications"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "DDoSMitigationFlowLogs"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "DDoSMitigationReports"

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_virtual_network_gateway" "gw" {
  count               = "${var.create_gateway}"
  name                = "${var.hub_prefix}-gw"
  location            = "${azurerm_resource_group.vnet.location}"
  resource_group_name = "${azurerm_resource_group.vnet.name}"

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "${var.hub_prefix}-gw-config"
    public_ip_address_id          = "${azurerm_public_ip.gw.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${azurerm_subnet.gateway.id}"
  }

  vpn_client_configuration {
    address_space = ["${var.client_address_space}"]

    root_certificate {
      name = "Avinor-VPN-Certificate"

      public_cert_data = "${module.vpn_key.ca_cert_base64_value}"
    }

    vpn_client_protocols = [
      "SSTP",
      "IkeV2",
    ]
  }

  # TODO Buggy... keep want to change this attribute
  lifecycle {
    ignore_changes = ["vpn_client_configuration.0.root_certificate"]
  }

  tags = "${var.tags}"
}

resource "azurerm_monitor_diagnostic_setting" "gw" {
  count                      = "${var.create_gateway}"
  name                       = "gw-analytics"
  target_resource_id         = "${azurerm_virtual_network_gateway.gw.id}"
  log_analytics_workspace_id = "${data.terraform_remote_state.setup.log_resource_id}"

  log {
    category = "GatewayDiagnosticLog"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "TunnelDiagnosticLog"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "RouteDiagnosticLog"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "IKEDiagnosticLog"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "P2SDiagnosticLog"

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_local_network_gateway" "onpremise" {
  name                = "${var.hub_prefix}-onpremise"
  resource_group_name = "${azurerm_resource_group.vnet.name}"
  location            = "${azurerm_resource_group.vnet.location}"
  gateway_address     = ""
  address_space       = [
  ]

  tags = "${var.tags}"
}

resource "random_string" "shared_key" {
  length = 32
  special = true
  override_special = "_-"
}

resource "azurerm_virtual_network_gateway_connection" "onpremise" {
  name                = "${var.hub_prefix}-onpremise"
  location            = "${azurerm_resource_group.vnet.location}"
  resource_group_name = "${azurerm_resource_group.vnet.name}"

  type                       = "IPsec"
  virtual_network_gateway_id = "${azurerm_virtual_network_gateway.gw.id}"
  local_network_gateway_id   = "${azurerm_local_network_gateway.onpremise.id}"

  shared_key = "${random_string.shared_key.result}"

  tags = "${var.tags}"
}