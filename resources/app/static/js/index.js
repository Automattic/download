const { dialog } =  require('electron').remote
let index = {
    isDownloading: false,
	update: function( message, data ) {
		let div = document.getElementById("update-status");
        div.innerHTML = message;

        if ( data && data .pct ) {
            document
                .querySelector( '#download-progress' )
                .setAttribute( 'value', data.pct );
        }
	},
    append: function( msg ) {
        let div = document.createElement("div");
        div.innerHTML = msg;
        document.getElementById("body").appendChild(div)
    },
    init: function() {
		const { dialog } = require('electron')
        asticode.loader.init();
        asticode.modaler.init();
        asticode.notifier.init();
        document.addEventListener('astilectron-ready', function() {
            index.listen();
            index.update("Enter a URL to begin")
			document.getElementById("url-input").addEventListener('change', index.change);
			document.getElementById("url-input").addEventListener('keyup', index.change);
			document.getElementById("download-button").addEventListener('click', index.download.bind(index));
        })
    },
    change: function(event) {
    	let url = document.getElementById("url-input").value;
    	if ( /^https?:\/\/[^\/]+\//.test(url) ) {
    		document.getElementById("download-button").disabled = false;
			index.update( 'Press download to choose a filename to save the file' );
    	} else {
    		document.getElementById("download-button").disabled = true;
            index.update("Enter a valid URL to begin")
    	}
    },
    download: function(event) {
        index.isDownloading = true;
		// asticode.loader.show();
    	let url = document.getElementById("url-input").value;

    	let defaultFileName = new String(url).substring(url.lastIndexOf('/') + 1);
    	index.update( "c -- " + url + "<br/>" + defaultFileName )
    	let path = dialog.showSaveDialogSync({defaultPath: defaultFileName})
        // asticode.loader.hide();
        if ( undefined === path ) {
			index.update("A file name is required to download. Please press download again and choose a file name")
			return;
        } else {
            index.update("OK. Attempting to download")
            document.getElementById("download-button").disabled = true;
        }
        document.querySelector('#download-progress').removeAttribute('style');
        index.send("download", { url: document.getElementById("url-input").value, save: path })
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
                if ( 'string' === typeof message.payload ) {
                    index.update( message.payload );
                } else {
                    index.update( message.payload.msg, message.payload );
                }
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
