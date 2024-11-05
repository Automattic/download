package main

import (
	"io"
)

type byteReportingWriter struct {
	w  io.Writer
	cb func(int)
}

func newByteReportingWriter(w io.Writer, cb func(int)) *byteReportingWriter {
	return &byteReportingWriter{
		w:  w,
		cb: cb,
	}
}

func (b *byteReportingWriter) Write(p []byte) (n int, err error) {
	n, err = b.w.Write(p)
	b.cb(n)
	return n, err
}
