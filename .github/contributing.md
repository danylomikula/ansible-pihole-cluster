# Contributing

## Pull Request Process

1. Update the README.md with details of changes to variables, features, or configuration options if applicable.
2. Run pre-commit hooks `pre-commit run -a`.
3. Ensure ansible-lint passes: `ansible-lint`.
4. If possible, run integration tests locally on Hetzner Cloud before submitting. See [scripts/README.md](../scripts/README.md) for instructions.
5. Once all outstanding comments and checklist items have been addressed, your contribution will be merged!

## Checklists for contributions

- [ ] Add [semantic prefix](#semantic-pull-requests) to your PR or Commits (at least one of your commit groups)
- [ ] CI tests are passing
- [ ] README.md has been updated after any changes to variables and features
- [ ] Run pre-commit hooks `pre-commit run -a`
- [ ] ansible-lint passes
- [ ] Tested locally if possible (see [scripts/README.md](../scripts/README.md))

## Semantic Pull Requests

To generate changelog, Pull Requests or Commits must have semantic prefix and follow conventional specs below:

- `feat:` for new features (minor version bump)
- `fix:` for bug fixes (patch version bump)
- `docs:` for documentation and examples
- `refactor:` for code refactoring
- `test:` for tests
- `ci:` for CI purpose
- `chore:` for chores stuff

## Development Setup

```bash
# Install Ansible dependencies
ansible-galaxy collection install -r requirements.yml

# Install pre-commit hooks
pip install pre-commit
pre-commit install

# Lint
ansible-lint
```

## Running Tests

Integration tests run on Hetzner Cloud using Molecule. A Hetzner Cloud API token is required.

```bash
# Run a single scenario on one platform
HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh --scenario default --platform debian13

# Run all scenarios on all platforms (9 tests)
HCLOUD_TOKEN=xxx ./scripts/test-all-platforms.sh
```

See [scripts/README.md](../scripts/README.md) for all options, environment variables, and test scenarios.
