# Bootstrap Role

Prepares the system for Pi-hole cluster deployment.

## Requirements

- Ansible 2.17+
- Root/sudo access

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `bootstrap_timezone` | `America/New_York` | System timezone (IANA format) |
| `bootstrap_install_packages` | `[unzip, curl]` | Packages to install |

The role also:
- Sets the system hostname to `inventory_hostname` (triggers reboot if changed)
- Installs DNS utilities (`dnsutils` on Debian, `bind-utils` on RedHat)
- Installs SELinux Python bindings and disables SELinux on RedHat-based systems

## Dependencies

None

## Example Playbook

```yaml
- hosts: pihole_cluster
  roles:
    - role: danylomikula.ansible_pihole_cluster.bootstrap
      vars:
        bootstrap_timezone: "Europe/London"
```

## License

Apache 2.0 Licensed. See [LICENSE](../../LICENSE) for full details.

## Authors

Role managed by [Danylo Mikula](https://github.com/danylomikula).
