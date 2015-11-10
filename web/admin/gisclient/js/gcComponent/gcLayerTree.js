(function($){

    $.widget("gcComponent.gcLayerTree", $.ui.gcComponent, {
		
		options: {
			widgetElementPrefix: 'gcLayerTree',
			showMoveLayersButtons: false,
			showLayerTools: false,
			showLayerMetadata: false,
			showViewTable: false,
			defaultThemeOptions: {
				radio: false,
				moveable: false,
				deleteable: false
			}
		},
		
		internalVars: {
			themes: {},
			gcTree: null,
			html: ''
		},
		
        _create: function(){
            var self = this;
			
            self.element
            .addClass( "ui-layertree ui-widget ui-widget-content" )
            .attr({
                role: "layertree"
            });
			
            if(typeof(gisclient.componentsOptions) == 'object' && typeof(gisclient.componentsOptions.gcLayerTree) == 'object') {
                $.extend(self.options, gisclient.componentsOptions.gcLayerTree);
            }
			
            $.ui.gcComponent.prototype._create.apply(self, arguments);
			
        },
		
		addThemeNode: function(id, title, options) {
			var self = this;
			
			if(typeof(options) == 'undefined') options = {};
			
			options = $.extend(true, {}, self.options.defaultThemeOptions, options);
			
			var inputId = self.options.widgetElementPrefix+id;
			var theme = {
				id: id,
				title: title,
				inputId: inputId,
				radio: options.radio,
				moveable: options.moveable,
				deleteable: options.deleteable,
				layers: {}
			};
			self.internalVars.themes[id] = theme;

			return inputId;
		},
		
		removeThemeNode: function(id) {
			var self = this;
			
			delete self.internalVars.themes[id];
		},
		
		removeLayerNode: function(themeId, layerId) {
			var self = this;
			
			delete self.internalVars.themes[themeId].layers[layerId];
		},
		
		addLayerNode: function(themeId, layerId, title, options) {
			var self = this;
			
			if(typeof(options) == 'undefined') options = {};
			var defaultOptions = {
				deleteable: false,
				metadataUrl: null,
				layerTools: true
			};
			options = $.extend({}, defaultOptions, options);
			
			var inputId = self._addWidgetElementPrefix(themeId+'_'+layerId);
			
			var layer = {
				id: layerId,
				title: title,
				inputId: inputId,
				deleteable: options.deleteable,
				layerTools: options.layerTools,
				metadataUrl: options.metadataUrl,
				features: {}
			};
			self.internalVars.themes[themeId].layers[layerId] = layer;
			
			return inputId;
		},
		
		liveAddLayerNode: function(themeId, layerId, title, options) {
			var self = this;
			
			if(typeof(options) == 'undefined') options = {};
			var defaultOptions = {
				deleteable: false,
				layerTools: true
			};
			options = $.extend({}, defaultOptions, options);
			
			var themeInputId = '#'+self.options.widgetElementPrefix+themeId;
			var inputId = self._addWidgetElementPrefix(themeId+'_'+layerId);
			
			var layer = {
				id: layerId,
				title: title,
				inputId: inputId,
				deleteable: options.deleteable,
				layerTools: options.layerTools,
				features: {}
			};
			self.internalVars.themes[themeId].layers[layerId] = layer;
			
			var html = self.getLayerHTML(themeId, layerId, layer);
			
			$(self.element).jstree('create', themeInputId, 'inside', {data:html}, function(){}, true);
			gisclient._trigger('gctreeloaded', null, {});
			
			return inputId;
		},
		
		liveRemoveLayerNode: function(themeId, layerId) {
			var self = this;
			
			var inputId = self._addWidgetElementPrefix(themeId+'_'+layerId);
			$(self.element).jstree('remove', $('#'+inputId).parent());
		},
		
		hideTheme: function(themeId) {
			var self = this;

			$('li[data-theme_id="'+themeId+'"]', self.element).hide();
		},
		
		showTheme: function(themeId) {
			var self = this;

			$('li[data-theme_id="'+themeId+'"]', self.element).show();
		},
		
		addFeatureNode: function(themeId, layerId, feature) {
			var self = this;
			
			var rowId = self._addWidgetElementPrefix(themeId+'_'+layerId+'_'+feature.featureId);
			
			var featureType = {
				id: feature.featureId,
				title: feature.title,
				rowId: rowId
			};
			self.internalVars.themes[themeId].layers[layerId].features[feature.featureId] = featureType;
			
			return rowId;
		},
		
		_buildHTML: function() {
			var self = this;

			var themesOrder = gisclient.componentObjects.gcLayersManager.internalVars.reversedThemes.slice(0);
			themesOrder.reverse();
			
			var html = '<ul>';
			$.each(themesOrder, function(e, themeId) {
				if(typeof(self.internalVars.themes[themeId]) == 'undefined') return;
				var theme = self.internalVars.themes[themeId];
				var inputHTML = '<input type="checkbox" data-role="theme" data-id="'+themeId+'" id="'+theme.inputId+'">';
				if(theme.radio) {
					inputHTML = '<input type="radio" name="'+self._addWidgetElementPrefix('radio')+'" data-role="theme" data-id="'+themeId+'" id="'+theme.inputId+'">';
				} else if(self.options.showMoveLayersButtons && theme.moveable) {
					inputHTML += ' <a href="#" data-action="move" data-direction="up" data-theme_id="'+themeId+'" class="up">'+OpenLayers.i18n('Move up')+'</a> '+
						'<a href="#" data-action="move" data-direction="down" data-theme_id="'+themeId+'" class="down">'+OpenLayers.i18n('Move down')+'</a> ';
				}
				
				html += '<li data-theme_id="'+themeId+'">'+inputHTML+'<label for="'+theme.inputId+'">'+theme.title+' <img src="'+OpenLayers.ImgPath+'ajax-loader.gif" data-input_id="'+theme.inputId+'" style="display:none;" class="layer_loading"></label><ul>';
				$.each(theme.layers, function(layerId, layer) {
					html += '<li>'+self.getLayerHTML(themeId, layerId, layer)+'</li>';
				});
				html += '</ul></li>';
			});
			html += '</ul>';
			self.internalVars.html = html;
		},
		
		getLayerHTML: function(themeId, layerId, layer) {
			var self = this;
			
			var html = '';
			if(self.options.showLayerTools && layer.layerTools) {
				html += '<a href="#" data-action="layer_tools" data-theme_id="'+themeId+'" data-layer_id="'+layerId+'" class="opacity">'+OpenLayers.i18n('Tools')+'</a> ';
			}
			if(layer.deleteable) {
				html += '<a href="#" class="delete" data-action="delete" data-theme_id="'+themeId+'" data-layer_id="'+layerId+'">'+OpenLayers.i18n('Delete')+'</a> ';
			}
			var title = layer.title;
			if(self.options.showLayerMetadata && layer.metadataUrl != null) {
				title += '<a href="'+layer.metadataUrl+'" target="_blank" title="'+OpenLayers.i18n('Info')+'"><img src="'+OpenLayers.ImgPath+'info.gif" border="0" style="width:12px;"></a>';
			}
			html += '<input type="checkbox" data-role="layer" data-id="'+layerId+'" data-parent="'+themeId+'" id="'+layer.inputId+'">' +
				'<label for="'+layer.inputId+'">'+title+' <img src="'+OpenLayers.ImgPath+'ajax-loader.gif" data-input_id="'+layer.inputId+'" style="display:none;" class="layer_loading"></label>';
			if(self.options.showViewTable && !$.isEmptyObject(layer.features)) {
				html += '<ul>';
				$.each(layer.features, function(featureType, feature) {
					html += '<li><a href="#" data-role="feature" data-id="'+featureType+'" data-parent="'+layerId+'" data-action="view_table">'+feature.title+'</a></li>';
				});
				html += '</ul>';
			}
			return html;
		},
		
		startJsTree: function() {
			var self = this;
			self._buildHTML();
			if(self.internalVars.gcTree != null) {
				$(self.element).jstree('destroy');
			}

            self.internalVars.gcTree = $(self.element).bind('loaded.jstree', function() {
				gisclient.componentObjects.gcLayersManager.initiallyCheckTree();
				gisclient.componentObjects.gcLayersManager.checkLayersVisibility();
				gisclient.componentObjects.gcLayersManager.updateLoadingIcons();
				gisclient._trigger('gctreeloaded', null, {});
			}).jstree({
                "themes" : {
                    "theme" : "default",
                    "dots" : true,
                    "icons" : false
                },
                "core" : {
                    "initially_open" : [],
					'html_titles': true
                },
                "html_data" : {
                    "data" : self.internalVars.html
                },
				"plugins" : [ "themes", "html_data", 'crrm' ]
            });


            //Gestione parentale degli input
            self.internalVars.gcTree.delegate('input', 'click', {self: self}, function(event) {
				var item = $(this);
				var uiHash = {
					inputId: item.attr('id'),
					id: item.data('id'),
					role: item.data('role'),
					checked: item.is(':checked')
				};
				if(item.data('role') == 'layer') uiHash.parent = item.data('parent');
				self._trigger("change", event, uiHash);
			});
			
			self.internalVars.gcTree.delegate('a[data-action="view_table"]', 'click', {self: self}, function(event) {
				event.preventDefault();
				
				gisclient.componentObjects.viewTable.openTable($(this).attr('data-id'));
			});
			
			if(self.options.showMoveLayersButtons) {
				self.internalVars.gcTree.delegate('a[data-action="move"]', 'click', {self: self}, function(event) {
					event.preventDefault();

					gisclient.componentObjects.gcLayersManager.moveTheme($(this).attr('data-direction'), $(this).attr('data-theme_id'));
				});
			}
			
			if(self.options.showLayerTools) {
				self.internalVars.gcTree.delegate('a[data-action="layer_tools"]', 'click', {self: self}, function(event) {
					event.preventDefault();
					
					gisclient.componentObjects.layerTools.showDialog($(this).attr('data-theme_id'), $(this).attr('data-layer_id'), $(this).offset());
				});
			}
			
			self.internalVars.gcTree.delegate('a[data-action="delete"]', 'click', {self: self}, function(event) {
				event.preventDefault();
				
				gisclient.componentObjects.gcLayersManager.removeLayer($(this).attr('data-theme_id'), $(this).attr('data-layer_id'));
			});
		},
		
		moveTheme: function(direction, themeId) {
			var self = this;
			
			if(direction == 'up') {
				$(self.element).jstree('move_node', $('li[data-theme_id="'+themeId+'"]'), $('li[data-theme_id="'+themeId+'"]').prev(), 'before', false);
			} else if(direction == 'down') {
				$(self.element).jstree('move_node', $('li[data-theme_id="'+themeId+'"]'), $('li[data-theme_id="'+themeId+'"]').next(), 'after', false);
			}
			return;			
		}
    });

    $.extend($.gcComponent.gcLayerTree, {
        version: "3.0.0"
    });
})(jQuery);