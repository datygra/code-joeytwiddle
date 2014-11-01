// ==UserScript==
// @name Next Image/Previous Image
// @author arty <me@arty.name>
// @namespace http://arty.name/
// @version 2.0.0
// @description  Quick scroll to next/previous image on a page with n/p buttons
// @include *
// ==/UserScript==

// This is a minor adaptation of arty's original, by joeytwiddle

// 2012/10 - Now sorting positions so out-of-order images do not break the sequence.

(function(){
  // var forwardButton  = 102; // F
  // var backwardButton = 114; // R
  var forwardButton  = 110; // N
  var backwardButton = 112; // P
  var positions = [];

  document.addEventListener('keypress', function(event){
    if (event.ctrlKey || event.shiftKey || event.altKey) return;
    var code = event.keyCode || event.which;
    if (code != backwardButton && code != forwardButton) return;
    if (event.target.tagName && event.target.tagName.match(/input|select|textarea/i) || event.target.getAttribute('contenteditable')==="true") return;

    // We force a rescan of the page's images every time, for dynamic pages.
    positions = [];
    if (positions.length === 0) {
      for (var index = 0; index < document.images.length; index++) {
        var image = document.images[index];
        if (image.width * image.height < 200*200) continue;
        var ytop = getYOffset(image);
        // Vertically centralise smaller images.
        if (image.height && image.height < window.innerHeight) {
          ytop -= (window.innerHeight - image.height)/2 | 0;
        }
        positions.push([index, ytop]);
      }
    }
    positions.sort(function(a,b) {
      return a[1] - b[1];
    });

    var scroll = Math.max(document.documentElement.scrollTop, document.body.scrollTop);

    if (code === forwardButton) {
      for (index = 0; index < positions.length; index++) {
        if (positions[index][1] <= scroll) continue;
        // Hard to detect which one our browser is using when we are at the top of the document.
        // Because Chrome presents documentElement.scrollTop = 0 all the time!
        // Likewise Firefox presents document.body.scrollTop = 0 all the time!
        // Solution?  Just set both of them!
        document.body.scrollTop = positions[index][1];
        document.documentElement.scrollTop = positions[index][1];
        return;
      }
    } else if (code === backwardButton) {
      for (index = positions.length - 1; index >= 0; index--) {
        if (positions[index][1] >= scroll) continue;
        document.body.scrollTop = positions[index][1];
        document.documentElement.scrollTop = positions[index][1];
        return;
      }
    }

  }, false);

  function getYOffset(node) {
    for (var offset = 0; node; offset += node.offsetTop, node = node.offsetParent);
    return offset;
  }
})();
