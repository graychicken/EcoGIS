/*
 */


(function($, undefined) {


	$.widget("gcTool.zoomIn", $.ui.gcTool, {

		widgetEventPrefix: "zoomIn",

		options: {
			label: OpenLayers.i18n('Zoom in'), // TODO: use as default value OpenLayers.i18n...
			icons: {
				primary: 'zoom_in' // TODO: choose better name
			},
			text: false
		},

		_create: function() {
			var self = this;

			$.ui.gcTool.prototype._create.apply(self, arguments);

			// create control and add to map
			self.options.control = new OpenLayers.Control.ZoomBox({
				draw: function() {
					this.handler = new OpenLayers.Handler.Box(
						this, 
						{done: this.zoomBox},
						{keyMask: this.keyMask,boxDivClassName: 'ui-state-highlight ui-priority-secondary'}
					);
				}
			});
			gisclient.map.addControl(self.options.control);
		}
	});

	$.extend($.gcTool.zoomIn, {
		version: "3.0.0"
	});
})(jQuery);