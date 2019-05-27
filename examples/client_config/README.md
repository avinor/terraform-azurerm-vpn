# Client configuration example

For configuring point-to-site configurations use the `client_configuration` variable. This example show how this can be configured. The certificate is just a demo certificate and should **not** be used in a real deployment.

## Testing

To test this example run (this assumes you are in the parent folder)

```bash
terraform init -backend=false examples/client_config
terraform plan examples/client_config
terraform apply examples/client_config
```

It is also possible to only test it to check the syntax by running

```bash
terraform validate examples/client_config
```