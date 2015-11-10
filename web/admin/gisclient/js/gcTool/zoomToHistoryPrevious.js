/*
 */


(function($, undefined) {


	$.widget("gcTool.zoomToHistoryPrevious", $.ui.gcTool, {

		widgetEventPrefix: "zoomToHistoryPrevious",

		options: {
			label: OpenLayers.i18n('Zoom to previous'),
			icons: {
				primary: 'zoom_prev' // TODO: choose better name
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

			self.options.control.previousTrigger();
			
			// call event change
			self._trigger( "click", event, self._getUIHash() );
		}
	});

	$.extend($.gcTool.zoomToHistoryPrevious, {
		version: "3.0.0"
	});
})(jQuery);