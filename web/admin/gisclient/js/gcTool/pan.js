/*
 */


(function($, undefined) {


	$.widget("gcTool.pan", $.ui.gcTool, {

		widgetEventPrefix: "pan",

		options: {
			label: OpenLayers.i18n('Pan'), // TODO: use as default value OpenLayers.i18n...
			icons: {
				primary: 'pan' // TODO: choose better name
			},
			text: false
		},

		_create: function() {
			var self = this;
			
			$.ui.gcTool.prototype._create.apply(self, arguments);

			// create control and add to map
			self.options.control = new OpenLayers.Control.Navigation({
				documentDrag: true,
				zoomBoxEnabled: false,
				zoomWheelEnabled: false,
				handleRightClicks: false,
				autoActivate: false
			});
			gisclient.map.addControl(self.options.control);
		}
	});

	$.extend($.gcTool.pan, {
		version: "3.0.0"
	});
})(jQuery);