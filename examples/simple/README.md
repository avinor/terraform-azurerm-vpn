# Simple example

This example deploys a minimum setup for VPN module. It will create a virtual gateway with no local networks defined and all default settings. `log_analytics_workspace_id` is not defined so it will not send logs to any Log Analytics workspace.

## Testing

To test this example run (this assumes you are in the parent folder)

```bash
terraform init -backend=false examples/simple
terraform plan examples/simple
terraform apply examples/simple
```

It is also possible to only test it to check the syntax by running

```bash
terraform validate examples/simple
```