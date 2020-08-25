// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()

jQuery = require("jquery");
require("jquery-ui");
require("bootstrap");
require("remodal");
require("cropper");
jstz = require("jstimezonedetect");
$ = jQuery;
window.jQuery = $;
window.$ = $;

$(document).ready(function(){
	$('.tips').tooltip({
		show: false,
		hide: false
	});
});
