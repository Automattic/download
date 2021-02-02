all: dist

dist:
	astilectron-bundler -c bundler.json

prep:
	go get -u github.com/asticode/go-astilectron-bundler/...
	go install github.com/asticode/go-astilectron-bundler/astilectron-bundler
