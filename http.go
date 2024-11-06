package main

import (
	"crypto/md5"
	"fmt"
	"io"
	"mime"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

type downloadHeadRequest struct {
	Status       string
	StatusCode   int
	Headers      http.Header
	Bytes        int64
	AcceptRanges bool
	Filename     string
	Error        error
}

type downloader struct {
	URL          string
	Filename     string
	BytesSaved   int64
	TempName     string
	HeadResponse *downloadHeadRequest
}

func (d *downloader) downloadToWithBytesCallback(to string, callback func(int64, int64)) error {
	// Create the request to configure it for the first pass (a pass that assumes that ranges work)
	req, err := http.NewRequest("GET", d.URL, nil)
	if err != nil {
		return err
	}

	tempPath := filepath.Clean(fmt.Sprintf("/%s/%s", to, d.TempName))
	openFileArgs := os.O_CREATE | os.O_RDWR
	fp, err := os.OpenFile(tempPath, openFileArgs, 0644)
	if fp != nil {
		defer fp.Close()
	}
	if err != nil {
		return err
	}
	info, err := fp.Stat()
	if err != nil {
		return err
	}
	d.BytesSaved = info.Size()

	req.Header.Set("Range", fmt.Sprintf("bytes=%d-", d.BytesSaved))
	rsp, err := http.DefaultClient.Do(req)
	if rsp != nil && rsp.Body != nil {
		defer rsp.Body.Close()
	}
	if err != nil {
		return err
	}
	if rsp.StatusCode > 299 || rsp.StatusCode < 200 {
		return fmt.Errorf("Download failed due to code: %d, Status: %s", rsp.StatusCode, rsp.Status)
	}

	if d.HeadResponse == nil {
		d.processGetResponseHeaders(rsp)
	}

	if rsp.StatusCode != 206 {
		fp.Seek(0, 0)
		fp.Truncate(0)
		d.BytesSaved = 0
	} else {
		d.HeadResponse.Bytes = d.HeadResponse.Bytes + d.BytesSaved
		fp.Seek(0, 2)
	}
	widgetProgressBar.Max = float64(d.HeadResponse.Bytes)

	callback(d.BytesSaved, d.HeadResponse.Bytes)

	writer := newByteReportingWriter(
		fp,
		func(i int) {
			d.BytesSaved = d.BytesSaved + int64(i)
			callback(d.BytesSaved, d.HeadResponse.Bytes)
		},
	)
	_, err = io.Copy(writer, rsp.Body)
	if err != nil {
		return err
	}
	fp.Close()
	filePath := filepath.Clean(fmt.Sprintf("/%s/%s", to, d.Filename))
	return os.Rename(tempPath, filePath)
}

func (d *downloader) processGetResponseHeaders(rsp *http.Response) {
	var bytes int64
	var ranges bool

	if rsp == nil {
		return
	}

	if contentLength := rsp.Header.Get("Content-Length"); contentLength != "" {
		if b, err := strconv.Atoi(contentLength); err == nil {
			bytes = int64(b)
		}
	}

	if acceptRanges := rsp.Header.Get("Accept-Ranges"); strings.ToLower(acceptRanges) == "bytes" {
		ranges = true
	}

	d.HeadResponse = &downloadHeadRequest{
		Status:       rsp.Status,
		StatusCode:   rsp.StatusCode,
		Headers:      rsp.Header.Clone(),
		Bytes:        bytes,
		AcceptRanges: ranges,
	}

	if _, params, err := mime.ParseMediaType(rsp.Header.Get("Content-Disposition")); err == nil {
		if filename, ok := params["filename"]; ok && filename != "" {
			d.HeadResponse.Filename = filename
			d.Filename = filename
		}
	}
}

func newDownloader(downloadURL string) *downloader {

	var rval = &downloader{
		URL:      downloadURL,
		TempName: fmt.Sprintf("%x-download.tmp", md5.Sum([]byte(downloadURL))),
	}
	if u, err := url.Parse(downloadURL); err == nil {
		if parsedFilename := filepath.Base(u.Path); parsedFilename != "/" && parsedFilename != "." {
			rval.Filename = parsedFilename
		}
	} else {
		parsedFilename := filepath.Base(downloadURL)
		if parsedFilename != "/" && parsedFilename != "." {
			rval.Filename = parsedFilename
		}
	}
	return rval
}
