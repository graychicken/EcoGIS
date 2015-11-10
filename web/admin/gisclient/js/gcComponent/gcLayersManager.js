var WMS_LAYER_TYPE = 1;
var GMAP2_LAYER_TYPE = 2;
var VMAP_LAYER_TYPE = 3;
var YMAP_LAYER_TYPE = 4;
var OSM_LAYER_TYPE = 5;
var TMS_LAYER_TYPE = 6;
var GMAP3_LAYER_TYPE = 7;
var BING_LAYER_TYPE = 8;
var WMTS_LAYER_TYPE = 9;

(function($) {


    $.widget("gcComponent.gcLayersManager", $.ui.gcComponent, {

        widgetEventPrefix: "gcLayersManager",

        options: {
            layerTree: 'treeList',
            layerSwitcher: false,
            referenceMap: 'refMapContainer',
            legend: 'legendList',
            editingLayer: true,
            selectionLayer: true,
            redlineLayer: true,
            redlineColor: null,
            defaultFeatureFilters: null,
            selectionLayerStyleMap: null,
            highlightLayerStyleMap: null,
            showSelectionLayer: true,
            addBgColorLayer: false,
            dataTypesMap: {
                PointPropertyType: 'point',
                MultiPointPropertyType: 'point',
                LineStringPropertyType: 'line',
                MultiLineStringPropertyType: 'line',
                PolygonPropertyType: 'polygon',
                MultiPolygonPropertyType: 'polygon'
            },
            customFeatureStyle: {
            }
        },

        internalVars: {
            themes: {},
            editingLayer: null,
            selectionLayer: null,
            highlightLayer: null,
            redlineLayer: null,
            redlineServiceUrl: null,
            layersToLoad: [],
            loadingLayers: {},
            checkForFirstLoading: true,
            referenceMapLayers: [],
            reversedThemes: [],
            reversedLayers: {},
            queryableLayers: {},
            editableLayers: {},
            additionalLayers: {},
            featureLinks: {}
        },

        _create: function() {
            var self = this;
            $.ui.gcComponent.prototype._create.apply(self, arguments);

            var mapsetData = gisclient.options.mapsetData;
            var featureLinks = typeof(gisclient.options.externalFeatureLink) == 'object' ? gisclient.options.externalFeatureLink : {};
            
            if(typeof(mapsetData.bg_color) != 'undefined') {
                self.options.addBgColorLayer = true;
            }

            if(self.options.selectionLayer) {
                self.internalVars.themes.gc_selectionLayer = {
                    title: OpenLayers.i18n('Selection layer'),
                    radio: false,
                    singleLayer: false,
                    isVector: true,
                    layers: {
                        selectionLayer: {
                            id: 'selectionLayer',
                            isActive: true,
                            olLayer: self._initSelectionLayer(),
                            options: {
                                visibility: true
                            },
                            title: OpenLayers.i18n('Selection layer')
                        }
                    },
                    id: 'gc_selectionLayer'
                };
                self.internalVars.reversedThemes.push('gc_selectionLayer');
                self.internalVars.reversedLayers['gc_selectionLayer'] = ['selectionLayer'];
            }
            if(self.options.redlineLayer) {
                self.internalVars.themes.gc_redlineLayer = {
                    title: OpenLayers.i18n('Redline'),
                    themeId: 'redline',
                    singleLayer: false,
                    radio: false,
                    id: 'gc_redlineLayer',
                    layers: {}
                };
                self.internalVars.reversedThemes.push('gc_redlineLayer');
                self.internalVars.reversedLayers['gc_redlineLayer'] = [];
            }

            $.each(mapsetData.theme, function(themeId, theme) {
                self.internalVars.reversedThemes.push(themeId);
                self.internalVars.reversedLayers[themeId] = [];

                self.internalVars.themes[themeId] = {
                    title: null,
                    radio: false,
                    singleLayer: ($.inArray(themeId, gisclient.getMapOptions().groupedThemes) > -1),
                    layers: {},
                    id: themeId
                };

                $.each(theme, function(propertyKey, propertyValue) {
                    if(propertyKey == 'title') {
                        self.internalVars.themes[themeId].title = propertyValue;
                        return;
                    }
                    if(propertyKey == 'radio') {
                        if(propertyValue == 1) self.internalVars.themes[themeId].radio = true;
                        return; 
                    }
                    if(typeof(propertyValue) != 'object') {
                        gisclient.log('Unexpected theme content in init JSON string');
                        return;
                    }
                    var layer = propertyValue;
                    var layerId = propertyKey;
                    layer.id = layerId;
                    layer.isActive = false;

                    self.internalVars.reversedLayers[themeId].push(layerId);

                    layer.userHasActivated = false;
                    layer.themeId = themeId;
                    self.internalVars.themes[themeId].layers[propertyKey] = layer;
                    if(typeof(layer.options.featureTypes) != 'object') return;
                    layer.geometryType = null;
                    $.each(layer.options.featureTypes, function(e, feature) {
                        if(typeof(feature.properties) != 'object') return;
                        var featureId = feature.typeName;
                        var showGeometry = (typeof(feature.hide_vector_geom) == 'undefined' || feature.hide_vector_geom != 1);
                        var fields = {};
                        var editableFields = {};
                        var count = 0;
                        var countEditable = 0;
                        var primaryKey = null;
                        $.each(feature.properties, function(f, field) {
                            if(typeof(self.options.dataTypesMap[field.type]) != 'undefined') {
                                layer.geometryType = self.options.dataTypesMap[field.type];
                                layer.isMulti = (field.type.substr(0,5) == 'Multi');
                                return;
                            }
                            field.fieldHeader = field.header;
                            if(field.resultType != 4) {
                                count += 1;
                                field.fieldHeader = field.header;
                                fields[field.name] = field;
                            }
                            if(field.editable == 1 || field.isPrimaryKey == 1) {
                                if(field.isPrimaryKey != 1) countEditable += 1;
                                if(field.isPrimaryKey == 1) primaryKey = field.name;
                                editableFields[field.name] = field;
                            }
                        });
                        var defaultFilters = null;
                        if(self.options.defaultFeatureFilters !== null) {
                            defaultFilters = (typeof(self.options.defaultFeatureFilters[featureId]) == 'undefined') ? null : self.options.defaultFeatureFilters[featureId];
                        }
                        var queryLayer = {
                            showGeometry: showGeometry,
                            themeId: themeId,
                            layerId: layerId,
                            featureId: featureId,
                            properties: feature.properties,
                            relation1n: typeof(feature.relation1n) != 'undefined' ? feature.relation1n : false,
                            fields: fields,
                            editableFields: editableFields,
                            towsFeatureType: typeof(feature.towsFeatureType) != 'undefined' ? feature.towsFeatureType : null,
                            towsUrl: gisclient.getMapOptions().mapsetURL+'services/tinyows/'+gisclient.getProject()+'/'+featureId+'/?',
                            searchable: (typeof(feature.searchable) != 'undefined' && feature.searchable == 0) ? false : true,
                            fieldsCount: count,
                            title: feature.title,
                            hidden: (typeof(feature.hidden) != 'undefined' && feature.hidden == 1) ? 1 : 0,
                            layer: layer,
                            groupTitle: layer.title,
                            defaultFilters: defaultFilters
                        };
                        self.internalVars.queryableLayers[featureId] = queryLayer;
                        if(countEditable > 0 && layer.geometryType != null) {
                            queryLayer.geometryType = layer.geometryType;
                            self.internalVars.editableLayers[featureId] = queryLayer;
                        }

                        if(typeof(featureLinks[featureId]) != 'undefined') {
                            self.internalVars.featureLinks[featureId] = featureLinks[featureId];
                        } else if(typeof(feature.link) != 'undefined' && feature.link != null && primaryKey != null) {
                            var linkUrl = feature.link[0].url;
                            self.internalVars.featureLinks[featureId] = {
                                objectIdField: primaryKey,
                                objectLinkType: 'popup',
                                objectLink: linkUrl,
                                objectLinkWidth: feature.link[0].width || null,
                                objectLinkHeight: feature.link[0].height || null
                            };
                        }
                    });
                });
                self.internalVars.reversedLayers[themeId].reverse();
                if(self.internalVars.reversedLayers[themeId].singleLayer) {
                    self.internalVars.reversedLayers[themeId] = ['gc_single_'+themeId];
                }
            });
            self.internalVars.reversedThemes.reverse();

            var radioThemes = self._getRadioThemes(); // set radio to false if there's only one radio theme
            if(radioThemes.length == 1) {
                self.internalVars.themes[radioThemes[0]].radio = false;
            }

            self._initLayers();

            gisclient.map.zoomToMaxExtent({
                restricted:true
            });

            if(self.options.layerTree) self._initTree();
            else if(self.options.layerSwitcher) self._initLayerSwitcher();

            if(self.options.legend) self._initLegend();
            if(self.options.referenceMap) self._initReferenceMap();
            if(self.options.editingLayer) self._initEditingLayer();
            if(self.options.redlineLayer) self._initRedlineLayer();

            if(self.options.layerTree) gisclient.map.events.register('zoomend',self,self.checkLayersVisibility);
        },

        _initLayers: function() {
            var self = this;

            //var bounds = OpenLayers.Bounds.fromArray(gisclient.options.mapsetData.maxExtent);
            var bounds = gisclient.map.maxExtent;
            var baseLayer = new OpenLayers.Layer.Image('BASE_LAYER', gisclient.options.mapsetURL +'images/pixel.png', bounds, new OpenLayers.Size(1,1), {
                isBaseLayer: true,
                resolutions: gisclient.options.mapsetData.resolutions,
                displayInLayerSwitcher: false
            });
            gisclient.map.addLayer(baseLayer);
            
            if(self.options.addBgColorLayer) {
                var bounds = OpenLayers.Bounds.fromArray(gisclient.options.mapsetData.maxExtent);
                var bgLayer = new OpenLayers.Layer.Image('BASE_LAYER', gisclient.options.mapsetURL +'images/bg_pixel.png', bounds, new OpenLayers.Size(1,1), {
                    isBaseLayer: false,
                    resolutions: gisclient.options.mapsetData.resolutions,
                    displayInLayerSwitcher: false,
                    displayOutsideMaxExtent: true
                });
                gisclient.map.addLayer(bgLayer);
            }

            $.each(self.internalVars.themes, function(themeId, theme) {
                var groupedLayerData = {};
                var minScale = 0;
                var isVisible = false;
                $.each(theme.layers, function(layerId, layerData) {
                    if(theme.isVector) return;
                    if(theme.singleLayer) {
                        if(typeof(layerData.options.minScale) != 'undefined' && minScale != null) {
                            if(layerData.options.minScale > minScale) minScale = layerData.options.minScale;
                            delete layerData.options.minScale;
                        } else minScale = null;
                        
                        if(typeof(layerData.options.visibility) == 'undefined' || layerData.options.visibility == true) isVisible = true;

                        if($.isEmptyObject(groupedLayerData)) {
                            groupedLayerData = $.extend(true, {}, layerData);
                        } else {
                            $.each(layerData.parameters.layers, function(e, layerName) {
                                if(typeof(layerData.options.visibility) != 'undefined' && !layerData.options.visibility) return;
                                groupedLayerData.parameters.layers.push(layerName);
                            });
                        }
                    } else {
                        //layerData.options.tileLoadingDelay = 1000;
                        self.internalVars.themes[themeId].layers[layerId].olLayer = self._createLayer(layerData);
                    }
                });
                if(theme.singleLayer) {
                    groupedLayerData.parameters.layers.reverse();
                    if(minScale != 0 && minScale != null) groupedLayerData.options.minScale = minScale;
                    if(!isVisible) groupedLayerData.options.visibility = false;
                    else groupedLayerData.options.visibility = true;
                    self.internalVars.themes[themeId].olLayer = self._createLayer(groupedLayerData);
                }
            });
        },

        _createLayer: function(layerData) {
            var self = this;
            var olLayer;

            switch(layerData.type) {
                case WMS_LAYER_TYPE:
                    if(typeof(GISCLIENT_DEBUG) == 'undefined') {
                        layerData.parameters.exceptions = 'BLANK';
                    }
                    layerData.parameters.lang = OpenLayers.Lang.getCode();

                    if(typeof(self.internalVars.loadingLayers[layerData.themeId]) == 'undefined') {
                        if(self.internalVars.themes[layerData.themeId].singleLayer) {
                            self.internalVars.loadingLayers[layerData.themeId] = false;
                        } else {
                            self.internalVars.loadingLayers[layerData.themeId] = {};
                        }
                    }
                    if(!self.internalVars.themes[layerData.themeId].singleLayer) {
                        self.internalVars.loadingLayers[layerData.themeId][layerData.id] = false;
                    }
                    layerData.options.noMagic = true;
                    layerData.options.isBaseLayer = false;
                    olLayer = new OpenLayers.Layer.WMS(layerData.title,layerData.url,layerData.parameters,layerData.options);
                    olLayer.events.register('loadend', self, self._layerLoaded);
                    olLayer.events.register('loadstart', self, self._layerStartLoading);
                    self.internalVars.layersToLoad.push(olLayer.gc_id);
                    break;
                case TMS_LAYER_TYPE:
                    if(typeof(self.internalVars.loadingLayers[layerData.themeId]) == 'undefined') {
                        if(self.internalVars.themes[layerData.themeId].singleLayer) {
                            self.internalVars.loadingLayers[layerData.themeId] = false;
                        } else {
                            self.internalVars.loadingLayers[layerData.themeId] = {};
                        }
                    }
                    if(!self.internalVars.themes[layerData.themeId].singleLayer) {
                        self.internalVars.loadingLayers[layerData.themeId][layerData.id] = false;
                    }
                    layerData.options.isBaseLayer = false;
                    var tileOrigin;
                    if(layerData.options.tileOrigin) {
                        var coordinates = layerData.options.tileOrigin.split(' ');
                        tileOrigin = new OpenLayers.LonLat(coordinates[0], coordinates[1]);
                    }
                    var options = {
                        'layername': layerData.options.layers,
                        'type': layerData.options.type,
                        'isBaseLayer': false,
                        visibility: layerData.options.visibility,
                        opacity: layerData.options.opacity,
                        serverResolutions: layerData.options.serverResolutions,
                        tileOrigin: tileOrigin
                    };
                    olLayer = new OpenLayers.Layer.TMS(layerData.title, layerData.url, options);
                    olLayer.events.register('loadend', self, self._layerLoaded);
                    olLayer.events.register('loadstart', self, self._layerStartLoading);
                    self.internalVars.layersToLoad.push(olLayer.gc_id);
                    break;
                case WMTS_LAYER_TYPE:
                    if(typeof(self.internalVars.loadingLayers[layerData.themeId]) == 'undefined') {
                        if(self.internalVars.themes[layerData.themeId].singleLayer) {
                            self.internalVars.loadingLayers[layerData.themeId] = false;
                        } else {
                            self.internalVars.loadingLayers[layerData.themeId] = {};
                        }
                    }
                    if(!self.internalVars.themes[layerData.themeId].singleLayer) {
                        self.internalVars.loadingLayers[layerData.themeId][layerData.id] = false;
                    }
                    layerData.options.isBaseLayer = false;
                    var tileOrigin;
                    if(layerData.options.tileOrigin) {
                        var coordinates = layerData.options.tileOrigin.split(' ');
                        tileOrigin = new OpenLayers.LonLat(coordinates[0], coordinates[1]);
                    }
                    olLayer = new OpenLayers.Layer.WMTS({
                        name: layerData.title,
                        url: layerData.url,
                        layer: layerData.options.layers,
                        projectName: gisclient.getProject(),
                        layerName: layerData.id,
                        matrixSet: layerData.options.matrixSet,
                        requestEncoding: "REST", // possible values: REST or KVP, if KVP required modify gisclient-author
                        style: layerData.options.style,
                        isBaseLayer: false,
                        zoomOffset: layerData.options.zoomOffset,
                        tileOrigin: tileOrigin,
                        visibility: layerData.options.visibility
                    });
                    olLayer.events.register('loadend', self, self._layerLoaded);
                    olLayer.events.register('loadstart', self, self._layerStartLoading);
                    self.internalVars.layersToLoad.push(olLayer.gc_id);
                    break;
                default:
                    gisclient.log(layerData);
                    alert('NOT IMPLEMENTED LAYER TYPE FOR '+layerData.title);
                    break;
            }
            
            if(layerData.overview == 1/* && (typeof(layerData.hide) == 'undefined' || layerData.hide == 0)*/) {
                var refLayer = olLayer.clone();
                refLayer.setVisibility(true);
                self.internalVars.referenceMapLayers.push(refLayer);
            }

            olLayer.is_gc_layer = true;

            return olLayer;
        },

        _layerLoaded: function(data) {
            var self = this;

            if(self.internalVars.checkForFirstLoading) {
                var pos = $.inArray(data.object.gc_id, self.internalVars.layersToLoad);
                self.internalVars.layersToLoad.splice(pos, 1);
                if(self.internalVars.layersToLoad.length == 0) {
                    gisclient._trigger('gclayersloaded', null, {});
                    self.internalVars.checkForFirstLoading = false;
                }
            }

            self._updateLayerLoadingState(data.object, false);
        },

        _layerStartLoading: function(data) {
            var self = this;

            self._updateLayerLoadingState(data.object, true);
        },

        _updateLayerLoadingState: function(layer, isLoading) {
            var self = this;

            var layer = self.getLayerByGcId(layer.gc_id);
            if(layer == null || typeof(layer.themeId) == 'undefined') return;

            if(layer.isTheme) {
                self.internalVars.loadingLayers[layer.themeId] = isLoading;
            } else {
                self.internalVars.loadingLayers[layer.themeId][layer.id] = isLoading;
            }
            self.updateLoadingIcons();
        },

        updateLoadingIcons: function() {
            var self = this;

            $.each(self.internalVars.loadingLayers, function(themeId, layers) {
                var themeIsLoading = false;
                if(typeof(layers) == 'object') {
                    $.each(layers, function(layerId, isLoading) {
                        if(isLoading) {
                            themeIsLoading = true;
                            self.showLayerLoading(themeId, layerId);
                        } else {
                            self.hideLayerLoading(themeId, layerId);
                        }
                    });
                } else {
                    themeIsLoading = layers;
                }
                if(themeIsLoading) self.showThemeLoading(themeId);
                else self.hideThemeLoading(themeId);
            });
        },

        showLayerLoading: function(themeId, layerId) {
            var self = this;

            var treeId = self.internalVars.themes[themeId].layers[layerId].treeId;
            $('img[data-input_id="'+treeId+'"]').show();
        },

        hideLayerLoading: function(themeId, layerId) {
            var self = this;

            var treeId = self.internalVars.themes[themeId].layers[layerId].treeId;
            $('img[data-input_id="'+treeId+'"]').hide();
        },

        showThemeLoading: function(themeId) {
            var self = this;

            var treeId = self.internalVars.themes[themeId].treeId;
            $('img[data-input_id="'+treeId+'"]').show();
        },

        hideThemeLoading: function(themeId) {
            var self = this;

            var treeId = self.internalVars.themes[themeId].treeId;
            $('img[data-input_id="'+treeId+'"]').hide();
        },

        loadLayers: function() {
            var self = this;

            $.each(self.internalVars.reversedThemes, function(e, themeId) {
                if(self.internalVars.themes[themeId].singleLayer) {
                    gisclient.map.addLayer(self.internalVars.themes[themeId].olLayer);
                    return;
                }
                $.each(self.internalVars.reversedLayers[themeId], function(i, layerId) {
                    var layer = self.internalVars.themes[themeId].layers[layerId];
                    //if(typeof(layer.hide) != 'undefined' && layer.hide == 1) return;
                    gisclient.map.addLayer(layer.olLayer);
                });
            });

            if(self.options.editingLayer) gisclient.map.addLayer(self.internalVars.editingLayer);
            //if(self.options.selectionLayer) gisclient.map.addLayer(self.internalVars.selectionLayer);
            if(self.options.redlineLayer) gisclient.map.addLayer(self.internalVars.redlineLayer);
        },

        _initReferenceMap: function() {
            var self = this;

            var refWidth = 250;
            var refHeight = 150;
            if (typeof gisclient.options.componentsOptions.referenceMap == 'object') {
                var refWidth = gisclient.options.componentsOptions.referenceMap.width || 250;
                var refHeight = gisclient.options.componentsOptions.referenceMap.height || 150;
            }
            var opt = {
                layers: self.internalVars.referenceMapLayers.reverse(),
                mapOptions: {
                    units: "m",
                    projection: new OpenLayers.Projection(gisclient.getProjection()),
                    maxExtent: new OpenLayers.Bounds.fromArray(gisclient.options.mapsetData.restrictedExtent),
                    resolutions: gisclient.options.mapsetData.resolutions,
                    size: new OpenLayers.Size(refWidth, refHeight)
                }
            }
            if (typeof gisclient.options.componentsOptions.referenceMap == 'object') {
                $.extend(true, opt, gisclient.options.componentsOptions.referenceMap);
            }   
            $('#'+self.options.referenceMap).referenceMap(opt);
        },

        _initTree: function() {
            var self = this;

            $('#'+self.options.layerTree).gcLayerTree({
                change: function(event, ui) {
                    self._treeClick(event, ui);
                }
            });
            var gcLayerTree = gisclient.componentObjects.gcLayerTree;

            $.each(self.internalVars.themes, function(themeId, theme) {
                var themeOptions = {};
                if(theme.radio) themeOptions.radio = theme.radio;
                if(theme.isVector) themeOptions.moveable = false;
                self.internalVars.themes[themeId].treeId = gcLayerTree.addThemeNode(themeId, theme.title, themeOptions);
                var hasLayergroups = false;
                $.each(theme.layers, function(layerId, layerData) {
                    var layerOptions = {};
                    if(theme.isVector) themeOptions.layerTools = true;
                    if(typeof(layerData.hide) != 'undefined' && layerData.hide == 1) return;
                    hasLayergroups = true;
                    var layerOptions = {};
                    if(typeof(layerData.options.metadataUrl) != 'undefined') layerOptions.metadataUrl = layerData.options.metadataUrl;
                    self.internalVars.themes[themeId].layers[layerId].treeId = gcLayerTree.addLayerNode(themeId, layerId, layerData.title, layerOptions);
                });
                if(!hasLayergroups && themeId != 'gc_redlineLayer') gcLayerTree.removeThemeNode(themeId);
            });

            $.each(self.getQueryableLayers(), function(featureType, feature) {
                if(typeof(feature.layer.hide) != 'undefined' && feature.layer.hide == 1) return;
                gcLayerTree.addFeatureNode(feature.themeId, feature.layerId, feature);
            });

            gcLayerTree.startJsTree();
        },

        initiallyCheckTree: function() {
            var self = this;

            $.each(self.internalVars.themes, function(themeId, theme) {
                var themeIsActive = false;
                if(theme.singleLayer) {
                    if(theme.olLayer.getVisibility()) {
                        themeIsActive = true;
                        $.each(self.internalVars.themes[themeId].layers, function(layerId, layerData) {
                            if(typeof(layerData.options.visibility) != 'undefined' && !layerData.options.visibility) return;
                            self.internalVars.themes[themeId].layers[layerId].userHasActivated = true;
                            self.internalVars.themes[themeId].layers[layerId].isActive = true;
                            self._checkLayer(layerData);
                        });
                    } else {
                        var pos = $.inArray(theme.olLayer.gc_id, self.internalVars.layersToLoad);
                        self.internalVars.layersToLoad.splice(pos, 1);
                    }
                } else {
                    $.each(theme.layers, function(layerId, layerData) {
                        //if(typeof(layerData.hide) != 'undefined' && layerData.hide == 1) return; fix for ticket 386.
                        self.internalVars.themes[themeId].layers[layerId].userHasActivated = true;
                        if(self.internalVars.themes[themeId].layers[layerId].olLayer.getVisibility()) {
                            self.internalVars.themes[themeId].layers[layerId].isActive = true;
                            self._checkLayer(layerData);
                            themeIsActive = true;
                        } else {
                            var pos = $.inArray(self.internalVars.themes[themeId].layers[layerId].olLayer.gc_id, self.internalVars.layersToLoad);
                            self.internalVars.layersToLoad.splice(pos, 1);
                        }
                    });
                }
                if(themeIsActive) self._checkTheme(theme);
            });
            self.initiallyHideLegend();
        },

        initiallyHideLegend: function() {
            var self = this;

            $.each(self.internalVars.themes, function(themeId, theme) {
                var allHidden = true;
                $.each(theme.layers, function(layerId, layer) {
                    if(!self.layerIsActive(themeId, layerId)) {
                        self._hideLegendLayer(layer);
                    } else allHidden = false;
                });
                if(allHidden) self._hideLegendTheme(theme);
            });
        },

        _initLayerSwitcher: function() {
        },

        _initLegend: function() {
            var self = this;

            $('#'+self.options.legend).gcLegendTree();
            var gcLegendTree = gisclient.componentObjects.gcLegendTree;

            $.each(self.internalVars.themes, function(themeId, theme) {
                if(theme.isVector) return;
                self.internalVars.themes[themeId].legendId = gcLegendTree.addThemeNode(themeId, theme.title);
                var hasLayergroups = false;
                $.each(theme.layers, function(layerId, layer) {
                    if((typeof(layer.hide) != 'undefined' && layer.hide == 1) || layer.type == 0) return;
                    hasLayergroups = true;
                    self.internalVars.themes[themeId].layers[layerId].legendId = gcLegendTree.addLayerNode(themeId, layerId, layer);
                    var visibleLegend = [];
                    $.each(layer.legend, function(e, classData) {
                        if(classData.legendtype_id != '0') {
                            gcLegendTree.addClassNode(themeId, layerId, classData);
                            visibleLegend.push(classData);
                        }
                    });
                    self.internalVars.themes[themeId].layers[layerId].legend = visibleLegend;
                });
                if(!hasLayergroups) gcLegendTree.removeThemeNode(themeId);
            });
            gcLegendTree.startLegendTree();
        },

        getEditingLayer: function() {
            var self = this;

            if(self.internalVars.editingLayer == null) self._initEditingLayer();
            return self.internalVars.editingLayer;
        },

        getSelectionLayer: function() {
            var self = this;
            //if(self.internalVars.selectionLayer == null) self._initSelectionLayer();
            return self.internalVars.selectionLayer;
        },

        getRedlineLayer: function() {
            var self = this;
            if(self.internalVars.redlineLayer == null) self._initRedlineLayer();
            return self.internalVars.redlineLayer;
        },

        getHighlightLayer: function() {
            var self = this;
            if(self.internalVars.highlightLayer == null) self._initHighlightLayer();
            return self.internalVars.highlightLayer;
        },

        _treeClick: function(event, ui) {
            var self = this;

            if(ui.role == 'theme') {
                if(ui.checked) self.activateTheme(ui.id);
                else self.deactivateTheme(ui.id);
            } else if(ui.role == 'layer') {
                if(ui.checked) {
                    self.internalVars.themes[ui.parent].layers[ui.id].userHasActivated = true;
                    self.activateLayer(ui.parent, ui.id);
                } else {
                    self.internalVars.themes[ui.parent].layers[ui.id].userHasActivated = false;
                    self.deactivateLayer(ui.parent, ui.id);
                }
            }

        },

        checkLayersVisibility: function() {
            var self = this;

            $.each(self.internalVars.themes, function(themeId, theme) {
                var allDisabled = true;
                if(theme.singleLayer) {
                    if(!theme.olLayer.calculateInRange()) {
                        $.each(theme.layers, function(layerId, layer) {
                            self._disableLayer(layer);
                        });
                        self._disableTheme(theme);
                    } else {
                        $.each(theme.layers, function(layerId, layer) {
                            self._enableLayer(layer);
                        });
                        self._enableTheme(theme);
                    }
                    return;
                }
                $.each(theme.layers, function(layerId, layer) {
                    if(typeof(layer.olLayer) == 'undefined') return;
                    if(!layer.olLayer.calculateInRange() && !theme.isVector) {
                        self._disableLayer(layer);
                    } else {
                        allDisabled = false;
                        self._enableLayer(layer);
                    }
                });
                if(allDisabled && themeId != 'gc_redlineLayer') self._disableTheme(theme);
                else self._enableTheme(theme);
                if(theme.isVector) self._hideSelectionLayer();
                if(theme.id == 'gc_redlineLayer' && $.isEmptyObject(self.internalVars.themes.gc_redlineLayer.layers)) self._hideRedlineWMSLayer();
            });
        },

        _getRadioThemes: function() {
            var self = this;

            var radioThemes = [];
            $.each(self.internalVars.themes, function(themeId, theme) {
                if(theme.radio) radioThemes.push(themeId);
            });
            return radioThemes;
        },

        themeIsActive: function(themeId) {
            var self = this;

            if(typeof(self.internalVars.themes[themeId]) == 'undefined') return false;
            if(self.internalVars.themes[themeId].singleLayer) {
                return self.internalVars.themes[themeId].olLayer.getVisibility();
            }

            var isActive = false;
            $.each(self.internalVars.themes[themeId].layers, function(layerId, layer) {
                if(typeof(layer.olLayer) == 'undefined' && layer.hide == 1) return;
                if(layer.olLayer.getVisibility()) isActive = true;
            });
            return isActive;
        },

        activateTheme: function(themeId) {
            var self = this;

            if(typeof(self.internalVars.themes[themeId]) == 'undefined') return false;
            if(self.internalVars.themes[themeId].singleLayer) {
                $.each(self.internalVars.themes[themeId].layers, function(layerId, layer) {
                    layer.isActive = true;
                    if(self.options.layerTree) {
                        self._checkLayer(layer);
                    }
                    if(self.options.legend) {
                        self._showLegendLayer(layer);
                    }
                });
                self.updateLayerParameter(themeId);
            } else {
                $.each(self.internalVars.themes[themeId].layers, function(layerId, layer) {
                    if((layer.hide == 1 || layer.userHasActivated)) {
                        if(layer.olLayer.calculateInRange()) {
                            self.activateLayer(themeId, layerId, false);
                        } else {
                            if(self.options.layerTree) {
                                layer.isActive = true;
                                self._checkLayer(layer);
                            }
                            layer.userHasActivated = true;
                            if(typeof(layer.olLayer) != 'undefined') {
                                layer.olLayer.setVisibility(true);
                            }
                        }
                    }
                });
            }
            if(self.options.layerTree) self._checkTheme(self.internalVars.themes[themeId]);
            if(self.options.legend) self._showLegendTheme(self.internalVars.themes[themeId]);

            if(self.internalVars.themes[themeId].radio) {
                $.each(self._getRadioThemes(), function(e, radioThemeId) {
                    if(themeId != radioThemeId) self.deactivateTheme(radioThemeId);
                });
            }
        },

        deactivateTheme: function(themeId) {
            var self = this;

            if(self.internalVars.themes[themeId].singleLayer) {
                $.each(self.internalVars.themes[themeId].layers, function(layerId, layer) {
                    layer.isActive = false;
                    if(self.options.layerTree) self._unCheckLayer(layer);
                    if(self.options.legend) self._hideLegendLayer(layer);
                });
                self.updateLayerParameter(themeId);
            } else {
                $.each(self.internalVars.themes[themeId].layers, function(layerId, layer) {
                    layer.isActive = false;
                    layer.olLayer.setVisibility(false);
                    if(self.options.layerTree) self._unCheckLayer(layer);
                    if(self.options.legend) self._hideLegendLayer(layer);
                });
            }
            if(self.options.layerTree) self._unCheckTheme(self.internalVars.themes[themeId]);
            if(self.options.legend) self._hideLegendTheme(self.internalVars.themes[themeId]);
        },

        layerIsActive: function(themeId, layerId) {
            var self = this;
            if(typeof(self.internalVars.themes[themeId]) == 'undefined') return false;
            if(typeof(self.internalVars.themes[themeId].layers[layerId]) == 'undefined') return false;
            return self.internalVars.themes[themeId].layers[layerId].isActive;
        },

        activateLayer: function(themeId, layerId, checkTheme) {
            var self = this;
            var theme = self.internalVars.themes[themeId];
            var layer = theme.layers[layerId];
            
            if(typeof(checkTheme) == 'undefined') checkTheme = true;

            if (!theme) {
                console.error("Invalid theme \"" + themeId + "\" in activateLayer(\"" + themeId + "\", \"" + layerId + "\")");
                return;
            }
            if (!layer) {
                console.error("Invalid layer \"" + layerId + "\" in activateLayer(\"" + themeId + "\", \"" + layerId + "\")");
                return;
            }
            if(!self.themeIsActive(themeId) && checkTheme){
                for(var i in theme.layers){
                    if(i === layerId){
                        continue;
                    }
                    theme.layers[i].userHasActivated = false;
                }
            }
            layer.isActive = true;

            if(theme.singleLayer) {
                self.updateLayerParameter(themeId);
            } else {
                if(typeof(layer.olLayer) != 'undefined') layer.olLayer.setVisibility(true);
            }
            if(self.options.layerTree) self._checkLayer(layer);
            if(self.options.legend) self._showLegendLayer(layer);

            if(self.options.layerTree && checkTheme) {
                self._checkTheme(theme);
            }
        },
        
        activateLayerByFeatureType: function(featureType) {
            var self = this;
            
            if (typeof(self.internalVars.queryableLayers[featureType]) == 'undefined') {
                console.log("Can't find layergroup/layer \"" + featureType + "\"");
                return false;
            }
            var queryableLayer = self.internalVars.queryableLayers[featureType];
            self.activateLayer(queryableLayer.themeId, queryableLayer.layerId);
        },

        deactivateLayer: function(themeId, layerId) {
            var self = this;

            var layer = self.internalVars.themes[themeId].layers[layerId];
            layer.isActive = false;

            if(self.internalVars.themes[themeId].singleLayer) {
                self.updateLayerParameter(themeId);
            } else {
                layer.olLayer.setVisibility(false);
            }

            if(self.options.layerTree) self._unCheckLayer(layer);
            if(self.options.legend) self._hideLegendLayer(layer);

            var allDeactivated = true;
            $.each(self.internalVars.themes[themeId].layers, function(layerId, layer) {
                if(self.layerIsActive(themeId, layerId)) allDeactivated = false;
            });
            if(allDeactivated) self.deactivateTheme(themeId);
        },

        getQueryableLayers: function(selectActive, includeHidden) {
            /*
             * getQueryableLayers(true, true) -> nessuna applicazione nota
             *
             * getQueryableLayers(true, false) -> 'layer attivi' del tool di selezione
             *  
             * getQueryableLayers(false, true) -> tutti i layer interrogabili
             * 
             * getQueryableLayers(false, false) -> layer che rientrano nei tool di selezione
             *
             */
             
            var self = this;
            if(typeof(selectActive) == 'undefined') selectActive = false;
            if(typeof(includeHidden) == 'undefined') includeHidden = false;

            if(!selectActive && includeHidden) return self.internalVars.queryableLayers;

            var queryableLayers = {};
            $.each(self.internalVars.queryableLayers, function(featureId, feature) {
                if(selectActive && !self.layerIsActive(feature.themeId, feature.layerId)) return;
                if(!includeHidden && (feature.fieldsCount == 0 || (typeof(feature.hidden) != 'undefined' && feature.hidden == 1))) return;
                queryableLayers[featureId] = feature;
            });
            return queryableLayers;
        },

        getEditableLayers: function() {
            var self = this;

            return self.internalVars.editableLayers;
        },

        getQueryableLayer: function(featureId) {
            var self = this;

            if(typeof(self.internalVars.queryableLayers[featureId]) == 'undefined') return false;

            return self.internalVars.queryableLayers[featureId];
        },

        _hideLegendTheme: function(theme) {
            var self = this;
            $('#'+theme.legendId).hide();
        },

        _hideLegendLayer: function(layer) {
            var self = this;
            $('#'+layer.legendId).hide();
        },

        _showLegendTheme: function(theme) {
            var self = this;
            $('#'+theme.legendId).show();
        },

        _showLegendLayer: function(layer) {
            var self = this;
            $('#'+layer.legendId).show();
        },

        _checkLayer: function(layer) {
            var self = this;
            $('#'+layer.treeId).prop('checked', 'checked');
        },

        _checkTheme: function(theme) {
            var self = this;
            $('#'+theme.treeId).prop('checked', 'checked');
        },

        _unCheckLayer: function(layer) {
            var self = this;
            $('#'+layer.treeId).prop('checked', false);
        },

        _unCheckTheme: function(theme) {
            var self = this;
            $('#'+theme.treeId).prop('checked', false);
        },

        _enableLayer: function(layer) {
            var self = this;
            $('#'+layer.treeId).removeAttr('disabled');
            if(self.options.legend && self.layerIsActive(layer.themeId, layer.id)) self._showLegendLayer(layer);
        },

        _enableTheme: function(theme) {
            var self = this;
            $('#'+theme.treeId).removeAttr('disabled');
            if(self.options.legend && self.themeIsActive(theme.id)) self._showLegendTheme(theme);
        },

        _disableLayer: function(layer) {
            var self = this;
            $('#'+layer.treeId).prop('disabled', true);
            if(self.options.legend) self._hideLegendLayer(layer);
        },

        _disableTheme: function(theme) {
            var self = this;
            $('#'+theme.treeId).prop('disabled', true);
            if(self.options.legend) self._hideLegendTheme(theme);
        },

        _initRedlineLayer: function() {
            var self = this;

            var mapOptions = gisclient.getMapOptions();
            self.internalVars.redlineServiceUrl = mapOptions.redlineServiceUrl;
            
            var redlineColor = '#FF0000';
            if(self.options.redlineColor) redlineColor = self.options.redlineColor;

            var redlineStyle = new OpenLayers.Style({
                pointRadius: 5, 
                fillColor: '#C0C0C0',
                strokeColor: redlineColor,
                fillOpacity: 0.5,
                fontSize: "14px",
                fontFamily: "Verdana",
                labelAlign: "rt",
                labelXOffset: 5,
                labelYOffset: 10
            });
            var redlineStyleMap = new OpenLayers.StyleMap({
                'default': redlineStyle
            });

            self.internalVars.redlineLayer = new OpenLayers.Layer.Vector('Redline',{
                styleMap:redlineStyleMap
            });
        },

        _initEditingLayer: function() {
            var self = this;

            // cursors for the transformfeature control
            var cursors = ["sw-resize", "s-resize", "se-resize", "e-resize", "ne-resize", "n-resize", "nw-resize", "w-resize"];
            var transformContext = {
                getCursor: function(feature){
                    var controls = gisclient.map.getControlsByClass('OpenLayers.Control.TransformFeature');
                    var i = OpenLayers.Util.indexOf(controls[0].handles, feature);
                    var cursor = "inherit";
                    if(i !== -1) {
                        i = (i + 8 + Math.round(controls[0].rotation / 90) * 2) % 8;
                        cursor = cursors[i];
                    }
                    return cursor;
                }
            };

            // styles for the vector layer
            var styles = new OpenLayers.StyleMap({
                "default": new OpenLayers.Style(null, {
                    rules: [new OpenLayers.Rule({
                        symbolizer: {
                            "Point": {
                                pointRadius: 5,
                                graphicName: "square",
                                fillColor: "white",
                                fillOpacity: 0.25,
                                strokeWidth: 1,
                                strokeOpacity: 1,
                                strokeColor: "#3333aa"
                            },
                            "Line": {
                                strokeWidth: 3,
                                strokeOpacity: 1,
                                strokeColor: "#6666aa"
                            },
                            "Polygon": {
                                strokeWidth: 1,
                                strokeOpacity: 1,
                                fillColor: "#9999aa",
                                strokeColor: "#6666aa"
                            }
                        }
                    })]
                }),
                "select": new OpenLayers.Style(null, {
                    rules: [
                    new OpenLayers.Rule({
                        symbolizer: {
                            "Point": {
                                pointRadius: 5,
                                graphicName: "square",
                                fillColor: "white",
                                fillOpacity: 0.25,
                                strokeWidth: 2,
                                strokeOpacity: 1,
                                strokeColor: "#0000ff"
                            },
                            "Line": {
                                strokeWidth: 3,
                                strokeOpacity: 1,
                                strokeColor: "#0000ff"
                            },
                            "Polygon": {
                                strokeWidth: 2,
                                strokeOpacity: 1,
                                fillColor: "#0000ff",
                                strokeColor: "#0000ff"
                            }
                        }
                    })
                    ]
                }),
                "temporary": new OpenLayers.Style(null, {
                    rules: [
                    new OpenLayers.Rule({
                        symbolizer: {
                            "Point": {
                                graphicName: "square",
                                pointRadius: 5,
                                fillColor: "white",
                                fillOpacity: 0.25,
                                strokeWidth: 2,
                                strokeColor: "#0000ff"
                            },
                            "Line": {
                                strokeWidth: 3,
                                strokeOpacity: 1,
                                strokeColor: "#0000ff"
                            },
                            "Polygon": {
                                strokeWidth: 2,
                                strokeOpacity: 1,
                                strokeColor: "#0000ff",
                                fillColor: "#0000ff"
                            }
                        }
                    })
                    ]
                }),
                "transform": new OpenLayers.Style({
                    cursor: "${getCursor}",
                    pointRadius: 5,
                    fillColor: "white",
                    fillOpacity: 1,
                    strokeColor: "black"
                }, {
                    context: transformContext
                })
            });

            var editingLayer = new OpenLayers.Layer.Vector('GisClientVector', {
                styleMap: styles
            });
            self.internalVars.editingLayer = editingLayer;
        },

        addRedlineWMS: function(redlineId) {
            var self = this;

            var olLayer = new OpenLayers.Layer.WMS(redlineId, self.internalVars.redlineServiceUrl, {
                "PROJECT": gisclient.getProject(),
                "REDLINEID": redlineId,
                'MAP': 'REDLINE',
                "SRS": gisclient.getProjection(),
                "FORMAT":"image/png; mode=24bit",
                "TRANSPARENT":true
            },{
                "visibility":true,
                "buffer":0,
                "singleTile":true,
                "gc_id":"gc_redline_" + redlineId
            });

            var layerNum = 1;
            $.each(self.internalVars.themes.gc_redlineLayer.layers, function(e, layer) {
                layerNum += 1
            });
            var layerId = 'redline_'+layerNum;

            self.internalVars.reversedLayers.gc_redlineLayer.push(layerId);

            self.internalVars.themes.gc_redlineLayer.layers[layerId] = {
                type: 0,
                title: OpenLayers.i18n('Redline')+' '+layerNum,
                treeId: gisclient.componentObjects.gcLayerTree.liveAddLayerNode('gc_redlineLayer', layerId, OpenLayers.i18n('Redline')+' '+layerNum, {
                    layerTools: false, 
                    deleteable: true
                }),
                redlineId: redlineId,
                layerId: layerId,
                olLayer: olLayer
            };
            self._checkLayer(self.internalVars.themes.gc_redlineLayer.layers[layerId]);

            gisclient.map.addLayer(olLayer);
            gisclient.toolObjects.redline.clearVectors();
            self._showRedlineWMSLayer();
        },
        
        _initSelectionLayer: function() {
            var self = this;

            if(self.options.selectionLayerStyleMap == null) {
                // functions to customize vector styles
                var styleFunctions = {
                    context: {
                        getStrokeWidth: function(feature) {
                            if(feature.geometry != null && typeof(feature.geometry.CLASS_NAME) != 'undefined') {
                                switch(feature.geometry.CLASS_NAME) {
                                    case 'OpenLayers.Geometry.LineString':
                                        return 10;
                                }
                            }
                            return 1;
                        }
                    }
                };


                // vector stylemap
                var styleMap = new OpenLayers.StyleMap({
                    "default": new OpenLayers.Style({
                        pointRadius: 12,
                        strokeColor: "#00B4B4",
                        fillColor: "#00B4B4",
                        fillOpacity: 0.2,
                        strokeOpacity:0.6,
                        strokeWidth: 2
                    }, styleFunctions),
                    "select": new OpenLayers.Style({
                        pointRadius: 14,
                        strokeWidth: 2,
                        strokeColor: "yellow",
                        fillColor: "yellow",
                        fillOpacity: 0.6
                    }, styleFunctions)
                });
            } else {
                var styleMap = self.options.selectionLayerStyleMap;
            }

            var layer = new OpenLayers.Layer.Vector('GisClientSelectionLayer', {
                styleMap:styleMap
            });
            if(self.options.selectionLayer && self.options.showSelectionLayer) {
                layer.events.register('featuresadded', self, self._showSelectionLayer);
                layer.events.register('featuresremoved', self, self._hideSelectionLayer);
            }
            self.internalVars.selectionLayer = layer;
            return layer;
        },

        _showSelectionLayer: function() {
            var self = this;

            if(gisclient.componentObjects.gcLayerTree && self.internalVars.selectionLayer.features.length > 0) {
                gisclient.componentObjects.gcLayerTree.showTheme('gc_selectionLayer');
            }
        },

        _hideSelectionLayer: function() {
            var self = this;

            if(gisclient.componentObjects.gcLayerTree && self.internalVars.selectionLayer.features.length == 0) {
                gisclient.componentObjects.gcLayerTree.hideTheme('gc_selectionLayer');
            }
        },

        _showRedlineWMSLayer: function() {
            var self = this;

            gisclient.componentObjects.gcLayerTree.showTheme('gc_redlineLayer');
            self._checkTheme(self.internalVars.themes.gc_redlineLayer);
        },

        _hideRedlineWMSLayer: function() {
            var self = this;

            gisclient.componentObjects.gcLayerTree.hideTheme('gc_redlineLayer');
        },

        _initHighlightLayer: function() {
            var self = this;

            if(self.options.highlightLayerStyleMap == null) {
                var styleMap = new OpenLayers.StyleMap({
                    "default": new OpenLayers.Style({
                        strokeWidth: 2,
                        strokeColor: "yellow",
                        fillColor: "yellow",
                        fillOpacity: 0.6,
                        pointRadius: 10
                    })
                });
            } else {
                var styleMap = self.options.highlightLayerStyleMap;
            }

            self.internalVars.highlightLayer = new OpenLayers.Layer.Vector('HighlightLayer', {
                styleMap:styleMap
            });
            gisclient.map.addLayer(self.internalVars.highlightLayer);
        },

        reloadLayer: function(themeId, layerId) {
            var self = this;

            self.internalVars.themes[themeId].layers[layerId].olLayer.redraw(true);
        },

        removeLayer: function(themeId, layerId) {
            var self = this;

            if(themeId == 'gc_redlineLayer') {
                var redlineId = self.internalVars.themes[themeId].layers[layerId].redlineId;
                gisclient.toolObjects.redline.deleteRedline(redlineId);
            }

            gisclient.componentObjects.gcLayerTree.liveRemoveLayerNode(themeId, layerId);
            self.internalVars.themes[themeId].layers[layerId].olLayer.destroy();
            delete self.internalVars.themes[themeId].layers[layerId];
            if($.isEmptyObject(self.internalVars.themes[themeId].layers)) {
                self._hideRedlineWMSLayer();
            }
        },

        reloadTheme: function(themeId) {
            var self = this;

            if(typeof(self.internalVars.themes[themeId]) == 'undefined') return;

            if(self.internalVars.themes[themeId].singleLayer) {
                return self.internalVars.themes[themeId].olLayer.redraw();
            }

            $.each(self.internalVars.themes[themeId].layers, function(layerId, layer) {
                self.reloadLayer(themeId, layerId);
            });
        },

        reloadThemes: function() {
            var self = this;

            $.each(self.internalVars.themes, function(themeId, theme) {
                self.reloadTheme(themeId);
            });
        },

        getLayer: function(themeId, layerId) {
            var self = this;
            
            if (typeof self.internalVars.themes[themeId] != 'undefined') {
                return self.internalVars.themes[themeId].layers[layerId];
            }
            return null;
        },

        getThemes: function() {
            var self = this;

            var themesWOLayers = {};
            $.each(self.internalVars.themes, function(themeId, theme) {
                themesWOLayers[themeId] = {
                    title: theme.title
                };
            });
            return themesWOLayers;
        },

        getTheme: function(themeId) {
            var self = this;

            return self.internalVars.themes[themeId];
        },

        getLayers: function(themeId) {
            var self = this;

            return self.internalVars.themes[themeId].layers;
        },

        moveTheme: function(direction, themeId) {
            var self = this;

            var themeKey = $.inArray(themeId, self.internalVars.reversedThemes);
            var targetThemeKey;
            var startThemeId = null;
            var endThemeId = null;

            if(direction == 'up') {
                if(typeof(self.internalVars.reversedThemes[(themeKey+1)]) == 'undefined') return;
                if(themeKey == 0) startThemeId = themeId;
                targetThemeKey = themeKey+1;
            } else if(direction == 'down') {
                if((themeKey-1) < 0) return;
                if(themeKey == (self.internalVars.reversedThemes.length -1)) endThemeId = themeId;
                targetThemeKey = themeKey-1;
            } else {
                return;
            }

            var targetThemeId = self.internalVars.reversedThemes[targetThemeKey];

            self.internalVars.reversedThemes[targetThemeKey] = themeId;
            self.internalVars.reversedThemes[themeKey] = targetThemeId;

            self.resetLayerIndexes(false, startThemeId, endThemeId);
            gisclient.componentObjects.gcLayerTree.moveTheme(direction, themeId);
        },

        getThemesOrder: function() {
            var self = this;

            return self.internalVars.reversedThemes;
        },

        setThemesOrder: function(themesOrder) {
            var self = this;

            self.internalVars.reversedThemes = themesOrder;
        },

        applyLayersOptions: function(layersOptions) {
            var self = this;

            $.each(layersOptions, function(layerGcId, options) {
                var layer = self.getLayerByGcId(layerGcId);
                if(layer == null) {
                    if(typeof(options.redlineId) != 'undefined') {
                        return self.addRedlineWMS(options.redlineId);
                    }
                    gisclient.log(layerGcId);
                    return;
                }
                if(typeof(options.visibility) != 'undefined') {
                    if(options.visibility == 'true') {
                        if(layer.isTheme) {
                            self.activateTheme(layer.id);
                        } else {
                            self.activateLayer(layer.themeId, layer.id);
                        }
                    } else {
                        if(layer.isTheme) {
                            self.deactivateTheme(layer.id);
                        } else {
                            self.deactivateLayer(layer.themeId, layer.id);
                        }
                    }
                }
                if(typeof(options.opacity) != 'undefined') layer.olLayer.setOpacity(parseFloat(options.opacity));
            });
            self.checkLayersVisibility();
        },

        getLayerByGcId: function(layerGcId) {
            var self = this;

            var layerFound = null;
            $.each(self.internalVars.themes, function(themeId, theme) {
                if(theme.singleLayer) {
                    if(theme.olLayer.gc_id == layerGcId) {
                        layerFound = theme;
                        layerFound.isTheme = true;
                    }
                } else {
                    $.each(theme.layers, function(layerId, layer) {
                        if(typeof(layer.olLayer) == 'undefined') return;
                        if(typeof(layer.olLayer.gc_id) == 'undefined') return;
                        if(layer.olLayer.gc_id == layerGcId) {
                            layerFound = layer;
                            layerFound.isTheme = false;
                        }
                    });
                }
            });
            return layerFound;
        },

        resetLayerIndexes: function(updateTree, startThemeId, endThemeId) {
            var self = this;

            if(typeof(updateTree) == 'undefined') updateTree = false;
            if(typeof(startThemeId) == 'undefined' || startThemeId == null) {
                var startThemeId = self.internalVars.reversedThemes[0];
            }
            if(typeof(endThemeId) == 'undefined' || endThemeId == null) {
                var endThemeId = self.internalVars.reversedThemes[self.internalVars.reversedThemes.length-1];
            }
            var startLayerId = self.internalVars.reversedLayers[startThemeId][0];
            var endLayerId = self.internalVars.reversedLayers[endThemeId][self.internalVars.reversedLayers[endThemeId].length-1];
            if(self.internalVars.themes[startThemeId].singleLayer) {
                var startIndex =  parseInt(gisclient.map.getLayerIndex(self.internalVars.themes[startThemeId].olLayer));
                var endIndex = parseInt(gisclient.map.getLayerIndex(self.internalVars.themes[endThemeId].olLayer));
            } else {
                var startIndex =  parseInt(gisclient.map.getLayerIndex(self.internalVars.themes[startThemeId].layers[startLayerId].olLayer));
                var endIndex = parseInt(gisclient.map.getLayerIndex(self.internalVars.themes[endThemeId].layers[endLayerId].olLayer));
            }

            var additionalLayers = [];
            $.each(gisclient.map.layers, function(e, layer) {
                if(e > endIndex) additionalLayers.push(layer);
            });

            var index = startIndex;
            $.each(self.internalVars.reversedThemes, function(e, themeId) {
                if(typeof(self.internalVars.reversedLayers[themeId]) == 'undefined') return;
                if(self.internalVars.themes[themeId].singleLayer) {
                    gisclient.map.setLayerIndex(self.internalVars.themes[themeId].olLayer, index);
                    index += 1;
                } else {
                    $.each(self.internalVars.reversedLayers[themeId], function(i, layerId) {
                        if(typeof(self.internalVars.themes[themeId].layers[layerId]) == 'undefined') return;
                        gisclient.map.setLayerIndex(self.internalVars.themes[themeId].layers[layerId].olLayer, index);
                        index += 1;
                    });
                }
            });
            $.each(additionalLayers, function(e, layer) {
                gisclient.map.setLayerIndex(layer, index);
                index += 1;
            });

            if(updateTree) gisclient.componentObjects.gcLayerTree.startJsTree();
        },

        getFeatureLink: function(featureId) {
            var self = this;

            if(typeof(self.internalVars.featureLinks[featureId]) != 'object') return false;
            return self.internalVars.featureLinks[featureId];
        },

        updateLayerParameter: function(themeId) {
            var self = this;

            var newLayersParam = [];
            var orderedLayers = self.internalVars.reversedLayers[themeId];
            $.each(orderedLayers, function(e, layerName) {
                if(self.internalVars.themes[themeId].layers[layerName].isActive) {
                    newLayersParam.push(layerName);
                }
            });
            self.internalVars.themes[themeId].olLayer.setVisibility((newLayersParam.length > 0));
            self.internalVars.themes[themeId].olLayer.params.LAYERS = newLayersParam;
            self.internalVars.themes[themeId].olLayer.redraw();
        }

    });

    $.extend($.gcComponent.gcLayersManager, {
        version: "3.0.0"
    });
})(jQuery);
