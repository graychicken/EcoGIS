/*
 */


(function($, undefined) {


	$.widget("gcTool.queryToFeatures", $.ui.gcTool, {

		widgetEventPrefix: "queryToFeatures",

		options: {
			label: OpenLayers.i18n('queryToFeatures'),
			icons: {
				primary: 'queryToFeatures' // TODO: choose better name
			},
			text: false
		},

		_create: function() {
			var self = this;

			$.ui.gcTool.prototype._create.apply(self, arguments);
			
			var styleMap = new OpenLayers.StyleMap({
				"default": new OpenLayers.Style({
					strokeColor: "black",
					strokeWidth: 5,
					fillColor: "red",
					fillOpacity: 0.5,
					pointRadius: 5
				})
			});
			
			self.options.queryLayer = new OpenLayers.Layer.Vector('queryLayer',{styleMap:styleMap});
			gisclient.map.addLayer(self.options.queryLayer);
			
			self.options.control = new OpenLayers.Control.SelectFeature(self.options.queryLayer, {highlightOnly:true});
			//self.options.control.events.register('featurehighlighted', self, self.writeFeatureAttributes);

			
			
		},

		_click: function(event) {
			var self = event.data.self;
			
			$('#div_querytofeatures').dialog({
				draggable:true,
				title:'Query',
				position: [200,0]
			});
			$('#div_querytofeatures button[name="query"]').click(function(event) {
				event.preventDefault();
				self.getFeatures();
			});
			$('#div_querytofeatures button[name="clear"]').click(function(event) {
				event.preventDefault();
				self.clear();
			});
			
			// call event change
			//$.ui.gcTool.prototype._click.apply(self, arguments);
		},
		
		getFeatures: function() {
			var self = this;
			
			var query = $('#div_querytofeatures textarea').val();
			var params = {sql:query};
			$.post('http://192.168.0.13/gisclient-r3client/default/queryToFeatures.php', params, function(data) {
				console.log(data);
				var features = [];
				if(typeof(data.data) != 'object' || data.data.length < 1) return; 
				$.each(data.data, function(e, row) {
					var feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.fromWKT(row.the_geom));
					$.each(row, function(indice, dati) {
						if(indice != 'the_geom') {
							feature.attributes[indice] = dati;
						}
					});
					features.push(feature);
				});
				self.options.queryLayer.addFeatures(features);
				console.log(self.options.queryLayer);
			},'json');
			
		},
		
		clear: function() {
			var self = this;
			self.options.queryLayer.removeAllFeatures();
		},
		
		writeFeatureAttributes: function() {
		}
	});

	$.extend($.gcTool.queryToFeatures, {
		version: "3.0.0"
	});
})(jQuery);