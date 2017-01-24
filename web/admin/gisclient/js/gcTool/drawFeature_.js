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
            customCallback: null
		},
		
		internalVars: {
			lastPoint: null,
			editingLayer: null,
			controls: {},
			currentGeometryType: null
		},
		
        help: {
            create : OpenLayers.i18n("1. Click on the map to insert the first point.<br>2. Click on the map to insert the next point.<br>3. To close the geometry double-click the last point."),
            modify:  OpenLayers.i18n("1. Select object clicking on it, the object will highlight.<br>2. Click on vertexes to move them.<br>3. Click on intermediate points to add new vertexes."),
            transform: OpenLayers.i18n("1. Select object by clicking on it, a box around the object will appear-<br>2. By moving the vertexes or the lines of the box you can scale, move or retate the object."),
            remove: OpenLayers.i18n("1. Select object clicking on it. A dialog box asks you to confirm the deletion.<br>2. To delete the object confirm and click SAVE, otherwise click on CANCEL.")
        },

		_create: function() {
			var self = this;

			$.ui.gcTool.prototype._create.apply(self, arguments);
            
            var polygonOptions = {handlerOptions: {holeModifier: 'altKey'}, allowMulti: true};
            var lineOptions = {allowMulti: true};
            var pointOptions = {allowMulti: true};

            if(self.options.geomTypes != null) {
                self.options.initControls = [];
                $.each(self.options.geomTypes, function(e, geomType) {
                    switch(geomType) {
                        case 'Point':
                        case 'MultiPoint':
                            self.options.initControls.push('point');
                            if(geomType == 'Point') pointOptions.allowMulti = false;
                        break;
                        case 'LineString':
                        case 'MultiLineString':
                            self.options.initControls.push('line');
                            if(geomType == 'LineString') lineOptions.allowMulti = false;
                        break;
                        case 'Polygon':
                        case 'MultiPolygon':
                            self.options.initControls.push('polygon');
                            if(geomType == 'Polygon') polygonOptions.allowMulti = false;
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
			self.internalVars.controls.remove = new OpenLayers.Control.SelectFeature(self.internalVars.editingLayer);
			self.internalVars.controls.remove.events.register("featurehighlighted", self, self._removeFeature);
			gisclient.map.addControls([self.internalVars.controls.modify, self.internalVars.controls.transform, self.internalVars.controls.remove]);
			
			if($('#draw_feature_dialog').length < 1) {
				$('body').append('<div id="draw_feature_dialog"></div>');
			}
			
            var html = '<label>Geometria</label><div class="noflow"><label>&nbsp;</label><select name="geometry_type">';
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
				'<div class="noflow"><label>'+OpenLayers.i18n('Action')+'</label>'+
				'<div class="radio_container">'+
				'<input class="radio" type="radio" name="editing_action" value="create" checked> '+OpenLayers.i18n('Create')+'<br/> '+
				'<input class="radio" type="radio" name="editing_action" value="modify"> '+OpenLayers.i18n('Edit')+'<br/> '+
				'<input class="radio" type="radio" name="editing_action" value="transform"> '+OpenLayers.i18n('Transform')+'<br/> '+
				'<input class="radio" type="radio" name="editing_action" value="remove"> '+OpenLayers.i18n('Delete')+
				'</div></div>'+
				'<div class="noflow"><label>&nbsp;</label><button name="editing_save">'+OpenLayers.i18n('Save')+'</button></div>'+
				//'<div class="noflow">'+OpenLayers.i18n('From last point')+' <span class="distance"></span></div>'+
				'<hr><div rel="snap_settings"></div>'+
				'<div rel="help"></div>';
			
            var dialogOptions = $.extend(gisclient.options.dialogDefaultPosition, {
                draggable:true,
				title: OpenLayers.i18n('Draw'),
                width:350,
                autoOpen:false
            });
			$('#draw_feature_dialog').html(html).dialog(dialogOptions);
			
			self.internalVars.currentGeometryType = $('#draw_feature_dialog select[name="geometry_type"]').val();
			self.options.control = self.internalVars.controls[self.internalVars.currentGeometryType];
			
            $('#draw_feature_dialog button[name="editing_save"]').click(function() {
                self._save();
            });
            $('#draw_feature_dialog input[name="editing_action"]').click(function() {
                self._activateControl($(this).val());
            });
            $('#draw_feature_dialog select[name="geometry_type"]').change(function() {
                self._activateControl($(this).val());
            });
		},
		
		_click: function(event) {
			var self = event.data.self;
			
			$.ui.gcTool.prototype._click.apply(self, arguments);
			
            var queryableLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers();
            if(queryableLayers != null) {
                self.options.snapIsActive = true;
                $('#draw_feature_dialog div[rel="snap_settings"]').snapPoint();
            }
			self._activateControl($('#draw_feature_dialog input[type="radio"][name="editing_action"]').val());
			$('#draw_feature_dialog').dialog('open');
            
            //$('#draw_feature_dialog input[type="radio"][name="editing_action"][value="create"]').attr('checked', 'checked');
		},
		
        _activateControl: function(controlName) {
            var self = this;
			
			$.each(self.internalVars.controls, function(e, control) {
                if(!control.allowMulti) {
                    self.internalVars.controls[self.internalVars.currentGeometryType].layer.events.unregister('beforefeatureadded', self, self._checkSingleGeometry);
                }
                control.deactivate();
            });
			
            var disableGeomTypeSelect = true;
            switch(controlName) {
                case 'create':
                    self.internalVars.controls[self.internalVars.currentGeometryType].activate();
                    if(!self.internalVars.controls[self.internalVars.currentGeometryType].allowMulti) {
                        self.internalVars.controls[self.internalVars.currentGeometryType].layer.events.register('beforefeatureadded', self, self._checkSingleGeometry);
                    }
                    $('#draw_feature_dialog div[rel="help"]').html(self.help.create);
                    disableGeomTypeSelect = false;
                break;
                case 'modify':
                    self.internalVars.controls.modify.activate();
                    $('#draw_feature_dialog div[rel="help"]').html(self.help.modify);
                break;
                case 'transform':
                    self.internalVars.controls.transform.activate();
                    $('#draw_feature_dialog div[rel="help"]').html(self.help.transform);
                break;
                case 'remove':
                    self.internalVars.controls.remove.activate();
                    $('#draw_feature_dialog div[rel="help"]').html(self.help.remove);
                break;
                default:
					self.internalVars.currentGeometryType = controlName;
                    self.internalVars.controls[self.internalVars.currentGeometryType].activate();
                    disableGeomTypeSelect = false;
                break;
            }
            
            if(disableGeomTypeSelect) {
                $('#draw_feature_dialog select[name="geometry_type"]').attr('disabled', 'disabled');
            } else {
                $('#draw_feature_dialog select[name="geometry_type"]').removeAttr('disabled');
            }
        },
		
		_deactivate: function() {
			var self = this;
			
			self._abort();
			$('#draw_feature_dialog').dialog('close');
		},
        
        _checkSingleGeometry: function(event) {
            var self = this;
            var layer = event.object;

            if(layer.features.length > 0) {
                if(self.options.singleGeometryBehaviour == 'auto') {
                    layer.removeAllFeatures();
                } else {
                    alert(OpenLayers.i18n('Only one feature allowed'));
                    return false;
                }
            }
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