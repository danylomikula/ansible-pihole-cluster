# Unbound Role

Installs and configures unbound as a recursive DNS resolver for Pi-hole.

## Requirements

- Ansible 2.14+
- Root/sudo access

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `unbound_enabled` | `true` | Enable unbound |
| `unbound_verbosity` | `0` | Log verbosity (0-5) |
| `unbound_interface` | `127.0.0.1` | Listen interface |
| `unbound_port` | `5335` | Listen port |
| `unbound_num_threads` | `1` | Worker threads |
| `unbound_edns_buffer_size` | `1232` | EDNS buffer size |
| `unbound_so_rcvbuf` | `1m` | Socket receive buffer size |
| `unbound_private_domain` | `homelab.local` | Private domain |

## Dependencies

None

## Example Playbook

```yaml
- hosts: pihole_cluster
  roles:
    - role: danylomikula.ansible_pihole_cluster.unbound
      when: unbound_enabled | default(true)
```

## License

Apache 2.0 Licensed. See [LICENSE](LICENSE) for full details.

## Authors

Role managed by [Danylo Mikula](https://github.com/danylomikula).
