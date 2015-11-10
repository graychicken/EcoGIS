/*
 */


(function($, undefined) {


	$.widget("gcTool.zoomToHistoryNext", $.ui.gcTool, {

		widgetEventPrefix: "zoomToHistoryNext",

		options: {
			label: OpenLayers.i18n('Zoom to next'),
			icons: {
				primary: 'zoom_next' // TODO: choose better name
			},
			text: false
		},

		_create: function() {
			var self = this;

			$.ui.gcTool.prototype._create.apply(self, arguments);

			// create control and add to map
			var controls = gisclient.map.getControlsByClass('OpenLayers.Control.NavigationHistory');
			if (controls.length > 0) {
				self.options.control = controls[0];
			} else {
				self.options.control = new OpenLayers.Control.NavigationHistory();
				gisclient.map.addControl(self.options.control);
			}
		},

		_click: function(event) {
			var self = event.data.self;

			self.options.control.nextTrigger();
			
			self._trigger( "click", event, self._getUIHash() );
		}
	});

	$.extend($.gcTool.zoomToHistoryNext, {
		version: "3.0.0"
	});
})(jQuery);