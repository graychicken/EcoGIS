/*
 */


(function($, undefined) {


	$.widget("gcTool.redline", $.ui.gcTool, {

		widgetEventPrefix: "redline",

		options: {
			label: OpenLayers.i18n('Redline'),
			icons: {
				primary: 'redline'
			},
			text: false,
			redlineServiceUrl: null
		},
		
		internalVars: {
			redlineLayer: null,
			activeControl: null,
			controls: {}
		},

		_create: function() {
			var self = this;
			
			$.ui.gcTool.prototype._create.apply(self, arguments);
			
			var mapOptions = gisclient.getMapOptions();
			self.options.redlineServiceUrl = mapOptions.redlineServiceUrl;
			
			var html = '<div id="gc_redline_dialog" style="display:none;">'+
				'<div class="noflow"><label>'+OpenLayers.i18n('Action')+':</label> <div class="radio_container"><input class="radio" type="radio" name="action" value="create" id="gc_redline_dialog_create" checked><label for="gc_redline_dialog_create">'+OpenLayers.i18n('Create')+'</label> <input class="radio" type="radio" name="action" id="gc_redline_dialog_delete" value="delete"><label for="gc_redline_dialog_delete">'+OpenLayers.i18n('Delete')+'</label></div></div>'+
				'<div class="noflow"><label>'+OpenLayers.i18n('Draw')+':</label>'+
				'<select name="control">' +
				'<option value="line" selected>'+OpenLayers.i18n('Line')+'</option>' +
				'<option value="polygon" >'+OpenLayers.i18n('Polygon')+'</option>' +
				'<option value="freehand" >'+OpenLayers.i18n('Free hand')+'</option>' + //LANG
				//'<option value="point" >'+OpenLayers.i18n('Point')+'</option>' +
				'</select></div>'+
				'<div class="logs"></div>'+
				'<div class="noflow"><label>'+OpenLayers.i18n('Add text')+'</label><input type="checkbox" name="add_text" value="yes" style="height: 25px; float:left;"> </div>'+
				'<div class="buttons"><button name="save">'+OpenLayers.i18n('Save')+'</button><button name="abort">'+OpenLayers.i18n('Abort')+'</button></div>'+
				'</div>';
				
			$('body').append(html);
			
			$('#gc_redline_dialog button[name="save"]').click(function(event) {
				self._save();
			});
			$('#gc_redline_dialog button[name="abort"]').click(function(event) {
				self._abort();
			});
			
			self._showButtons([]);
			
			$('#gc_redline_dialog input[name="action"]').click(function(event) {
				var selectedMode = $(this).val();
				
				if(selectedMode == 'create') {
					self.options.control.deactivate();
					self._switchTool($('#gc_redline_dialog select[name="control"]').val());
				} else {
					$.each(self.internalVars.controls, function(e, control) {
						control.deactivate();
					});
					self.options.control.activate();
				}
			});
			
			$('#gc_redline_dialog select[name="control"]').change(function() {
				self._switchTool($(this).val());
			});
			
			$('#gc_redline_dialog').dialog({
				draggable:true,
				title:OpenLayers.i18n('Redline'),
				position: [200,0],
                width: 390,
				autoOpen: false,
				close: function(event, self) {
					var self = gisclient.toolObjects.redline;
					self._abort();
				}
			});
			
			self.internalVars.redlineLayer = gisclient.componentObjects.gcLayersManager.getRedlineLayer();
			
			self.options.control = new OpenLayers.Control.SelectFeature(self.internalVars.redlineLayer);
			self.options.control.events.register("featurehighlighted", self, self._removeFeature);
			
			self.internalVars.controls.polygon = new OpenLayers.Control.DrawFeature(self.internalVars.redlineLayer, OpenLayers.Handler.Polygon);			
			self.internalVars.controls.line = new OpenLayers.Control.DrawFeature(self.internalVars.redlineLayer, OpenLayers.Handler.Path);
			self.internalVars.controls.point = new OpenLayers.Control.DrawFeature(self.internalVars.redlineLayer, OpenLayers.Handler.Point);
			
			$.each(self.internalVars.controls, function(e, control) {
				control.events.register('featureadded', self, self._handleFeature);
			});
			
			gisclient.map.addControls([self.options.control, self.internalVars.controls.point, self.internalVars.controls.line, self.internalVars.controls.polygon]);

		},
		
		_click: function(event) {
			var self = event.data.self;
			
			$.ui.gcTool.prototype._click.apply(self, arguments);
			
			$('#gc_redline_dialog').dialog('open');

			self.options.control.deactivate();
            $('#gc_redline_dialog_create').trigger('click');
		},
		
		_handleFeature: function(event) {
			var self = this;
			
			var feature = event.feature;
            var color = '#FF0000';
            if(gisclient.componentObjects.gcLayersManager.options.redlineColor) color = gisclient.componentObjects.gcLayersManager.options.redlineColor;
			feature.attributes = {color: color};
			if($('#gc_redline_dialog input[name="add_text"]:checked').length > 0) {
				if($('#gc_redline_dialog_add_text').length < 1) {
					$('body').append('<div id="gc_redline_dialog_add_text"><textarea name="redline_text"></textarea></div>');
				} else {
					$('#gc_redline_dialog_add_text textarea').val('');
				}
				$('#gc_redline_dialog_add_text').dialog({
					draggable: true,
					title: OpenLayers.i18n('Text'),
					buttons: [{
						text: "Ok",
						click: function() {
							$(this).dialog("close").trigger('close');
						}
					}],
					close: function() {
						var text = $('#gc_redline_dialog_add_text textarea').val();
						if(text != '') {
							self._addText(feature, text);
						}
					}
				});
			}
			
			self._showButtons(['save','abort']);
		},
		
		_addText: function(feature, text) {
			var self = this;
			
			var vertices = feature.geometry.getVertices();
			var lastPoint = vertices[vertices.length-1].clone();
            var color = '#000000';
            if(gisclient.componentObjects.gcLayersManager.options.redlineColor) color = gisclient.componentObjects.gcLayersManager.options.redlineColor;
			var symbolizer = {
				fontColor: color,
				fontSize: "12px",
				pointRadius: 1,
				label: text,
				fontFamily: "Courier New, monospace",
				fontWeight: "bold",
				labelAlign: "lb",
				labelXOffset: 5,
				labelYOffset: 10
			};
			var labelFeature = new OpenLayers.Feature.Vector(lastPoint, {note: text}, symbolizer);
			self.internalVars.redlineLayer.addFeatures([labelFeature]);
			feature.attributes.note = text;
		},
		
		_save: function() {
			var self = this;
			
			var redlineLayer = gisclient.componentObjects.gcLayersManager.getRedlineLayer();
			var features = [];
			$.each(redlineLayer.features, function(e, feature) {
				if(feature.state == OpenLayers.State.INSERT) features.push(feature);
			});
			
			var format = new OpenLayers.Format.GeoJSON();
			var params = {
				REQUEST: 'SaveLayer',
				SRS: gisclient.getProjection(),
				features: format.write(features),
				PROJECT: gisclient.getProject(),
				MAPSET: gisclient.getMapOptions().mapsetName
			};

			$.ajax({
				url: self.options.redlineServiceUrl,
				type: 'post',
				dataType: 'json',
				data: params,
				success: function(response) {
					if(typeof(response) != 'object' || typeof(response.redlineId) == 'undefined') {
						return $('gc_redline_dialog div.logs').html(OpenLayers.i18n('Error'));
					}
					gisclient.componentObjects.gcLayersManager.addRedlineWMS(response.redlineId);
				},
				error: function() {
					$('gc_redline_dialog div.logs').html(OpenLayers.i18n('Error'));
				}
			});
		},
		
		_removeFeature: function(event) {
			var self = this;

			var string = OpenLayers.i18n('Are you sure you want to delete this geometry?');
			if(confirm(string)) {
				self.internalVars.redlineLayer.destroyFeatures([event.feature]);
				
				if(self.internalVars.redlineLayer.features.length < 1) {
					self._showButtons([]);
				}
			}
		},
		
		_switchTool: function(selectedTool) {
			var self = this;
			
			var selectedControl = selectedTool;
			if(selectedTool == 'line' || selectedTool == 'freehand') {
				selectedControl = 'line';
				self.internalVars.controls.line.handler.freehand = (selectedTool == 'freehand');
			}
			$.each(self.internalVars.controls, function(controlName, control) {
				control.deactivate();
			});
			self.internalVars.controls[selectedControl].activate();
		},
		
		clearVectors: function() {
			var self = this;
			
			self.internalVars.redlineLayer.removeAllFeatures();
			self._showButtons([]);
		},
		
		deleteRedline: function(redlineId) {
			var self = this;
			
			$.ajax({
				type: 'GET',
				url: self.options.redlineServiceUrl,
				dataType: 'json',
				data: {REQUEST:'DeleteLayer', redlineId:redlineId},
				success: function(response) {
				},
				error: function() {}
			});
		},
		
		_abort: function() {
			var self = this;
			
			self.internalVars.redlineLayer.removeAllFeatures();
			$.each(self.internalVars.controls, function(e, control) {
				control.deactivate();
			});
			self._switchTool($('#gc_redline_dialog select[name="control"]').val());
		},
		
		_deactivate: function() {
			var self = this;
			
			self._abort();
			$('#gc_redline_dialog').dialog('close');
		},
		
		_showButtons: function(array) {
			var self = this;
			$('#gc_redline_dialog div.buttons button').hide();
			
			$.each(array, function(e, buttonName) {
				$('#gc_redline_dialog div.buttons button[name="'+buttonName+'"]').show();
			});
		}

	});

	$.extend($.gcTool.redline, {
		version: "3.0.0"
	});
})(jQuery);