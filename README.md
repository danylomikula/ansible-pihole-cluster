<div align="center">
  <h2 align="center"><strong>Pi-hole HA cluster with Keepalived, Gravity-Sync, and Unbound</strong></h2>
  <h1 align="center">
    <picture>
      <img src=".github/logo.png" height="256" width="256" alt="pi-hole HA cluster project logo" />
    </picture>
  </h1>
</div>

## 📖 General Information
This Ansible playbook will allow you to bootstrap a Highly Available Pi-hole cluster with:
- [x] [keepalived](https://github.com/acassen/keepalived)
- [x] [Gravity Sync](https://github.com/vmstan/gravity-sync)
- [x] [unbound](https://github.com/NLnetLabs/unbound)

Has been tested on:
- [x] Debian - version 12 (bookworm)
- [x] Ubuntu - version 22.04 (Jammy Jellyfish)
- [x] Ubuntu - version 23.10 (Mantic Minotaur)
- [x] Rocky - version 9.3

## ✅ Requirements
- Ansible 2.14+

- Two `nodes` on which Pi-hole will be installed.

- Each `node` should have a static IP address.
  > If your Linux distribution network controller is NetworkManager, you can use this example to set static IP, DNS, and gateway:<br />
    ```bash 
    nmcli con mod "Wired connection 1" ipv4.addresses 10.0.20.50/24 ipv4.gateway 10.0.20.1 ipv4.dns "1.1.1.1 1.0.0.1" ipv4.ignore-auto-dns yes ipv4.method manual
    ```

- Passwordless SSH access between the machine running `ansible` and the `nodes`, if not you can supply arguments to provide credentials `--ask-pass --ask-become-pass` to each command.

- Ansible should be able to use sudo without a password.<br />
  > You may need to configure this on `Rocky Linux`.<br />
    Suppose your `ansible_user = rocky`, run this command under `root` user to disable password verification for `rocky` user:<br />
    ```bash 
    echo rocky 'ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/rocky
    ```

## 🚀 Getting Started
- Install collections that this playbook uses by running<br /> `ansible-galaxy collection install -r ./collections/requirements.yml`

- Edit the `inventory/hosts.ini` file with IP addresses, hostnames and paths to your SSH keys for each node.
  ```bash
  [master]
  pihole-master ansible_host=10.0.20.50 ansible_ssh_private_key_file=~/.ssh/pihole-master priority=150
  
  [backup]
  pihole-backup ansible_host=10.0.20.51 ansible_ssh_private_key_file=~/.ssh/pihole-backup priority=140
  ```

- Modify `inventory/group_vars/all.yml` based on your needs.

- Start cluster provisioning using the following command:
  `ansible-playbook bootstrap-pihole.yaml`

- Point your DNS server settings to the virtual IP (`pihole_vip_ipv4`, `pihole_vip_ipv6`) that you set previously in `inventory/group_vars/all.yml`

> [!NOTE]
> You can run `bootstrap-pihole.yaml` playbook any time.<br />
> It will bootstrap a fresh Pi-hole installation with updates (statistics will not be deleted)

## ⚙️ Updates
To quickly update system or change settings you can run `update-pihole.yaml` playbook<br />
`ansible-playbook update-pihole.yaml`

You can use this playbook to:
- Update Pi-hole version.
- Update Pi-hole settings.
- Modify Pi-hole custom DNS or CNAME records.
- Update host packages and dependencies.
