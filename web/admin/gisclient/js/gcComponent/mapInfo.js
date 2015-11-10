/*
 * NOTE: for lat/lon transformation the proj4js library is required
 */


(function($, undefined) {


	$.widget("gcComponent.mapInfo", $.ui.gcComponent, {

		widgetEventPrefix: "mapInfo",

		options: {
			idMapInfoScale: null,
			idMapInfoMousePosition: null,
			idMapInfoMousePositionLatLon: null,
			idmapInfoRefSystem: null,
			controls: []
		},

		_create: function() {
			var self = this;
			
			$.ui.gcComponent.prototype._create.apply(self, arguments);
			
			// create control for scale information
			if(self.options.idMapInfoScale != null) {
				self.options.controls.push(new OpenLayers.Control.Scale(self.options.idMapInfoScale,{isPermanent:true}));
			}

			// create control for mouse position (map projection)
			// Valutare se usare un solo controllo invece di due
			if(self.options.idMapInfoMousePosition != null && self.options.idMapInfoMousePositionLatLon != null) {
				var mousePosition = new OpenLayers.Control.MousePosition({
					div: document.getElementById(self.options.idMapInfoMousePosition),
					separator: ' ',
					numDigits: self.options.numDigits,
					formatOutput : self._formatOutput,
					isPermanent: true
				});
				self.options.controls.push(mousePosition);

				// create control for mouse position (latlon projection)
				var mousePositionLatLon = new OpenLayers.Control.MousePosition({
					div: document.getElementById(self.options.idMapInfoMousePositionLatLon),
					separator: ' ',
					displayProjection: new OpenLayers.Projection('EPSG:4326'), // needs the proj4js library
					numDigits: self.options.numDigits,
					formatOutput: self._formatOutputLonLat,
					self: self,
					isPermanent: true
				});
				self.options.controls.push(mousePositionLatLon);

				gisclient.map.addControls(self.options.controls);
			}
			
		},
		_formatOutput: function(lonLat) {
			var digits = parseInt(this.numDigits);
			var newHtml =
			'X: ' +
			lonLat.lon.toFixed(digits) +
			this.separator +
			'Y: ' +
			lonLat.lat.toFixed(digits);
			return newHtml;
		},
		_formatOutputLonLat: function(lonLat) {
			var self = this.self;
			var lon_degrees = self._LonLatDecimals2Degrees(lonLat.lon, parseInt(this.numDigits));
			var lat_degrees = self._LonLatDecimals2Degrees(lonLat.lat, parseInt(this.numDigits));
			var newHtml =
			'Lat: ' + lat_degrees +
			this.separator +
			'Lon: ' + lon_degrees;
			return newHtml;
		},
		_LonLatDecimals2Degrees: function(dec, digits) {
			var degrees = Math.floor(dec);
			var minutes = Math.floor((dec - degrees)*60);
			var seconds = ((dec - degrees)*60 - minutes)*60;
			return degrees +'&deg; ' + minutes + "' " + seconds.toFixed(digits) + "''";
		}
		
	});

	$.extend($.gcComponent.mapInfo, {
		version: "3.0.0"
	});
})(jQuery);
