package main

import (
	"fmt"
	"net/url"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/layout"
	"fyne.io/fyne/v2/theme"
	"fyne.io/fyne/v2/widget"
)

var (
	downloadURL          string
	saveAs               string
	application          fyne.App
	window               fyne.Window
	widgetDownloadURL    *widget.Entry
	widgetProgressBar    *widget.ProgressBar
	widgetDownloadButton *widget.Button
	sizeNormal           = fyne.NewSize(1024, 256)
	sizeSave             = fyne.NewSize(1024, 512)
	localDownloader      *downloader
)

func main() {
	application = app.NewWithID("AutomatticDownloaderApplication")
	application.Settings().SetTheme(theme.LightTheme())

	window = application.NewWindow("Downloader")
	window.Resize(sizeNormal)

	widgetDownloadURL = widget.NewEntry()
	widgetDownloadURL.SetPlaceHolder("Enter download URL")
	widgetDownloadURL.OnChanged = func(newDownloadURL string) {
		downloadURL = newDownloadURL
	}
	// when developing... this is helpful
	// widgetDownloadURL.SetText("https://cdimage.debian.org/debian-cd/current/amd64/iso-bd/debian-edu-12.7.0-amd64-BD-1.iso")

	widgetProgressBar = widget.NewProgressBar()
	widgetProgressBar.Min = 0
	widgetProgressBar.Max = 100
	widgetProgressBar.Hide()

	widgetDownloadButton = widget.NewButton(
		"Download Now",
		func() {
			widgetDownloadButton.Disable()
			widgetDownloadURL.Disable()
			defer widgetDownloadButton.Enable()
			defer widgetDownloadURL.Enable()
			if localDownloader == nil || localDownloader.URL != downloadURL {
				localDownloader = newDownloader(downloadURL)
			}
			window.Resize(sizeSave)
			window.SetTitle("Downloader - Choose a folder to save the file into")
			dialog.ShowFolderOpen(
				func(choice fyne.ListableURI, err error) {
					window.Resize(sizeNormal)
					if err != nil {
						window.SetTitle("Downloader - SaveAborted")
						dialog.ShowError(err, window)
						return
					}
					if choice == nil {
						window.SetTitle("Downloader - SaveAborted")
						return
					}
					toURL, err := url.Parse(choice.String())
					if err != nil {
						dialog.ShowError(err, window)
						return
					}
					widgetProgressBar.Show()

					err = localDownloader.downloadToWithBytesCallback(
						toURL.Path,
						func(downloaded int64, total int64) {
							window.SetTitle(
								fmt.Sprintf(
									"Downloading - %s %s/%s",
									localDownloader.Filename,
									niceByteString(downloaded),
									niceByteString(localDownloader.HeadResponse.Bytes),
								),
							)
							widgetProgressBar.SetValue(float64(downloaded))
						},
					)
					if err != nil {
						dialog.ShowError(err, window)
						return
					}
					window.SetTitle(
						fmt.Sprintf(
							"Download Complete - %s %s/%s",
							localDownloader.Filename,
							niceByteString(localDownloader.BytesSaved),
							niceByteString(localDownloader.HeadResponse.Bytes),
						),
					)
				},
				window,
			)
		},
	)

	vbox := container.NewVBox(
		layout.NewSpacer(),
		widgetDownloadURL,
		widgetDownloadButton,
		layout.NewSpacer(),
		widgetProgressBar,
		layout.NewSpacer(),
	)

	window.SetContent(vbox)

	window.ShowAndRun()
}
