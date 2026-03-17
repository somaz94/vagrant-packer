# Legacy JSON Templates (Deprecated)

These Packer JSON templates are kept for reference only.

For new builds, use the HCL2 templates in `../hcl2/` which support:
- `templatefile()` for kickstart variable injection
- `sensitive` variable marking
- Variable files (`.auto.pkrvars.hcl`)
- Better IDE support and validation

To migrate JSON templates to HCL2:

```bash
packer hcl2_upgrade your-template.json
```

See [Packer: Migrate to HCL2](https://developer.hashicorp.com/packer/tutorials/configuration-language/hcl2-upgrade) for details.
