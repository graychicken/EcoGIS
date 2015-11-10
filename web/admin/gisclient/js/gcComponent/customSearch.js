(function($, undefined) {


$.widget("gcComponent.customSearch", $.ui.gcComponent, {

	widgetEventPrefix: "customSearch",

	options: {
		gisclient: null
	},
	
	internalVars: {
	},
	
	_create: function() {
		var self = this;
		$.ui.gcComponent.prototype._create.apply(self, arguments);
	},
	
	search: function(url) {
		var self = this;
		
		self.clear();
		
		var errorString = OpenLayers.i18n('Error reading results, the request has been aborted');
		
		$.ajax({
			url: url,
			type: 'GET',
			dataType: 'json',
			success: function(response) {
				var geojsonFormat = new OpenLayers.Format.GeoJSON();
				var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
				var features = geojsonFormat.read(response);
				selectionLayer.addFeatures(features);
				gisclient.map.zoomToExtent(selectionLayer.getDataExtent());
				gisclient.internalVars.lastZoomOn = null;
				gisclient.internalVars.lastCustomSearch = url;
			},
			error: function() {
				gisclient.componentObjects.errorHandler.show(errorString);
			}
		});
		
	},
	
	clear: function() {
		var self = this;
		
		var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
		selectionLayer.removeAllFeatures();
	}
	
});

$.extend($.gcComponent.searchForm, {
	version: "3.0.0"
});
	
	
})(jQuery);