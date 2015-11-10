/*
 */


(function($, undefined) {


    $.widget("gcTool.selectFeatures", $.ui.gcTool, {

        widgetEventPrefix: "selectFeatures",

        options: {
            label: OpenLayers.i18n('Select features'),
            icons: {
                primary: 'select_features' // TODO: choose better name
            },
            text: false,
            gisclient: null,
            control: null,
            queryLayers: {}, // int obj to store the queryable layers data
            featureType: null,
            filter: null,
            showDialog: null,
            limitVectorFeatures: 100,
            selectFeaturesLayer: null,
            displaySettingsId: null // if null, settings will be display in a dialog, otherwise it must be a DOM element id
        },
		
        _create: function() {
            var self = this;
			
            $.ui.gcTool.prototype._create.apply(self, arguments);
			
            self.options.styleMap = new OpenLayers.StyleMap({
                strokeColor: "red",
                strokeWidth: 2
            });
			
            self.options.queryLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers();
            if(self.options.queryLayers == null) return;
			
            var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();

            self.options.control = new OpenLayers.Control.SelectFeature(selectionLayer);
            gisclient.map.addControl(self.options.control);
            self.options.control.events.register('featurehighlighted',self,self._handleSelection);
			
            if(!(self.options.featureType in self.options.queryLayers)) {
                var html = '<div id="selectfeatures_settings">'+OpenLayers.i18n('Features layer')+'<br /><select id="selectfeatures_layer"><option value="0">'+OpenLayers.i18n('Select')+'</option>';
                $.each(self.options.queryLayers, function(featureId, layer) {
                    html += '<option value="'+featureId+'">'+layer.title+'</option>';
                });
                html += '</select><br /><br /><button name="reload">'+OpenLayers.i18n('Reload')+'</button></div>';
				
                if(self.options.displaySettingsId == null) {
                    $('body').append(html);
                    var dialogOptions = $.extend(gisclient.options.dialogDefaultPosition, {draggable:true,title:OpenLayers.i18n('Selection options'),autoOpen:false});
                    $('#selectfeatures_settings').dialog(dialogOptions);
                } else {
                    $('#'+self.options.displaySettingsId).html(html).hide();
                }
                $('#selectfeatures_layer').change(function() {
                    if($(this).val() != '0') {
                        self.options.featureType = $(this).val();
                        self._getFeatures(self.options.featureType, null);
                    }
                });
                $('#selectfeatures_settings button[name="reload"]').click(function() {
                    self._getFeatures(self.options.featureType, self.options.filter);
                });
				
                self.options.showSettings = true;
            } else self.options.showSettings = false;
        },
		
        limitFeatures: function(featureTypes) {
            var self = this;
            var newQueryLayers = {};
            $.each(featureTypes, function(e, featureType) {
                if(featureType in self.options.queryLayers) {
                    newQueryLayers[featureType] = self.options.queryLayers[featureType];
                }
            });

            $.each(self.options.queryLayers, function(featureType, layer) {
                if(!(featureType in newQueryLayers)) {
                    $('#selectfeatures_layer option[value="'+featureType+'"]').remove();
                }
            });
        },
		
        _click: function(event) {
            var self = event.data.self;
			
            $.ui.gcTool.prototype._click.apply(self, arguments);
			
            if(self.options.showSettings) {
                if(self.options.displaySettingsId == null && !$('#selectfeatures_settings').dialog('isOpen')) $('#selectfeatures_settings').dialog('open');
                if(self.options.displaySettingsId != null) $('#'+self.options.displaySettingsId).show();
            } else {
                self._getFeatures(self.options.featureType, self.options.filter);
            }
		
        },
		
        _getFeatures: function(featureType, filter) {
            var self = this;
            var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
			
            if(selectionLayer.features.length > 0) {
                selectionLayer.removeAllFeatures();
            }
			
            gisclient.componentObjects.loadingHandler.show();
			
            var queryLayer = self.options.queryLayers[featureType];
			
            var bounds = gisclient.map.getExtent();

            var spatialFilter = new OpenLayers.Filter.Comparison({
                type: OpenLayers.Filter.Spatial.BBOX,
                property: featureType,
                value: bounds
            });
			
            var filters;
            if(filter != null) {
                filters = new OpenLayers.Filter.Logical({
                    type: OpenLayers.Filter.Logical.AND,
                    filters: [spatialFilter,filter]
                });
            } else filters = spatialFilter;
			
            var filter_1_1 = new OpenLayers.Format.Filter({version: "1.1.0"});
            var xml = new OpenLayers.Format.XML();
            var filterValue = xml.write(filter_1_1.write(filters));

            var params = {
                PROJECT: gisclient.getProject(),
                MAP: queryLayer.layer.parameters.map,
                SERVICE: 'WFS',
                VERSION: '1.1.0', // required, because RESULTTYPE=HITS is only implemented in WFS >= 1.1.0
                REQUEST: 'GETFEATURE',
                SRS: gisclient.getProjection(),
                TYPENAME: featureType,
                FILTER: filterValue,
                RESULTTYPE: 'HITS'
            };
			
            $.ajax({
                url: queryLayer.layer.url,
                type: 'GET',
                dataType: 'xml',
                data: params,
                success: function(response, status, jqXHR) {
                    var count = parseInt($(response).children().attr('numberOfFeatures'));
                    if(count > 0) {
                        if(count > self.options.limitVectorFeatures) {
                            var string = OpenLayers.i18n('Your request returned with ${count} results. The visualization of these results may take several minutes. Do you want to continue?', {count:count});
                            if(!confirm(string)) {
                                gisclient.componentObjects.loadingHandler.hide();
                                return false;
                            }
                        }

                        self._downloadFeatures(featureType, filterValue);
						
                    } else {
                        gisclient.componentObjects.errorHandler.show(OpenLayers.i18n('No results'));
                    }
                },
                error: function(response, status, jqXHR) {
                    var string = OpenLayers.i18n('Error counting results, the request has been aborted');
                    gisclient.componentObjects.errorHandler.show(string);
                    gisclient.log(jqXHR.responseText);
                    return false;
                }
            });
        },
		
        _downloadFeatures: function(featureType, filterValue) {
            var self = this;
            var queryLayer = self.options.queryLayers[featureType];
            var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
			
            var params = {
                PROJECT: gisclient.getProject(),
                MAP: queryLayer.layer.parameters.map,
                SERVICE: 'WFS',
                VERSION: '1.0.0',
                REQUEST: 'GETFEATURE',
                SRS: gisclient.getProjection(),
                TYPENAME: featureType,
                FILTER: filterValue
            };
			
            $.ajax({
                url: queryLayer.layer.url,
                type: 'GET',
                dataType: 'xml',
                data: params,
                success: function(response, status, jqXHR) {
                    var format = new OpenLayers.Format.GML();
                    var features = format.read(response);
					
                    selectionLayer.addFeatures(features);
                    gisclient.componentObjects.loadingHandler.hide();
                },
                error: function(response, status, jqXHR) {
                    gisclient.log(jqXHR.responseText);
                    return false;
                }
            });
			
        },
		
        _handleSelection: function(object) {
            var self = this;
            var uiHash = self._getUIHash();
            object.feature.attributes.selectedLayer = self.options.featureType;
            uiHash.feature = object.feature;
			
            self._trigger( "handleFeature", null, uiHash);
        },
		
        _deactivate: function() {
            var self = this;
            // destroy the layer
            if(self.options.queryLayers == null) return;
			
            //var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
            //selectionLayer.removeAllFeatures();
			
            // close the tooltip settings dialog
            if(self.options.displaySettingsId == null && $('#selectfeatures_settings').dialog('isOpen')) $('#selectfeatures_settings').dialog('close');
            if(self.options.displaySettingsId != null) $('#'+self.options.displaySettingsId).hide();
        }
		
    });

    $.extend($.gcTool.selectFeatures, {
        version: "3.0.0"
    });
})(jQuery);
