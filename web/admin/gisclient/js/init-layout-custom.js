var outerLayout, mainLayout, eastLayout;
$(document).ready(function() { 
	mainLayout = $('#layout_container').layout({
		applyDefaultStyles: true,
		center__paneSelector:"#mapOL",
		north__paneSelector:"#header",
		north__size:33,
		north__closable:false,
		north__resizable:false,
		north__spacing_open: 0,
		east__paneSelector:	"#sidebarSx",
		east__size:300,
		east__closable:true,
		east__resizable:true,
		east__onresize_end: function() {
			if($('#sidebarSx table.ui-jqgrid-btable').length > 0) {
				var newWidth = $(mainLayout.panes.east.selector).width() - 30;
				$('#sidebarSx table.ui-jqgrid-btable').setGridWidth(newWidth);
			}
			var totHeight = $('#treeDiv').height();
			var headerHeight = $('#treeDiv > ul').height();
			$('#treeDiv > div').height(totHeight-headerHeight-21);
		},
		center__onresize: "eastLayout.resizeAll",
		south__paneSelector:	"#footer",
		south__size:20,
		south__closable:false,
		south__resizable:false,
		south__spacing_open: 0
	});
	eastLayout = $('#sidebarSx').layout({
		applyDefaultStyles: true,
		center__paneSelector: '.east-center',
		south__paneSelector: '.east-south',
		south__resizable: false,
		south__size: 180
		//center__paneSelector: '.east-foo',
		//center__initClosed: true,
		//center__initHidden: true
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