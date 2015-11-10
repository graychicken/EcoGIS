var outerLayout, mainLayout;
$(document).ready(function() {    
	mainLayout = $('#layout_container').layout({
		applyDefaultStyles: true,
		center__paneSelector:"#mapOL",
		north__paneSelector:"#header",
		north__size: "auto",
        north__size:48,
		north__closable:false,
		north__resizable:false,
		north__spacing_open: 0,
        togglerLength_closed: 100,
        togglerLength_open: 100,
        spacing_closed: 20,
        spacing_open: 20,
        east__togglerContent_open: "&#8250;",
		center__onresize: "eastLayout.resizeAll",
		south__paneSelector: "#footer",
		south__size: 25,
		south__closable:false,
		south__resizable:false,
		south__spacing_open: 0
	});
	
	

	$('#toolbar span').buttonset();
	
	$('#toolbar span button#zoom_full').button({
		icons: {
			primary: "zoom_full"
		},
		text:false
	});
	$('#toolbar span button#zoom_prev').button({
		icons: {
			primary: "zoom_prev"
		},
		text:false
	});
	$('#toolbar span button#zoom_next').button({
		icons: {
			primary: "zoom_next"
		},
		text:false
	});
	/*$('#toolbar span input:radio').button({
		icons: {
			primary: "zoom_full"
		},
		text: false
	});*/
	
	$("#treeDiv").tabs().find(".ui-tabs-nav");
});