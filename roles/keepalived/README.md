# Keepalived Role

Installs and configures keepalived for Pi-hole high availability using VRRP.

## Requirements

- Ansible 2.17+
- Root/sudo access
- Two or more nodes for HA

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `keepalived_vip_ipv4` | `10.20.0.53/16` | Virtual IPv4 (CIDR) |
| `keepalived_interface` | `""` (auto) | VRRP interface (empty = `ansible_default_ipv4.interface`) |
| `keepalived_unicast_src_ip` | `""` (auto) | Unicast source IP (empty = `ansible_default_ipv4.address`) |
| `keepalived_virtual_router_id` | `1` | VRRP router ID (1-255) |
| `keepalived_advert_int` | `1` | Advertisement interval (seconds) |
| `keepalived_preempt_delay` | `900` | Preemption delay (seconds) |
| `keepalived_check_interval` | `2` | Health check interval (seconds) |
| `keepalived_check_timeout` | `2` | Health check timeout (seconds) |
| `keepalived_check_fall` | `3` | Failures before marking DOWN |
| `keepalived_check_rise` | `2` | Successes before marking UP |
| `priority` | **required** | VRRP priority (host variable) |

**Global variables (shared across roles):**

| Variable | Default | Description |
|----------|---------|-------------|
| `ipv6_enabled` | `false` | Enable IPv6 support |
| `ipv6_vip` | `fe80::53/64` | IPv6 virtual IP address (CIDR notation) |

## Dependencies

None

## Example Playbook

```yaml
- hosts: pihole_cluster
  roles:
    - role: danylomikula.ansible_pihole_cluster.keepalived
      vars:
        keepalived_vip_ipv4: "192.168.1.53/24"
```

## Inventory Example

```ini
[master]
pihole-01 priority=150

[backup]
pihole-02 priority=140
```

## License

Apache 2.0 Licensed. See [LICENSE](../../LICENSE) for full details.

## Authors

Role managed by [Danylo Mikula](https://github.com/danylomikula).
