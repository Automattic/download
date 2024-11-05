BUILD_VERSION=1
BUILD_TIME=$(shell date +%s) 

all: release

fyne:
	go install github.com/fyne-io/fyne-cross@latest
	go install fyne.io/fyne/v2/cmd/fyne@v2.5

release:
	@rm -rf fyne-cross
	fyne-cross darwin -app-id com.automattic.downloader -app-version $(BUILD_VERSION).$(BUILD_TIME) -arch=* -pull
	fyne-cross windows -app-id com.automattic.downloader -app-version $(BUILD_VERSION).$(BUILD_TIME) -arch=* -pull
	cd fyne-cross/dist/darwin-amd64 && zip -r ../downloader-mac-amd64.zip downloader.app
	cd fyne-cross/dist/darwin-arm64 && zip -r ../downloader-mac-arm64.zip downloader.app
	mv fyne-cross/dist/windows-arm64/downloader.exe.zip fyne-cross/dist/downloader-windows-arm64.zip
	mv fyne-cross/dist/windows-amd64/downloader.exe.zip fyne-cross/dist/downloader-windows-amd64.zip
	mv fyne-cross/dist/windows-386/downloader.exe.zip fyne-cross/dist/downloader-windows-i386.zip
	rm -rf fyne-cross/bin fyne-cross/tmp fyne-cross/dist/darwin-amd64 fyne-cross/dist/darwin-arm64 fyne-cross/dist/windows-arm64 fyne-cross/dist/windows-amd64 fyne-cross/dist/windows-386
