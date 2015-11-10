/*
 */


(function($, undefined) {


	$.widget("gcTool.selectPolygon", $.ui.gcTool, {

		widgetEventPrefix: "selectPolygon",

		options: {
			label: OpenLayers.i18n('Select')+' '+OpenLayers.i18n('Polygon'),
			icons: {
				primary: 'select_polygon' // TODO: choose better name
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
					this.polygon = new OpenLayers.Handler.Polygon(self.options.control,{"done": self._handleFeature});
					this.polygon.activate();
				},
				CLASS_NAME: 'OpenLayers.Control.selectPolygon'
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
			
			uiHash.polygon = geom.toString();
			
			$('#'+gisclient.divs.mapDialogId).dialog('close');
			
			// call event change
			self._trigger( "handleFeature", null, uiHash);
		}


	});

	$.extend($.gcTool.selectBox, {
		version: "3.0.0"
	});
})(jQuery);