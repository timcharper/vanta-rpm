# Build System Overview

This project uses a Makefile-based build system to automate the creation of an RPM package from Vanta's Debian package.

## Workflow

```
make rpm
  ↓
  ├─→ Build container image (Dockerfile)
  │    └─→ Creates: target/image-built
  │
  ├─→ Extract assets from container
  │    └─→ Creates: assets/ directory
  │
  ├─→ Extract version from DEBIAN/control
  │    └─→ Creates: target/version
  │
  ├─→ Generate vanta.spec from template
  │    └─→ Creates: vanta.spec (with @VERSION@ replaced)
  │
  └─→ Build RPM with rpmbuild
       └─→ Creates: rpmbuild/RPMS/x86_64/vanta-{version}-1.*.rpm
```

## Key Features

- **Automated versioning**: Version is extracted from the Debian package control file
- **Templated spec file**: `vanta.spec.template` uses `@VERSION@` placeholder
- **Incremental builds**: Makefile tracks dependencies to avoid rebuilding
- **SELinux support**: Post-install script handles SELinux contexts
- **Clean targets**: `make clean` removes all build artifacts

## Files

- `Makefile` - Main build orchestration
- `Dockerfile` - Downloads Vanta DEB package
- `vanta.spec.template` - RPM spec template with version placeholder
- `build-rpm.sh` - Legacy build script (can be removed)
- `extract.sh` - Legacy extract script (can be removed)

## Directory Structure

```
.
├── Makefile
├── Dockerfile
├── vanta.spec.template
├── target/
│   ├── image-built       # Marker file for container build
│   └── version           # Extracted version number
├── assets/               # Extracted DEB package contents
│   ├── DEBIAN/
│   ├── etc/
│   ├── usr/
│   └── var/
└── rpmbuild/            # RPM build directory
    ├── BUILD/
    ├── RPMS/
    ├── SOURCES/
    ├── SPECS/
    └── SRPMS/
```

## Usage

```bash
# Build everything
make rpm

# Just build the container
make build

# Just extract assets
make extract

# Clean up
make clean
```
