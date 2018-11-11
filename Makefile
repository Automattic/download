all: clean single

try: clean single runosx

runosx:
	output/darwin-amd64/Download.app/Contents/MacOS/Download -d

single:
	astilectron-bundler -v

clean:
	- rm -rvf bind_darwin_amd64.go  bind_linux_amd64.go  bind_windows_amd64.go windows.syso output/*/*

release: clean dists

dists:
	astilectron-bundler -v -l -d -w
