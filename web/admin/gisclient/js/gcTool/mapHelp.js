
(function($, undefined) {


	$.widget("gcTool.mapHelp", $.ui.gcTool, {

		widgetEventPrefix: "mapHelp",

		options: {
			label: OpenLayers.i18n('Help'),
			icons: {
				primary: 'map_help' // TODO: choose better name
			},
			text: false,
			helpUrl: null,
            autoOpen: true,
            footer: '<input type="checkbox" name="map_help_toggle_autoshow"><span style="margin-left:5px;">'+OpenLayers.i18n('Do not show this hint again')+'</span><hr>'
		},

		_create: function() {
			var self = this;
			$.ui.gcTool.prototype._create.apply(self, arguments);
			
            if(self.options.helpUrl == null) {
                self.options.helpUrl = gisclient.getMapOptions().mapHelpUrl;
            }
            
            $('body').append('<div id="gc_map_url_dialog"></div>');
            $('#gc_map_url_dialog').load(self.options.helpUrl, function(response, status) {
                if (status == "error") {
                    $(self.element).button('destroy');
                    $(self.element).parent('span').remove();
                    return;
                }
                $('#gc_map_url_dialog').prepend(self.options.footer);
                $('#gc_map_url_dialog input[name="map_help_toggle_autoshow"]').click(function() {
                    if($(this).prop('checked')) { // cambiato attr in prop, problemi di versione jquery che supportava attr fino ad una certa versione
                        createCookie('map_help_autoshow', 1, 30);
                    } else {
                        eraseCookie('map_help_autoshow');
                    }
                });
                var autoOpenCookie = readCookie('map_help_autoshow');
                var autoOpen = self.options.autoOpen;
                if(autoOpenCookie) autoOpen = !autoOpenCookie;
                if(autoOpen) $('#gc_map_url_dialog').dialog('open');
            }).dialog({
                width: 700,
                height: 500,
                autoOpen: false,
                title: OpenLayers.i18n('Help')
            });
		},
		
		_click: function(event) {
			var self = event.data.self;
			
            $('#gc_map_url_dialog').dialog('open');
            
		}

	});

	$.extend($.gcTool.mapHelp, {
		version: "3.0.0"
	});
})(jQuery);
