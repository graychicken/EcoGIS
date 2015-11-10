/*
 */


(function($, undefined) {


	$.widget("gcTool.measureArea", $.ui.gcTool, {

		widgetEventPrefix: "measureArea",

		options: {
			label: OpenLayers.i18n('Measure area'),
			icons: {
				primary: 'ruler2' // TODO: choose better name
			},
			text: false,
			targetDiv: null
		},

		_create: function() {
			var self = this;

			$.ui.gcTool.prototype._create.apply(self, arguments);

			// create control and add to map
			self.options.control = new OpenLayers.Control.Measure(OpenLayers.Handler.Polygon, {
				persist: true,
                                geodesic: self._isGeodesic()
			});
			self.options.control.events.register('measure', self, self._handleMeasurements);
			self.options.control.events.register('measurepartial', self, self._handleMeasurements);

			gisclient.map.addControl(self.options.control);
		},
		
		_deactivate: function() {
			var self = this;
			
			$('#'+self.options.targetDiv).empty();
		},

		_handleMeasurements: function(event) {
			var self = this;
			
			var decimals = 1;
			if(event.units == 'km') {
				decimals = 3;
			}
			
			var html = OpenLayers.i18n('Area')+' '+gisclient.numberFormat(event.measure, decimals) + " " + event.units + "2";
			$('#'+self.options.targetDiv).html(html);
		},
                
                _isGeodesic: function() {
                    switch(gisclient.map.getProjection()) {
                        case "EPSG:3857":
                            return true;
                        default:
                            return false;
                    }
                }
	});

	$.extend($.gcTool.measureArea, {
		version: "3.0.0"
	});
})(jQuery);