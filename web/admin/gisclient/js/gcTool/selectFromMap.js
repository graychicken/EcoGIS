/*
 */


(function($, undefined) {


    $.widget("gcTool.selectFromMap", $.ui.gcTool, {

        widgetEventPrefix: "selectFromMap",

        options: {
            label: OpenLayers.i18n('Select'),
            icons: {
                primary: 'select' // TODO: choose better name
            },
            text: false,
            idDataList: null,
            idDialog: null, // dialog container id
            hoverControl: null,
            controls: [], // array of the control handlers
            control: null,
            selectionType: 'box', // default selection type
            defaultSelectionLayer: null,   // default layer to query (null=all layer)
            selectionTypeList: [/*{point: 'Point'}, */{box: 'Box'}, {polygon: 'Polygon'}, {circle: 'Circle'}],
            limitVectorFeatures: 100, // if the selected features are more of this limit, the user must to confirm the selection
            tooltips: true,
            tooltipWidth: 200,
            selectionBuffer: 5,  //map unit at scale 1:1000
            refScale: 1000,
            cols: {},
            actionSelectionParent: 'after_selection_action', // the parent of the after selection action radio button
            requests: {}, // object to store the requests, because we need to check if all the requests are returned
            pointSelectionDefaultTolerance: 10, // the default tolerance for the point selection
            tolerance: null, // the current selected tolerance
            displayFeatures: true
            
        },
        
        _create: function() {
            var self = this;
            
            $.extend(this, $.searchEngine);
            // html for the selection settings dialog
            var html = '<div id="selection_settings_mode" class="noflow">'
                + '<label>' + OpenLayers.i18n('Geometry type') +'</label> '
                + '<select name="selection_type" id="selection_type">';
                $.each(self.options.selectionTypeList, function(dummy, obj) {
                    $.each(obj, function(key, text) {
                        html += '<option value="' + key + '">' + OpenLayers.i18n(text) + '</option>';
                    });
                });
                    
            html += '</select></div>'
                 + '<div id="selection_settings_point" style="display:none;float:left;">'+OpenLayers.i18n('Tolerance')+' <span id="selection_tolerance_value">10</span>  '+OpenLayers.i18n('Meters')+'<div id="selection_tolerance" style="width:250px;"></div></div>'
                 + '<div class="separator_dialog_without_fieldset"></div><div id="after_selection_action" class="noflow"><label>'+OpenLayers.i18n('After selection action')+'</label><div class="radio_container"><input class="radio" type="radio" name="after_selection_action" value="zoom"> '+OpenLayers.i18n('Zoom')+'<br/>    <input class="radio" type="radio" name="after_selection_action" value="center"> '+OpenLayers.i18n('Center')+'<br/> <input class="radio" type="radio" name="after_selection_action" value="none" checked> '+OpenLayers.i18n('None')+'</div> </div><div class="separator_dialog_without_fieldset"></div>'
                 + '<div class="noflow buttons"><button class="button" name="use_selected_features">'+OpenLayers.i18n('Use selected features')+'</button> <button class="button" name="annulla_selezione">'+OpenLayers.i18n('Undo selection')+'</button></div>';
            $('#'+self.options.idDialog).html(html);
            $('#selection_type').val(self.options.selectionType);
            
            var options = {
                draggable: true,
                title: OpenLayers.i18n('Selection options'),
                autoOpen:false,
                width: 445,
                close: function(event, self) {
                    var self  = gisclient.toolObjects.selectFromMap;
                    self._abort();
                }
            }
            var dialogOptions = $.extend(gisclient.options.dialogDefaultPosition, options);
            $('#selection_settings').dialog(dialogOptions);
            
            var html = '<div id="datalist_searchresults"></div>';
            $('#'+self.options.idDataList).html(html);

            $.ui.gcTool.prototype._create.apply(self, arguments);
            
            // create the custom control to handle the selection
            self.options.control = new OpenLayers.Control({autoActivate:false});
            OpenLayers.Util.extend(self.options.control, {
                draw: function () {
                    this.box = new OpenLayers.Handler.Box(self.options.control,
                        {"done": self._handleSelection},
                        {boxDivClassName: 'ui-state-highlight ui-priority-secondary'}
                    );
                    this.polygon = new OpenLayers.Handler.Polygon(self.options.control,
                        {"done": self._handleSelection}
                    );
                    this.circle = new OpenLayers.Handler.RegularPolygon(self.options.control,
                        {'done': self._handleSelection},
                        {'sides':30}
                    );
                    this.point = new OpenLayers.Handler.Point(self.options.control,
                        {'done': self._handleSelection}
                    );
                },
                CLASS_NAME: 'OpenLayers.Control.selectByBox'
            });
            // HACKS: attach gisclient and self to the control to use them in _handleSelection
            self.options.control.self = self;
            // populate the handlers array
            // Ticket #366
            self.options.controls = ['point', 'box','polygon','circle'];
            
            gisclient.map.addControl(self.options.control);
            
            // create a control to hilight table rows when hovering features
            var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
            self.options.hoverControl = new OpenLayers.Control.SelectFeature(selectionLayer, {hover:true});
            self.options.hoverControl.events.register('featurehighlighted', self, self._highlightTableRow);
            self.options.hoverControl.events.register('featureunhighlighted', self, self._unhighlightTableRow);
            gisclient.map.addControl(self.options.hoverControl);
            
            // when the user change the selection type, toggle the control (handler)
            $('#selection_type').change(function() {
                self._toggleHandler($(this).val());
            });
            
            $('#selection_settings button[name="annulla_selezione"]').click(function(event) {
                event.preventDefault();
                self.unSelectAll();
            });
            
            $('#selection_settings button[name="use_selected_features"]').click(function(event) {
                event.preventDefault();
                self.useSelectedFeatures();
            });
            
            // create the options for the target of the selection
            var queryableLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers();
            
            var opt='';
            var currentGroup = null;

            $.each(queryableLayers, function(featureType, queryableLayer) {
                if(currentGroup != queryableLayer.groupTitle) {
                    opt += '<optgroup label="'+queryableLayer.groupTitle+'">';
                    currentGroup = queryableLayer.groupTitle;
                }
                opt += '<option value="'+featureType+'">'+queryableLayer.title+'</option>';
            });

            if(opt.length>0){
                var qt = '<label>'+OpenLayers.i18n('Layer')+'</label><select name="qtlist" id="qtlist"><option value="attivi">'+OpenLayers.i18n('Active layers')+'</option>';//LANG
                qt += opt;
                qt += '</select>';
                $('#selection_settings_mode').append(qt);
                if (self.options.defaultSelectionLayer) {
                    $('#qtlist').val(self.options.defaultSelectionLayer);
                }
            }
            
            // select width ie fix
            $('select#qtlist').ieSelectWidth({
                containerClassName : 'select-container',
                overlayClassName : 'select-overlay'
            });
            
        },
        
        _click: function(event) {
            var self = event.data.self;
            
            $.ui.gcTool.prototype._click.apply(self, arguments);

            // open the selection settings dialog           
            if(!$('#selection_settings').dialog('isOpen')) $('#selection_settings').dialog('open');
            
            // toggle the control (handler)
            self._toggleHandler(self.options.selectionType);
            
            // check if hoverControl is active and eventually active it
            if(!self.options.hoverControl.active) self.options.hoverControl.activate();
        },
        
        _toggleHandler: function(selectionType) {
            var self = this;
            // deactivate all the handlers
            for(var i in self.options.controls) {
                self.options.control[self.options.controls[i]].deactivate();
            }
            // ...and activate the selected one
            
            self.options.control[selectionType].activate();
            if(selectionType == 'point') {
                // show the point selection options (tolerance slider)
                $('#selection_settings_point').show();
                $('#selection_tolerance').slider({value: self.options.pointSelectionDefaultTolerance,width:350}).bind('slidechange', {self:self}, function(event, ui) {
                    var self = event.data.self;
                    // update the tolerance value
                    self.options.tolerance = ui.value;
                    // update the tolerance value shown to the user
                    $('#selection_tolerance_value').html(ui.value);
                });
            } else {
                // hide the point selection options, destroy the slider and set the tolerance value to default
                $('#selection_settings_point').hide();
                if ($('#selection_tolerance').hasClass("ui-slider")) {
                    $('#selection_tolerance').slider('destroy');
                }
                self.options.tolerance = self.options.pointSelectionDefaultTolerance;
                $('#selection_tolerance_value').html(self.options.pointSelectionDefaultTolerance);
            }
            self.options.selectionType = selectionType;
        },
        
        _handleSelection: function(geom) {
            var self = gisclient.toolObjects.selectFromMap;

            gisclient.componentObjects.loadingHandler.show();
            
            // check the geometry drown by the user and assign a filter type and value
            if(typeof(geom.CLASS_NAME) == 'undefined' && typeof(geom) == 'object') {
                var orFilters = [];
                $.each(geom, function(e, geometry) {
                    orFilters.push(new OpenLayers.Filter.Spatial({
                        type: OpenLayers.Filter.Spatial.INTERSECTS,
                        value: geometry,
                        projection: gisclient.getProjection(),
                        property: 'the_geom'
                    }));
                });
                var filter = new OpenLayers.Filter.Logical({
                    type: OpenLayers.Filter.Logical.OR,
                    filters: orFilters
                });
            } else {
                var type, value;
                if(geom.CLASS_NAME == 'OpenLayers.Bounds') {
                    type = OpenLayers.Filter.Spatial.BBOX;
                    var lb = gisclient.map.getLonLatFromPixel(new OpenLayers.Pixel(geom.left, geom.bottom)); 
                    var rt = gisclient.map.getLonLatFromPixel(new OpenLayers.Pixel(geom.right, geom.top));
                    value = new OpenLayers.Bounds(lb.lon, lb.lat, rt.lon, rt.lat);
                    self.options.selectionExtent = value;
                } else if(geom.CLASS_NAME == 'OpenLayers.Geometry.Polygon' || geom.CLASS_NAME.substr(0, 25) == 'OpenLayers.Geometry.Multi' || geom.CLASS_NAME == 'OpenLayers.Geometry.LineString') {
                    type = OpenLayers.Filter.Spatial.INTERSECTS;
                    value = geom;
                    self.options.selectionExtent = geom.getBounds();
                } else if(geom.CLASS_NAME == 'OpenLayers.Geometry.Point') {
                    type = OpenLayers.Filter.Spatial.INTERSECTS;
                    var tolerance = parseInt($('#selection_tolerance').slider("option","value"));
                    value = OpenLayers.Geometry.Polygon.createRegularPolygon(geom, tolerance, 30, 90);
                    self.options.selectionExtent = value.getBounds();
                } else if(geom.CLASS_NAME == 'OpenLayers.Pixel') {
                    var lonLat = gisclient.map.getLonLatFromPixel(new OpenLayers.Pixel(geom.x, geom.y));
                    geom = new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat);
                    type = OpenLayers.Filter.Spatial.INTERSECTS;
                    value = OpenLayers.Geometry.Polygon.createRegularPolygon(geom, self.options.selectionBuffer * (gisclient.map.getScale()/self.options.refScale), 20, 90);
                    self.options.selectionExtent = value;
                } else {
                    alert(OpenLayers.i18n('Invalid selection'));
                    gisclient.componentObjects.loadingHandler.hide();
                    return false;
                }
                
                // create the openlayers spatial filter
                var filter = new OpenLayers.Filter.Spatial({
                    type: type,
                    value: value,
                    projection: gisclient.getProjection(),
                    property: 'the_geom'
                });
            }
            // populate the queryLayers array
            var queryLayers = [];
            // the user wants to query a specific layer
            if($('#qtlist').val() != 'attivi') {
                var queryableLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers();
                queryLayers.push(queryableLayers[$('#qtlist').val()]);
            } else { // the user wants to query all the active layers
                queryLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers(true);
            }
            // start the query
            self._query(queryLayers, filter);
        },
        
        _abort: function() {
            var self = this;

            //self.unSelectAll();
            
            gisclient.componentObjects.loadingHandler.hide();
            
            if($('#selection_settings').dialog('isOpen')) $('#selection_settings').dialog('close');
            
            for(var i in self.options.controls) {
                self.options.control[self.options.controls[i]].deactivate();
            }
        },
        
        useSelectedFeatures: function() {
            var self = this;
            
            var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
            
            var geometries = [];
            $.each(selectionLayer.features, function(e, feature) {
                if(feature.geometry.CLASS_NAME.substr(0, 25) == 'OpenLayers.Geometry.Multi') {
                    $.each(feature.geometry.components, function(i, singleGeom) {
                        geometries.push(self.toPolygon(singleGeom));
                    });
                } else {
                    geometries.push(self.toPolygon(feature.geometry));
                }
            });
            
            if(geometries.length == 0) return;
            if(geometries.length == 1) self._handleSelection(geometries[0]);
            else self._handleSelection(geometries);
        },
        
        toPolygon: function(geometry) {
            if(geometry.CLASS_NAME == 'OpenLayers.Geometry.Point') {
                return OpenLayers.Geometry.Polygon.createRegularPolygon(geometry, 1, 4);
            }
            return geometry;
        },
        
        _deactivate: function() {
            var self = this;
            
            self._abort();
        }

    });

    $.extend($.gcTool.selectFromMap, {
        version: "3.0.0"
    });
})(jQuery);