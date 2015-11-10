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
            showOnFooter: true,
            showOnMouseMove: true,
			units: null,
			targetDiv: null,
			targetPartialDiv: null,
            targetMouseMoveDiv: 'measure_mouse_move_div',
            _mouseMoveTooltip: true
		},

		_create: function() {
			var self = this;

			$.ui.gcTool.prototype._create.apply(self, arguments);

			// create control and add to map
			self.options.control = new OpenLayers.Control.Measure(OpenLayers.Handler.Path, {
				persist: true
			});
			self.options.control.events.register('measure', self, self._handleMeasurements);
			self.options.control.events.register('measurepartial', self, self._handleMeasurements);
			self.options.control.events.register('activate', self, self._addPartialMeasurementHandler);
			self.options.control.events.register('deactivate', self, self._removePartialMeasurementHandler);
            
            if(self.options.showOnMouseMove) {
                $('body').append('<div id="measure_mouse_move_div" style="display:none;z-index:90000;background-color:white;position:absolute;"><span data-role="partial"></span><br><span data-role="total"></span></div>');
                self.options.mousemovehandler = function(e) {
                    $('#'+self.options.targetMouseMoveDiv).css({
                       left: e.pageX+15,
                       top: e.pageY+5
                    });
                };
            }
			
			gisclient.map.addControl(self.options.control);
		},
		
		_deactivate: function() {
			var self = this;
			
			$('#'+self.options.targetPartialDiv).empty();
			$('#'+self.options.targetDiv).empty();
			$('#'+self.options.targetMouseMoveDiv+' span[data-role!=""]').empty();
            $('#'+self.options.targetMouseMoveDiv).hide();
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
			
            var value = gisclient.numberFormat(event.measure, decimals) + " " + event.units;
			var html = OpenLayers.i18n('Length')+' '+ value;
			
			$('#'+self.options.targetDiv).html(html);
            if(self.options.showOnMouseMove) {
                $('#'+self.options.targetMouseMoveDiv+' span[data-role="total"]').html(value);
            }
            if(event.type == 'measurepartial') {
                if(!self.options._mouseMoveTooltip) $('#'+self.options.targetMouseMoveDiv).hide();
                self.options._mouseMoveTooltip = true;
            }
            if(event.type == 'measure') self.options._mouseMoveTooltip = false;
		},
		
		_handlePartialMeasurement: function(event) {
			var self = this;
            
            /*if(self.options.showOnMouseMove && !self.options._mouseMoveBound) {
                $(gisclient.map.div).bind('mousemove', self.options.mousemovehandler);
                $('#'+self.options.targetMouseMoveDiv).show();
                self.options._mouseMoveBound = true;
            }*/
            if(self.options._mouseMoveTooltip) {
                $('#'+self.options.targetMouseMoveDiv).css({
                   left: event.pageX+15,
                   top: event.pageY+5
                }).show();
            }
            
			if(self.options.last_point != null) {
				var pixel = event.xy;
				var point = gisclient.map.getLonLatFromPixel(pixel);
				var distance = self.options.last_point.distanceTo(new OpenLayers.Geometry.Point(point.lon, point.lat));
				if(distance > 1000) {
					distance = (distance/1000);
					var decimals = 3;
					var units = 'km';
				} else {
					var decimals = 1;
					var units = 'm';
				}
                var value = gisclient.numberFormat(distance, decimals)+' '+units;
				$('#'+self.options.targetPartialDiv).html(OpenLayers.i18n('From last point')+value);
                if(self.options.showOnMouseMove && self.options._mouseMoveTooltip) {
                    $('#'+self.options.targetMouseMoveDiv+' span[data-role="partial"]').html(value);
                }
			}
		}
	});

	$.extend($.gcTool.measureLine, {
		version: "3.0.0"
	});
})(jQuery);