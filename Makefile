BUILD_VERSION=1
BUILD_TIME=$(shell date +%s)
APP_ID=com.automattic.download

all: release

fyne:
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

release-windows: fyne
	@rm -rf fyne-cross
	fyne-cross windows \
		-app-id $(APP_ID) \
		-app-version $(BUILD_VERSION).$(BUILD_TIME) \
		-arch=* -pull \
		-debug \
		-engine podman
	mv fyne-cross/dist/windows-arm64/download.exe.zip fyne-cross/dist/download-windows-arm64.zip
	mv fyne-cross/dist/windows-amd64/download.exe.zip fyne-cross/dist/download-windows-amd64.zip
	mv fyne-cross/dist/windows-386/download.exe.zip fyne-cross/dist/download-windows-i386.zip
	rm -rf fyne-cross/bin fyne-cross/tmp fyne-cross/dist/windows-arm64 fyne-cross/dist/windows-amd64 fyne-cross/dist/windows-386
