(function($){

    $.widget("gcComponent.gcLegendTree", $.ui.gcComponent, {
	
		options: {
			widgetElementPrefix: 'gcLegendTree'
		},
		internalVars: {
			themes: {}
		},
		
		_create: function() {
			var self = this;
			$.ui.gcComponent.prototype._create.apply(self, arguments);
		},
		
		addThemeNode: function(id, title) {
			var self = this;
			var domId = self._addWidgetElementPrefix(id);
			
			self.internalVars.themes[id] = {
				id: id,
				title: title,
				domId: domId,
				layers: {}
			};
			return domId;
		},
		
		removeThemeNode: function(id) {
			var self = this;
			
			delete self.internalVars.themes[id];
		},
		
		addLayerNode: function(themeId, layerId, layerData) {
			var self = this;
			var domId = self._addWidgetElementPrefix(themeId+'_'+layerId);
			
			var layer = {
				id: layerId,
				title: layerData.title,
				domId: domId,
				layerData: layerData,
				classes: []
			};
			self.internalVars.themes[themeId].layers[layerId] = layer;
			
			return domId;
		},
		
		addClassNode: function(themeId, layerId, classData) {
			var self = this;
			self.internalVars.themes[themeId].layers[layerId].classes.push(classData);
		},
		
		startLegendTree: function() {
			var self = this;
			var mapOptions = gisclient.getMapOptions();
			
			var themesWithLegend = {};
			$.each(self.internalVars.themes, function(themeId, theme) {
				var hasLayers = false;
				var layers = {};
				$.each(theme.layers, function(layerId, layer) {
					var hasClasses = (layer.classes.length > 0);
					if(hasClasses) {
						hasLayers = true;
						layers[layerId] = layer;
					}
				});
				theme.layers = layers;
				if(hasLayers) themesWithLegend[themeId] = theme;
			});
			self.internalVars.themes = themesWithLegend;

			var html = '<ul class="legend">';
			$.each(self.internalVars.themes, function(themeId, theme) {
                html += '<li id="'+theme.domId+'" class="theme">'+theme.title+'<ul>';
                
                $.each(theme.layers, function(layerId, layer) {
					html += '<li id="'+layer.domId+'" class="layer">'+layer.title+'<ul>';

                    var iconOffset=-1;
                    var separator = gisclient.getQueryStringSeparator(layer.layerData.url);
                    var parameters = {
                        PROJECT: layer.layerData.parameters.project,
                        MAP: layer.layerData.parameters.map,
                        SERVICE: 'WMS',
                        VERSION: '1.1.1',
                        REQUEST: 'GETLEGENDGRAPHIC',
                        LAYER: layerId,
                        GCLEGENDTEXT: 0,
                        ICONW: 24,
                        ICONH: 16,
                        FORMAT: 'image/png'
                    };
                    if (layer.layerData.parameters.sld) {
                        $.extend(parameters, {
                            SLD: layer.layerData.parameters.sld
                        });
                    }
                    var wmsGetLegendGraphicUrl = layer.layerData.url+separator+OpenLayers.Util.getParameterString(parameters);
                    
					var layerLegendHtml = '';
                    if(layer.classes.length == 1) {
                        layerLegendHtml = '<li class="classe"><img src="'+ mapOptions.mapsetURL + 'images/pixel.png" style="background-image:url('+ wmsGetLegendGraphicUrl + ');width:24px;height:16px;background-position:0px ' + iconOffset + 'px;" /> '+layer.classes[0].class_title+'</li>';
                        iconOffset-=16;
                    } else if (layer.classes.length > 1) {
                        for(var legendIndex in layer.classes) {
							layerLegendHtml += '<li class="classe"><img src="'+ mapOptions.mapsetURL + 'images/pixel.png" style="background-image:url('+ wmsGetLegendGraphicUrl + ');width:24px;height:16px;background-position:0px ' + iconOffset + 'px;" /> ' + layer.classes[legendIndex].class_title + '</li>'
                            iconOffset-=16;
                        }
                    }
                    html += layerLegendHtml+'</ul></li>';
                });
                html += '</ul></li>';
			});
			html += '</ul>';
			$(self.element).html(html);
		},
		
		showTheme: function() {
		},
		
		showLayer: function() {
		},
		
		hideTheme: function() {
		},
		
		hideLayerGroup: function() {
		},
		
		hideLayer: function() {
		}
    });

    $.extend($.gcComponent.gcLegendTree, {
        version: "3.0.0"
    });
})(jQuery);