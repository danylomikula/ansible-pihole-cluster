# Bootstrap Role

Prepares the system for Pi-hole cluster deployment.

## Requirements

- Ansible 2.14+
- Root/sudo access

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `bootstrap_timezone` | `America/New_York` | System timezone (IANA format) |
| `bootstrap_install_packages` | `[unzip, curl]` | Packages to install |

Additional packages installed automatically:
- **All systems**: DNS utilities (`dnsutils` on Debian, `bind-utils` on RedHat)
- **RedHat only**: SELinux Python bindings (`python3-libselinux`, `python3-requests`)

SELinux is automatically disabled on RedHat-based systems.

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

Apache 2.0 Licensed. See [LICENSE](LICENSE) for full details.

## Authors

Role managed by [Danylo Mikula](https://github.com/danylomikula).
