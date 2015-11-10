(function($){

    $.widget("gcComponent.viewTable", $.ui.gcComponent, {
		
		options: {
			widgetElementPrefix: 'viewTable'
		},
		
		internalVars: {
			data: {},
			selectedFeature: null
		},
		
        _create: function() {
            var self = this;
			$.ui.gcComponent.prototype._create.apply(self, arguments);
			
			var html = '<table id="view_table"></table>';
			self.element.html(html);
			
            var dialogOptions = $.extend({}, gisclient.options.dialogDefaultPosition, {
                draggable:true,
                width:600,
				title: 'Table',
				height: 400,
                autoOpen:false,
				close: function(event, self) {
					var self  = gisclient.componentObjects.viewTable;
					self._clear();
				}
            });
            self.element.dialog(dialogOptions);
			
        },
		
		checkCount: function(featureType, callbackFunction) {
			var self = this;
			
			var feature = gisclient.componentObjects.gcLayersManager.getQueryableLayer(featureType);
			self.internalVars.selectedFeature = featureType;
			
			var filter = new OpenLayers.Filter.Spatial({
				type: OpenLayers.Filter.Spatial.BBOX,
				property: 'the_geom',
				value: gisclient.map.getExtent()
			});
			var filter_1_1 = new OpenLayers.Format.Filter({version: "1.1.0"});
			var xml = new OpenLayers.Format.XML();
			var filterValue = xml.write(filter_1_1.write(filter));	
			
			var params = {
				PROJECT: gisclient.getProject(),
				MAP: feature.layer.parameters.map,
				SERVICE: 'WFS',
				VERSION: '1.1.0', // required, because RESULTTYPE=HITS is only implemented in WFS >= 1.1.0
				REQUEST: 'GETFEATURE',
				SRS: gisclient.getProjection(),
				TYPENAME: featureType,
				RESULTTYPE: 'HITS',
				FILTER: filterValue
			};
			
			$.ajax({
				url: feature.layer.url,
				type: 'GET',
				data: params,
				dataType: 'xml',
				success: function(data) {
					var count = $(data).children().attr('numberOfFeatures');
					if(count > 250) {
						if(!confirm(OpenLayers.i18n('Your request returned with ${count} results. The visualization of these results may take several minutes. Do you want to continue?', {count:count}))) return;
					}
					callbackFunction(filter);
				},
				error: function() {
					var string = OpenLayers.i18n('Error reading results, the request has been aborted');
					gisclient.componentObjects.errorHandler.show(string);
					return false;
				}
			});
					
		},
		
		openTable: function(featureType) {
			var self = this;
			
			self.checkCount(featureType, self.request);
		},
		
		request: function(filter) {
			var self = gisclient.componentObjects.viewTable;

			var feature = gisclient.componentObjects.gcLayersManager.getQueryableLayer(self.internalVars.selectedFeature);
			
			var filter_1_0 = new OpenLayers.Format.Filter({version: "1.0.0"});
			var xml = new OpenLayers.Format.XML();
			var filterValue = xml.write(filter_1_0.write(filter));	
			
			var params = {
				PROJECT: gisclient.getProject(),
				MAP: feature.layer.parameters.map,
				SERVICE: 'WFS',
				VERSION: '1.0.0',
				REQUEST: 'GETFEATURE',
				SRS: gisclient.getProjection(),
				TYPENAME: self.internalVars.selectedFeature,
				FILTER: filterValue
			};
			
			$.ajax({
				url: feature.layer.url,
				type: 'GET',
				data: params,
				dataType: 'xml',
				success: function(data) {
					var format = new OpenLayers.Format.GML();
					var resp = format.read(data);
					
					if(resp.length < 1) {
						$('table', self.element).html('<tr><td>'+OpenLayers.i18n('No results')+'</td></tr>');
						return;
					}
					
					self.showTable(feature, resp);
				},
				error: function() {
					var string = OpenLayers.i18n('Error reading results, the request has been aborted');
					gisclient.componentObjects.errorHandler.show(string);
					return false;
				}
			});
		},
		
		showTable: function(featureTypeData, features) {
			var self = this;
			
			var tHead = '<tr>';
			$.each(featureTypeData.fields, function(key, col) {
				tHead += '<th data-key="'+key+'">'+col.fieldHeader+'</th>';
			});
			tHead += '<th><a href="#" data-action="zoom_to_features">Zoom</a><a href="#" data-action="unhighlight">'+OpenLayers.i18n('Unhighlight')+'</th></tr>';
			$('table', self.element).html(tHead);
            
            $('table a[data-action="zoom_to_features"]', self.element).addClass('gc_ui-icon-minimized').button({ icons: { primary: "ui-icon-search" }, text:false });
            $('table a[data-action="unhighlight"]', self.element).addClass('gc_ui-icon-minimized').button({ icons: { primary: "ui-icon-cancel" }, text:false });
			
			$.each(features, function(e, row) {
				var tBodyRow = '<tr data-id="'+row.id+'" data-action="highlight_row">';
				$.each(featureTypeData.fields, function(key, col) {
					if(typeof(row.attributes[key]) == 'undefined') {
						tBodyRow += '<td></td>';
						return;
					}
                    var value = (row.attributes[key] == null ? '' : row.attributes[key]);
					tBodyRow += '<td>'+value+'</td>';
				});
				tBodyRow += '<td><a href="#" data-action="zoom_to_feature" data-id="'+row.id+'">Zoom</a> '+
					'<a href="#" data-action="highlight_feature" data-id="'+row.id+'">'+OpenLayers.i18n('Highlight')+'</a></td></tr>';
				$('table', self.element).append(tBodyRow);
				row.featureType = self.internalVars.selectedFeature;
				self.internalVars.data[row.id] = row;
			});
            if(typeof(featureTypeData.title) != 'undefined') {
                self.element.dialog('option', 'title', featureTypeData.title);
            }
			self.element.dialog('open');

			$('table tr[data-action="highlight_row"]', self.element).click(function(event) {
				event.preventDefault();
				
				self.highlightFeature($(this).attr('data-id'), false);
			});
			
			$('table a', self.element).click(function(event) {
				var action = $(this).attr('data-action');
				if(typeof(action) == 'undefined') return;
				var id = $(this).attr('data-id');
				
				switch(action) {
					case 'highlight_feature':
						self.highlightFeature(id, false);
					break;
					case 'zoom_to_feature':
						self.highlightFeature(id, true);
					break;
                    case 'zoom_to_features':
                        self.zoomToFeatures();
                    break;
                    case 'unhighlight':
                        self.unHighlight();
                    break;
				}
			});
			
			$('table a[data-action="highlight_feature"]', self.element).addClass('gc_ui-icon-minimized').button({ icons: { primary: "ui-icon-lightbulb" }, text:false });
			$('table a[data-action="zoom_to_feature"]', self.element).addClass('gc_ui-icon-minimized').button({ icons: { primary: "ui-icon-search" }, text:false });
			$('table a[data-action="show1ntable"]').click(function(event) {
				event.preventDefault();
				gisclient.componentObjects.detailTable.show($(this).attr('data-qtrelation_id'), $(this).attr('data-f_key_value')); 
			});
		},
		
		highlightFeature: function(rowId, zoom) {
			if(typeof(zoom) == 'undefined') zoom = false;
			
			var self = this;
			
			var highlightLayer = gisclient.componentObjects.gcLayersManager.getHighlightLayer();
			highlightLayer.removeAllFeatures();
            $('table tr', self.element).removeClass('selected_row');
			
			var feature = self.internalVars.data[rowId];
			highlightLayer.addFeatures([feature]);
			highlightLayer.redraw();
            $('table tr[data-id="'+rowId+'"]', self.element).addClass('selected_row');
			
			if(zoom) {
				gisclient.zoomToExtent(feature.bounds);
			}
		},
        
        zoomToFeatures: function() {
            var self = this;
            
            var bounds = new OpenLayers.Bounds();
            $.each(self.internalVars.data, function(rowId, feature) {
                bounds.extend(feature.geometry.getBounds());
            });
            
            gisclient.zoomToExtent(bounds);
        },
        
        unHighlight: function() {
            var self = this;
            
            var highlightLayer = gisclient.componentObjects.gcLayersManager.getHighlightLayer();
			highlightLayer.removeAllFeatures();
        },
		
		_clear: function() {
			var self = this;
			
            self.unHighlight();
			
			$('table', self.element).empty();
		}
    });

    $.extend($.gcComponent.viewTable, {
        version: "3.0.0"
    });
})(jQuery);