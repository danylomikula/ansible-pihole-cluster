# Status Role

Verifies Pi-hole cluster service status.

## Requirements

- Ansible 2.14+
- Pi-hole cluster deployed

## Role Variables

No role-specific variables.

**Global variables used:**

| Variable | Default | Description |
|----------|---------|-------------|
| `ipv6_enabled` | `false` | Enable IPv6 support |
| `ipv6_vip` | `fe80::53/64` | IPv6 virtual IP address |
| `keepalived_vip_ipv4` | `10.20.0.53/16` | IPv4 virtual IP address |
| `unbound_enabled` | `true` | Check unbound service status |

Status output is printed on hosts in the `master` group.

Services are automatically checked based on enabled components:
- keepalived (always)
- pihole-FTL (always)
- unbound (when `unbound_enabled` is true)

## Dependencies

None

## Example Playbook

```yaml
- hosts: pihole_cluster
  roles:
    - role: danylomikula.ansible_pihole_cluster.status
```

## License

Apache 2.0 Licensed. See [LICENSE](LICENSE) for full details.

## Authors

Role managed by [Danylo Mikula](https://github.com/danylomikula).
