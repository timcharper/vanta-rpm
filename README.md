# Vanta Agent RPM Builder

Build an RPM package for the Vanta security monitoring agent.

## Prerequisites

- **rpmbuild**: `sudo dnf install rpm-build`
- **bsdtar**: `sudo dnf install bsdtar`
- **make**: `sudo dnf install make`

## Build

```bash
make rpm
```

Output: `rpmbuild/RPMS/x86_64/vanta-{version}-1.*.rpm`

## Install

```bash
sudo rpm -ivh rpmbuild/RPMS/x86_64/vanta-*.rpm
```

With configuration (use `.envrc`):

```bash
sudo -E rpm -ivh rpmbuild/RPMS/x86_64/vanta-*.rpm
```

## Other Targets

```bash
make build    # Build container image only
make extract  # Extract assets from container
make version  # Extract version info
make clean    # Clean build artifacts
```

## Uninstall

```bash
sudo rpm -e vanta
```
