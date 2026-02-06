# Pi-hole Role

Installs and configures Pi-hole DNS sinkhole.

## Requirements

- Ansible 2.14+
- Root/sudo access
- Supported OS (Debian, Ubuntu, Rocky Linux)

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `pihole_version` | `6.3` | Pi-hole version |
| `pihole_web_password` | **required** | Web UI password (use vault) |
| `pihole_local_domain` | `homelab.local` | Local domain |
| `pihole_interface` | `""` (auto) | Network interface (empty for auto-detection) |
| `pihole_upstream_dns` | `[1.1.1.1, 1.0.0.1]` | Upstream DNS |
| `pihole_web_theme` | `default-auto` | Web UI theme |
| `pihole_dnssec` | `false` | Enable DNSSEC |
| `pihole_dns_cache_size` | `10000` | DNS cache size |
| `pihole_reboot_after_run` | `true` | Reboot cluster in order after install (master -> backup) |
| `pihole_reboot_timeout` | `900` | Reboot timeout (seconds) |

See `defaults/main.yml` for all available variables.

## Dependencies

None

## Example Playbook

```yaml
- hosts: pihole_cluster
  roles:
    - role: danylomikula.ansible_pihole_cluster.pihole
      vars:
        pihole_web_password: "{{ vault_pihole_password }}"
        pihole_local_domain: "home.lan"
```

## Security Note

Always use `ansible-vault` for `pihole_web_password`. The password is set securely using stdin and `no_log: true`.

## License

Apache 2.0 Licensed. See [LICENSE](LICENSE) for full details.

## Authors

Role managed by [Danylo Mikula](https://github.com/danylomikula).
