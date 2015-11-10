
(function($, undefined) {


	$.widget("gcTool.geolocate", $.ui.gcTool, {

		widgetEventPrefix: "geolocate",

		options: {
			label: OpenLayers.i18n('Zoom to actual location'),
			icons: {
				primary: 'geolocate'
			},
			text: false,
            correctionParameters: {
                x:0, 
                y:0
            }
		},
        
        internalVars: {
            markerLayer: null
        },

		_create: function() {
			var self = this;
			
			$.ui.gcTool.prototype._create.apply(self, arguments);

            
            self.internalVars.markerLayer = new OpenLayers.Layer.Markers("GPS Position");
            
		},

		_click: function(event) {
			var self = event.data.self;
			
            if(self.options.timeout) clearTimeout(self.internalVars.timeout);
            
            gisclient.componentObjects.loadingHandler.show();
            self.internalVars.timeout = setTimeout(function() {
                gisclient.componentObjects.loadingHandler.hide();
            }, 50 * 1000);
            
            
            gisclient.getGPSPosition({
                locationupdated: self._zoomToLocation,
                locationfailed: function() {
                    gisclient.componentObjects.loadingHandler.hide();
                    if(self.options.timeout) clearTimeout(self.internalVars.timeout);
                    alert('geolocation failed, check gps status');
                },
                locationuncapable: function() {
                    gisclient.componentObjects.loadingHandler.hide();
                    if(self.options.timeout) clearTimeout(self.internalVars.timeout);
                    alert('cannot get position');
                },
                scope: self
            });
            
            
            
            if(!self.internalVars.markerLayer.map) {
                gisclient.map.addLayer(self.internalVars.markerLayer);
            }

		},
        
        _zoomToLocation: function(event) {
            var self = this;
            
            gisclient.componentObjects.loadingHandler.hide();
            if(self.options.timeout) clearTimeout(self.internalVars.timeout);
            
            var point = event.point;
            
            if(self.options.correctionParameters.x != 0 || self.options.correctionParameters.y != 0) {
                point.x += self.options.correctionParameters.x;
                point.y += self.options.correctionParameters.y;
            }
            
            var lonLat = new OpenLayers.LonLat(point.x, point.y);
            
            self._clearMarkers();
            
            if(!gisclient.map.isValidLonLat(lonLat)) return alert('Position '+lonLat.lon+' '+lonLat.lat+' is not valid');
            if(!gisclient.map.getMaxExtent().containsLonLat(lonLat)) return alert('Position '+lonLat.lon+' '+lonLat.lat+' out of extent');
            gisclient.map.setCenter(lonLat);
            gisclient.map.zoomToScale(1000, true);
            
            var size = new OpenLayers.Size(21,25);
            var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
            var icon = new OpenLayers.Icon(OpenLayers.ImgPath+'marker-gold.png', size, offset);
            var marker = new OpenLayers.Marker(lonLat,icon);
            self.internalVars.markerLayer.addMarker(marker);
            setTimeout(function() {
                self.internalVars.markerLayer.removeMarker(marker);
            }, 20 * 1000);
        },
        
        _clearMarkers: function() {
            var self = this;
            
            for(var i = 0; i < self.internalVars.markerLayer.markers; i++) {
                self.internalVars.markerLayer.removeMarker(self.internalVars.markerLayer.markers[i]);
            }
        }
	});

	$.extend($.gcTool.zoomToMaxExtent, {
		version: "3.0.0"
	});
})(jQuery);