let index = {
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
    	} else {
    		document.getElementById("download-button").disabled = true;
            index.update("Enter a valid WordPress.com media export URL to begin")
    	}
    },
    download: function(event) {
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
                } else {
        	        index.append(JSON.stringify(message))
                }
                // {"name":"update","payload":"got request for download"}

        });
    }
};
window.index = index;
