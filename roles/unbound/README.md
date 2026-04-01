# Unbound Role

Installs and configures unbound for Pi-hole using either recursive resolution or a native `forward-zone` configuration.

## Requirements

- Ansible 2.17+
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
| `unbound_mode` | `recursive` | Resolver mode: `recursive` or `forward` |
| `unbound_forward_zone` | `""` | Native `forward-zone` clause body without the `forward-zone:` line |
| `unbound_private_domain` | `{{ pihole_local_domain }}` | Private domain (inherits from `pihole_local_domain`, falls back to `homelab.local`) |

## Dependencies

None

## Modes

- `recursive`: Unbound resolves DNS queries itself.
- `forward`: Unbound forwards queries using the native `forward-zone` block that you provide.

## Forwarding

`unbound_forward_zone` accepts the body of a native Unbound `forward-zone` clause without the leading `forward-zone:` line. It is used only when `unbound_mode: forward`.

Reference:
- https://unbound.docs.nlnetlabs.nl/en/latest/manpages/unbound.conf.html#forward-zone-options

Quad9 DNS-over-TLS example:

```yaml
unbound_mode: forward
unbound_forward_zone: |
  name: "."
  forward-tls-upstream: yes
  forward-addr: 9.9.9.9@853#dns.quad9.net
  forward-addr: 149.112.112.112@853#dns.quad9.net
  forward-addr: 2620:fe::fe@853#dns.quad9.net
  forward-addr: 2620:fe::9@853#dns.quad9.net
```

Quad9 service references:
- https://docs.quad9.net/services/
- https://quad9.net/service/service-addresses-and-features/

## Example Playbook

```yaml
- hosts: pihole_cluster
  roles:
    - role: danylomikula.ansible_pihole_cluster.unbound
      when: unbound_enabled
```

Recursive mode example:

```yaml
unbound_mode: recursive
```

Forward mode example with Quad9 DoT:

```yaml
unbound_mode: forward
unbound_forward_zone: |
  name: "."
  forward-tls-upstream: yes
  forward-addr: 9.9.9.9@853#dns.quad9.net
  forward-addr: 149.112.112.112@853#dns.quad9.net
  forward-addr: 2620:fe::fe@853#dns.quad9.net
  forward-addr: 2620:fe::9@853#dns.quad9.net
```

## License

Apache 2.0 Licensed. See [LICENSE](../../LICENSE) for full details.

## Authors

Role managed by [Danylo Mikula](https://github.com/danylomikula).
