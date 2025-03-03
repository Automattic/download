BUILD_VERSION=1
BUILD_TIME=$(shell date +%s) 

all: release

fyne:
	go install github.com/fyne-io/fyne-cross@latest
	go install fyne.io/fyne/v2/cmd/fyne@v2.5

ruby:
	@echo "--- :ruby: Setting up Ruby tools"
	bundle install

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
