# Pi-hole Role

Installs and configures Pi-hole DNS sinkhole.

## Requirements

- Ansible 2.14+
- Root/sudo access
- Supported OS (Debian, Ubuntu, Rocky Linux)

## Role Variables

**General:**

| Variable | Default | Description |
|----------|---------|-------------|
| `pihole_version` | `6.3` | Pi-hole version |
| `pihole_web_password` | **required** | Web UI password (use vault) |
| `pihole_manage_config` | `true` | Manage pihole.toml on every run (set `false` to keep web UI changes) |
| `pihole_reboot_after_run` | `true` | Reboot cluster in order after install (master -> backup) |
| `pihole_reboot_timeout` | `900` | Reboot timeout (seconds) |

**DNS settings:**

| Variable | Default | Description |
|----------|---------|-------------|
| `pihole_local_domain` | `homelab.local` | Local domain |
| `pihole_local_domain_local` | `true` | Keep queries local to this domain |
| `pihole_interface` | `""` (auto) | Network interface (empty for auto-detection) |
| `pihole_socket_listening` | `ALL` | Socket listening mode |
| `pihole_upstream_dns` | `[1.1.1.1, 1.0.0.1]` | Upstream DNS (ignored when unbound is enabled) |
| `pihole_query_logging` | `true` | Enable query logging |
| `pihole_privacy_level` | `0` | Privacy level (0=show everything, 3=hide all) |

**DNS behavior:**

| Variable | Default | Description |
|----------|---------|-------------|
| `pihole_cname_deep_inspect` | `true` | CNAME deep inspection |
| `pihole_block_esni` | `true` | Block encrypted SNI |
| `pihole_edns0_ecs` | `true` | EDNS0 client subnet |
| `pihole_ignore_localhost` | `false` | Ignore queries from localhost |
| `pihole_domain_needed` | `false` | Never forward non-FQDN queries |
| `pihole_bogus_priv` | `true` | Never forward reverse lookups for private ranges |
| `pihole_dns_cache_size` | `10000` | DNS cache size |
| `pihole_dnssec` | `false` | Enable DNSSEC validation |
| `pihole_show_dnssec` | `true` | Show DNSSEC status in web UI |

**Client resolution:**

| Variable | Default | Description |
|----------|---------|-------------|
| `pihole_resolve_ipv4` | `true` | Resolve IPv4 client names |
| `pihole_resolve_ipv6` | `true` | Resolve IPv6 client names |
| `pihole_network_names` | `true` | Use network-level name resolution |
| `pihole_refresh_names` | `IPV4_ONLY` | Name refresh policy |

**Rate limiting:**

| Variable | Default | Description |
|----------|---------|-------------|
| `pihole_rate_limit_count` | `1000` | Max queries per interval |
| `pihole_rate_limit_interval` | `60` | Rate limit interval (seconds) |

**Behavior:**

| Variable | Default | Description |
|----------|---------|-------------|
| `pihole_reply_when_busy` | `DROP` | Reply behavior when busy |
| `pihole_block_mozilla_canary` | `true` | Block Mozilla canary domain |
| `pihole_block_icloud_pr` | `true` | Block iCloud Private Relay |
| `pihole_ptr` | `HOSTNAMEFQDN` | PTR record behavior |

**Database:**

| Variable | Default | Description |
|----------|---------|-------------|
| `pihole_max_db_days` | `91` | Max database retention (days) |
| `pihole_db_interval` | `60` | Database write interval (seconds) |

**NTP sync:**

| Variable | Default | Description |
|----------|---------|-------------|
| `pihole_ntp_sync_active` | `true` | Enable NTP sync |
| `pihole_ntp_sync_server` | `time.cloudflare.com` | NTP server |
| `pihole_ntp_sync_interval` | `3600` | Sync interval (seconds) |
| `pihole_ntp_sync_count` | `8` | Number of NTP samples |

**Web interface:**

| Variable | Default | Description |
|----------|---------|-------------|
| `pihole_web_domain` | `{{ ansible_hostname }}.{{ pihole_local_domain }}` | Web domain |
| `pihole_web_port` | `80o,443os,[::]:80o,[::]:443os` | Web port configuration |
| `pihole_web_session_timeout` | `1800` | Session timeout (seconds) |
| `pihole_web_boxed_layout` | `true` | Boxed layout in web UI |
| `pihole_web_theme` | `default-auto` | Web UI theme |
| `pihole_web_acl` | `""` | Web access control list |
| `pihole_web_tls_cert` | `""` | Path to TLS certificate |
| `pihole_web_paths_webhome` | `""` | Custom web home path |
| `pihole_web_paths_prefix` | `""` | URL prefix (e.g., `/admin`) |

**Optional DNS records (uncomment to use):**

| Variable | Default | Description |
|----------|---------|-------------|
| `local_dns_records` | — | Custom DNS A/AAAA records (multiline string) |
| `local_cname_records` | — | Custom CNAME records (multiline string) |
| `pihole_rev_servers` | — | Conditional forwarding rules (list of `cidr`, `target`, `domain`) |

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
