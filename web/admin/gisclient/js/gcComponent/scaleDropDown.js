(function($, undefined) {


	$.widget("gcComponent.scaleDropDown", $.ui.gcComponent, {

		widgetEventPrefix: "scaleDropDown",

		options: {
			layers: [],
			gisclient: null,
			currentScale: null,
            unit: 'm'
		},

		_create: function() {
			var self = this;
			
			$.ui.gcComponent.prototype._create.apply(self, arguments);
			
			// add resolutions to autocomplete
			var resolutions = gisclient.getResolutions();
			var options = [];
            
            var projection = gisclient.getProjection();
            if(projection == 'EPSG:4326') self.options.unit = 'degrees';
            
			for(var i in resolutions) {
				var res = self.commafy(Math.round(OpenLayers.Util.getScaleFromResolution(resolutions[i], self.options.unit)));
				options.push({val:resolutions[i],value:'1:'+res});
			}
			$(self.element).autocomplete({
				source: options,
				minLength: 0
			});
			$(self.element).bind('autocompleteselect',{self:self},self._changeZoom);
			
			$(self.element).click(function() {
				$(self.element).autocomplete('search','').select();
			});
			
			self._zoomChange();
			
			gisclient.map.events.register('zoomend', self, self._zoomChange);
			
			$(self.element).keypress(function(event){
				if(event.which == 13) {
                    var scale = $(self.element).val();
                    if(scale.indexOf(':') > -1) {
                        var parts = scale.split(':');
                        scalePart = parts[1];
                        var scale = scalePart.replace('.', '');
                    }
					var resolution = OpenLayers.Util.getResolutionFromScale(scale, self.options.unit);
					var ui = {item:{val:resolution}};
					event.data = {self:self}; // passing self to _changeZoom function
					self._changeZoom(event, ui);
					event.preventDefault();
				}
			});

		},

		_changeZoom: function(event, ui) {
			var self = event.data.self;
			
			gisclient.map.zoomTo(gisclient.map.getZoomForResolution(ui.item.val));
		},
		
		_zoomChange: function(event) {
			var self = this;
			var map = gisclient.map;
	
			var scale = self.getCurrentScale();
			$(self.element).val('1:'+scale);
			self.options.currentScale = scale;
		},
		
		getCurrentScale: function() {
			var self = this;
			
			var currentRes = gisclient.map.getResolution();
			var currentScale = Math.round(OpenLayers.Util.getScaleFromResolution(currentRes, self.options.unit));
			return self.commafy(currentScale);
		},
		
		commafy: function(num) {
			var decpoint = ',';
			var sep = '.';
			num = num.toString();
			a = num.split(decpoint);
			x = a[0]; // decimal
			y = a[1]; // fraction
			z = "";
			if (typeof(x) != "undefined") {
				// reverse the digits. regexp works from left to right.
				for (i=x.length-1;i>=0;i--)
				z += x.charAt(i);
				// add seperators. but undo the trailing one, if there
				z = z.replace(/(\d{3})/g, "$1" + sep);
				if (z.slice(-sep.length) == sep)
				z = z.slice(0, -sep.length);
				x = "";
				// reverse again to get back the number
				for (i=z.length-1;i>=0;i--)
				x += z.charAt(i);
				// add the fraction back in, if it was there
				if (typeof(y) != "undefined" && y.length > 0)
				x += decpoint + y;
			}
			return x;
		}
		
	});

	$.extend($.gcComponent.scaleDropDown, {
		version: "3.0.0"
	});
})(jQuery);