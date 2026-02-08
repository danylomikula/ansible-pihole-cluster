# Nebula Sync Role

Deploys nebula-sync Docker container for Pi-hole settings synchronization.

## Requirements

- Ansible 2.14+
- Docker installed on master node
- Root/sudo access

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `nebula_sync_enabled` | `true` | Enable nebula-sync |
| `nebula_sync_version` | `v0.11.1` | Container version |
| `nebula_sync_cron` | `*/30 * * * *` | Sync schedule (cron) |
| `nebula_sync_client_skip_tls_verification` | `true` | Skip TLS verification |
| `nebula_sync_run_gravity` | `true` | Run gravity after sync |
| `nebula_sync_full_sync` | `true` | Full sync mode |
| `nebula_sync_additional_settings` | `{}` | Partial sync settings |

**Required global variable:**
- `pihole_web_password` - Pi-hole admin password (from pihole role)

## Dependencies

None

## Example Playbook

```yaml
- hosts: pihole_cluster
  roles:
    - role: danylomikula.ansible_pihole_cluster.nebula_sync
      when: nebula_sync_enabled | default(true)
```

## License

Apache 2.0 Licensed. See [LICENSE](LICENSE) for full details.

## Authors

Role managed by [Danylo Mikula](https://github.com/danylomikula).
