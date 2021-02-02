package main

import (
	"flag"
	"log"

	astikit "github.com/asticode/go-astikit"
	"github.com/asticode/go-astilectron"
	bootstrap "github.com/asticode/go-astilectron-bootstrap"
	"github.com/asticode/go-astilog"
	"github.com/pkg/errors"
)

// Vars
var (
	AppName string
	BuiltAt string
	debug   = flag.Bool("d", false, "enables the debug mode")
	w       *astilectron.Window
)

func main() {
	// Init
	flag.Parse()
	l := astilog.NewFromFlags()

	// Run bootstrap
	l.Debugf("Running app built at %s", BuiltAt)
	if err := bootstrap.Run(bootstrap.Options{
		Asset:    Asset,
		AssetDir: AssetDir,
		AstilectronOptions: astilectron.Options{
			AppName:            AppName,
			AppIconDarwinPath:  "resources/icon.icns",
			AppIconDefaultPath: "resources/icon.png",
		},
		Debug: *debug,
		MenuOptions: []*astilectron.MenuItemOptions{
			{
				Label: astikit.StrPtr("File"),
				SubMenu: []*astilectron.MenuItemOptions{
					{Role: astilectron.MenuItemRoleClose},
				},
			},
			{
				Label: astikit.StrPtr("Edit"),
				SubMenu: []*astilectron.MenuItemOptions{
					{Role: astilectron.MenuItemRoleCopy},
					{Role: astilectron.MenuItemRoleCut},
					{Role: astilectron.MenuItemRolePaste},
					{Role: astilectron.MenuItemRoleDelete},
					{Role: astilectron.MenuItemRoleUndo},
					{Role: astilectron.MenuItemRoleRedo},
				},
			},
		},
		OnWait: func(a *astilectron.Astilectron, ww []*astilectron.Window, m *astilectron.Menu, t *astilectron.Tray, tm *astilectron.Menu) error {
			w = ww[0]
			if *debug {
				log.Println(ww)
				log.Println(w)
				w.Resize(1400, 1400)
				w.OpenDevTools()
			}
			return nil
		},
		RestoreAssets: RestoreAssets,
		Windows: []*bootstrap.Window{{
			Homepage:       "index.html",
			MessageHandler: handleMessages,
			Options: &astilectron.WindowOptions{
				WebPreferences: &astilectron.WebPreferences{
					EnableRemoteModule: astikit.BoolPtr(true),
				},
				BackgroundColor: astikit.StrPtr("#333"),
				Center:          astikit.BoolPtr(true),
				Height:          astikit.IntPtr(200),
				Width:           astikit.IntPtr(700),
			},
		}},
	}); err != nil {
		l.Fatal(errors.Wrap(err, "running bootstrap failed"))
	}
}
