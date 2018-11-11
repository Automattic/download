package main

import (
	"encoding/json"
	"log"

	"github.com/asticode/go-astilectron"
	"github.com/asticode/go-astilectron-bootstrap"
)

func sendMessage(name string, payload interface{}) error {
	//log.Println(w)
	//log.Println(name)
	//log.Println(payload)
	return bootstrap.SendMessage(w, name, payload)
}

// handleMessages handles messages
func handleMessages(_ *astilectron.Window, m bootstrap.MessageIn) (payload interface{}, err error) {
	// log.Printf("%#v", m)
	switch m.Name {
	case "download":
		var what = &struct {
			URL  string `json:"url"`
			Save string `json:"save"`
		}{}
		if err = json.Unmarshal(m.Payload, &what); err != nil {
			log.Fatal(err.Error())
		}
		// log.Printf("%#v", what)
		download(what.URL, what.Save)
	}
	return
}
