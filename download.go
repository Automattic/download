package main

import (
	"fmt"
	"io"
	"log"
	"math"
	"net/http"
	"net/http/httputil"
	"os"
	"strconv"
	"time"

	humanize "github.com/dustin/go-humanize"
)

type progressBar struct {
	total     int64
	current   int64
	snapRate  int64
	snapTime  time.Time
	snapBytes int64
}

func (p *progressBar) round(x float64) int64 {
	t := math.Trunc(x)
	if math.Abs(x-t) >= 0.5 {
		return int64(t + math.Copysign(1, x))
	}
	return int64(t)
}

func (p *progressBar) Write(b []byte) (int, error) {
	l := len(b)
	p.current += int64(l)
	p.update()
	return l, nil
}

func (p *progressBar) update() {
	pct := int(float32(p.current) / float32(p.total) * 100)
	now := time.Now()
	since := time.Now().Sub(p.snapTime)
	if since > time.Second {
		p.snapRate = p.round(float64(p.current-p.snapBytes) / since.Seconds())
		p.snapTime = now
		p.snapBytes = p.current
	}
	sendMessage(
		"update",
		fmt.Sprintf(
			"%2d%% Downloaded: %s of %s (%s/sec)",
			pct,
			humanize.Bytes(uint64(p.current)),
			humanize.Bytes(uint64(p.total)),
			humanize.Bytes(uint64(p.snapRate)),
		),
	)
}

func download(url, to string) error {
	sendMessage("update", "got request for download")
	bytes := int64(head(url))
	fp, err := os.OpenFile(to, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return err
	}
	stat, _ := fp.Stat()
	read := stat.Size()
	p := new(progressBar)
	p.total = bytes
	p.current = read

	for {
		req, err := http.NewRequest(http.MethodGet, url, nil)
		if err != nil {
			log.Fatalf("Error preparing request to %s: %s", url, err.Error())
		}
		if read > 0 {
			req.Header.Set("Range", fmt.Sprintf("bytes=%d-", read))
			log.Println(fmt.Sprintf("bytes=%d-", read))
		}
		b, _ := httputil.DumpRequestOut(req, false)
		os.Stderr.Write(b)
		rsp, err := http.DefaultClient.Do(req)
		if rsp.StatusCode == 200 || rsp.StatusCode == 206 {
			if err != nil {
				log.Fatalf("Error requesting %s at byte offset %d: %s", url, read, err.Error())
			}
			// log.Printf("%#v\n", rsp.Body)
			got, _ := io.Copy(fp, io.TeeReader(rsp.Body, p))
			rsp.Body.Close()
			read += int64(got)
		}
		// log.Println(read, "/", bytes)
		if read >= bytes {
			break
		}
	}
	return nil
}

func head(url string) int {
	sendMessage("update", "making head request...")
	rsp, err := http.Head(url)
	if err != nil {
		log.Fatalf("Error making HEAD request to %s: %s", url, err.Error())
	}
	defer rsp.Body.Close()
	intLen, err := strconv.Atoi(rsp.Header.Get("Content-Length"))
	if err != nil {
		log.Fatalf("Error reading or parsing Content-Length of '%s': %s", rsp.Header.Get("Content-Length"), err.Error())
	}
	//if "bytes" != rsp.Header.Get("Accept-Ranges") {
	//	log.Fatal("Missing valid Accept-Ranges header")
	//}
	return intLen
}
