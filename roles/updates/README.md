# Updates Role

Updates system packages on Pi-hole cluster nodes.

## Requirements

- Ansible 2.14+
- Root/sudo access

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `updates_enabled` | `true` | Enable updates |
| `updates_reboot` | `true` | Reboot after updates if required |

Package cache and unused packages are automatically cleaned.

## Dependencies

None

## Example Playbook

```yaml
- hosts: pihole_cluster
  roles:
    - role: danylomikula.ansible_pihole_cluster.updates
```

## License

Apache 2.0 Licensed. See [LICENSE](LICENSE) for full details.

## Authors

Role managed by [Danylo Mikula](https://github.com/danylomikula).
