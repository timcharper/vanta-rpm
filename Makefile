.PHONY: all clean rpm build extract version

# Variables
IMAGE_NAME := vanta-builder
TARGET_DIR := target
ASSETS_DIR := assets
RPMBUILD_DIR := rpmbuild
VERSION_FILE := $(TARGET_DIR)/version
IMAGE_BUILT := $(TARGET_DIR)/image-built
SPEC_TEMPLATE := vanta.spec.template
SPEC_FILE := vanta.spec

all: rpm

# Create target directory
$(TARGET_DIR):
	mkdir -p $(TARGET_DIR)

# Build the container image
$(IMAGE_BUILT): Dockerfile | $(TARGET_DIR)
	podman build -t $(IMAGE_NAME) .
	touch $(IMAGE_BUILT)

build: $(IMAGE_BUILT)

# Extract assets from the container
$(ASSETS_DIR): $(IMAGE_BUILT)
	mkdir -p $(ASSETS_DIR)
	podman run --rm -v $(PWD)/$(ASSETS_DIR):/$(ASSETS_DIR):Z --userns=keep-id -u "$$(id -u):$$(id -g)" $(IMAGE_NAME) \
		bash -c "dpkg-deb -x /tmp/vanta-amd64.deb /$(ASSETS_DIR); dpkg-deb -e /tmp/vanta-amd64.deb /$(ASSETS_DIR)/DEBIAN"

extract: $(ASSETS_DIR)

# Extract version from Debian control file
$(VERSION_FILE): $(ASSETS_DIR)
	grep '^Version:' $(ASSETS_DIR)/DEBIAN/control | awk '{print $$2}' > $(VERSION_FILE)

version: $(VERSION_FILE)

# Generate spec file from template
$(SPEC_FILE): $(SPEC_TEMPLATE) $(VERSION_FILE)
	sed "s/@VERSION@/$$(cat $(VERSION_FILE))/g" $(SPEC_TEMPLATE) > $(SPEC_FILE)

# Build the RPM package
rpm: $(SPEC_FILE)
	mkdir -p $(RPMBUILD_DIR)/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
	cp $(SPEC_FILE) $(RPMBUILD_DIR)/SPECS/
	cp -r $(ASSETS_DIR) $(RPMBUILD_DIR)/SOURCES/
	rpmbuild --define "_topdir $(PWD)/$(RPMBUILD_DIR)" \
	         --define "_sourcedir $(PWD)" \
	         -bb $(RPMBUILD_DIR)/SPECS/$(SPEC_FILE)
	@echo ""
	@echo "=== RPM Built Successfully ==="
	@RPM_FILE=$$(find $(RPMBUILD_DIR)/RPMS -name "*.rpm" -type f | head -n 1); \
	if [ -n "$$RPM_FILE" ]; then \
		echo "Location: $$RPM_FILE"; \
		echo ""; \
		echo "To install:"; \
		echo "  sudo rpm -ivh $$RPM_FILE"; \
		echo ""; \
		echo "With configuration:"; \
		echo "  sudo VANTA_KEY='your-key' VANTA_OWNER_EMAIL='admin@example.com' rpm -ivh $$RPM_FILE"; \
	fi

# Clean build artifacts
clean:
	rm -rf $(TARGET_DIR) $(ASSETS_DIR) $(RPMBUILD_DIR) $(SPEC_FILE)
	podman rmi $(IMAGE_NAME) 2>/dev/null || true

# Clean everything including extracted directory (legacy)
distclean: clean
	rm -rf extracted
