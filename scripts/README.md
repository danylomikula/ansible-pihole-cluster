# Scripts

Utility scripts for testing and managing the ansible-pihole-cluster project.

## test-all-platforms.sh

Run molecule tests on Hetzner Cloud across all supported platforms and scenarios.

### Quick Start

```bash
# Run ALL scenarios on ALL platforms (9 tests total)
HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh

# Quick test - only default scenario on debian13
HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh --scenario default --platform debian13
```

### Usage

```bash
HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh [OPTIONS] [MOLECULE_COMMAND]
```

### Options

| Option | Description |
|--------|-------------|
| `--scenario NAME` | Run only specific scenario on all platforms |
| `--platform NAME` | Run all scenarios on specific platform only |
| `--list-scenarios` | List available scenarios |
| `--list-platforms` | List available platforms |
| `-h, --help` | Show help |

### Molecule Commands

Default command is `test`. You can specify any molecule command:

- `test` - Full test cycle (create, converge, idempotence, verify, destroy)
- `converge` - Only create and configure (no destroy)
- `verify` - Only run verification tests
- `destroy` - Only destroy test instances

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HCLOUD_TOKEN` | *required* | Hetzner Cloud API token |
| `HCLOUD_SERVER_TYPE` | `cx33` | Hetzner server type |
| `HCLOUD_LOCATION` | `fsn1` | Primary datacenter location |
| `HCLOUD_FALLBACK_LOCATIONS` | `nbg1,hel1` | Fallback locations if primary unavailable |
| `STOP_ON_FAILURE` | `true` | Stop testing after first failure. Set to `false` to continue |

### Supported Platforms

| Platform | Hetzner Image |
|----------|---------------|
| debian13 | debian-13 |
| ubuntu2404 | ubuntu-24.04 |
| rockylinux10 | rocky-10 |

### Test Scenarios

| Scenario | Description | Features Tested |
|----------|-------------|-----------------|
| `default` | Full feature test | Pi-hole, Keepalived, Unbound, Updatelists, Nebula Sync |
| `custom-config` | Custom configuration | Custom cache size, privacy level, NTP server, upstream DNS |
| `no-unbound` | External DNS | Pi-hole with Cloudflare/Google DNS (no Unbound) |

### Examples

```bash
# Test all scenarios on all platforms
HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh

# Test only default scenario on debian13
HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh --scenario default --platform debian13

# Test all scenarios on Rocky Linux 10 only
HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh --platform rockylinux10

# Only converge (keep instances running for debugging)
HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh converge

# Continue testing after failures
STOP_ON_FAILURE=false HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh

# Use specific server type and location
HCLOUD_TOKEN=xxx HCLOUD_SERVER_TYPE=cx32 HCLOUD_LOCATION=fsn1 ./scripts/test-all-platforms.sh

# List available scenarios
./scripts/test-all-platforms.sh --list-scenarios

# List available platforms
./scripts/test-all-platforms.sh --list-platforms
```

### Test Matrix

Running without filters executes: **3 scenarios x 3 platforms = 9 tests**

```
default/debian13        default/ubuntu2404        default/rockylinux10
custom-config/debian13  custom-config/ubuntu2404  custom-config/rockylinux10
no-unbound/debian13     no-unbound/ubuntu2404     no-unbound/rockylinux10
```

### Infrastructure

Each test run creates:
- 2 Hetzner Cloud servers (master + backup)
- 1 private network for VIP failover testing
- Temporary SSH keys for access

Resources are automatically destroyed after tests complete.

### Output

The script provides colored output:
- `[INFO]` - Blue - General information
- `[PASS]` - Green - Test passed
- `[FAIL]` - Red - Test failed
- `[WARN]` - Yellow - Warnings
- `[SCENARIO]` - Cyan - Scenario start

At the end, a summary shows all test results with pass/fail counts.

### Requirements

- Hetzner Cloud account with API token
- `hcloud` CLI (`brew install hcloud`)
- Python 3.10+
- molecule (`pip install molecule ansible`)
- community.crypto Ansible collection

### Hetzner API Token

Get your API token from: https://console.hetzner.cloud/projects/*/security/tokens

### Notes

- **Real VMs**: Unlike Docker-based testing, Hetzner provides real VMs allowing full VIP failover testing.
- **Nebula Sync**: Fully tested.
- **System updates**: The `updates` role is skipped in tests to avoid unnecessary reboots.
- **Cost**: Tests create billable Hetzner resources. The script automatically destroys them after each test (including on failure or Ctrl+C).
