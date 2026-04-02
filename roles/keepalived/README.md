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
| `keepalived_interface` | `""` (auto) | VRRP interface (auto-detected from default IPv4 interface) |
| `keepalived_unicast_src_ip` | `""` (auto) | Unicast source IP (auto-detected from default IPv4 address) |
| `keepalived_interface_ipv6` | `""` (auto) | IPv6 VRRP interface (auto-detected from default IPv6 interface, then falls back to `keepalived_interface`) |
| `keepalived_unicast_src_ip_ipv6` | `""` (auto) | Unicast source IPv6 address (auto-detected from default IPv6 address) |
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
| `ipv6_vip` | `""` | IPv6 virtual IP address (CIDR notation); required when `ipv6_enabled: true` |

## Dependencies

None

## IPv6 Notes

When `ipv6_enabled: true`, the role creates a separate IPv6 VRRP instance.

- In the default setup, you only need to set the VIPs. The role auto-detects the IPv4/IPv6 interfaces and peer addresses.
- IPv4 and IPv6 VRRP unicast transport must use matching address families.
- The role does not set `unicast_src_ip` unless you explicitly override it, so keepalived uses its documented default source-address selection.
- IPv6 peer discovery uses `keepalived_unicast_src_ip_ipv6` first, then falls back to each host's `default_ipv6.address`.
- Use `keepalived_interface_ipv6` or `keepalived_unicast_src_ip_ipv6` only when auto-detection picks the wrong IPv6 interface or source address.

## Example Playbook

```yaml
- hosts: pihole_cluster
  roles:
    - role: danylomikula.ansible_pihole_cluster.keepalived
      vars:
        keepalived_vip_ipv4: "192.168.1.53/24"
```

## License

Apache 2.0 Licensed. See [LICENSE](../../LICENSE) for full details.

## Authors

Role managed by [Danylo Mikula](https://github.com/danylomikula).
