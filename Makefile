BUILD_VERSION=1
BUILD_TIME=$(shell date +%s)
APP_ID=com.automattic.download

all: release

fyne:
	go install github.com/fyne-io/fyne-cross@latest
	go install fyne.io/fyne/v2/cmd/fyne@v2.5

release: release-mac release-windows

release-mac:
	@rm -rf fyne-cross
	fyne-cross darwin -app-id $(APP_ID) -app-version $(BUILD_VERSION).$(BUILD_TIME) -arch=* -pull
	cd fyne-cross/dist/darwin-amd64 && zip -r ../download-mac-amd64.zip download.app
	cd fyne-cross/dist/darwin-arm64 && zip -r ../download-mac-arm64.zip download.app
	rm -rf fyne-cross/bin fyne-cross/tmp fyne-cross/dist/darwin-amd64 fyne-cross/dist/darwin-arm64

release-windows:
	@rm -rf fyne-cross
	fyne-cross windows -app-id $(APP_ID) -app-version $(BUILD_VERSION).$(BUILD_TIME) -arch=* -pull
	mv fyne-cross/dist/windows-arm64/download.exe.zip fyne-cross/dist/download-windows-arm64.zip
	mv fyne-cross/dist/windows-amd64/download.exe.zip fyne-cross/dist/download-windows-amd64.zip
	mv fyne-cross/dist/windows-386/download.exe.zip fyne-cross/dist/download-windows-i386.zip
	rm -rf fyne-cross/bin fyne-cross/tmp fyne-cross/dist/windows-arm64 fyne-cross/dist/windows-amd64 fyne-cross/dist/windows-386
