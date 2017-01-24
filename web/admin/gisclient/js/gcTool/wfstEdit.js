(function($, undefined) {

	$.widget("gcTool.wfstEdit", $.ui.gcTool, {

		widgetEventPrefix: "wfstEdit",

		options: {
			label: OpenLayers.i18n('Edit Layer'),
			icons: {
				primary: 'wfst_edit'
			},
			control: null,
			lookupServiceUrl: null,
			text: false
		},
		
		internalVars: {
			controls: {
				create: null,
				modify: null,
				remove: null
			},
			mode: null,
			selectedFeature: null,
			drawControl: null,
			modifyControl: null,
			drawHandlers: {
				polygon: OpenLayers.Handler.Polygon,
				line: OpenLayers.Handler.Path,
				point: OpenLayers.Handler.Point
			},
			wfstLayer: null,
			saveStrategy: null,
			lookupCache: {}
		},
		
		help: {
			selectLayer : OpenLayers.i18n('Select layer'),
			selectFeature:  OpenLayers.i18n('Select the feature clicking on the map'),
			editFeature: OpenLayers.i18n('Edit data, then click Save. To edit geometry, click on it and move vertexes')
		},
		
		_create: function() {
			var self = this;
			
			$.ui.gcTool.prototype._create.apply(self, arguments);
			
			var html = '<div id="gc_wfstedit_dialog"><div class="instructions"></div>'+
				'<div class="select"><select name="feature_type"><option value="0">'+OpenLayers.i18n('Select')+'</option></select></div>'+
				'<div class="form"><table border="1" cellpadding="2"><tr data-role="header"><th>'+OpenLayers.i18n('Field')+'</th><th>'+OpenLayers.i18n('Value')+'</th></tr></table></div>'+
				'<div class="logs"></div>'+
				'<div class="buttons"><button name="new">'+OpenLayers.i18n('New')+'</button><button name="save">'+OpenLayers.i18n('Save')+'</button> <button name="delete">'+OpenLayers.i18n('Delete')+'</button> <button name="abort">'+OpenLayers.i18n('Abort')+'</button></div>'+
				'<hr><div rel="snap_settings"></div></div>';
				
			$('body').append(html);
			
			var editableLayers = gisclient.componentObjects.gcLayersManager.getEditableLayers();
			$.each(editableLayers, function(featureType, feature) {
				$('#gc_wfstedit_dialog select[name="feature_type"]').append('<option value="'+featureType+'">'+feature.title+'</option>');
			});
			
			$('#gc_wfstedit_dialog').dialog({
				draggable:true,
				title:OpenLayers.i18n('Edit Layer'),
				position: [200,0],
				width: 420,
				maxHeight: 550,
				autoOpen: false,
				close: function(event, self) {
					var self  = gisclient.toolObjects.wfstEdit;
					self._abort();
				}
			});
			
			self._showButtons([]);
			self._showInstructions('selectLayer');
			$('#gc_wfstedit_dialog select[name="feature_type"]').change(function() {
				self._handleFeatureTypeSelection($(this).val());
			});
			$('#gc_wfstedit_dialog button[name="new"]').click(function() {
				self._addFeature();
			});
			$('#gc_wfstedit_dialog button[name="save"]').click(function() {
				self._saveFeature();
			});
			$('#gc_wfstedit_dialog button[name="abort"]').click(function() {
				self._abort();
			});
			$('#gc_wfstedit_dialog button[name="delete"]').click(function() {
				if(!confirm(OpenLayers.i18n('Are you sure you want to delete this feature? This cannot be undone'))) return;
				self._deleteFeature();
			});
			
			$('#gc_wfstedit_dialog div.form').hide();
			
			self.options.control = new OpenLayers.Control({autoActivate:false});
			
			self.internalVars.saveStrategy = new OpenLayers.Strategy.Save();
			self.internalVars.saveStrategy.events.register("success", self, self._saveSuccess);
			self.internalVars.saveStrategy.events.register("fail", self, self._saveFailure);
			
			var mapOptions = gisclient.getMapOptions();
			self.options.lookupServiceUrl = mapOptions.lookupServiceUrl;
			self.options.uploadUrl = mapOptions.uploadServiceUrl;
		},
		
		_click: function(event) {
			var self = event.data.self;

			$.ui.gcTool.prototype._click.apply(self, arguments);
			
			var queryableLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers();
			if(queryableLayers != null) {
				$('#gc_wfstedit_dialog div[rel="snap_settings"]').snapPoint();
			}
			
			$('#gc_wfstedit_dialog').dialog('open');
		},
		
		_deactivate: function() {
			var self = this;
			
			if($('#gc_wfstedit_dialog').dialog('isOpen')) $('#gc_wfstedit_dialog').dialog('close');
			$('#gc_wfstedit_dialog div.logs').empty();
			self._destroyLayer();
			
			if(typeof(gisclient.componentObjects.snapPoint) != 'undefined')	gisclient.componentObjects.snapPoint.destroySnap();
		},
		
        // Insert or update (not delete)
        _saveFeature: function() {
			var self = this;
			self.uploads = [];
			
			var featureData = gisclient.componentObjects.gcLayersManager.getQueryableLayer(self.internalVars.selectedFeatureType);
			var feature = self._getEditingFeature();
            if(self.internalVars.mode == 'edit') {
                feature.state = OpenLayers.State.UPDATE;
            } else {
                feature.state = OpenLayers.State.INSERT;
            }

			$.each(featureData.editableFields, function(key, col) {
				var newValue = $('#gc_wfstedit_dialog div.form table [name="'+key+'"]').val();
				var type = $('#gc_wfstedit_dialog div.form table [name="'+key+'"]').attr('type');
				
				if(type == 'file') {
					if(newValue && newValue !== '') {
						self.uploads.push(key);
					} else {
						delete feature.attributes[key];
					}
				} else {
                    if(key == self.internalVars.primaryKey) {
                        // Don't change Primary key
                        return;
                    }    
					if (newValue && newValue !== '') {
                        feature.attributes[key] = newValue;
                    } else {
                        feature.attributes[key] = null;
					}
				}
			});
			if(self.uploads.length > 0) {
				gisclient.componentObjects.loadingHandler.show();
				self.processUploads();
				self.afterUpload = function() {
					gisclient.componentObjects.loadingHandler.hide();
					this.internalVars.saveStrategy.save();
				};
			} else {
				self.internalVars.saveStrategy.save();
			}
		},
        
		processUploads: function() {
			var self = this;
			var allDone = true;
			
			for(var i = 0; i < self.uploads.length; i++) {
				var upload = self.uploads[i];

				if(upload) {
					allDone = false;
					$('#gc_wfstedit_dialog div.form table input[type="file"][name="'+upload+'"]').ajaxfileupload({
						action: self.options.uploadUrl,
						params: {
						   key: upload,
						   uploadNum: i
						},
						onComplete: function(response) {
							if(!response || typeof(response) != 'object' || !response.name) {
								gisclient.componentObjects.loadingHandler.hide();
								return alert('System error');
							}
							var feature = self._getEditingFeature();
							feature.attributes[response.key] = response.name
							self.uploads[response.uploadNum] = false;
							self.processUploads();
						},
						autoStart: true,
						validate_extensions: false
					});
					break;
				}
			}
			
			if(allDone) {
				if(self.afterUpload && typeof(self.afterUpload) == 'function') {
					self.afterUpload.call(self);
				}
			}
		},
		
		_getEditingFeature: function() {
			var self = this;
			var feature;
			
			if(self.internalVars.mode == 'edit') {
				var featureId = self.internalVars.selectedFeature.id;
				feature = self.internalVars.wfstLayer.getFeatureById(featureId);
			} else {
				feature = null;
				$.each(self.internalVars.wfstLayer.features, function(e, f) {
					if(f.state == 'Insert') feature = f;
				});
				if(feature === null) {
					//error
					return;
				}
			}
			return feature;
		},
		
		_handleFeatureTypeSelection: function(featureType) {
			var self = this;
			
			$('#gc_wfstedit_dialog div.logs').empty();
			self.internalVars.selectedFeature = null;

			if(featureType != null && featureType != '0') {
				self._showInstructions('selectFeature');
				self._showButtons(['new', 'abort']);
				self.internalVars.selectedFeatureType = featureType;
				var feature = gisclient.componentObjects.gcLayersManager.getQueryableLayer(featureType);
				gisclient.componentObjects.gcLayersManager.activateLayer(feature.themeId, feature.layerId);
				$('#gc_wfstedit_dialog div.logs').empty();
				self._destroyLayer();
				self._createLayer();
			} else {
				self._showInstructions('selectLayer');
				self.internalVars.selectedFeatureType = null;
				self._destroyLayer();
			}
		},
		
        escapeHtml: function(string) {
            var entityMap = {
                "&": "&amp;",
                "<": "&lt;",
                ">": "&gt;",
                '"': '&quot;',
                "'": '&#39;',
                "/": '&#x2F;'
            };
            return String(string).replace(/[&<>"'\/]/g, function (s) 
            {
                return entityMap[s];
            });
        },
  
		startEdit: function(feature) {
            "use strict"
			var self = this;
			
			$('#gc_wfstedit_dialog div.logs').empty();
			
			self.internalVars.mode = 'edit';
			if(typeof(feature) == 'undefined') {
				feature = null;
				self.internalVars.mode = 'new';
			}
			
			self.internalVars.selectedFeature = feature;

			var featureType = gisclient.componentObjects.gcLayersManager.getQueryableLayer(self.internalVars.selectedFeatureType);
			$.each(featureType.editableFields, function(key, col) {
				if(col.relationType != 0) return;
				var disabled = '';
				if(col.isPrimaryKey == 1) {
					disabled = ' disabled="disabled" ';
					self.internalVars.primaryKey = key;
					return;
				} else if(col.editable != 1) return;
				
				var value = '';
				if(self.internalVars.mode == 'edit') {
					value = (feature.attributes[key]) ? feature.attributes[key] : '';
				}
				var tableRow = '<tr><td>'+col.fieldHeader+' </td><td>';
				if(typeof(col.lookup) == 'object') {
					tableRow += '<select name="'+key+'"><option value="">'+OpenLayers.i18n('Select')+'</option></select>';
					$.ajax({
						url: self.options.lookupServiceUrl,
						type: 'GET',
						dataType: 'json',
						data: col.lookup,
						success: function(response) {
							if(typeof(response) != 'object' || typeof(response.result) == 'undefined' || response.result != 'ok') {
								return alert(OpenLayers.i18n('System error'));
							}
							var options = '';
							$.each(response.data, function(lookupKey, lookupValue) {
								options += '<option value="'+lookupKey+'">'+lookupValue+'</option>';
							});
							$('#gc_wfstedit_dialog div.form select[name="'+key+'"]').append(options);
							$('#gc_wfstedit_dialog div.form select[name="'+key+'"]').val(value);
						},
						error: function() {
							alert(OpenLayers.i18n('System error'));
						}
					});
				} else if(col.fieldType == 8 || col.fieldType == 10) {  // 8 = Image, 10 = File
					tableRow += '<input type="file" name="'+key+'">';
				} else {	
                    if (col.dataType == 2) {  /* 2 = Number */
                        tableRow += '<input type="number" name="'+key+'" value="'+self.escapeHtml(value)+'"' +disabled+ ' style="width: 100px;">';
                    } else {
                        tableRow += '<input type="text" name="'+key+'" value="'+self.escapeHtml(value)+'"' +disabled+ '>';
                    }
				}
				tableRow += '</td></tr>';
				$('#gc_wfstedit_dialog div.form table').append(tableRow);
				if(col.searchType == 5) {
					$('#gc_wfstedit_dialog div.form table input[name="'+key+'"]').datepicker();
				}
			});
			
			$('#gc_wfstedit_dialog div.logs').empty();
			$('#gc_wfstedit_dialog div.select').hide();
			$('#gc_wfstedit_dialog div.form').show();
			
			var buttons = ['save', 'abort'];
			if(self.internalVars.mode == 'edit') buttons.push('delete');
			
			self._showInstructions('editFeature');
			self._showButtons(buttons);
			

		},
		
		_createLayer: function() {
			var self = this;
			
			$('#gc_wfstedit_dialog div.logs').empty();
			
			var BBOXStrategy = new OpenLayers.Strategy.BBOX();
			
			var featureData = gisclient.componentObjects.gcLayersManager.getQueryableLayer(self.internalVars.selectedFeatureType);
			
			self._destroyLayer();
			self.internalVars.wfstLayer = new OpenLayers.Layer.Vector('WFS-T', {
				strategies: [BBOXStrategy, self.internalVars.saveStrategy],
				projection: new OpenLayers.Projection(gisclient.getProjection()),
				protocol: new OpenLayers.Protocol.WFS({
					version: "1.0.0",
					srsName: gisclient.getProjection(),
					url: featureData.towsUrl,
					featureNS :  "http://www.tinyows.org/",
					featureType: featureData.towsFeatureType,
					geometryName: "the_geom",
					schema: featureData.towsUrl+'service=wfs&request=DescribeFeatureType&version=1.0.0&typename=feature:'+featureData.towsFeatureType
				})
			});
			var style = self.internalVars.wfstLayer.styleMap.styles.default.defaultStyle;
			style.strokeWidth = 6;


			gisclient.map.addLayer(self.internalVars.wfstLayer);
			gisclient.componentObjects.snapPoint.changeEditingLayer(self.internalVars.wfstLayer);
			BBOXStrategy.update();
			
			self.internalVars.modifyControl = new OpenLayers.Control.ModifyFeature(self.internalVars.wfstLayer);
			self.internalVars.wfstLayer.events.register('beforefeaturemodified', self, function(event) {
				if(self.internalVars.selectedFeature === null || self.internalVars.selectedFeature.fid != event.feature.fid) self.startEdit(event.feature);
			});
			self.internalVars.wfstLayer.events.register('afterfeaturemodified', self, function(event) {
				self._restart();
			});
			gisclient.map.addControl(self.internalVars.modifyControl);
			self.internalVars.modifyControl.activate();
		},

		_showButtons: function(array) {
			var self = this;
			$('#gc_wfstedit_dialog div.buttons button').hide();
			
			$.each(array, function(e, buttonName) {
				$('#gc_wfstedit_dialog div.buttons button[name="'+buttonName+'"]').show();
			});
		},
		
		_addFeature: function() {
			var self = this;
			
			self.internalVars.modifyControl.deactivate();
			
			var featureType = gisclient.componentObjects.gcLayersManager.getQueryableLayer(self.internalVars.selectedFeatureType);
			if(typeof(self.internalVars.drawHandlers[featureType.geometryType]) == 'undefined') {
				// error
				return;
			}
			var controlOptions = {
				handlerOptions: {
					multi: featureType.layer.isMulti,
					holeModifier: 'altKey'
				}
			};
			self.internalVars.drawControl = new OpenLayers.Control.DrawFeature(self.internalVars.wfstLayer, self.internalVars.drawHandlers[featureType.geometryType], controlOptions);
			gisclient.map.addControl(self.internalVars.drawControl);
			self.internalVars.drawControl.activate();
			
			self.startEdit();			
		},
		
		_deleteFeature: function() {
			var self = this;
			
			self.internalVars.selectedFeature.state = OpenLayers.State.DELETE;
			self.internalVars.saveStrategy.save();
		},
		
		_destroyLayer: function() {
			var self = this;
			
			$('#gc_wfstedit_dialog div.logs').empty();

			if(self.internalVars.wfstLayer !== null) {
				self._destroyControls();
				self.internalVars.wfstLayer.destroy();
				self.internalVars.wfstLayer = null;
			}
		},
		
		_destroyControls: function() {
			var self = this;
			
			if(self.internalVars.drawControl !== null) {
				self.internalVars.drawControl.destroy();
				self.internalVars.drawControl = null;
			}
			if(self.internalVars.modifyControl !== null) {
				self.internalVars.modifyControl.destroy();
				self.internalVars.modifyControl = null;
			}
		},
		
		_saveSuccess: function() {
			var self = this;
			
			$('#gc_wfstedit_dialog div.logs').html(OpenLayers.i18n('Ok'));
			
			self._restart();
			
			var feature = gisclient.componentObjects.gcLayersManager.getQueryableLayer(self.internalVars.selectedFeatureType);
			gisclient.componentObjects.gcLayersManager.reloadTheme(feature.themeId);
		},
		
		_restart: function() {
			var self = this;
			
			self._handleFeatureTypeSelection(self.internalVars.selectedFeatureType);
			self._resetDialog();
			
			self._showInstructions('selectFeature');
			self._showButtons(['new','abort']);
		},
		
		_abort: function() {
			var self = this;
			
			$('#gc_wfstedit_dialog select[name="feature_type"]').val('0');
			self._handleFeatureTypeSelection(null);
			self._resetDialog();
			
			self._showInstructions('selectLayer');
			self._showButtons([]);
			
			if(typeof(gisclient.componentObjects.snapPoint) != 'undefined')	gisclient.componentObjects.snapPoint.destroySnap();
		},
		
		_resetDialog: function() {
			var self = this;
			
			$('#gc_wfstedit_dialog div.form table tr[data-role!="header"]').remove();
			
			$('#gc_wfstedit_dialog div.logs').empty();
			$('#gc_wfstedit_dialog div.select').show();
			$('#gc_wfstedit_dialog div.form').hide();
		},
		
		_saveFailure: function(event) {
			var self = this;

			var format = new OpenLayers.Format.OGCExceptionReport();
			var exceptionData = format.read(event.response.priv.responseText);
			$('#gc_wfstedit_dialog div.logs').html(OpenLayers.i18n('Error')+':<br>');
			$.each(exceptionData.exceptionReport.exceptions, function(e, exception) {
				if(typeof(exception.text) != 'undefined') {
					$('#gc_wfstedit_dialog div.logs').append(exception.text+'<br>');
				} else if(typeof(exception.texts) != 'undefined') {
					$('#gc_wfstedit_dialog div.logs').append(exception.texts.join('<br>')+'<br>');
				} else {
					$('#gc_wfstedit_dialog div.logs').append(OpenLayers.i18n('Unknown error')+'<br>');
				}
			});
			
		},
		
		_mergeParams: function(url, feature) {
			var self = this;
			
			url += 'project='+gisclient.getProject()+'&gctypename='+feature.featureId+'&';
			return url;
		},
		
		_showInstructions: function(action) {
			var self = this;
			
			$('#gc_wfstedit_dialog div.instructions').html(self.help[action]);
		}
		
	});

	$.extend($.gcTool.wfstEdit, {
		version: "3.0.0"
	});
})(jQuery);
