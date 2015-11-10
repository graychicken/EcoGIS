/*
 */


(function($, undefined) {


	$.widget("gcTool.reloadLayers", $.ui.gcTool, {

		widgetEventPrefix: "reloadLayers",

		options: {
			label: OpenLayers.i18n('Reload'),
			icons: {
				primary: 'reload' // TODO: choose better name
			},
			text: false
		},

		_create: function() {
			var self = this;
			
			$.ui.gcTool.prototype._create.apply(self, arguments);

		},
		
		reloadTheme: function(theme) { // deprecated
			gisclient.componentObjects.gcLayersManager.reloadTheme(theme);
		},
		
		reloadLayer: function(themeName, layerName) { // deprecated
			gisclient.componentObjects.gcLayersManager.reloadLayer(themeName, layerName);
		},

		_click: function(event) {
			gisclient.componentObjects.gcLayersManager.reloadThemes();
		}
	});

	$.extend($.gcTool.reloadLayers, {
		version: "3.0.0"
	});
})(jQuery);