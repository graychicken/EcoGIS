(function($, undefined) {
    

	$.widget("gcTool.toolTip", $.ui.gcTool, {

		widgetEventPrefix: "toolTip",

		options: {
			label: OpenLayers.i18n('Tooltip'), // TODO: use as default value OpenLayers.i18n...
			icons: {
				primary: 'tooltip' // TODO: choose better name
			},
			text: false,
			gisclient: null,
			tooltipWidth: 200,
			delayBeforeToolTipRequest: 1000, // in milliseconds
			selectionBuffer: 5,  //map unit at scale 1:1000
			applyBufferTo: ['point','multipoint','line','multiline'],
			control: null,
			queryLayers: {}, // int obj to store the queryable layers data
			cols: {}, // int obj to store the columns model of the selected layer
			keepPopups: false
		},
		
		_create: function() {
			var self = this;
			
			$.ui.gcTool.prototype._create.apply(self, arguments);
		},
        
        
		
		_click: function(event) {
			var self = event.data.self;
			
			// create a custom control
			self.options.control = new OpenLayers.Control();
			OpenLayers.Util.extend(self.options.control, {
				EVENT_TYPES: ['mousestopped'],
				handler: null,
				handlerOptions: {hover:{delay:self.options.delayBeforeToolTipRequest}},
				initialize: function() {
					OpenLayers.Control.prototype.initialize.apply(this, arguments);
/* 					this.EVENT_TYPES = OpenLayers.Control.prototype.EVENT_TYPES.concat(
						OpenLayers.Control.prototype.EVENT_TYPES
					); */
					this.handler = new OpenLayers.Handler.Hover(
						this, {
							'move': this.cancelHover,
							'pause': this.getInfoForHover
						},
						this.handlerOptions.hover
					);
				},
				activate: function () {
					if (!this.active) {
						this.handler.activate();
					}
					return OpenLayers.Control.prototype.activate.apply(
						this, arguments
					);
				},
				deactivate: function() {
					if(this.active) {
						this.handler.deactivate();
					}
					return OpenLayers.Control.prototype.deactivate.apply(
						this, arguments
					);
				},
				getInfoForHover: function(evt) {
					var parents = document.getElementsByClassName('olPopup');
					var stopCallTooltip = false;
					if (parent !== null) {
						for (var i = 0; i < parents.length; i++) {
							var parent = parents[i];
							var child = evt.target;
							var node = child.parentNode;
							while (node !== null) {
								if (node == parent) {
									//stopCallTooltip = true;
									break;
								}
								node = node.parentNode;
							}
							if(stopCallTooltip){
								break;
							}
						}
					}
					if (!stopCallTooltip) {
						var lonLat = this.map.getLonLatFromPixel(evt.xy);
						this.events.triggerEvent("mousestopped", {lonLat: lonLat, xy: evt.xy});
					}
				},
				cancelHover: function() {
					if (this.hoverRequest) {
						this.hoverRequest.abort();
						this.hoverRequest = null;
					}
				},
				CLASS_NAME: 'OpenLayers.Control.toolTip'
			});
			self.options.control.initialize(); // PERCHE DEVO CHIAMARLA A MANO?!?!?!?!?!?
			
			self.options.control.events.register("mousestopped", self, self._requestToolTip);
			
			gisclient.map.addControl(self.options.control);
			
			// build html for the tooltip dialog
			var checked = (self.options.keepPopups) ? 'checked' : '';
			var html = '<div id="tooltip_settings" style="display:none;">' +
				'<div class="instructions ui-state-highlight ui-cornel-all" style="padding:2px; margin-bottom:10px;">' +
				'<span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span>' +
				OpenLayers.i18n('Select the layer, then move the mouse over the object to query and wait') +
				'</div><div style="margin-bottom:10px;"><input id="keep_popups" type="checkbox" name="keep_popups" value="yes"> ' +
				'<label for="keep_popups" style="float:none">' + OpenLayers.i18n('Keep tooltips opened')+'</label>'+
				'</div><div style="margin-bottom:10px;">' +
				OpenLayers.i18n('Tooltip layer')+'<br /><select id="tooltip_layer" style="width:250px;">' +
				'<option value="0">'+OpenLayers.i18n('Select')+'</option>';
			self.options.queryLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers();
			
			var currentGroup = null;
			$.each(self.options.queryLayers, function(featureType, layer) {
				if(currentGroup != layer.groupTitle) {

					html += '<optgroup label="'+layer.groupTitle+'">';
					currentGroup = layer.groupTitle;
				}
				html += '<option value="'+featureType+'">'+layer.title+'</option>';
			});

			html += '</select></div><br /><a href="#" id="tooltip_unselectall">'+OpenLayers.i18n('Unselect all')+'</a>';
			
			$('body').append(html);
			$('#tooltip_settings input[name="keep_popups"]').prop('checked', (self.options.keepPopups ? 'checked' : false));
			
			var dialogOptions = $.extend(gisclient.options.dialogDefaultPosition, {draggable:true,title:OpenLayers.i18n('Tooltip options'),autoOpen:false,width:300,height:200});
			dialogOptions.close = function(event) {
				var self = gisclient.toolObjects.toolTip;
				self._deactivate();
			};
			$('#tooltip_settings').dialog(dialogOptions);
			
			$('#tooltip_unselectall').click(function(event) {
				event.preventDefault();
				self._unSelectAll(event);
				self._removeDialogs();
			});
			$('#tooltip_settings input[name="keep_popups"]').click(function() {
				self._toggleKeepPopups($('#tooltip_settings input[name="keep_popups"]').prop('checked'));
			});
			
			$.ui.gcTool.prototype._click.apply(self, arguments);
			
			if(!$('#tooltip_settings').dialog('isOpen')) $('#tooltip_settings').dialog('open');
            
            // select width ie8 fix
            $('select#tooltip_layer').ieSelectWidth({
                containerClassName : 'select-container',
                overlayClassName : 'select-overlay'
            });

		},
		
		_deactivate: function() {
			var self = this;
			// remove the selected features and destroy popups
			self._unSelectAll();
			self._removeDialogs();
			
			// close the tooltip settings dialog
			if($('#tooltip_settings').dialog('isOpen')) $('#tooltip_settings').dialog('close');
			
			
			$('#tooltip_layer option[value="0"]').prop('selected', 'selected');
		},

		_removeDialogs: function(start){
			if (start === undefined) {
				start = 0;
			}
			var dialogs = $('.tooltipDialog');
			for (var i = start; i < dialogs.length; i++) {
				$(dialogs[i]).dialog('destroy').remove();
			}
		},		
        
		_requestToolTip: function(event) {
			var self = this;
			
			if(!self.options.keepPopups) self._unSelectAll();
			
			var lonLat = event.lonLat; // get the mouse position
			
			var selectedLayer = $('#tooltip_layer').val(); // get the layer selected by the user
			if(typeof(self.options.queryLayers[selectedLayer]) === 'undefined') return;
			var queryLayer = self.options.queryLayers[selectedLayer];
			var geom = new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat);
			if(typeof(queryLayer.layer.geometryType) !== 'undefined' && $.inArray(queryLayer.layer.geometryType, self.options.applyBufferTo) > -1) {
				var refScale = 1000;
				geom = OpenLayers.Geometry.Polygon.createRegularPolygon(geom, self.options.selectionBuffer * (gisclient.map.getScale()/refScale), 20, 90);
			}


            
			// create the openlayers spatial filter
            var finalFilter;
			var filter = new OpenLayers.Filter.Spatial({
				type: OpenLayers.Filter.Spatial.INTERSECTS,
				value: geom,
				projection: gisclient.getProjection(),
				property: 'the_geom'
			});
            
            if(queryLayer.defaultFilters !== null) {
                var filters = $.extend(true, [], queryLayer.defaultFilters);
                filters.push(filter);
                finalFilter = new OpenLayers.Filter.Logical({
                    type: OpenLayers.Filter.Logical.AND,
                    filters: filters
                });
            } else finalFilter = filter;
            
			var filter_1_1 = new OpenLayers.Format.Filter({version: "1.1.0"});
			var xml = new OpenLayers.Format.XML();
			var filterValue = xml.write(filter_1_1.write(finalFilter));	

			self.options.cols[selectedLayer] = {};
			$.each(queryLayer.fields, function(key, col) {
				self.options.cols[selectedLayer][key] = col.fieldHeader;
			});
			
			gisclient.componentObjects.loadingHandler.show();
			
			// build the WFS url request
			// TODO: MAXFEATURES da parametrizzare
			var params = {
				PROJECT: gisclient.getProject(),
				MAP: queryLayer.layer.parameters.map,
				SERVICE: 'WFS',
				VERSION: '1.0.0',
				SRS: gisclient.getProjection(),
				REQUEST: 'GETFEATURE',
				TYPENAME: selectedLayer,
				FILTER: filterValue,
                                LANG: gisclient.options.language,
				OUTPUTFORMAT: 'text/xml; subtype=gml/2.1.2'
			};
			
			$.ajax({
				url: queryLayer.layer.url,
				type: 'POST',
				dataType: 'xml',
				data: params,
				success: function(response, status, jqXHR) {
					var format = new OpenLayers.Format.GML();
					var features = format.read(response);

					gisclient.componentObjects.loadingHandler.hide();

					var dialogOptions = {
						height: 300,
						title: OpenLayers.i18n('${count} objects found', {count:features.length}),
						position: [event.xy.x+15,event.xy.y]
					};

					var html = '<div class="tooltip">';
					//create a template of popup
					if($('#temp_tooltip').length < 1){
						$('body').append('<div id="temp_tooltip" style="display:none;width:'+self.options.tooltipWidth+';"></div>');
					}
					if(features.length > 0) {
						// add vector features to selection layer
						var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
						selectionLayer.addFeatures(features);
						
						var cols = self.options.cols[selectedLayer];
						var one_feature;
						$.each(features, function(i, feature) {
							one_feature = feature;
							$.each(cols, function(key, label) {
								if(feature.attributes[key] === null){
									feature.attributes[key] = '';
								}
								html += '<strong>'+label+'</strong>: '+feature.attributes[key]+'<br />';
							});
							html += '<hr>';
						});
						
						dialogOptions.close = function(){
							var f = features;
							var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
							selectionLayer.removeFeatures(f);
						};
					} else {
						html += OpenLayers.i18n('No results');
					}
					console.log(dialogOptions);
					html += '</div>';
					$('#temp_tooltip').html(html);
					var h = ($('#temp_tooltip').height())+10;
					var dialogs = $('.tooltipDialog');
					if(self.options.keepPopups || dialogs.length === 0){
						var dialogExist = false;
						if(dialogs.length > 0) {

						}
						$('<div class="tooltipDialog"></div>').html($('#temp_tooltip').html()).dialog(dialogOptions);
					} else {
						self._removeDialogs(1);
						$(dialogs[0]).html($('#temp_tooltip').html()).dialog(dialogOptions);
					}			
				},
				error: function(response, status, jqXHR) {
					var string = OpenLayers.i18n('Error reading results, the request has been aborted');
					gisclient.componentObjects.errorHandler.show(string);//LANG
					gisclient.log(jqXHR.responseText);
					return false;
				}
			});
		},
		
		_toggleKeepPopups: function(checked) {
			var self = this;
			self.options.keepPopups = checked;
		},
		
		_unSelectAll: function(event) {
			var self = this;
			var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
			while(gisclient.map.popups.length > 0) {
				gisclient.map.removePopup(gisclient.map.popups[0]);
			}
			selectionLayer.removeFeatures(selectionLayer.features);
		}
	});

	$.extend($.gcTool.toolTip, {
		version: "3.0.0"
	});
})(jQuery);
