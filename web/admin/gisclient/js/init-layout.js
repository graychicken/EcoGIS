$(document).ready(function() {
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

	$("#treeDiv").tabs().find(".ui-tabs-nav");
});
