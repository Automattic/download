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

ruby:
	@echo "--- :ruby: Setting up Ruby tools"
	bundle install

apple_certificate:
	@echo "--- :apple: Fetching code signing"
	bundle exec fastlane configure_code_signing

release:
	@rm -rf fyne-cross
	fyne-cross darwin -app-id com.automattic.download -app-version $(BUILD_VERSION).$(BUILD_TIME) -arch=* -pull
	fyne-cross windows -app-id com.automattic.download -app-version $(BUILD_VERSION).$(BUILD_TIME) -arch=* -pull
	cd fyne-cross/dist/darwin-amd64 && zip -r ../download-mac-amd64.zip download.app
	cd fyne-cross/dist/darwin-arm64 && zip -r ../download-mac-arm64.zip download.app
	mv fyne-cross/dist/windows-arm64/download.exe.zip fyne-cross/dist/download-windows-arm64.zip
	mv fyne-cross/dist/windows-amd64/download.exe.zip fyne-cross/dist/download-windows-amd64.zip
	mv fyne-cross/dist/windows-386/download.exe.zip fyne-cross/dist/download-windows-i386.zip
	rm -rf fyne-cross/bin fyne-cross/tmp fyne-cross/dist/darwin-amd64 fyne-cross/dist/darwin-arm64 fyne-cross/dist/windows-arm64 fyne-cross/dist/windows-amd64 fyne-cross/dist/windows-386

release-mac: fyne ruby apple_certificate
	@echo "--- :rocket: Building for public distribution (fyne release)"
	fyne release \
		-appID $(APP_ID) \
		-appVersion $(BUILD_VERSION) \
		-appBuild $(BUILD_TIME) \
		-certificate 'Developer ID Application: Automattic, Inc. (PZYM8XX95Q)' \
		-profile 'match Direct $(APP_ID)' \
		-category utilities \
		-icon Icon.png
	zip -r download.app.zip download.app

package-mac: fyne ruby apple_certificate
	@echo "--- :rocket: Building for public distribution (fyne release)"
	fyne package \
		-release \
		-os darwin \
		-name Download \
		-appID $(APP_ID) \
		-appVersion $(BUILD_VERSION) \
		-appBuild $(BUILD_TIME) \
		-certificate 'Developer ID Application: Automattic, Inc. (PZYM8XX95Q)' \
		-profile 'match Direct $(APP_ID)' \
		-icon Icon.png
	zip -r download.app.zip download.app
