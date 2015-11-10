/*
 */


(function($, undefined) {


	$.widget("gcTool.selectBox", $.ui.gcTool, {

		widgetEventPrefix: "selectBox",

		options: {
			label: OpenLayers.i18n('Select box'),
			icons: {
				primary: 'select_box' // TODO: choose better name
			},
			text: false,
			snapOptionsId: null
		},

		_create: function() {
			var self = this;

			$.ui.gcTool.prototype._create.apply(self, arguments);
			
			self.options.control = new OpenLayers.Control({autoActivate:false});
			OpenLayers.Util.extend(self.options.control, {
				draw: function () {
					this.box = new OpenLayers.Handler.Box(self.options.control,
						{"done": self._handleFeature},
						{boxDivClassName: 'ui-state-highlight ui-priority-secondary'}
					);
					this.box.activate();
				},
				CLASS_NAME: 'OpenLayers.Control.selectBox'
			});
			// HACKS: attach gisclient and self to the control to use them in _handleFeature
			self.options.control.gisclient = gisclient;
			self.options.control.self = self;
			
			gisclient.map.addControl(self.options.control);
		},
		
		_click: function(event) {
			var self = event.data.self;
			
			$.ui.gcTool.prototype._click.apply(self, arguments);
			
			if(self.options.snapOptionsId != null) {
				$('#'+self.options.snapOptionsId).snapPoint({gisclient:gisclient});
				gisclient.componentObjects.snapPoint.showSnapOptions();
			}
		},
		
		_handleFeature: function(geom) {
			var self = this.self;
			var uiHash = self._getUIHash();
			
			var lb = gisclient.map.getLonLatFromPixel(new OpenLayers.Pixel(geom.left, geom.bottom)); 
			var rt = gisclient.map.getLonLatFromPixel(new OpenLayers.Pixel(geom.right, geom.top));
			uiHash.box = new OpenLayers.Bounds(lb.lon, lb.lat, rt.lon, rt.lat);
			
			$('#'+gisclient.divs.mapDialogId).dialog('close');
			
			// call event change
			self._trigger( "handleFeature", null, uiHash);
		}


	});

	$.extend($.gcTool.selectBox, {
		version: "3.0.0"
	});
})(jQuery);