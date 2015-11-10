/*
 */


(function($, undefined) {


    $.widget("gcTool.drawFeature", $.ui.gcTool, {

        widgetEventPrefix: "drawFeature",

        options: {
            label: OpenLayers.i18n('Draw'),
            icons: {
                primary: 'draw_feature'
            },
            text: false,
            geometryType: 'line',
            geomTypes: null,
            singleGeometryBehaviour: 'alert',
            initControls: ['polygon','line','point'],
            control: null,
            customCallback: null,
            useSnap: null,
            showInstructions: null
        },
		
        internalVars: {
            lastPoint: null,
            editingLayer: null,
            controls: {},
            currentGeometryType: null
        },
		
        help: {
            create : OpenLayers.i18n("1. Cliccare sulla mappa per inserire il primo punto.<br>2. Cliccare sulla mappa per inserire i punti successivi.<br>3. Per chiudere la geometria effettaure doppio clic sull'ultimo punto."),
            modify:  OpenLayers.i18n("1. Selezionare l'oggetto cliccandoci sopra, l'oggetto verrà evidenziato.<br>2. Cliccare sui vertici per spostarli.<br>3. Cliccare sui punti intermedi per creare nuovi vertici."),
            transform: OpenLayers.i18n("1. Selezionare l'oggetto cliccandoci sopra, verrà evidenziato un riquadro intorno all'oggetto.<br>2. Agendo sui vertici o i bordi del riquadro è possibile allargare, spostare e ruotare l'oggetto."),
            remove: OpenLayers.i18n("1. Selezionare l'oggetto cliccandoci sopra. Si aprirà un dialogo di conferma eliminazione.<br>2. Per eliminare l'oggetto confermare e cliccare su Salva, altrimenti cliccare su annulla.")
        },

        _create: function() {
            var self = this;

            $.ui.gcTool.prototype._create.apply(self, arguments);
            
            if(self.options.useSnap === null) self.options.useSnap = !gisclient.isMobile();
            if(self.options.showInstructions === null) self.options.showInstructions = !gisclient.isMobile();

            var polygonOptions = {
                handlerOptions: {
                    holeModifier: 'altKey'
                }, 
                allowMulti: true,
                callbacks : {
                   "point": self._pointHandler
                },
            };
            var lineOptions = {
                allowMulti: true
            };
            var pointOptions = {
                allowMulti: true
            };

            if(self.options.geomTypes !== null) {
                self.options.initControls = [];
                $.each(self.options.geomTypes, function(e, geomType) {
                    switch(geomType) {
                        //@fallthrough
                        case 'Point':
                            pointOptions.allowMulti = false;
                        case 'MultiPoint':
                            self.options.initControls.push('point');
                            break;

                        case 'LineString':
                            lineOptions.allowMulti = false;
                        case 'MultiLineString':
                            self.options.initControls.push('line');
                            break;

                        case 'Polygon':
                            polygonOptions.allowMulti = false;
                        case 'MultiPolygon':
                            self.options.initControls.push('polygon');
                            break;
                    }
                });
            }
            
            // create controls (one for each geometry type) and add to map
            self.internalVars.editingLayer = gisclient.componentObjects.gcLayersManager.getEditingLayer();
            if($.inArray('polygon', self.options.initControls) >= 0) {
                self.internalVars.controls.polygon = new OpenLayers.Control.DrawFeature(self.internalVars.editingLayer, OpenLayers.Handler.Polygon, polygonOptions);
                gisclient.map.addControl(self.internalVars.controls.polygon);
            }
            if($.inArray('line', self.options.initControls) >= 0) {
                self.internalVars.controls.line = new OpenLayers.Control.DrawFeature(self.internalVars.editingLayer, OpenLayers.Handler.Path, lineOptions);
                gisclient.map.addControl(self.internalVars.controls.line);
            }
            if($.inArray('point', self.options.initControls) >= 0) {
                self.internalVars.controls.point = new OpenLayers.Control.DrawFeature(self.internalVars.editingLayer, OpenLayers.Handler.Point, pointOptions);
                gisclient.map.addControl(self.internalVars.controls.point);				
            }
            self.internalVars.controls.modify = new OpenLayers.Control.ModifyFeature(self.internalVars.editingLayer);
            self.internalVars.controls.transform = new OpenLayers.Control.TransformFeature(self.internalVars.editingLayer);
            self.internalVars.controls.transform.events.register("transformcomplete", self, self._transformComplete);
            self.internalVars.controls.remove = new OpenLayers.Control.SelectFeature(self.internalVars.editingLayer);
            self.internalVars.controls.remove.events.register("featurehighlighted", self, self._removeFeature);
            gisclient.map.addControls([self.internalVars.controls.modify, self.internalVars.controls.transform, self.internalVars.controls.remove]);
			
            if($('#draw_feature_dialog').length < 1) {
                $('body').append('<div id="draw_feature_dialog"></div>');
            }
			
            var html = '<div class="noflow"><label>Geometria:</label><select style="width:auto" name="geometry_type">';
            if($.inArray('point', self.options.initControls) >= 0) {
                html += '<option value="point">'+OpenLayers.i18n('Point')+'</option>';
            }
            if($.inArray('line', self.options.initControls) >= 0) {
                html += '<option value="line">'+OpenLayers.i18n('Line')+'</option>';
            }
            if($.inArray('polygon', self.options.initControls) >= 0) {
                html += '<option value="polygon">'+OpenLayers.i18n('Polygon')+'</option>';
            }
            html += '</select></div>' +
            '<div class="noflow"><label>'+OpenLayers.i18n('Action')+':</label>'+
            '<div class="radio_container">';
            if(gisclient.isMobile()) {
                html += '<select name="editing_action">'+
                    '<option value="create">'+OpenLayers.i18n('Create')+'</option>'+
                    '<option value="modify">'+OpenLayers.i18n('Edit')+'</option>'+
                    '<option value="transform">'+OpenLayers.i18n('Transform')+'</option>'+
                    '<option value="remove">'+OpenLayers.i18n('Delete')+'</option>'+
                    '</select>';
            } else {
                html += '<input class="radio" type="radio" name="editing_action" value="create" checked> '+OpenLayers.i18n('Create')+'<br/> '+
                    '<input class="radio" type="radio" name="editing_action" value="modify"> '+OpenLayers.i18n('Edit')+'<br/> '+
                    '<input class="radio" type="radio" name="editing_action" value="transform"> '+OpenLayers.i18n('Transform')+'<br/> '+
                    '<input class="radio" type="radio" name="editing_action" value="remove"> '+OpenLayers.i18n('Delete');
            }
            html += '</div></div>'+
            '<div class="noflow" style="clear:both;"><label>&nbsp;</label>' +
            '<button title="'+ OpenLayers.i18n('Undo vertex') +'" id="undo" style="margin: 10px 0px 0px; padding: 2px; float: left; display:none"><span class="ui-icon ui-icon-arrowreturnthick-1-w"></span></button><button name="editing_save" style="margin: 10px 0 0 0;">'+OpenLayers.i18n('Save')+'</button></div>'+
            //'<div class="noflow">'+OpenLayers.i18n('From last point')+' <span class="distance"></span></div>'+
            '<div rel="snap_settings"></div>';
            if(self.options.useInstructions) {
                html += '<div rel="help"></div>';
            }
			
            var dialogOptions = $.extend(gisclient.options.dialogDefaultPosition, {
                draggable:true,
                title: OpenLayers.i18n('Draw'),
                width:410,
                autoOpen:false
            });
            $('#draw_feature_dialog').html(html).dialog(dialogOptions);
            
            $('#undo').click(function(event){
                if(!self.internalVars.controls.polygon.undo()){
                    self.internalVars.controls.polygon.cancel();
                }
            });
			
            self.internalVars.currentGeometryType = $('#draw_feature_dialog select[name="geometry_type"]').val();
            self.options.control = self.internalVars.controls[self.internalVars.currentGeometryType];
			
            self._disableSave();
            $('#draw_feature_dialog button[name="editing_save"]').click(function() {
                self._save();
            });
            if(gisclient.isMobile()) {
                $('#draw_feature_dialog select[name="editing_action"]').change(function() {
                    self._activateControl($(this).val());
                });
            } else {
                $('#draw_feature_dialog input[name="editing_action"]').click(function() {
                    self._activateControl($(this).val());
                });
            }
            $('#draw_feature_dialog select[name="geometry_type"]').change(function() {
                console.log(self.options.controlName);
                self.internalVars.currentGeometryType = $(this).val();                
                self._activateControl(self.options.controlName);
            });
            if(/MSIE [6-8].0/.test(navigator.userAgent)){
                alert("Your browser is not supported");
            }
        },
		
        _click: function(event) {
            var self = event.data.self;
			
            $.ui.gcTool.prototype._click.apply(self, arguments);
			
            var queryableLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers();
            if(queryableLayers !== null && self.options.useSnap) {
                self.options.snapIsActive = true;
                $('#draw_feature_dialog div[rel="snap_settings"]').snapPoint();
            }
            if(gisclient.isMobile()) {
                self._activateControl($('#draw_feature_dialog select[name="editing_action"]').val());
            } else {
                self._activateControl($('#draw_feature_dialog input[type="radio"][name="editing_action"]').val());
            }
            $('#draw_feature_dialog').dialog('open');
            
        //$('#draw_feature_dialog input[type="radio"][name="editing_action"][value="create"]').attr('checked', 'checked');
        },
		
        _activateControl: function(controlName) {
            var self = this;

            if(self.internalVars.currentGeometryType === null) return;

            $.each(self.internalVars.controls, function(e, control) {
                self.internalVars.controls[self.internalVars.currentGeometryType].layer.events.unregister('beforefeatureadded', self, self._checkGeometry);
                control.deactivate();
            });
            if (self.internalVars.editingLayer.features.length > 0) {
                if(self._isValid(self.internalVars.editingLayer.features[0])){
                    self._enableSave();
                } else {
                    self._disableSave();
                }
            }
            var disableGeomTypeSelect = true;
            switch(controlName) {
                case 'create':
                    self.internalVars.controls[self.internalVars.currentGeometryType].activate();
                    self.internalVars.controls[self.internalVars.currentGeometryType].layer.events.register('beforefeatureadded', self, self._checkGeometry);
                    if(self.options.useInstructions) $('#draw_feature_dialog div[rel="help"]').html(self.help.create);
                    disableGeomTypeSelect = false;
                    break;
                case 'modify':
                    self.internalVars.controls.modify.activate();
                    if(self.options.useInstructions) $('#draw_feature_dialog div[rel="help"]').html(self.help.modify);
                    break;
                case 'transform':
                    self.internalVars.controls.transform.activate();
                    if(self.options.useInstructions) $('#draw_feature_dialog div[rel="help"]').html(self.help.transform);
                    break;
                case 'remove':
                    self.internalVars.controls.remove.activate();
                    if(self.options.useInstructions) $('#draw_feature_dialog div[rel="help"]').html(self.help.remove);
                    self._disableSave();
                    $('input[value="create"]').attr("disabled", false);
                    break;
                default:
                    self.internalVars.currentGeometryType = controlName;
                    self.internalVars.controls[self.internalVars.currentGeometryType].activate();
                    disableGeomTypeSelect = false;
                    break;
            }

            if(self.internalVars.currentGeometryType === 'polygon') {
                self.internalVars.editingLayer.events.on({
                    "sketchmodified": function(event){
                        self._isValid(event.feature);
                    },
                    "vertexmodified" : function(event){
                        self._isValid(event.feature);
                    },
                    "vertexremoved" : function(event){
                        self._isValid(event.feature);
                    },
                    "featuremodified" : function(event){
                        if(self._isValid(event.feature)){
                            self._enableSave();
                        } else {
                            self._disableSave();
                        }
                    }
                });
            } else {
                self.internalVars.editingLayer.events.remove("sketchmodified");
                self.internalVars.editingLayer.events.remove("vertexmodified");
                self.internalVars.editingLayer.events.remove("vertexremoved");
                self.internalVars.editingLayer.events.remove("featuremodified");
            }
            
            self.options.controlName = controlName;
            if(disableGeomTypeSelect) {
                $('#draw_feature_dialog select[name="geometry_type"]').attr("disabled", true);
            } else {
                $('#draw_feature_dialog select[name="geometry_type"]').attr("disabled", false);
            }
        },
        
        _deactivate: function() {
            var self = this;
            
            //self._abort();
            $('#draw_feature_dialog').dialog('close');
        },

        _checkGeometry: function(event){
            var self = this;
            if(self._isValid(event.feature)){
                self._enableSave();
            } else {
                self._disableSave();
            }
            if(!self.internalVars.controls[self.internalVars.currentGeometryType].allowMulti) {                
                return self._isSingle(event);          
            }
        },
        
        _isSingle: function(event) {
            var self = this;
            var layer = event.object;
            $('#undo').hide();
            
            if(layer.features.length > 0) {
                if(self.options.singleGeometryBehaviour == 'auto') {
                    layer.removeAllFeatures();
                    return true;
                } else {
                    alert(OpenLayers.i18n('Only one feature allowed'));
                    return false;
                }
            }
        },

        _pointHandler: function(aPoint) {
            var self = gisclient.toolObjects.drawFeature;
            var feature = this.events.object.handler.polygon;
            if($('#undo').is(':hidden')) {
                $('#undo').show();
            }
        },

        _isValid: function(feature){
            if(/MSIE [6-8].0/.test(navigator.userAgent)){return;}
            var self = this;
            var wkt = new OpenLayers.Format.WKT();
            var reader = new jsts.io.WKTReader();
            var geomString = wkt.write(feature);
            var input = reader.read(geomString);
            if(!input.isValid()){
                var notValidStyle = feature.layer.styleMap.styles.temporary.defaultStyle;
                notValidStyle.fillColor = "#ff0000";
                notValidStyle.strokeColor = "#ff0000";

                feature.style = notValidStyle;

                return false;
            } else {
                feature.style = null;
                return true;
            }

        },

        _disableSave: function(){
            $('#draw_feature_dialog button[name="editing_save"]').attr("disabled", true);
        },

        _enableSave: function(){
            $('#draw_feature_dialog button[name="editing_save"]').attr("disabled", false);
        },
		
        _removeFeature: function(event) {
            var self = this;
            self.internalVars.controls.remove.unselectAll();
			
            var mpControl = gisclient.map.getControlsByClass('OpenLayers.Control.MousePosition');
            var lastLonLat = gisclient.map.getLonLatFromPixel(mpControl[0].lastXy);
            var point = new OpenLayers.Geometry.Point(lastLonLat.lon, lastLonLat.lat);
			
            var string = OpenLayers.i18n('Are you sure you want to delete this geometry?');
            if(confirm(string)) {
				
                var feature = self.internalVars.editingLayer.getFeatureById(event.feature.id).clone();
                self.internalVars.editingLayer.destroyFeatures([event.feature]);
				
                if(feature.geometry.id.indexOf('Multi') > -1 && feature.geometry.components.length > 1) {
                    var minDistance = null;
                    var selectedComponent = null;
                    $.each(feature.geometry.components, function(e, component) {
                        var distance = component.distanceTo(point);
                        if(minDistance == null || minDistance > distance) {
                            minDistance = distance;
                            selectedComponent = component;
                        }
                    });
                    if(selectedComponent != null) {
                        self.internalVars.controls.remove.unselectAll();
                        feature.geometry.removeComponent(selectedComponent);
                        self.internalVars.editingLayer.addFeatures(feature);
                    }
                }
            }
        },
        
        _transformComplete: function(event) {
            event.feature.state = 'Update';
        },
		
        _save: function() {
            var self = this;
			
            if(self.options.customCallback == null) {
                var uiHash = self._getUIHash();
                uiHash.features = self.internalVars.editingLayer.features;
			
                self._trigger( "save", null, uiHash);
            } else {
                self.options.customCallback(self.internalVars.editingLayer.features);
            }
        },
		
        _abort: function() {
            var self = this;
			
            self.internalVars.editingLayer.removeAllFeatures();
        }
		
    });

    $.extend($.gcTool.drawFeature, {
        version: "3.0.0"
    });
})(jQuery);