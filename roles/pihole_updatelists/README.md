# Pi-hole Updatelists Role

Automated blocklist management for Pi-hole using pihole-updatelists.

## Requirements

- Ansible 2.17+
- Pi-hole installed
- Root/sudo access

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `pihole_updatelists_enabled` | `true` | Enable updatelists |
| `pihole_updatelists_blocklists_url` | Firebog | URL containing list of blocklist URLs |
| `pihole_updatelists_blacklist_url` | StevenBlack | URL for exact domain blacklist |
| `pihole_updatelists_whitelist_url` | anudeepND | URL for exact domain whitelist |
| `pihole_updatelists_allowlists_url` | `""` | URL containing list of allowlist URLs |
| `pihole_updatelists_regex_blacklist_url` | mmotti | URL for regex blacklist rules |
| `pihole_updatelists_regex_whitelist_url` | mmotti | URL for regex whitelist rules |
| `pihole_updatelists_interval` | `24h` | Update frequency (e.g., 12h, 24h, weekly) |
| `pihole_updatelists_run_now` | `true` | Run updatelists immediately after install |

## Dependencies

None

## Example Playbook

```yaml
- hosts: pihole_cluster
  roles:
    - role: danylomikula.ansible_pihole_cluster.pihole_updatelists
      when: pihole_updatelists_enabled | default(true)
```

## License

Apache 2.0 Licensed. See [LICENSE](../../LICENSE) for full details.

## Authors

Role managed by [Danylo Mikula](https://github.com/danylomikula).
