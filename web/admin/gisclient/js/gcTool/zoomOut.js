/*
 */


(function($, undefined) {


	$.widget("gcTool.zoomOut", $.ui.gcTool, {

		widgetEventPrefix: "zoomOut",

		options: {
			label: OpenLayers.i18n('Zoom out'), // TODO: use as default value OpenLayers.i18n...
			icons: {
				primary: 'zoom_out' // TODO: choose better name
			},
			text: false
		},

		_create: function() {
			var self = this;

			$.ui.gcTool.prototype._create.apply(self, arguments);

			// create control and add to map
			self.options.control = new OpenLayers.Control.ZoomBox({
				out: true,
				draw: function() {   // TODO: put this function into configuration (OpenLayers Hacks)
					this.handler = new OpenLayers.Handler.Box(this, {
						done: this.zoomBox
					},
					{
						keyMask: this.keyMask,
						boxDivClassName: 'ui-state-highlight ui-priority-secondary'
					} );
				}
			});
			gisclient.map.addControl(self.options.control);
		}
	});

	$.extend($.gcTool.zoomOut, {
		version: "3.0.0"
	});
})(jQuery);