# Status Role

Verifies Pi-hole cluster service status.

## Requirements

- Ansible 2.14+
- Pi-hole cluster deployed

## Role Variables

None.

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
