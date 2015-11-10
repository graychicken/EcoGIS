(function($){

    $.widget("gcComponent.layerTools", $.ui.gcComponent, {
		
		options: {
			widgetElementPrefix: 'layerTools',
			bufferServiceUrl: null
		},
		
		internalVars: {
			selectedLayer: null,
			selectedOpacity: null
		},
		
        _create: function(){
            var self = this;
			
			var html = '<span data-role="layer_title"></span><br><br><div data-role="opacity">'+OpenLayers.i18n('Opacity')+': <span data-role="layer_opacity_value"></span><div data-role="layer_opacity_slider"></div></div>'+
				'<div data-role="buffer" style="display:none;"><hr>'+OpenLayers.i18n('Buffer')+' <input type="text" name="buffer_value" size="3" style="width:50px;">(m) <button name="apply_buffer">'+OpenLayers.i18n('Apply')+'</button></div>';
			
			$(self.element).html(html);
			
			$('div[data-role="layer_opacity_slider"]', self.element).slider({
				change: self.opacityChange,
				self: self
			});
			
			$('button[name="apply_buffer"]', self.element).click(function(event) {
				event.preventDefault();
				
				self.applyBuffer();
			});
			
            var dialogOptions = $.extend({}, {
                draggable:true,
				title: OpenLayers.i18n('Opacity'),
                width: 250,
				height: 'auto',
                autoOpen:false,
				close: function(event, self) {
				}
            });
			
			$(self.element).dialog(dialogOptions);
			
			if(self.options.bufferServiceUrl == null) self.options.bufferServiceUrl = gisclient.getMapOptions().bufferServiceUrl;
			
            $.ui.gcComponent.prototype._create.apply(self, arguments);
			
        },
		
		opacityChange: function(event, ui) {
			var self = gisclient.componentObjects.layerTools;
			
			$('span[data-role="layer_opacity_value"]').html(ui.value);
			self.internalVars.selectedOpacity = ui.value;
			self.internalVars.selectedLayer.olLayer.setOpacity(ui.value/100);
		},
		
		applyBuffer: function() {
			var self = this;
			
			var buffer = $('input[name="buffer_value"]', self.element).val();
			$('input[name="buffer_value"]', self.element).val('');
			if(buffer == '') alert(OpenLayers.i18n('Invalid buffer'));
			
			var format = new OpenLayers.Format.WKT();
			var features = format.write(self.internalVars.selectedLayer.olLayer.features);
			
			gisclient.componentObjects.loadingHandler.show();
			
			$.ajax({
				url: self.options.bufferServiceUrl,
				type: 'POST',
				dataType: 'json',
				data: {features: features, projection: gisclient.getProjection(), buffer: buffer},
				success: function(response) {
					gisclient.componentObjects.loadingHandler.hide();
					if(typeof(response) != 'object' || typeof(response.result) == 'undefined' || response.result != 'ok') {
						return alert(OpenLayers.i18n('Error'));
					}
					
					self.internalVars.selectedLayer.olLayer.removeAllFeatures();
					var features = format.read(response.geometries);
					self.internalVars.selectedLayer.olLayer.addFeatures(features);
				},
				error: function() {
					gisclient.componentObjects.loadingHandler.hide();
					return alert(OpenLayers.i18n('Error'));
				}
			});
			
		},
		
		showDialog: function(themeId, layerId, position) {
			var self = this;

			self.internalVars.selectedLayer = gisclient.componentObjects.gcLayersManager.getLayer(themeId, layerId);
			if(gisclient.componentObjects.gcLayersManager.getTheme(themeId).isVector) {
				$('div[data-role="buffer"]').show();
			}
			
			$('span[data-role="layer_title"]', self.element).html(self.internalVars.selectedLayer.title);
			
			var currentOpacity = 1;
			if(typeof(self.internalVars.selectedLayer.olLayer.opacity) != 'undefined' && self.internalVars.selectedLayer.olLayer.opacity != null) currentOpacity = self.internalVars.selectedLayer.olLayer.opacity;
			currentOpacity = Math.round(currentOpacity * 100);
			
			$('div[data-role="layer_opacity_slider"]', self.element).slider('value', currentOpacity);
			
			var dialogPosition = [position.left-50, position.top-100];

			$(self.element).dialog('option', 'position', dialogPosition).dialog('open');
			
		}
    });

    $.extend($.gcComponent.layerTools, {
        version: "3.0.0"
    });
})(jQuery);