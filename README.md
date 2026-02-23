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

### Regarding SELinux

Vanta will expect all its binaries to be located at `/var/vanta`.

1. After installation, verify the files actually exist. If they're not there, copy over the folder `vanta` located at `vanta-rpm/assets/var/vanta` after having built the rpm.
2. Modify the SELinux context so the service can see and execute them
```
sudo semanage fcontext -a -t bin_t '/var/vanta(/.*)?'
sudo restorecon -Rv /var/vanta
```
3. Verify the key and owner values are populated in `/etc/vanta.conf`
4. Start and enable the service by running `sudo systemctl enable --now vanta.service`

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
