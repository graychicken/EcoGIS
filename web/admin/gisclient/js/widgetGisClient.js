/* use global var GISCLIENT_DEBUG to activate debug mode */
//GISCLIENT_DEBUG = 1;

var gisclient;

(function($){

    $.widget("ui.gisclientmap", {
		
        options: {
            log_level: 'mail',
            baseLayerFirst: true,
            supportsGml3: false,
            activateKeyboardControl: true,
            contextualLegend: true, // Contextual Legend: legend will be available only for active layers
            mapsetData: null,
            mapQueryActivateLayers: {},  // themeId.layerGroupId: [themeIdToActivate.layerGroupIdToActivate, ...]
            dialogDefaultPosition: {
                position: [600,0]
            }, // default position of dialogs, (left, top)
            mapDefaultSize: [550,400],
            isMobile: null,
            detailLinkTemplates: null
        },
		
        internalVars: {
            lastZoomOn: null,
            lastCustomSearch: null,
            geolocateControl: null,
            geolocateLastConfig: null
        },
	
        _create: function() {
            this.element
            .addClass( "ui-gisclient ui-widget ui-widget-content" )
            .attr({
                role: "gisclient"
            });
            this.mapStarted = false;
            gisclient = this; // global variable
        },
		
        _init: function(){
            var self = this;

            self.divs = self.options.divs;
            self.callbacks = self.options.callbacks || {};
            self.toolsOptions = self.options.toolsOptions || {};
            self.componentsOptions = self.options.componentsOptions || {};
            self.searchEngineOptions = self.options.searchEngineOptions || {};
                        
            // apply proxy: for wfs requests on other domains
            if (self.options.proxy) {
                OpenLayers.ProxyHost = self.options.proxy;
                $.ajaxPrefilter( function( options ) {
                    if ( options.crossDomain ) {
                        var url = options.url;
                        if (options.data)
                            url += self.getQueryStringSeparator(url) + options.data;
                        options.url = self.options.proxy + encodeURIComponent(url);
                        options.crossDomain = false;
                    }
                });
            }
			
            // apply language
            if (self.options.language)
                OpenLayers.Lang.setCode(self.options.language);
				
            self.mapUrl = location.href;
			
            if(self.options.mapsetURL){
                $.getJSON(self.options.mapsetURL + "services/gcmap.php", {
                    jsonformat:true, // force service to return a json output
                    mapset:self.options.mapsetName,
                    legend:(typeof(self.divs.legendList) == 'undefined') ? 0 : 1, // TODO: no more used
                    querytemplate:self.options.querytemplate ? 1 : 0, // TODO: no more used
                    tmp: (typeof(self.options.tmp) != 'undefined' && self.options.tmp == 1) ? 1 : 0,
                    show_as_public: (typeof self.options.showAsPublic !== 'undefined' && self.options.showAsPublic == 1) ? 1 : 0,
                    lang:OpenLayers.Lang.getCode()
                }, function(settings) {
                    self.options.mapsetData = settings;
                    self._initMap(self.options.mapsetData);
                });
            } else {
                alert('MISSING MAPSET URL');
            }
        },
		
        getMap: function (){
            return this.map;
        },
		
        getProject:function(){
            return this.project;
        },
		
        getProjection: function() {
            return this.projection;
        },
        
        getSRID: function() {
            var parts = this.projection.split(':');
            return parts[1];
        },
		
        getLanguage: function() {
            return this.options.language;
        },
		
        getResolutions: function() {
            return this.resolutions;
        },
		
        getMapTitle: function() {
            return this.mapTitle;
        },
		
        getMapOptions: function() {
            var self = this;

            var options = {
                mapsetURL: self.options.mapsetURL,
                mapsetName: self.options.mapsetName,
                mapsetTitle: self.options.mapsetData.title,
                restrictedExtent: self.options.restrictedExtent,
                redlineServiceUrl: self.options.mapsetURL + 'services/redline.php',
                lookupServiceUrl: self.options.mapsetURL + 'services/lookup.php',
                mapContextServiceUrl: self.options.mapsetURL + 'services/context.php',
                bufferServiceUrl: self.options.mapsetURL + 'services/buffer.php',
                mapExportServiceUrl: self.options.mapsetURL + 'services/export.php',
                autocompleteServiceUrl: self.options.mapsetURL + 'services/autocomplete.php',
                geolocatorServiceUrl: self.options.mapsetURL + 'services/geolocator.php',
                detailServiceUrl: self.options.mapsetURL + 'services/get1nData.php',
                detailLinkTemplates: self.options.detailLinkTemplates,
                printServiceUrl: self.options.mapsetURL + 'services/print.php',
                mapHelpUrl: 'help.html',
                mapDownloadServiceUrl: self.options.mapsetURL + 'services/download.php',
                dpi: self.options.dpi,
                groupedThemes: (typeof self.options.groupedThemes === 'undefined') ? [] : self.options.groupedThemes,
                legend: (typeof self.divs.legendList === 'undefined') ? false : true,
                uploadServiceUrl: self.options.mapsetURL + 'services/files/save.php',
                filesUrl: self.options.mapsetURL + 'services/files/'
            };
            return options;
        },
		
        _initMap: function(settings){
            var self = this,
                displayProjection;
		
            if (typeof self.options.mapOptions != 'undefined' && typeof self.options.mapOptions.resolutions != 'undefined') {
                settings.resolutions = self.options.mapOptions.resolutions;
            }
            this.project = this.options.project_name;
            this.projection = settings.projection;
            this.mapTitle = settings.title;
            this.resolutions = settings.resolutions;
            if (typeof settings.displayProjection != 'undefined') {
                displayProjection = new OpenLayers.Projection(settings.displayProjection);
            } else {
                displayProjection = new OpenLayers.Projection(settings.projection);
            }
			
            this.toolObjects = {};
            this.componentObjects = {};
			
            if(typeof(self.options.restrictedExtent) != 'undefined') self.options.restrictedExtent = OpenLayers.Bounds.fromString(self.options.restrictedExtent);
            else self.options.restrictedExtent = OpenLayers.Bounds.fromArray(settings.restrictedExtent);
			
            var controls = [
            new OpenLayers.Control.Attribution(),
            new OpenLayers.Control.Navigation({
                isPermanent:true
            }),
            new OpenLayers.Control.ScaleLine({
                isPermanent:true
            }),
            new OpenLayers.Control.PanZoomBar({
                forceFixedZoomLevel:true,
                isPermanent:true
            })
            ];
            if(self.options.activateKeyboardControl) {
                controls.push(new OpenLayers.Control.KeyboardDefaults({
                    isPermanent:true
                }));
            }
            var mapOptions = {
                controls:controls,
                units: "m",
                projection: new OpenLayers.Projection(settings.projection),
                displayProjection: displayProjection, // questo serve solo se c'è un layer google o simili
                maxExtent: self.options.restrictedExtent,
                resolutions: settings.resolutions,
                fractionalZoom: true,
                size: new OpenLayers.Size(this.options.mapDefaultSize[0], this.options.mapDefaultSize[1])
            };
            
            if (typeof self.options.mapOptions == 'object') {
                $.extend(mapOptions, self.options.mapOptions);
            }

            OpenLayers.IMAGE_RELOAD_ATTEMPTS = 3;
            OpenLayers.Util.onImageLoadErrorColor = "transparent";
            OpenLayers.DOTS_PER_INCH = settings.dpi;
            
            //Istanza dell'oggetto mappa
            var map = new OpenLayers.Map(this.element.get(0), mapOptions);
            map.events.register('zoomend',self,self._checkButtons);
			
            self.map = map;
            self.mapId = map.id.replace(".","_");
			
            $('body').append('<div id="gc_layer_tools"></div>');
            $('#gc_layer_tools').layerTools();
			
            var layersManagerOptions = {
                layerTree: (typeof(self.divs.treeList) == 'undefined') ? false : self.divs.treeList,
                legend: (typeof(self.divs.legendList) == 'undefined') ? false : self.divs.legendList,
                referenceMap: (typeof(self.divs.referenceMap) == 'undefined') ? false : self.divs.referenceMap,
                redlineLayer: (typeof(self.options.tools.redline) != 'undefined'),
                defaultFeatureFilters: (typeof(self.options.defaultFeatureFilters) == 'undefined') ? null : self.options.defaultFeatureFilters
            };
            if(typeof(self.componentsOptions['gcLayersManager']) == 'object') {
                layersManagerOptions = $.extend(layersManagerOptions, self.componentsOptions['gcLayersManager']);
            }
            $('#div_layermanager').gcLayersManager(layersManagerOptions);
            
            var contextHandlerOptions = {};
            if(typeof(self.componentsOptions.contextHandler) == 'object') {
                contextHandlerOptions = self.componentsOptions.contextHandler;
            }
            self.initContext(contextHandlerOptions);
			
            if(self.options.tools) self._initTools();
			
            self._trigger('gisclientready', null, {});
            self._deactivateEmptyTools();
        },
		
        _deactivateEmptyTools: function() {
            var self = this;
			
            if(typeof(gisclient.toolObjects.selectFromMap) != 'undefined') {
                var queryableLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers();
                if($.isEmptyObject(queryableLayers)) {
                    $(gisclient.toolObjects.selectFromMap.element).remove();
                    $('label[for='+gisclient.toolObjects.selectFromMap.element[0].id+']').remove();
                    delete gisclient.toolObjects.selectFromMap;
                }
            }
            if(typeof(gisclient.toolObjects.toolTip) != 'undefined') {
                var queryableLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers();
                if($.isEmptyObject(queryableLayers)) {
                    $(gisclient.toolObjects.toolTip.element).remove();
                    $('label[for='+gisclient.toolObjects.toolTip.element[0].id+']').remove();
                    delete gisclient.toolObjects.toolTip;
                }
            }
            if(typeof(gisclient.toolObjects.wfstEdit) != 'undefined') {
                var editableLayers = gisclient.componentObjects.gcLayersManager.getEditableLayers();
                if($.isEmptyObject(editableLayers)) {
                    $(gisclient.toolObjects.wfstEdit.element).remove();
                    $('label[for='+gisclient.toolObjects.wfstEdit.element[0].id+']').remove();
                    delete gisclient.toolObjects.wfstEdit;
                }
            }
        },
		
        startMap: function() {
            var self = this;

            gisclient.componentObjects.gcLayersManager.loadLayers();
            self.mapStarted = true;
        },
		
        _updatePositionLink: function() {
            var center = gisclient.map.getCenter();
            var zoom = gisclient.map.getZoom();
            $('#'+gisclient.divs.positionLink).html('<a href="?x='+center.lon+'&y='+center.lat+'&zoom='+zoom+'">Link</a>');
        },
		
        _checkButtons: function() {
            var gisclient = this;
            if(typeof(gisclient.toolObjects) == 'undefined' || gisclient.toolObjects.length < 1) return;
            if(typeof(gisclient.toolObjects.zoomToMaxExtent) == 'undefined' || typeof(gisclient.toolObjects.zoomToHistoryPrevious) == 'undefined' || typeof(gisclient.toolObjects.zoomToHistoryNext) == 'undefined') return;
            
            // enable/disable maxextent, previous, next
            if(gisclient.map.getNumZoomLevels() > gisclient.map.zoom) {
                $('#' + gisclient.options.tools['zoomFull']).zoomToMaxExtent('enable');
            } else {
                $('#' + gisclient.options.tools['zoomFull']).zoomToMaxExtent('disable');
            }
            if(gisclient.toolObjects.zoomToHistoryPrevious.options.control.previousStack.length > 0) {
                $('#' + gisclient.options.tools['zoomPrev']).zoomToHistoryPrevious('enable');
            } else {
                $('#' + gisclient.options.tools['zoomPrev']).zoomToHistoryPrevious('disable');
            }
            if(gisclient.toolObjects.zoomToHistoryNext.options.control.nextStack.length > 0) {
                $('#' + gisclient.options.tools['zoomNext']).zoomToHistoryNext('enable');
            } else {
                $('#' + gisclient.options.tools['zoomNext']).zoomToHistoryNext('disable');
            }
        },
		
        _initTools: function() {
            var self=this;
            var domObj;
            var divs = self.divs;
            var callbacks = self.callbacks;
            var toolsOptions = self.toolsOptions;
			
            if(typeof(divs.mapInfoRefSystemDescription) != 'undefined' && typeof(self.options.mapsetData.projectionDescription) != 'undefined') {
                if (typeof self.options.mapsetData.displayProjectionDescription != 'undefined') {
                    $('#'+divs.mapInfoRefSystemDescription).html(self.options.mapsetData.displayProjectionDescription);
                } else {
                    $('#'+divs.mapInfoRefSystemDescription).html(self.options.mapsetData.projectionDescription);
                }
            }

            for(var key in this.options.tools) {
                domObj = $('#' + this.options.tools[key]); //elemento del dom associato al controllo
                switch(key){
                    case 'dummy':   // Prevent error log
                        break;
                        
                    case 'zoomFull':
                        var options = {};
                        if(typeof(toolsOptions['zoomFull']) == 'object') {
                            options = $.extend(options, toolsOptions['zoomFull']);
                        }
                        $(domObj).zoomToMaxExtent(options);
                        break;
						
                    case 'zoomPrev':
                        $(domObj).zoomToHistoryPrevious();
                        break;
						
                    case 'zoomNext':
                        $(domObj).zoomToHistoryNext();
                        break;
						
                    case 'zoomIn':
                        $(domObj).zoomIn();
                        break;
						
                    case 'zoomOut':
                        $(domObj).zoomOut();
                        break;
						
                    case 'Pan':
                        $(domObj).pan();
                        break;

                    case 'selectFromMap':
                        var options = {
                            idDialog: divs.selectionSettings,
                            idDataList: divs.dataList,
                            idTree: divs.tree
                        };
                        if(typeof(toolsOptions['selectFromMap']) == 'object') {
                            options = $.extend(options, toolsOptions['selectFromMap'], self.searchEngineOptions);
                        }    
                        if(typeof(divs.selectionSettings) != 'undefined' && typeof(divs.dataList) != 'undefined') {
                            $(domObj).selectFromMap(options);
                        } else {
                            console.error('Initialization of selectFromMap faild: invalid selectionSettings or dataList');
                        }
                        break;
						
                    case 'easySelectFromMap':
                        if(typeof(divs.dataList) != 'undefined') {
                            $(domObj).easySelectFromMap({
                                idDataList: divs.dataList,
                                idTree: divs.tree
                            });
                        }
                        break;
						
                    case 'measureLine':
                        if(typeof(divs.lineMeasure) != 'undefined' && typeof(divs.lineMeasurePartial) != 'undefined') {
                            $(domObj).measureLine({
                                targetDiv:divs.lineMeasure,
                                targetPartialDiv:divs.lineMeasurePartial
                            });
                        }
                        break;
						
                    case 'measureArea':
                        if(typeof(divs.areaMeasure) != 'undefined') {
                            $(domObj).measureArea({
                                targetDiv:divs.areaMeasure
                            });
                        }
                        break;
					
                    case 'drawFeature':
                        if(typeof(callbacks['drawFeature']) != 'function') callbacks['drawFeature'] = function() {};
                        var options = {
                            save: callbacks['drawFeature']
                        };
                        if(typeof(toolsOptions['drawFeature']) == 'object') {
                            options = $.extend(options, toolsOptions['drawFeature']);
                        }
                        $(domObj).drawFeature(options);
                        break;
						
                    case 'reloadLayers':
                        $(domObj).reloadLayers();
                        break;
						
                    case 'selectPoint':
                        if(typeof(callbacks['selectPoint']) != 'function') callbacks['selectPoint'] = function() {};
                        $(domObj).selectPoint({
                            snapOptionsId: divs.snapOptionsId,
                            handleFeature: callbacks['selectPoint']
                        });
                        break;
						
                    case 'selectFeatures':
                        if(typeof(callbacks['selectFeatures']) != 'function') callbacks['selectFeatures'] = function() {};
                        var settingsId = (typeof(divs.selectFeaturesSettings) != 'undefined')?divs.selectFeaturesSettings:null;
                        if(typeof(gisclient.options.selectFeaturesSettings) != 'undefined') {
                            var featureType = (typeof(gisclient.options.selectFeaturesSettings.featureType) != 'undefined') ? gisclient.options.selectFeaturesSettings.featureType : null;
                            var filter = (typeof(gisclient.options.selectFeaturesSettings.filter) != 'undefined') ? gisclient.options.selectFeaturesSettings.filter : null;

                        }
                        $(domObj).selectFeatures({
                            displaySettingsId: settingsId,
                            featureType: featureType,
                            filter: filter,
                            handleFeature: callbacks['selectFeatures']
                        });
                        break;
						
                    case 'selectBox':
                        if(typeof(callbacks['selectBox']) != 'function') callbacks['selectBox'] = function() {};
                        $(domObj).selectBox({
                            snapOptionsId: divs.snapOptionsId,
                            handleFeature: callbacks['selectBox']
                        });
                        break;
						
                    case 'selectPolygon':
                        if(typeof(callbacks['selectPolygon']) != 'function') callbacks['selectPolygon'] = function() {};
                        $(domObj).selectPolygon({
                            snapOptionsId: divs.snapOptionsId,
                            handleFeature: callbacks['selectPolygon']
                        });
                        break;
						
                    case 'redline':
                        if(typeof(divs.redlineDialog) != 'undefined') {
                            $(domObj).redline({
                                redlineDialogDiv: divs.redlineDialog
                            });
                        }
                        break;
						
                    case 'toolTip':
                        $(domObj).toolTip();
                        break;
						
                    case 'mapPrint':
                        if(typeof(gisclient.componentObjects.mapImageDialog) == 'undefined') {
                            var options = typeof(self.componentsOptions.mapImageDialog) == 'object' ? self.componentsOptions.mapImageDialog : {};
                            gisclient.initMapImageDialog(options);
                        }
                        var options = {};
                        if(typeof(toolsOptions['mapPrint']) == 'object') {
                            options = $.extend(options, toolsOptions['mapPrint']);
                        }
                        $(domObj).mapPrint(options);
                        break;
						
                    case 'mapImageDownload':
                        if(typeof(gisclient.componentObjects.mapImageDialog) == 'undefined') {
                            var options = typeof(self.componentsOptions.mapImageDialog) == 'object' ? self.componentsOptions.mapImageDialog : {};
                            gisclient.initMapImageDialog(options);
                        }
                        $(domObj).mapImageDownload();
                        break;
						
                    case 'mapContext':
                        $(domObj).mapContext();
                        break;
						
                    case 'wfstEdit':
                        $(domObj).wfstEdit();
                        break;
                        
                    case 'mapHelp':
                        var options = {};
                        if(typeof(gisclient.toolsOptions.mapHelp) != 'undefined') options = gisclient.toolsOptions.mapHelp;
                        $(domObj).mapHelp(options);
                        break;
                    
                    case 'geolocate':
                        var options = {};
                        if(typeof(gisclient.toolsOptions.geolocate) != 'undefined') options = gisclient.toolsOptions.geolocate;
                        if ($.gcTool.geolocate) {
                            $(domObj).geolocate(options);
                        }
                        break;
						
                    case 'toStreetView':
                        var options = {};
                        if(typeof(toolsOptions['toStreetView']) == 'object') {
                            options = $.extend(options, toolsOptions['toStreetView']);
                        }
                        $(domObj).toStreetView(options);
                        break;
                    case 'exportKmlWms':
                        var options = {};
                        if(typeof(toolsOptions['exportKmlWms']) == 'object') {
                            options = $.extend(options, toolsOptions['exportKmlWms']);
                        }
                        $(domObj).exportKmlWms(options);
                        break;
                    default:     
                        console.warn('Undefined tool "' + key + '"');
                }
            }
            
            $('#'+divs.toolBar).find('span.gc-buttonset').buttonset();
            
            if(typeof(divs.footer) != 'undefined') {
                $('#'+divs.footer).mapInfo({
                    idMapInfoScale: divs.mapInfoScale,
                    idMapInfoMousePosition: divs.mapInfoMousePosition,
                    idMapInfoMousePositionLatLon: divs.mapInfoMousePositionLatLon,
                    idmapInfoRefSystem: divs.mapInfoRefSystem
                });
            }
			
            if(typeof(divs.scaleDropDown) != 'undefined') {
                $('#'+divs.scaleDropDown).scaleDropDown();
            }
			
            if(typeof(divs.searchList) != 'undefined') {
                var options = {
                    idDataList: divs.dataList,
                    idTree: divs.tree
                };
                if(typeof(self.componentsOptions['searchForm']) == 'object') {
                    options = $.extend(options, self.componentsOptions['searchForm'], self.searchEngineOptions);
                }
                $('#'+divs.searchList).searchForm(options);
            }
			
            if(typeof(divs.customSearch) != 'undefined') {
                $('#'+divs.customSearch).customSearch();
            }
			
            if(typeof(divs.viewTable) != 'undefined') {
                $('#'+divs.viewTable).viewTable();
            }
            
            if (typeof(divs.geolocator) != 'undefined' && $.gcComponent.geolocator) {
                $('#'+divs.geolocator).geolocator();
            }
            
            if ($.gcComponent.detailTable) {
                if(typeof divs.detailTable !== 'undefined') {
                    $('body').append('<div id="gc_auto_div_detailtable"></div>');
                }
                $('#gc_auto_div_detailtable').detailTable();
            }
			
            $('#'+divs.loading).loadingHandler();
			
            $('#'+divs.errors).errorHandler();
			
            $('#' + gisclient.options.tools['zoomFull']).zoomToMaxExtent('disable');
            $('#' + gisclient.options.tools['zoomPrev']).zoomToHistoryPrevious('disable');
            $('#' + gisclient.options.tools['zoomNext']).zoomToHistoryNext('disable');
			
            self.toolObjects.pan._toggleControl();
        },
		
        parentGoTo: function(url) {
            window.opener.location = url;
            window.opener.focus();
        },
		
        openPopup: function(url, options) {
            var options = $.extend({}, {target: 'popup_link', 
                                        left: null,
                                        top: null,
                                        width: 800,
                                        height: 600,
                                        scrollbars: "yes",
                                        toolbar: "no",
                                        resizable: "no",
                                        menubar: "no"}, options);
            options.width = Math.min(screen.availWidth || 800, options.width || 800);
            options.height = Math.min(screen.availHeight || 600, options.height || 600);
            options.left = options.left || ((screen.availWidth - options.width) / 2);
            options.top = options.top || ((screen.availHeight - options.height) / 2);

            var hWin = window.open(url, options.target, "top=" + options.top + ", left=" + options.left + ", width=" + options.width + ", height=" + options.height + 
                                                        ", scrollbars=" + options.scrollbars + ",toolbar=" + options.toolbar + ",resizable=" + options.resizable + ",menubar=" + options.menubar);
            if (hWin == null) {
                alert(OpenLayers.i18n('Error opening window'));
            } else {
                hWin.focus();
            }
        },
        
        parentOpenDialog: function(url) {
            var context = window.opener;
            context.$('#r3_dialog').remove();
            
            var options = {
                autoOpen: false,
                modal: true,
                width: 800,
                height: 700,
                position: [200,50],
                resizable: false,
                close: function(event, ui) {
                    context$("#r3_dialog").remove();
                }
            };
            
            if (context.$('#r3_dialog', context.document).length == 0) {
                context.$('<div id="r3_dialog"></div>', context.document).appendTo(context.$('body', context.document)).hide();
                context.$('#r3_dialog', context.document).html('Loading ...');
                context.$('#r3_dialog', context.document).dialog(options);
            } else {
                context.$('#r3_dialog', context.document).html('Loading ...');
                context.$('#r3_dialog', context.document).dialog('option', options);
            }
            
            context.$('#r3_dialog', context.document).dialog('open').load(url);
            context.focus();
        },
        
        getQueryStringSeparator: function(url) {
            if(url.indexOf('?') == -1) {
                return '?';

            }
            if(url.substr(-1) == '?') {
                return '';
            } else if(url.substr(-1) != '&') {
                return '&';
            }
            return '';
        },
		
        zoomOn: function(where, highlight) {
            // remove features to avoid problems with already highlighted objects
            var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
            selectionLayer.removeAllFeatures();
			
            gisclient.internalVars.lastCustomSearch = null;
            gisclient.internalVars.lastZoomOn = where;
            if(typeof(where.CLASS_NAME) != 'undefined' && where.CLASS_NAME == 'OpenLayers.Bounds') {
                gisclient.map.zoomToExtent(where);
                return true;
            } else {
                if(typeof(where.featureType) == 'undefined' || typeof(where.field) == 'undefined' || typeof(where.value) == 'undefined') return false;
                var featureType = where.featureType;
                var field = where.field;
                var value = where.value;
                if(typeof(highlight) == 'undefined' && typeof(where.highlightFeatures) != 'undefined') {
                    var highlight = where.highlightFeatures;
                }
				
                if(highlight) gisclient.internalVars.lastZoomOn.highlight = 1;
                else gisclient.internalVars.lastZoomOn.highlight = 0;
                var queryableLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers(false, true);
                if(featureType in queryableLayers) {
                    var queryModel = queryableLayers[featureType];
                    var filter = new OpenLayers.Filter.Comparison({
                        type: OpenLayers.Filter.Comparison.EQUAL_TO,
                        property: field,
                        value: value
                    });
                    var filter_1_0 = new OpenLayers.Format.Filter({
                        version: "1.0.0"
                    });
                    var xml = new OpenLayers.Format.XML();
                    var filterValue = xml.write(filter_1_0.write(filter));
					
                    var params = {
                        PROJECT: queryModel.layer.parameters.project,
                        MAP: queryModel.layer.parameters.map,
                        SERVICE: 'WFS',
                        LANG: gisclient.getLanguage(),
                        VERSION: '1.0.0',
                        REQUEST: 'GETFEATURE',
                        SRS: gisclient.getProjection(),
                        TYPENAME: featureType,
                        FILTER: filterValue
                    };

                    $.ajax({
                        url: queryModel.layer.url,
                        type: 'POST',
                        dataType: 'xml',
                        data: params,
                        success: function(response, status, jqXHR) {
                            var format = new OpenLayers.Format.GML();
                            var features = format.read(response);
                            if(features.length < 1) {
                                gisclient.log(jqXHR.responseText);
                                return false;
                            }
                            
                            var gcLayersManager = gisclient.componentObjects.gcLayersManager;
							
                            if(highlight) {
                                var selectionLayer = gcLayersManager.getSelectionLayer();
                                selectionLayer.addFeatures(features);
                            }

                            if(!gcLayersManager.layerIsActive(queryModel.themeId, queryModel.layerId)) gcLayersManager.activateLayer(queryModel.themeId, queryModel.layerId);
								
                            var bounds = new OpenLayers.Bounds();
                            $.each(features, function(i, feature) {
                                bounds.extend(feature.bounds);
                            });
							
                            gisclient.zoomToExtent(bounds);
                            return true;
                        },
                        error: function(response, status, jqXHR) {
                            gisclient.log(jqXHR.responseText);
                            return false;
                        }
                    });
                } else {
                    console.log("zoomOn faild: Layer is not queryable");
                }
                return false;
            }
        },
		
        addVectorFeatures: function(targetLayer, where, callback) {
            if(typeof(where.featureType) == 'undefined' || (typeof(where.field) == 'undefined' || typeof(where.value) == 'undefined') && (typeof(where.filter) == 'undefined')) return false;
            var featureType = where.featureType;
            if(typeof(where.filter) == 'undefined') {
                var field = where.field;
                var value = where.value;
            }
			
            if(typeof(highlight) == 'undefined' && typeof(where.highlightFeatures) != 'undefined') {
                var highlight = where.highlightFeatures;
            }
			
            var queryableLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers(false, true);
            if(featureType in queryableLayers) {
                var queryModel = queryableLayers[featureType];
                var filter;
                if(typeof(where.filter) != 'undefined') {
                    filter = where.filter;
                } else {
                    var filter = new OpenLayers.Filter.Comparison({
                        type: OpenLayers.Filter.Comparison.EQUAL_TO,
                        property: where.field,
                        value: where.value
                    });

                }
                var filter_1_0 = new OpenLayers.Format.Filter({
                    version: "1.0.0"
                });
                var xml = new OpenLayers.Format.XML();
                var filterValue = xml.write(filter_1_0.write(filter));
				
                var params = {
                    PROJECT: queryModel.layer.parameters.project,
                    MAP: queryModel.layer.parameters.map,
                    SERVICE: 'WFS',
                    LANG: gisclient.getLanguage(),
                    VERSION: '1.0.0',
                    REQUEST: 'GETFEATURE',
                    SRS: gisclient.getProjection(),
                    TYPENAME: featureType,
                    FILTER: filterValue
                };
                	
                $.ajax({
                    url: queryModel.layer.url,
                    type: 'POST',
                    dataType: 'xml',
                    data: params,
                    success: function(response, status, jqXHR) {
                        var format = new OpenLayers.Format.GML();
                        var features = format.read(response);
                        if(features.length < 1) return false;
                        
                        if(gisclient.componentObjects.gcLayersManager.options.customFeatureStyle[featureType] != 'undefined') {
                            var addFeatures = [];
                            $.each(features, function(e, feature) {
                                addFeatures.push(new OpenLayers.Feature.Vector(feature.geometry, feature.attributes, gisclient.componentObjects.gcLayersManager.options.customFeatureStyle[featureType]));
                            });
                            targetLayer.addFeatures(addFeatures);
                        } else {
                            targetLayer.addFeatures(features);
                        }
                        if(typeof(callback) == 'function') callback(features);
                        return true;
                    },
                    error: function(response, status, jqXHR) {
                        gisclient.log(jqXHR.responseText);
                        return false;
                    }
                });
				
            } else gisclient.log(where);
            return false;
        },
		
        zoomToExtent: function(bounds, minScale) {
            var extendedBounds = new OpenLayers.Bounds(
                bounds.left-20,
                bounds.bottom-20,
                bounds.right+20,
                bounds.top+20
                );

            // set default value for minScale
            if (typeof minScale == 'undefined') {
                minScale = 1000;
            }

            // calculate minzoomlevel from minscale
            var dpi = OpenLayers.DOTS_PER_INCH;
            var res = minScale / (dpi * 100/2.54);
            var minZoomLevel = Math.round(gisclient.map.getZoomForResolution(res, true));

            // get zoomlevel from extent
            var zoom = gisclient.map.getZoomForExtent(extendedBounds);

            // zoom to minscale, when the extent is very small
            if(zoom >= minZoomLevel) {
                gisclient.map.setCenter(bounds.getCenterLonLat(), minZoomLevel);
            } else {
                gisclient.map.zoomToExtent(extendedBounds);
            }
        },
        
        autocompleteFromQueryableLayer: function(request, response) {
            var featureType = this.options.feature;
            var selectedField = this.options.selectedField;
            var useWfs = this.options.useWfs;
            var fieldId = featureType.fields[selectedField].fieldId;

            if(typeof(this.options.useWfs) != 'undefined' && this.options.useWfs == false) {
                var params = {
                    field_id: fieldId,
                    filter: request.term,
                    lang: gisclient.getLanguage()
                };
                
                if(typeof(filterByUserDoId) != 'undefined' && filterByUserDoId) {
                    var hasDoId = false;
                    var featureObj = gisclient.componentObjects.gcLayersManager.getQueryableLayer(featureType.featureId);
                    $.each(featureObj.properties, function(index, property) {
                        if(property.name == 'do_id') hasDoId = true;
                    });
                    if(hasDoId) params.do_id = userDoId;
                }
                
                $.ajax({
                    type: 'GET',
                    url: gisclient.getMapOptions().autocompleteServiceUrl,
                    data: params,
                    dataType: 'json',
                    success: function(getdata) {
                        if(typeof(getdata) != 'object' || typeof(getdata.result) == 'undefined' || getdata.result != 'ok') {
                            response([]);
                            return;
                        }
                        var data = [];
                        
                        var returnData = [];
                        $.each(getdata.data, function(e, row) {
                            returnData.push({
                                label:row
                            });
                        });

                        response(returnData);
                    },
                    error: function() {
                    }
                });
                return;
            }
            

            var params = {
                PROJECT: gisclient.getProject(),
                MAP: featureType.layer.parameters.map,
                SERVICE: 'WFS',
                LANG: gisclient.getLanguage(),
                VERSION: '1.0.0',
                REQUEST: 'GETFEATURE',
                SRS: gisclient.getProjection(),
                TYPENAME: featureType.featureId,
                PROPERTYNAME: '('+selectedField+')',
                OUTPUTFORMAT: 'text/xml',
                SUBTYPE: 'gml/2.1.2'
            };
			
            var filters = [];
            if(request.term.length > 0) {
                filters.push(new OpenLayers.Filter.Comparison({
                    type: OpenLayers.Filter.Comparison.LIKE,
                    property: selectedField,
                    value: '*'+request.term+'*'
                }));
            }
            
            if(featureType.defaultFilters) {
                if(featureType.defaultFilters.length > 1) {
                    var defaultFilters = new OpenLayers.Filter.Logical({
                        type: OpenLayers.Filter.Logical.AND,
                        filters: $.extend(true, [], featureType.defaultFilters)
                    });
                } else {
                    var defaultFilters = $.extend(true, [], featureType.defaultFilters)[0];
                }
                filters.push(defaultFilters);
            }

            if(this.options.preFilterField) {
                filters.push(new OpenLayers.Filter.Comparison({
                    type: OpenLayers.Filter.Comparison.EQUAL_TO,
                    property: this.options.preFilterField,
                    value: $(this.options.preFilterInputId).val()
                }));
            }
            
            if(filters.length > 0) {
                var filter;
                if(filters.length > 1) {
                    filter = new OpenLayers.Filter.Logical({
                        type: OpenLayers.Filter.Logical.AND,
                        filters: filters
                    });
                } else {
                    filter = filters[0];
                }
                
                var filter_1_1 = new OpenLayers.Format.Filter({
                    version: "1.0.0"
                });
                var xml = new OpenLayers.Format.XML();
                var filterValue = xml.write(filter_1_1.write(filter));
                /* MAPSERVER HACK: need to specify matchcase=false in order to get case insensitive search */
                filterValue = filterValue.replace('escape="!">', 'escape="!" matchCase="false">');
                params.FILTER = filterValue;
            }

            $.ajax({
                url: featureType.layer.url,
                type: 'POST',
                dataType: 'xml',
                data: params,
                success: function(data, status, jqXHR) {
                    var format = new OpenLayers.Format.GML();
                    var features = format.read(data);
                    if(features.length < 1) {
                        response([]);
                        return false;
                    }
					
                    var data = [];
					
                    if(features.length > 0) {
                        $.each(features, function(e, feature) {
                            if($.inArray(feature.attributes[selectedField], data) == -1) data.push(feature.attributes[selectedField]);
                        });
                    }
                    data.sort();
                    var returnData = [];
                    $.each(data, function(e, row) {
                        returnData.push({
                            label:row
                        });
                    });
                    response(returnData);
                },
                error: function() {
                    gisclient.log(arguments);
                    return false;
                }
            });
        },
		
        numberFormat: function(number, decimals, decimalSeparator, thousandSeparator) {
            var self = this;
			
            if(typeof(decimalSeparator) == 'undefined') decimalSeparator = ',';
            if(typeof(thousandSeparator) == 'undefined') thousandSeparator = '.';
			
            var multiplier = Math.pow(10, decimals);
            number = Math.round(number*multiplier)/multiplier;
            var numberString = new String(number);
            if(numberString.indexOf('.') > -1) numberString = numberString.replace('.', decimalSeparator);
            var thousands = Math.floor(number/1000);
            if(thousands > 1) {
                var thousandsString = new String(thousands);
                var notThousands = numberString.substr(thousandsString.length);
                numberString = thousandsString + thousandSeparator + notThousands;
            }
            return numberString;
        },
		
        initMapImageDialog: function() {
            $('body').append('<div id="div_mapimage_dialog"></div>');
            var options = {};
            if(typeof(gisclient.componentsOptions['mapImageDialog']) != 'undefined') options = gisclient.componentsOptions['mapImageDialog'];
            $('#div_mapimage_dialog').mapImageDialog(options);
        },
        
        initContext: function(options) {
            $('body').append('<div id="gc_div_context"></div>');
            $('#gc_div_context').contextHandler(options);
        },
		
        getContext: function(id, byUser) {
            gisclient.componentObjects.contextHandler.getContext(id, byUser);
        },
		
        componentExists: function(componentName) {
            var self = this;
			
            return (typeof(self.componentObjects[componentName]) == 'object');
        },
		
        toolExists: function(toolName) {
            var self = this;
			
            return (typeof(self.toolObjects[toolName]) == 'object');
        },
		
        exportXls: function(featureType, features) {
            var self = this;
			
            var queryableLayer = gisclient.componentObjects.gcLayersManager.getQueryableLayer(featureType);
            var fields = [];
			
            $.each(queryableLayer.fields, function(e, field) {
                fields.push({
                    field_name:field.name, 
                    title:field.fieldHeader
                });
            });
			
            var data = [];
            $.each(features, function(e, feature) {
                var row = {};
                $.each(queryableLayer.fields, function(name, foo) {
                    if(typeof(feature.attributes[name]) != 'undefined') {
                        row[name] = feature.attributes[name];
                    }
                });
                data.push(row);
            });
			
            var params = {
                export_format: 'xls',
                feature_type: featureType,
                fields: fields,
                data: data
            };
			
            $.ajax({
                type:'POST',
                dataType:'json',
                url:gisclient.getMapOptions().mapExportServiceUrl,
                data: params,
                success: function(response) {
                    if(typeof(response) != 'object' || typeof(response.result) == 'undefined' || response.result != 'ok') {
                        alert('Error');
                    }
                    location.href = response.file;
                },
                error: function() {
                    alert('Error');
                }
            });
        },
        
        showAttachment: function(fileName) {
            var url = this.getMapOptions().filesUrl + fileName;
            this.openPopup(url);
        },
        
        showImage: function(fileName) {
            var url = this.getMapOptions().filesUrl + fileName;
            this.openPopup(url);
        },
        
        log: function(message) { 
            console.log(message);
            console.trace();
        },
        
        isMobile: function() {
            var self = this;
            
            if(self.options.isMobile === null) {
                self.options.isMobile = isMobile.any();
                // TODO: remove!!??
                self.options.isMobile = true; //temp debug
            }
            return self.options.isMobile;
        },
        
        getGPSPosition: function(config) {
            var self = this;
            var defaultConfig = {
                locationupdated: function() {},
                locationfailed: function() {},
                locationuncapable: function() {},
                geolocateConfig: {
                    watch:false,
                    bind:false,
                    geolocationOptions: {
                        enableHighAccuracy: true, // required to turn on gps requests!
                        maximumAge: 3000,
                        timeout: 50000
                    }
                },
                scope: self
            };
            config = $.extend(defaultConfig, config);
            
            
            if(!self.internalVars.geolocateControl) {
                self.internalVars.geolocateControl = new OpenLayers.Control.Geolocate(config.geolocateConfig);
                self.map.addControl(self.internalVars.geolocateControl);
            } else if(self.internalVars.geolocateLastConfig) {
                self.internalVars.geolocateControl.events.unregister('locationupdated', self.internalVars.geolocateLastConfig.scope, self.internalVars.geolocateLastConfig.locationupdated);
                self.internalVars.geolocateControl.events.unregister('locationfailed', self.internalVars.geolocateLastConfig.scope, self.internalVars.geolocateLastConfig.locationfailed);
                self.internalVars.geolocateControl.events.unregister('locationuncapable', self.internalVars.geolocateLastConfig.scope, self.internalVars.geolocateLastConfig.locationuncapable);
            }
            
            self.internalVars.geolocateControl.events.register('locationupdated', config.scope, config.locationupdated);
            self.internalVars.geolocateControl.events.register('locationfailed', config.scope, config.locationfailed);
            self.internalVars.geolocateControl.events.register('locationuncapable', config.scope, config.locationuncapable);
            
            self.internalVars.geolocateControl.activate();
            self.internalVars.geolocateControl.getCurrentLocation();
            
            self.internalVars.geolocateLastConfig = config;
        }
    });

    $.extend($.ui.gisclientmap, {
        version: "3.0.0",
        instances: []
    });
	

})(jQuery);

// Define console (if not already defined)
if (!window.console) {
    window.console = { 
        log: function() { },
        debug: function() { console.log(arguments) }, 
        error: function() { console.log(arguments) },
        info: function() { console.log(arguments) },
        warn: function() { console.log(arguments) },
        trace: function() { console.log(arguments) } 
    }; 
}

var isMobile = {
    Android: function() {
        return navigator.userAgent.match(/Android/i);
    },
    BlackBerry: function() {
        return navigator.userAgent.match(/BlackBerry/i);
    },
    iOS: function() {
        return navigator.userAgent.match(/iPhone|iPad|iPod/i);
    },
    Opera: function() {
        return navigator.userAgent.match(/Opera Mini/i);
    },
    Windows: function() {
        return navigator.userAgent.match(/IEMobile/i);
    },
    any: function() {
        return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera() || isMobile.Windows());
    }
};
