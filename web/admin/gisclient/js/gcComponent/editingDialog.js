/*
 * NOTE: for lat/lon transformation the proj4js library is required
 */


(function($, undefined) {


    $.widget("gcComponent.editingDialog", $.ui.gcComponent, {

        widgetEventPrefix: "editingDialog",

        options: {
            gisclient: null,
            activeTool: null,
            toolControls: {},
            geometryType: null,
            snapIsActive: false
        },
		
        internalVars: {
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
			
            $.ui.gcComponent.prototype._create.apply(self, arguments);
			
            var html = '<div class="noflow"><label>&nbsp;</label><select name="redline_type" id="editing_type">';
            html += '<option value="polygon">'+OpenLayers.i18n('Polygon')+'</option><option value="line" selected>'+OpenLayers.i18n('Line')+'</option><option value="point">'+OpenLayers.i18n('Point')+'</option></select></div>'
            + '<div id="editing_mode" class="noflow"><label>'+OpenLayers.i18n('Action')+'</label><div class="radio_container"><input class="radio" type="radio" name="editing_action" value="create" checked> '+OpenLayers.i18n('Create')+'<br/>	<input class="radio" type="radio" name="editing_action" value="modify"> '+OpenLayers.i18n('Edit')+'<br/> <input class="radio" type="radio" name="editing_action" value="transform"> '+OpenLayers.i18n('Transform')+'<br/> <input class="radio" type="radio" name="editing_action" value="remove"> '+OpenLayers.i18n('Delete')+'</div></div>'
            + '<div class="noflow"><label>&nbsp;</label><button name="editing_save">'+OpenLayers.i18n('Save')+'</button></div>'
            + '<div name="help"></div>'
            + '<hr><div id="editing_redline"><div class="noflow"><label>&nbsp;</label><select name="redline_fonttype" id="redline_fonttype"><option value="Arial">Arial</option><option value="Verdana">Verdana</option></select></div>'
            + '<div class="noflow"><label>' + OpenLayers.i18n('Font size')+':</label> <input type="text" name="redline_fontsize" id="redline_fontsize" size="4"> px <button type="button" id="redline_fontsize_button">OK</button></div>'
            + '<div class="noflow"><label>' + OpenLayers.i18n('Font color')+':</label> <input type="color" name="redline_fontcolor" id="redline_fontcolor" size="5" style="height:15px;"></div>'
            + '<div class="noflow"><label>' + OpenLayers.i18n('Line color')+':</label> <input type="color" name="redline_linecolor" id="redline_linecolor" size="5" style="height:15px;"></div>'
            + '<div class="noflow"><label>' + OpenLayers.i18n('Fill color')+':</label> <input type="color" name="redline_fillcolor" id="redline_fillcolor" size="5" style="height:15px;"></div></div><div id="editing_last_point_distance">'+OpenLayers.i18n('From last point')+' <span class="distance"></span></div><div id="snap_settings"></div>';
				
            self.element.html(html);
            var dialogOptions = $.extend(gisclient.options.dialogDefaultPosition, {
                draggable:true,
                width:350,
                autoOpen:false
            });
            self.element.dialog(dialogOptions);
            $('button[name="editing_save"]').click(function() {
                self._save();
            });
            $('input[name="editing_action"]').click(function() {
                self._toggleControl($(this).val());
            });
            $('#editing_type').change(function() {
                self._toggleControl($(this).val());
            });
            $('#redline_fonttype').change(function() {
                self.modifyFont(this.value);
            });
            $('#redline_fontsize_button').click(function() {
                self.modifyFontSize($('#redline_fontsize').val());
            });
            $('input[type="color"]').mColorPicker({
                imageFolder: OpenLayers.ImgPath
            });
            $('#redline_fontcolor').bind('colorpicked', function () {
                self.modifyFontColor($(this).val());
            });
            $('#redline_linecolor').bind('colorpicked', function () {
                self.modifyLineColor($(this).val());
            });
            $('#redline_fillcolor').bind('colorpicked', function () {
                self.modifyFillColor($(this).val());
            });
            var queryableLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers();
            if(queryableLayers != null) {
                self.options.snapIsActive = true;
                $('#snap_settings').snapPoint();
            }
            $('div[name="help"]',self.element).html(self.help.create);
        },
		
        openDialog: function() {
            var self = this;
            if(!self.element.dialog('isOpen')) self.element.dialog('open');
        },
		
        closeDialog: function() {
            var self = this;
            if(self.element.dialog('isOpen')) self.element.dialog('close');
            if(self.options.snapIsActive) gisclient.componentObjects.snapPoint.destroySnap();
        },
		
        toggleTool: function(tool) {
            var self = this;
			
            self.options.activeTool = tool;
            self.options.geometryType = gisclient.toolObjects[tool].options.geometryType;
            self.internalVars.currentGeometryType = self.options.geometryType;
            self.options.toolControls = gisclient.toolObjects[tool].options.controls;
            if(tool == 'drawFeature') {
                $('#editing_redline').hide();
                $('button[name="editing_save"]').show();
                $('#editing_snap').show();
                $('#editing_last_point_distance').show();
                self.element.dialog('option', 'title', OpenLayers.i18n('Editing options'));
                var initControls = gisclient.toolObjects[tool].options.initControls;
                $.each(['polygon', 'line', 'point'], function(e, type) {
                    if($.inArray(type, initControls) < 0) {
                        $('#editing_type option[value="'+type+'"]').remove();
                    }
                });
            } else if(tool == 'redline') {
                $('#editing_snap').hide();
                $('button[name="editing_save"]').hide();
                $('#editing_redline').show();
                $('#editing_last_point_distance').hide();
                self.element.dialog('option', 'title', OpenLayers.i18n('Redline options'));
            }
			
            self._toggleControl(self.options.geometryType);
        },
		
        _toggleControl: function(controlName) {
            var self = this;
            var controls = self.options.toolControls;
			
            for(var i in controls) controls[i].deactivate();
            switch(controlName) {
                case 'create':
                    controls[self.internalVars.currentGeometryType].activate();
                    $('div[name="help"]',self.element).html(self.help.create);
                    break;
                case 'modify':
                    controls[controlName].activate();
                    $('div[name="help"]',self.element).html(self.help.modify);
                    break;
                case 'transform':
                    controls[controlName].activate();
                    $('div[name="help"]',self.element).html(self.help.transform);
                    break;
                case 'remove':
                    controls[controlName].activate();
                    $('div[name="help"]',self.element).html(self.help.remove);
                    break;
                default:
                    controls[controlName].activate();
                    self.internalVars.currentGeometryType = controlName;
                    break;
            }
        },
		
        modifyFont: function(font) {
            var self = this;
			
            var vectorLayer = gisclient.componentObjects.gcLayersManager.getEditingLayer();
            var style = vectorLayer.styleMap;
            var rule = {
                1: {
                    fontFamily:font
                }
            }; 
            style.addUniqueValueRules("default","redline",rule); // edit the font of the redline features
            vectorLayer.redraw();
        },
		
        modifyFontSize: function(size) {
            var self = this;
			
            var vectorLayer = gisclient.componentObjects.gcLayersManager.getEditingLayer();
            var style = vectorLayer.styleMap;
            var rule = {
                1: {
                    fontSize:size
                }
            };
            style.addUniqueValueRules("default","redline",rule);
            vectorLayer.redraw();
        },
		
        modifyFontColor: function(color) {
            var self = this;
			
            var vectorLayer = gisclient.componentObjects.gcLayersManager.getEditingLayer();
            var style = vectorLayer.styleMap;
            var rule = {
                1: {
                    fontColor:color
                }
            };
            style.addUniqueValueRules("default","redline",rule);
            vectorLayer.redraw();
        },
		
        modifyLineColor: function(color) {
            var self = this;
			
            var vectorLayer = gisclient.componentObjects.gcLayersManager.getEditingLayer();
            var style = vectorLayer.styleMap;
            var rule = {
                1: {
                    strokeColor:color
                }
            };
            style.addUniqueValueRules("default","redline",rule);
            vectorLayer.redraw();
        },
		
        modifyFillColor: function(color) {
            var self = this;
			
            var vectorLayer = gisclient.componentObjects.gcLayersManager.getEditingLayer();
            var style = vectorLayer.styleMap;
            var rule = {
                1: {
                    fillColor:color,
                    fillOpacity:0.25
                }
            };
            style.addUniqueValueRules("default","redline",rule);
            vectorLayer.redraw();
        },
		
        _save: function() {
            var self = this;

            self.options.geometryType = gisclient.toolObjects[self.options.activeTool]._save();
        },
		
        updateFromLastPointDistance: function(distance) {
            $('#editing_last_point_distance span.distance').html(distance);
        }
		
    });

    $.extend($.gcComponent.editingDialog, {
        version: "3.0.0"
    });
})(jQuery);