package main

import "fmt"

func niceByteString(bytes int64) string {
	if bytes < 1024 {
		return fmt.Sprintf("%db", bytes)
	}
	if bytes < 1048576 {
		return fmt.Sprintf("%.2fk", float64(bytes)/1024)
	}
	if bytes < 1073741824 {
		return fmt.Sprintf("%.2fm", float64(bytes)/1024/1024)
	}
	if bytes < 1099511627776 {
		return fmt.Sprintf("%.2fg", float64(bytes)/1024/1024/1024)
	}
	return fmt.Sprintf("%.2ft", float64(bytes)/1024/1024/1024/1024)
}
