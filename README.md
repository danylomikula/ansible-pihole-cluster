<div align="center">
  <h2 align="center"><strong>Pi-hole HA cluster with Keepalived, Nebula Sync, and Unbound</strong></h2>
  <h1 align="center">
    <picture>
      <img src=".github/logo.png" height="256" width="256" alt="pi-hole HA cluster project logo" />
    </picture>
  </h1>
  <p align="center">
    <a href="https://galaxy.ansible.com/ui/repo/published/danylomikula/ansible_pihole_cluster/">
      <img src="https://img.shields.io/badge/Ansible%20Galaxy-danylomikula.ansible__pihole__cluster-blue?logo=ansible" alt="Ansible Galaxy" />
    </a>
    <a href="https://dev.to/mikula/build-a-highly-available-pi-hole-cluster-with-ansible-vrrp-gbp">
      <img src="https://img.shields.io/badge/dev.to-Read%20the%20tutorial-black?logo=dev.to" alt="Read the tutorial on dev.to" />
    </a>
  </p>
</div>

## General Information
This Ansible Collection will allow you to bootstrap a Highly Available Pi-hole cluster with:
- [x] [keepalived](https://github.com/acassen/keepalived) - VRRP failover with Virtual IP
- [x] [nebula-sync](https://github.com/lovelaze/nebula-sync) - Pi-hole settings synchronization
- [x] [unbound](https://github.com/NLnetLabs/unbound) - Recursive DNS resolver
- [x] [pihole-updatelists](https://github.com/jacklul/pihole-updatelists) - Automated blocklist management

Has been tested on:
- [x] Debian - version 13 (Trixie)
- [x] Ubuntu - version 24.04 (Noble Numbat)
- [x] Rocky Linux - version 10

## Requirements
- Ansible 2.17+ installed on the control machine.
- Two Linux nodes where Pi-hole will be installed.
- Static IP configured on each node.
  > If your Linux distribution network controller is NetworkManager, you can use this example to set static IP, DNS, and gateway:<br />
    ```bash
    nmcli con mod "Wired connection 1" ipv4.addresses 10.0.20.50/24 ipv4.gateway 10.0.20.1 ipv4.dns "1.1.1.1 1.0.0.1" ipv4.ignore-auto-dns yes ipv4.method manual
    ```
- SSH access from the control machine to the nodes.
- Use SSH keys (recommended) or run playbooks with `-k` to be prompted for the SSH password.
- Privilege escalation via sudo is required.
- Use passwordless sudo (recommended) or run playbooks with `-K` to be prompted for the sudo password.
  > If your sudo policy requires a password, either use `-K` or enable passwordless sudo for the Ansible user. Example (run as `root`, replace `ansible` with your user):<br />
    ```bash
    echo ansible 'ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
    chmod 440 /etc/sudoers.d/ansible
    ```

  > [!NOTE]
  > You can use [ansible-bootstrap](https://github.com/danylomikula/ansible-bootstrap) to automate initial host setup (SSH keys, sudo, static IP, etc.) before running this collection.

## Guide
Read the step-by-step guide: **[Build a Highly Available Pi-hole Cluster with Ansible (VRRP)](https://dev.to/mikula/build-a-highly-available-pi-hole-cluster-with-ansible-vrrp-gbp)**

## Getting Started

### 1. Install the Collection

```bash
ansible-galaxy collection install danylomikula.ansible_pihole_cluster
```

### 2. Create Project Structure

Create **`inventory/hosts.ini`** with your nodes:
```ini
[master]
pihole-master ansible_host=10.0.20.50 ansible_ssh_private_key_file=~/.ssh/pihole-master priority=150

[backup]
pihole-backup ansible_host=10.0.20.51 ansible_ssh_private_key_file=~/.ssh/pihole-backup priority=140

[pihole_cluster:children]
master
backup
```

Create **`site.yml`** - the main playbook with all configuration:
```yaml
---
- name: Deploy Pi-hole HA Cluster
  hosts: pihole_cluster
  become: true
  vars:
    ansible_user: ansible
    bootstrap_timezone: "America/New_York"
    keepalived_vip_ipv4: "10.20.0.53/16"           # Virtual IP for failover
    pihole_web_password: "your-secure-password"    # Use ansible-vault!
    pihole_version: "6.3"
    nebula_sync_version: "v0.11.1"
    pihole_local_domain: "homelab.local"
    local_dns_records: |
      10.20.0.88 node.homelab.local
      10.20.0.96 nas.homelab.local
  roles:
    - role: danylomikula.ansible_pihole_cluster.updates
    - role: danylomikula.ansible_pihole_cluster.bootstrap
    - role: danylomikula.ansible_pihole_cluster.docker
    - role: danylomikula.ansible_pihole_cluster.keepalived
    - role: danylomikula.ansible_pihole_cluster.unbound
    - role: danylomikula.ansible_pihole_cluster.pihole
    - role: danylomikula.ansible_pihole_cluster.pihole_updatelists
    - role: danylomikula.ansible_pihole_cluster.nebula_sync
    - role: danylomikula.ansible_pihole_cluster.status
```

> See the full list of available variables in the [group_vars/all.yml](group_vars/all.yml) example.

### 3. Deploy Cluster

```bash
ansible-playbook site.yml
```

Point your DNS server settings to the virtual IP (`keepalived_vip_ipv4`) that you set in `site.yml`.

> **Note:**
> You can run `site.yml` playbook at any time.
> It will bootstrap a fresh Pi-hole installation or apply updates to an existing one.
> By default, any settings changed manually on the nodes (e.g. via the Pi-hole web UI) will be overwritten by the values defined in your playbook.
> To prevent this, set `pihole_manage_config: false` — the playbook will skip `pihole.toml` generation and preserve your existing configuration.

## Updates

To quickly update system or change settings, create an `update_cluster.yml` playbook:
```yaml
---
- name: Update Pi-hole HA Cluster
  hosts: pihole_cluster
  become: true
  vars:
    pihole_version: "6.3"
    nebula_sync_version: "v0.11.1"
  roles:
    - role: danylomikula.ansible_pihole_cluster.updates
    - role: danylomikula.ansible_pihole_cluster.pihole
    - role: danylomikula.ansible_pihole_cluster.nebula_sync
    - role: danylomikula.ansible_pihole_cluster.status
```

Then run:
```bash
ansible-playbook update_cluster.yml
```

You can use this playbook to:
- Update Pi-hole version.
- Update Pi-hole settings.
- Modify Pi-hole custom DNS or CNAME records.
- Update host packages and dependencies.

## Configuration Management

By default, the playbook generates `pihole.toml` from a template on every run, keeping the configuration in sync with your playbook variables. This means any changes made via the Pi-hole web UI will be overwritten.

You can control this behavior with `pihole_manage_config`:

```yaml
pihole_manage_config: true   # (default) Always generate pihole.toml from playbook variables
pihole_manage_config: false  # Skip config generation, preserve settings changed via web UI
```

> **Note:** Even with `pihole_manage_config: false`, the config is always generated during **initial installation** (Pi-hole needs it to start).

### Custom `pihole.toml` File

Alternatively, you can provide a **fully custom configuration file** instead of using the template.
Place a file named `custom-pihole.toml` in the **root directory of your Ansible project** and the playbook will use it instead of the template.

### How It Works
1. The playbook **checks** if `custom-pihole.toml` exists in your project root directory.
2. If found, it **copies** the custom file to `/etc/pihole/pihole.toml`, replacing the default template.
3. If no custom file is found, the playbook **generates** `pihole.toml` from the Jinja2 template (`pihole.toml.j2`) **using the variables from your playbook**.

## Included Roles

| Role | Description |
|------|-------------|
| `bootstrap` | System preparation (timezone, hostname, SELinux) |
| `docker` | Docker installation on master node (for nebula-sync) |
| `keepalived` | VRRP failover setup with Virtual IP |
| `nebula_sync` | Pi-hole settings synchronization via Docker |
| `pihole` | Pi-hole installation, configuration, and gravity update |
| `pihole_updatelists` | Automated blocklist management |
| `status` | Service status verification |
| `unbound` | Recursive DNS resolver |
| `updates` | System package updates |

## IPv6 Configuration

Set two global variables to enable IPv6 support across all components:

```yaml
ipv6_enabled: true
ipv6_vip: "fd00::53/64"
```

## Authors

Collection managed by [Danylo Mikula](https://github.com/danylomikula).

## Contributing

Contributions are welcome! Please read the [Contributing Guide](.github/contributing.md) for details.

## License

Apache 2.0 Licensed. See [LICENSE](LICENSE) for full details.
