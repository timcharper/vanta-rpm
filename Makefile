.PHONY: all clean rpm download extract version

# Variables
TARGET_DIR := target
ASSETS_DIR := assets
RPMBUILD_DIR := rpmbuild
VERSION_FILE := $(TARGET_DIR)/version
DEB_FILE := $(TARGET_DIR)/vanta-amd64.deb
SPEC_TEMPLATE := vanta.spec.template
SPEC_FILE := vanta.spec

all: rpm

# Create target directory
$(TARGET_DIR):
	mkdir -p $(TARGET_DIR)

# Download the Debian package
$(DEB_FILE): | $(TARGET_DIR)
	curl --progress-bar -L https://app.vanta.com/osquery/download/linux -o $(DEB_FILE)

download: $(DEB_FILE)

# Extract assets from the Debian package using bsdtar
$(ASSETS_DIR): $(DEB_FILE)
	mkdir -p $(ASSETS_DIR)
	bsdtar -Oxf $(DEB_FILE) 'data.tar.gz' | \
		bsdtar -xf - \
			--exclude='./usr/share/doc' \
			-C $(ASSETS_DIR)
	bsdtar -Oxf $(DEB_FILE) 'control.tar.gz' | bsdtar -xf - -C $(ASSETS_DIR)
	mkdir -p $(ASSETS_DIR)/DEBIAN
	mv $(ASSETS_DIR)/control $(ASSETS_DIR)/DEBIAN/control
	mv $(ASSETS_DIR)/md5sums $(ASSETS_DIR)/DEBIAN/md5sums
	mv $(ASSETS_DIR)/postinst $(ASSETS_DIR)/DEBIAN/postinst
	mv $(ASSETS_DIR)/postrm $(ASSETS_DIR)/DEBIAN/postrm
	mv $(ASSETS_DIR)/prerm $(ASSETS_DIR)/DEBIAN/prerm
	mv $(ASSETS_DIR)/conffiles $(ASSETS_DIR)/DEBIAN/conffiles

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

# Clean everything including extracted directory (legacy)
distclean: clean
	rm -rf extracted
