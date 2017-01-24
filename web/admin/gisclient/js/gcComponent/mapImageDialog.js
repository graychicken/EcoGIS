(function($, undefined) {

	$.widget("gcComponent.mapImageDialog", $.ui.gcComponent, {
	
		widgetEventPrefix: "mapImageDialog",

		options: {
			type: null,
			northArrow: null,
			fixedDate: false,
			displayBox: false,
            forceLegend: false,
			allowedPrintFormats: ['A4','A3','A2','A1','A0'],
            availableFormats: ['PDF'],
			allowedResolutions: {'150':'High'},
            printVectors: true,
            logoSx: null,
            logoDx: null
		},
		
		internalVars: {
			tool: null,
			useBox: false,
			printBox: null
		},

		_create: function() {
			var self = this;
			var mapOptions = gisclient.getMapOptions();

			$.ui.gcComponent.prototype._create.apply(self, arguments);
			
			var container = '<div id="mapimage_dialog"></div>';
			$('body').append(container);
			
			var html = 
			'<div class="settings"><fieldset data-tool="print">' +
			'	<legend data-text="information">'+OpenLayers.i18n('Print headers')+'</legend>' +
			'	<div class="noflow" data-tool="print"><label>'+OpenLayers.i18n('Text')+':</label> <textarea name="text">'+gisclient.getMapTitle()+'</textarea></div>' +
			'	<div class="noflow" data-tool="print"><label>'+OpenLayers.i18n('Date')+':</label> ';
			if(self.options.fixedDate) {
				html += '<span data-role="fixed_date"></span><input type="hidden" name="date" value="">';
			} else {
				html += '<input type="text" name="date" style="width:82px;">';
			}
			html += '</div>'+
			'</fieldset>' +
			'<fieldset data-tool="print">' +
			'	<legend>'+OpenLayers.i18n('Print properties')+':</legend>' ;
			if(mapOptions.legend) {
                if(!self.options.forceLegend) {
                    html += '<div class="noflow" data-tool="print"><label>'+OpenLayers.i18n('Legend')+':</label> <div class="radio_container"><input class="radio" type="radio" name="legend" id="legend_yes" value="yes"> <label for="legend_yes">'+OpenLayers.i18n('Yes')+'</label> <input class="radio" type="radio" name="legend" id="legend_no" value="no" checked> <label for="legend_no">'+OpenLayers.i18n('No')+'</label></div></div>';
                } else {
                    html += '<input type="hidden" name="legend" value="yes">';
                }
			}
			html += 
			'	<div class="noflow"><label>'+OpenLayers.i18n('Print layout')+':</label> <div class="radio_container"><input class="radio" type="radio" name="direction" id="direction_v" value="vertical" checked> <label for="direction_v">'+OpenLayers.i18n('Vertical')+'</label><br/><input class="radio" type="radio" name="direction" id="direction_h" value="horizontal" > <label for="direction_h">'+OpenLayers.i18n('Horizontal')+'</label></div></div>' +
			'	<div class="noflow" data-role="print-formats"><label>'+OpenLayers.i18n('Print format')+':</label> <div class="radio_container"><select name="formato" style="width:auto;">';
			var printFormatsCount = 0;
			$.each(self.options.allowedPrintFormats, function(e, format) {
				if(format == null) return;
				html += '<option value="'+format+'">'+format+'</option>';
				printFormatsCount += 1;
			});
			html += '	</select></div></div>';
            
            if(self.options.availableFormats.length > 1) {
                html += '<div class="noflow"><label>'+OpenLayers.i18n('Format')+':</label> <div class="radio_container">';
                $.each(self.options.availableFormats, function(e, format) {
                    html += '<input class="radio" type="radio" name="format" id="format_'+format+'" value="'+format+'" checked> <label for="format_'+format+'">'+format+'</label> ';
                });
                html += '</div></div>';
            } else if(self.options.availableFormats.length !== 1) {
                console.log('No Available print formats (html, pdf...)');
            }
            html += '</fieldset>' +
            '<fieldset>'+
            '	<legend>'+OpenLayers.i18n('Options')+'</legend>' +
			'	<div class="noflow"><label>'+OpenLayers.i18n('Scale')+':</label> <div class="radio_container"><input class="radio" type="radio" name="scale_mode" id="scale_mode_auto" value="auto" checked> <label for="scale_mode_auto">'+OpenLayers.i18n('Auto')+'</label><br /> <input class="radio" type="radio" name="scale_mode" id="scale_mode_user" value="user"> <label for="scale_mode_user">1: </label><input type="text" name="scale" style="width:70px;" disabled="disabled"> <button title="'+OpenLayers.i18n('Select area by box')+'" name="show_box" style="display:none;" class="gc_ui-icon-minimized"><img src="'+OpenLayers.ImgPath+'print-box-move.gif" alt="'+OpenLayers.i18n('Select area by box')+'" /></button><button name="hide_box" style="display:none;" class="gc_ui-icon-minimized" title="'+OpenLayers.i18n('Delete box')+'"><img src="'+OpenLayers.ImgPath+'print-box-delete.gif" alt="'+OpenLayers.i18n('Delete box')+'" /></button></div></div>';
/*             if(self.options.printVectors) {
                html += '<div class="noflow" data-tool="print"><label>'+OpenLayers.i18n('Vectors')+':</label> <div class="radio_container"><input class="radio" type="radio" name="print_vectors" id="print_vectors_yes" value="yes"> <label for="print_vectors_yes">'+OpenLayers.i18n('Yes')+'</label> <input class="radio" type="radio" name="print_vectors" id="print_vectors_no" value="no" checked> <label for="print_vectors_no">'+OpenLayers.i18n('No')+'</label></div></div>';
            } else {
                html += '<input type="hidden" name="print_vectors" value="no">';
            } */
			var resolutionsCount = 0;
            
            if(Object.keys(self.options.allowedResolutions).length > 1) {
                html += '	<div class="noflow" data-role="resolutions"><label>'+OpenLayers.i18n('Resolution')+':</label> <select name="dpi" style="width:auto;">';
                $.each(self.options.allowedResolutions, function(resValue, resName) {
                    if(resName === null) return;
                    html += '<option value="'+resValue+'">'+OpenLayers.i18n(resName)+'</option>';
                    resolutionsCount += 1;
                });
                html += '</select></div>' +
                    '</fieldset>';
            } else if(Object.keys(self.options.allowedResolutions).length === 0) {
                console.log('No Available resolutions');
            }
            
			html += '<div class="buttons"><button name="print" data-tool="download">'+OpenLayers.i18n('Download')+'</button><button name="print" data-tool="print">'+OpenLayers.i18n('Print')+'</button></div></div>'+
			//restart
			'<div class="loading" style="display:none;"><img src="'+OpenLayers.ImgPath+'ajax-loader.gif"></div>'+
			'<div class="results" style="display:none;">'+
			'	<span name="result"></span>'+
			'	<div class="buttons"><button name="restart">'+OpenLayers.i18n('Restart')+'</button> </div>'+
			'</div>';
			
			$('#mapimage_dialog').html(html);
			
			if(self.options.displayBox) {
				var boxHtml = '<div id="print_box" style="border:3px solid red;position:absolute;top:0px;left:0px;z-index:1000;cursor:move;display:none;"><div style="background:silver;opacity:0.1;width:100%;height:100%;filter:alpha(opacity=10);">&nbsp;</div></div>';
				$(gisclient.element).append(boxHtml);
				$('#print_box').draggable({containment: 'parent'}).bind('dragstop',{self:self},self._boxMoved);
				$('#print_box').resizable({containment: 'parent'}).bind('resizestop',{self:self},self._boxMoved);
			}
			
			if(printFormatsCount === 1) {
				$('#mapimage_dialog div[data-role="print-formats"]').hide();
			}
			if(resolutionsCount === 1) {
				$('#mapimage_dialog div[data-role="resolutions"]').hide();
			}
			
			$('#mapimage_dialog').dialog({
				draggable:true,
				width: 435,
				title:OpenLayers.i18n('Print settings'),
				close: function() {
					if(self.options.displayBox) self._hideBox();
				},
				autoOpen: false
			});
			
			$('#mapimage_dialog button[name="restart"]').click(function() {
				self.internalVars.tool.initForm();
				if(self.options.displayBox) self._hideBox();
			});
			$('#mapimage_dialog button[name="print"]').click(function() {
				self.internalVars.tool.processRequest();
			});

			$('#mapimage_dialog input[name="scale_mode"]').click(function() {
				var mode = $('#mapimage_dialog input[name="scale_mode"]:checked').val();
				if(mode === 'auto') {
					$('#mapimage_dialog input[name="scale"]').attr('disabled', 'disabled');
					if(self.options.displayBox) {
						self._hideBox();
						$('#mapimage_dialog button[name="show_box"]').hide();
						$('#mapimage_dialog button[name="hide_box"]').hide();
					}
				} else {
					$('#mapimage_dialog input[name="scale"]').removeAttr('disabled');
					if(self.options.displayBox) {
						$('#mapimage_dialog button[name="show_box"]').show();
					}
				}
			});
			
			if(self.options.displayBox) {
				$('#mapimage_dialog button[name="show_box"]').button().hide().click(function(event) {
					event.preventDefault();
					
					self._showBox();
				});
				$('#mapimage_dialog button[name="hide_box"]').button().hide().click(function(event) {
					event.preventDefault();
					
					self._hideBox();
				});
			}
		},
		
		
		switchTool: function(type, tool) {
			var self = this;
			
			self.options.type = type;
			self.internalVars.tool = tool;
			
			if (type === 'print') {
				$('#mapimage_dialog [data-tool="print"]').show();
				$('#mapimage_dialog [data-tool="download"]').hide();
				$('#mapimage_dialog').dialog('option', 'title', OpenLayers.i18n('Print settings'));
                $('#print_box').resizable('disable');
			} else {
				$('#mapimage_dialog [data-tool="print"]').hide();
				$('#mapimage_dialog [data-tool="download"]').show();
				$('#mapimage_dialog').dialog('option', 'title', OpenLayers.i18n('Download settings'));
                $('#print_box').resizable('enable');
			}
		},
		
		showForm: function() {
			var self = this;
			
			$('#mapimage_dialog div.results').hide();
			$('#mapimage_dialog div.loading').hide();
			$('#mapimage_dialog div.settings').show();
			self.openDialog();
		},
		
		openDialog: function() {
			$('#mapimage_dialog').dialog('open');
		},
		
		closeDialog: function() {
			$('#mapimage_dialog').dialog('close');
		},
		
		setDefault: function(field, value) {
			$('#mapimage_dialog input[name="'+field+'"]').val(value);
			$('#mapimage_dialog span[data-role="fixed_'+field+'"]').html(value);
		},
		
		getParams: function() {
			var self = this;
			
			$('#mapimage_dialog div.results').hide();
			$('#mapimage_dialog div.loading').show();
			$('#mapimage_dialog div.settings').hide();
			
			var tiles = [];
			
			$.each(gisclient.map.layers, function(layername, layer) {
				if (!layer.getVisibility()) return;
				//if (!layer.calculateInRange()) return;
                var tile;
				if(layer.CLASS_NAME == 'OpenLayers.Layer.TMS') {
                    tile = {
                        url: layer.url.replace('/tms/', '/wms/'),
                        service: 'TMS',
                        parameters: {
                            service: 'WMS',
                            request: 'GetMap',
                            project: gisclient.getProject(),
                            map: gisclient.getMapOptions().mapsetName,
                            layers: [layer.layername.substr(0, layer.layername.indexOf('@'))],
                            version: '1.1.1',
                            format: 'image/png'
                        },
                        opacity: layer.opacity ? (layer.opacity * 100) : 100
                    };
                } else if(layer.CLASS_NAME == 'OpenLayers.Layer.WMS') {
                    tile = {
                        url: layer.url,
                        service: 'WMS',
                        parameters: layer.params,
                        opacity: layer.opacity ? (layer.opacity * 100) : 100
                    };
                } else if(layer.CLASS_NAME == 'OpenLayers.Layer.WMTS') {
                    tile = {
                        url: layer.url,
                        service: 'WMTS',
                        project: layer.projectName,
                        layer: layer.layerName,
                        parameters: layer.params,
                        opacity: layer.opacity ? (layer.opacity * 100) : 100
                    };
                }
                if(tile) tiles.push(tile);
			});

			var mapOptions = gisclient.getMapOptions();
			if(mapOptions.legend) {
				var gcLayersManager = gisclient.componentObjects.gcLayersManager;
				var printLegend = {mapsetUrl:gisclient.options.mapsetURL,themes:[]};
				var themes = gcLayersManager.getThemes();
				$.each(themes, function(themeId, theme) {
					if(!gcLayersManager.themeIsActive(themeId)) return;
					var themeObj = {title:theme.title, id:themeId, groups:[]};
					$.each(gcLayersManager.getLayers(themeId), function(groupId, group) {
						if(!gcLayersManager.layerIsActive(themeId, groupId)) return;
						if(typeof(group.legend) == 'undefined') return;
						var groupObj = {title:group.title, id:groupId, map:themeId, project:gisclient.getProject(), layers:[]};
						if(typeof(group.parameters) == 'object' && typeof(group.parameters.sld) != 'undefined') {
							groupObj.sld = group.parameters.sld;
						}
						var url = mapOptions.mapsetURL+'legend/'+gisclient.getProject()+'/'+themeId+'-'+groupId+'.png';
						$.each(group.legend, function(e, layerName) {
							var legendObj = {url:url, title:layerName.class_title};
							groupObj.layers.push(legendObj);
						});
						themeObj.groups.push(groupObj);
					});
					printLegend.themes.push(themeObj);
				});
			}

			var params = self._getConfigParams();
			
			params.tiles = tiles;

            if(self.options.forceLegend) {
                params.legend = 'yes';
            } else {
                if(mapOptions.legend && $('#mapimage_dialog input[name="legend"]:checked').val() == 'yes') {
                    params.legend = printLegend;
                }
            }
            
            if(self.options.printVectors) {
                //var printVectors = $('#mapimage_dialog input[name="print_vectors"]:checked').val();
                //if(printVectors == 'yes') {
                    params.vectors = self.getVectors();
                //}
            }
            
			return params;
			
		},
        
        getVectors: function() {
            var self = this;
            var vectors = [];
            
            var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
            if(selectionLayer.features.length == 0 || selectionLayer.visibility === false) return [];
            
            
            $.each(selectionLayer.features, function(e, feature) {
                if(!feature.geometry) {
                    console.log('feature without geometry!', feature);
                    return;
                }
                vectors.push({
                    type: feature.geometry.CLASS_NAME.replace('OpenLayers.Geometry.', ''),
                    geometry: feature.geometry.toString()
                });
            });
            
            return vectors;
        },
		
		_getConfigParams: function() {
			var self = this;
			
			var size  = gisclient.map.getCurrentSize();
			var bounds = gisclient.map.calculateBounds();
			var topLeft = new OpenLayers.Geometry.Point(bounds.top, bounds.left);
			var topRight = new OpenLayers.Geometry.Point(bounds.top, bounds.right);
			var distance = topLeft.distanceTo(topRight);
			var pixelsDistance  = size.w / distance;
			var scaleMode = $('#mapimage_dialog input[name="scale_mode"]:checked').val();
			var scale = pointedToInt($('#mapimage_dialog input[name="scale"]').val());
			var currentScale = pointedToInt(gisclient.componentObjects.scaleDropDown.getCurrentScale());
			if(scaleMode === 'user') {
				pixelsDistance = pixelsDistance / (scale/currentScale);
			}
			
			if(self.internalVars.useBox) {
				bounds = new OpenLayers.Bounds();
				bounds.extend(new OpenLayers.LonLat(self.internalVars.printBox[0], self.internalVars.printBox[1]));
				bounds.extend(new OpenLayers.LonLat(self.internalVars.printBox[2], self.internalVars.printBox[3]));
				var center = bounds.getCenterLonLat();
				//var newbounds = bounds.toBBOX();
			} else {
				var center = gisclient.map.getCenter();
			}
			
			var copyrightString = null;
			var searchControl = gisclient.map.getControlsByClass('OpenLayers.Control.Attribution');
			if(searchControl.length > 0) {
				copyrightString = searchControl[0].div.innerText;
			}
            
            var viewportSize = [size.w, size.h];
            if(self.options.type === 'download' && self.internalVars.useBox) {
                var printBox = $('#print_box');
                if(printBox.length > 0) {
                    var width = printBox.width(),
                        height = printBox.height();
                    
                    if(width && height) viewportSize = [width, height];
                }
            }

            var format;
            if (self.options.availableFormats.length === 1) {
                format = self.options.availableFormats[0];
            } else {
               if($('#mapimage_dialog input[name="format"]:checked').length > 0) {
                    format = $('#mapimage_dialog input[name="format"]:checked').val();
                }
            }
                
            var dpi;
            if (Object.keys(self.options.allowedResolutions).length === 1) {
                // if there is only one allowed value, take it
                dpi = Object.keys(self.options.allowedResolutions)[0]; 
            } else {
                dpi = $('#mapimage_dialog select[name="dpi"]');
            }


			var params = {
				viewport_size: viewportSize,
				center: [center.lon, center.lat],
				format: format,
				printFormat: $('#mapimage_dialog select[name="formato"]').val(),
				direction: $('#mapimage_dialog input[name="direction"]:checked').val(),
				scale_mode: scaleMode,
				scale: scale,
				current_scale: currentScale,
				text: $('#mapimage_dialog textarea[name="text"]').val(),
				extent: bounds.toBBOX(),
				date: $('#mapimage_dialog input[name="date"]').val(),
				dpi: dpi,
				srid: gisclient.getProjection(),
				lang: gisclient.getLanguage(),
				pixels_distance: pixelsDistance,
				northArrow: self.options.northArrow,
				copyrightString: copyrightString,
                logoSx: self.options.logoSx || '',
                logoDx: self.options.logoDx || ''
			};
			return params;
			
		},
		
		_showBox: function() {
			var self = this;
			if(!self.options.displayBox) return;
			
			var params = self._getConfigParams();
			params.request_type = 'get-box';
			
			$.ajax({
				url: gisclient.getMapOptions().printServiceUrl,
				type: 'POST',
				dataType: 'json',
				data: params,
				success: function(response) {
                    if(typeof(response) != 'object' || response == null || typeof(response.result) != 'string' || response.result != 'ok' || typeof(response.box) != 'object') {
                        return alert(OpenLayers.i18n('System error'));
                    }
					self.internalVars.printBox = response.box;
					
					self._updateBox();
					
					$('#print_box').show();
					$('#mapimage_dialog button[name="show_box"]').hide();
					$('#mapimage_dialog button[name="hide_box"]').show();
					
					self.internalVars.useBox = true;
					
					gisclient.map.events.register('moveend', self, self._updateBox);
					
				},
				error: function() {
					return alert(OpenLayers.i18n('System error'));
				}
			});
		},
		
		_updateBox: function() {
			var self = this;
			if(!self.options.displayBox) return;
			
			var bounds = gisclient.map.getExtent();
			var refSize = gisclient.map.getCurrentSize();

			var lb = gisclient.map.getViewPortPxFromLonLat(new OpenLayers.LonLat(self.internalVars.printBox[0], self.internalVars.printBox[1]));
			var rt = gisclient.map.getViewPortPxFromLonLat(new OpenLayers.LonLat(self.internalVars.printBox[2], self.internalVars.printBox[3]));

			var left = (lb.x>0) ? lb.x : 0;
			var top = (rt.y>0) ? rt.y : 0;
			var width = ((rt.x-lb.x)<refSize.w) ? (rt.x-lb.x) : refSize.w;
			var height = ((lb.y-rt.y)<refSize.h) ? (lb.y-rt.y) : refSize.h;
			if((left+width)>refSize.w) width = refSize.w-left;
			if((top+height)>refSize.h) height = refSize.h-top;
			$('#print_box').css({
				'left':left,
				'top':top,
				'width':width,
				'height':height
			});

			console.log(self.internalVars.printBox);
		},
		
		_boxMoved: function(event) {
			var self = event.data.self;
			if(!self.options.displayBox) return;
			
            var pos = $(this).position();
            // get the left-boom and right-top LonLat, given the rectangle position
            var lb = gisclient.map.getLonLatFromPixel(new OpenLayers.Pixel(pos.left, (pos.top+$(this).height())));
            var rt = gisclient.map.getLonLatFromPixel(new OpenLayers.Pixel((pos.left+$(this).width()), pos.top));
            // update the map viewport with the bounds calculated above
			self.internalVars.printBox = [lb.lon, lb.lat, rt.lon, rt.lat];
			console.log(self.internalVars.printBox);
		},
		
		_hideBox: function() {
			var self = this;
			if(!self.options.displayBox) return;
			
			$('#print_box').hide();
			$('#mapimage_dialog button[name="show_box"]').show();
			$('#mapimage_dialog button[name="hide_box"]').hide();
			
			self.internalVars.useBox = false;
			
			gisclient.map.events.unregister('moveend', self, self._updateBox);
		},
		
		showResult: function(file, format) {
			$('#mapimage_dialog div.loading').hide();
			$('#mapimage_dialog hr').next().remove();
			var link = '<a href="'+file+'" target="_blank" rel="file">';
			if(format == 'HTML') {
				link += OpenLayers.i18n('View print file');
			} else if(format == 'PDF') {
				link += OpenLayers.i18n('Download print file');
			} else if(format == 'geotiff') {
				link += OpenLayers.i18n('Download image');
			}
			link += '</a>';
			$('#mapimage_dialog div.results span[name="result"]').html(link);
			$('#mapimage_dialog div.results').show();
		},
		
		showError: function(error) {
			$('#mapimage_dialog div.loading').hide();
			$('#mapimage_dialog hr').next().remove();
			$('#mapimage_dialog div.results span[name="result"]').html(OpenLayers.i18n('Error'));
			$('#mapimage_dialog div.results').show();
		}

	});

	$.extend($.gcComponent.mapImageDialog, {
		version: "3.0.0"
	});
})(jQuery);

function pointedToInt(number) {
	var string = number.toString();
	if(string.indexOf('.') > -1) {
		string = string.replace('.', '');
	}
	return parseInt(string);
}
