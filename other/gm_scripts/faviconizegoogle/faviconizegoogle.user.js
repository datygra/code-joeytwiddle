// ==UserScript==
// @name           FaviconizeGoogle
// @namespace      noggieb
// @description    Adds Favicons to Google search results.
// @include        http://www.google.com/search?*
// ==/UserScript==

var placeFaviconByUrl = false;

function filterListBy(l,c) {
	var ret = new Array();
	for (var i=0;i<l.length;i++) {
		var it = l[i];
		if (c(it)) {
			ret[ret.length] = it;
		}
	}
	return ret;
}

// var links = document.evaluate("//a[@class='l']",document,null,6,null);
var links = filterListBy(document.links, function(x){ return x.className=='l'; } );

// GM_log("Got links = "+links.snapshotLength);

var style = document.createElement('STYLE');
style.innerHTML = ".favicon { padding-right: 4px; vertical-align: middle; }";
document.getElementsByTagName('head')[0].appendChild(style);

// for (var i=0;i<links.snapshotLength;i++) {
	// var link = links.snapshotItem(i);
for (var i=0;i<links.length;i++) {
	var link = links[i];
	// if (link.href.match('^javascript:') || link.href.match('^#')) {
		// continue;
	// }
	var host = link.href.replace(/^[^\/]*:\/\//,'').replace(/\/.*$/,'');
	// if (host == document.location.host) {
		// continue;
	// }
	var img = document.createElement('IMG');
	img.src = 'http://'+host+'/favicon.ico';
	img.width = '16';
	img.height = '16';
	img.className = 'favicon';
	if (placeFaviconByUrl) {
		// var urlNodes = document.evaluate("./parent-node::li[1]//cite",link,null,6,null);
		// var urlNode = urlNodes.snapshotItem(0);
		var urlNode = link.parentNode.parentNode.getElementsByTagName('cite')[0];
		urlNode.parentNode.insertBefore(img,urlNode);
	} else {
		link.parentNode.insertBefore(img,link);
	}

}
