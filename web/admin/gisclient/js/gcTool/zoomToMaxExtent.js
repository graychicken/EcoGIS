/*
 */


(function($, undefined) {


	$.widget("gcTool.zoomToMaxExtent", $.ui.gcTool, {

		widgetEventPrefix: "zoomToMaxExtent",

		options: {
			label: OpenLayers.i18n('Zoom to max extent'),
			icons: {
				primary: 'zoom_full' // TODO: choose better name
			},
			text: false,
			extent: null			
		},

		_create: function() {
			var self = this;
			$.ui.gcTool.prototype._create.apply(self, arguments);
			
			// create control and add to map
			self.options.control = new OpenLayers.Control.ZoomToMaxExtent();
			gisclient.map.addControl(self.options.control);
		},

		_click: function(event) {
			var self = event.data.self;
			if (self.options.extent) {
				gisclient.zoomOn(self.options.extent);
			} else {
				self.options.control.trigger();
			}

			// call event change
			var uiHash = {
				control: self.options.control
			};
			self._trigger( "click", event, uiHash );
		}
	});

	$.extend($.gcTool.zoomToMaxExtent, {
		version: "3.0.0"
	});
})(jQuery);