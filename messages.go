package main

import (
	"encoding/json"
	"log"

	"github.com/asticode/go-astilectron"
	bootstrap "github.com/asticode/go-astilectron-bootstrap"
)

func sendMessage(name string, payload interface{}) error {
	return bootstrap.SendMessage(w, name, payload)
}

func handleMessages(_ *astilectron.Window, m bootstrap.MessageIn) (payload interface{}, err error) {
	switch m.Name {
	case "download":
		var what = &struct {
			URL  string `json:"url"`
			Save string `json:"save"`
		}{}
		if err = json.Unmarshal(m.Payload, &what); err != nil {
			log.Fatal(err.Error())
		}
		download(what.URL, what.Save)
	}
	return
}
