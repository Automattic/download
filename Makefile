all: dist dist-release

try: darwin try-exec

try-exec:
	-rm -r test/
	mkdir -p test/
	cp output/darwin-amd64/Download.app/Contents/MacOS/Download test/download
	cd test/ && ./download -d

dist: darwin linux windows

darwin:
	astilectron-bundler -d -c bundler.json

linux:
	astilectron-bundler -l -c bundler.json


windows:
	astilectron-bundler -w -c bundler.json

dist-release:
	-mkdir release
	-rm release/*
	cd output/darwin-amd64/ && zip -r darwin-amd64-Download.app.zip Download.app
	mv output/darwin-amd64/darwin-amd64-Download.app.zip release/
	tar -zcf - ./output/linux-amd64/Download > release/linux-amd64-Download.tar.gz
	cd output/windows-amd64/ && zip windows-amd64-Download.exe.zip Download.exe
	mv output/windows-amd64/windows-amd64-Download.exe.zip release/


prep:
	go get -u github.com/asticode/go-astilectron-bundler/...
	go install github.com/asticode/go-astilectron-bundler/astilectron-bundler
