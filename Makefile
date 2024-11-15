# Windows apps have upper bounds on the version components:
#
# For Windows 10 or Windows 11 (UWP) packages, the last (fourth) section of the
# version number is reserved for Store use and must be left as 0 when you build
# your package (although the Store may change the value in this section). The
# other sections must be set to an integer between 0 and 65535 (except for the
# first section, which cannot be 0).
#
# https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/app-package-requirements#package-version-numbering
BUILD_VERSION=1.$(shell date +%y%m)
BUILD_TIME=$(shell date +%d%H)
APP_ID=com.automattic.download

all: release

fyne:
	@echo "--- :go: Installing Go tools"
	go install github.com/fyne-io/fyne-cross@latest
	go install fyne.io/fyne/v2/cmd/fyne@v2.5

# FIXME: Set up this way, release-windows will delete the release-mac artifacts
release: release-mac release-windows

release-mac: fyne
	@rm -rf fyne-cross
	# fyne-cross fails to create this in CI, maybe creating it beforhead will help?
	# update: did not
	mkdir -p fyne-cross/bin/darwin-amd64
	mkdir -p fyne-cross/bin/darwin-arm64
	chmod -R 777 fyne-cross # Temporarily set full permissions for debugging
	# -debug to try figure out what's wrong
	# -engine podman is inspired from https://github.com/fyne-io/fyne-cross/issues/201
	# and is an attempt to address the failure at
	# https://buildkite.com/automattic/download/builds/41#01930abf-1920-4a71-a6de-2766903e7e9e
	fyne-cross darwin \
		-app-id $(APP_ID) \
		-app-version $(BUILD_VERSION).$(BUILD_TIME) \
		-arch=* \
		-pull \
		-debug \
		-engine podman
	cd fyne-cross/dist/darwin-amd64 && zip -r ../download-mac-amd64.zip download.app
	cd fyne-cross/dist/darwin-arm64 && zip -r ../download-mac-arm64.zip download.app
	rm -rf fyne-cross/bin fyne-cross/tmp fyne-cross/dist/darwin-amd64 fyne-cross/dist/darwin-arm64

# TODO: Find a way to DRY the -app* flags?
#
# Notice -appBuild 1: Windows docs says this should be 0 for store use but fyne requires it to be > 0
release-windows: fyne
	# The release command works, but:
	#
	# - The exe is not signed
	# - The appx is installed but does not go anywhere
	@echo "--- :rocket: Preparing package for release"
	fyne release \
		-appID $(APP_ID) \
		-appVersion $(BUILD_VERSION).$(BUILD_TIME) \
		-appBuild 1 \
		-name Download \
		-os windows \
		-developer 'CN="Automattic, Inc.", O="Automattic, Inc.", S=California, C=US' \
		-certificate certificate.pfx \
		-password $(WINDOWS_CODE_SIGNING_CERT_PASSWORD)

package-windows: fyne
	# Despite passing the certificate, the exe remains unsigned
	@echo "--- :rocket: Packaging for distribution"
	fyne package \
		-release \
		-appID $(APP_ID) \
		-appVersion $(BUILD_VERSION).$(BUILD_TIME) \
		-appBuild 1 \
		-name Download \
		-os windows \
		-certificate certificate.pfx
