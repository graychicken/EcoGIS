/*
 */


(function($, undefined) {


	$.widget("gcTool.measureLine", $.ui.gcTool, {

		widgetEventPrefix: "measureLine",

		options: {
			label: OpenLayers.i18n('Measure line'),
			icons: {
				primary: 'ruler' // TODO: choose better name
			},
			text: false,
			last_point: null,
			units: null,
			targetDiv: null,
			targetPartialDiv: null
		},

		_create: function() {
			var self = this;

			$.ui.gcTool.prototype._create.apply(self, arguments);

			// create control and add to map
			self.options.control = new OpenLayers.Control.Measure(OpenLayers.Handler.Path, {
				persist: true,
                                geodesic: self._isGeodesic()
			});
			self.options.control.events.register('measure', self, self._handleMeasurements);
			self.options.control.events.register('measurepartial', self, self._handleMeasurements);
			self.options.control.events.register('activate', self, self._addPartialMeasurementHandler);
			self.options.control.events.register('deactivate', self, self._removePartialMeasurementHandler);
			
			gisclient.map.addControl(self.options.control);
		},
		
		_deactivate: function() {
			var self = this;
			
			$('#'+self.options.targetPartialDiv).empty();
			$('#'+self.options.targetDiv).empty();
			self.options.last_point = null;
		},
		
		_addPartialMeasurementHandler: function(event) {
			var self = this;
			
			gisclient.map.events.register('mousemove', self, self._handlePartialMeasurement);
		},
		
		_removePartialMeasurementHandler: function(event) {
			var self = this;
			
			gisclient.map.events.unregister('mousemove', self, self._handlePartialMeasurement);
			self.options.last_point = null;
			$('#'+self.options.targetPartialDiv).empty();
		},

		_handleMeasurements: function(event) {
			var self = this;
			var geometry = event.geometry;
			var segments = geometry.getSortedSegments();
			var last_segment = segments[segments.length-1];
			var decimals = event.units == 'm' ? 1 : 3;
			self.options.last_point = new OpenLayers.Geometry.Point(last_segment.x2, last_segment.y2);
			self.options.units = event.units;
			
			var html = OpenLayers.i18n('Length')+' '+ gisclient.numberFormat(event.measure, decimals) + " " + event.units;
			
			$('#'+self.options.targetDiv).html(html);
		},
		
		_handlePartialMeasurement: function(event) {
                        var self = this,
                            lonlat, point1, point2, distance, decimals, units;
                    
                        lonlat = gisclient.map.getLonLatFromPixel(event.xy);
                        if(self.options.last_point != null) {
                            point1 = self.options.last_point.clone().transform(gisclient.map.projection, gisclient.map.displayProjection);
                            point2 = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat).transform(gisclient.map.projection, gisclient.map.displayProjection);
                            distance = point1.distanceTo(point2);
                            if(distance > 1000) {
                                distance = (distance/1000);
                                decimals = 3;
                                units = 'km';
                            } else {
                                decimals = 1;
                                units = 'm';
                            }
                            
                            $('#'+self.options.targetPartialDiv).html(OpenLayers.i18n('From last point')+' '+gisclient.numberFormat(distance, decimals)+' '+units);
			}
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

	$.extend($.gcTool.measureLine, {
		version: "3.0.0"
	});
})(jQuery);