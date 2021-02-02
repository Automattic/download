all: dist

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

prep:
	go get -u github.com/asticode/go-astilectron-bundler/...
	go install github.com/asticode/go-astilectron-bundler/astilectron-bundler
