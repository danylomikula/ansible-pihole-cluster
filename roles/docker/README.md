# Docker Role

Installs Docker on the master node for running nebula-sync container.

## Requirements

- Ansible 2.14+
- Root/sudo access
- Internet access for Docker installation

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `nebula_sync_enabled` | `true` | Enable Docker installation (runs only on master node) |
| `docker_install_packages` | `[docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin]` | Docker packages to install (RedHat only) |

Installation method varies by OS:
- **Debian/Ubuntu**: Uses official Docker convenience script (get.docker.com)
- **RedHat/CentOS**: Uses Docker CE repository with configurable packages

## Dependencies

None

## Example Playbook

```yaml
- hosts: pihole_cluster
  roles:
    - role: danylomikula.ansible_pihole_cluster.docker
      when: nebula_sync_enabled | default(true)
```

## License

Apache 2.0 Licensed. See [LICENSE](LICENSE) for full details.

## Authors

Role managed by [Danylo Mikula](https://github.com/danylomikula).
