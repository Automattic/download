let index = {
    isDownloading: false,
	update: function( msg ) {
		let div = document.getElementById("update-status");
		div.innerHTML = msg;
	},
    append: function( msg ) {
        let div = document.createElement("div");
        div.innerHTML = msg;
        document.getElementById("body").appendChild(div)
    },
    init: function() {
        asticode.loader.init();
        asticode.modaler.init();
        asticode.notifier.init();
        document.addEventListener('astilectron-ready', function() {
            index.listen();
            index.update("Enter a WordPress.com media export URL to begin")
			document.getElementById("url-input").addEventListener('change', index.change);
			document.getElementById("url-input").addEventListener('keyup', index.change);
			document.getElementById("download-button").addEventListener('click', index.download.bind(index));
        })
    },
    change: function(event) {
    	let url = document.getElementById("url-input").value;
    	index.update("2");
    	if ( /^https?:\/\/[^\/]+\/media-export\.php\?/.test(url) ) {
    		document.getElementById("download-button").disabled = false;
            index.update("Press download to choose a filename to save the export as and begin the download")

            const xhr = new XMLHttpRequest();
            xhr.open( 'HEAD', url );
            xhr.onload = () => {
                if ( index.isDownloading ) {
                    // too late, don't overwrite following messages
                    return;
                }

                const fileSize = parseInt( xhr.getResponseHeader( 'Content-length' ), 10 );

                index.update(
                    'Press download to choose a filename to save ' +
                    'the export as and begin the download: ' + index.humanSize( fileSize )
                );
            };
            xhr.send();
    	} else {
    		document.getElementById("download-button").disabled = true;
            index.update("Enter a valid WordPress.com media export URL to begin")
    	}
    },
    download: function(event) {
        index.isDownloading = true;
		asticode.loader.show();
    	let url = document.getElementById("url-input").value;
    	let dom = url.match(/^https?:\/\/([^\/]+)\/media-export\.php\?/)[1]
    	dialog.showSaveDialog({defaultPath: "export." + dom + ".tar"}, function( path ) {
    	//dialog.showOpenDialog({defaultPath: "export." + dom + ".tar"}, function( path ) {
            asticode.loader.hide();
            if ( undefined === path ) {
				index.update("A file name is required to download. Please press download again and choose a file name")
				return;
            } else {
            	index.update("OK. Attempting to download")
            	document.getElementById("download-button").disabled = true;
            }
            index.send("download", { url: document.getElementById("url-input").value, save: path })
    	});
    },
    send: function(name, payload, callback) {
    	if ( undefined === typeof callback ) {
    		callback=function(){}
    	}
    	astilectron.sendMessage({name: name, payload: payload}, callback)
    },
    listen: function() {
        astilectron.onMessage(function(message) {
                if ( "update" === message.name ) {
                        index.update(message.payload)
                } else if ( "complete" === message.name ) {
                    index.update("Finished downloading media export!");
                } else {
        	        index.append(JSON.stringify(message))
                }
                // {"name":"update","payload":"got request for download"}

        });
    },
    // match go/humanize
    humanSize: function( size ) {
        const prefixes = {
            '0': '',
            '3': 'k',
            '6': 'M',
            '9': 'G',
            '12': 'T'
        };

        if ( size === 0 ) {
            return '0';
        }

        const mag = size;
        let exp = Math.floor( Math.floor( Math.log10( size ) ) / 3 ) * 3;
        let value = mag / Math.pow( 10, exp );

        if ( value === 1000 ) {
            exp += 3;
            value = mag / Math.pow( 10, exp );
        }

        return `${ Math.round( value * 10 ) / 10 } ${ prefixes[ exp ] }B`;
    }
};
window.index = index;
