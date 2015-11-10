(function($) {

	$.searchEngine = {
        internalVars: {
            noResultsMsg: 'No results'
        },
	
		_query: function(queryLayers, filter) { // only used by selectFromMap
			var self = this;

			// populate the requests object with empty objects
			self.options.requests = {};
			$.each(queryLayers, function(i, layer) {
				self.options.requests[layer.featureId] = {};
			});
			
			self.unSelectAll();
			
			// build the WFS requests and pass them to the countFeatures function
			$.each(queryLayers, function(i, layer) {
				if(layer.defaultFilters != null) {
					var filters = $.extend(true, [], layer.defaultFilters);
					filters.push(filter);
					var finalFilter = new OpenLayers.Filter.Logical({
						type: OpenLayers.Filter.Logical.AND,
						filters: filters
					});
				} else finalFilter = filter;
			
                //versione del filtro commentata per mapserver 6, se da fastidio a mapserver 5, allora bisogna specificare la versione in configurazione
				var filter_1_1 = new OpenLayers.Format.Filter(/* {version: "1.1.0"} */);
				var xml = new OpenLayers.Format.XML();
				var filterValue = xml.write(filter_1_1.write(finalFilter));	
				var title = layer.title;
				if(typeof(title) == 'undefined') title = layer.layer.title;
				
				var params = {
					PROJECT: gisclient.getProject(),
					MAP: layer.layer.parameters.map,
					SERVICE: 'WFS',
					LANG: gisclient.getLanguage(),
					VERSION: '1.1.0',
					REQUEST: 'GETFEATURE',
					SRS: gisclient.getProjection(),
					TYPENAME: layer.featureId,
					FILTER: filterValue
				};
				
				var showGeometry = true;
				if(typeof(layer.showGeometry) != 'undefined' && layer.showGeometry == false) showGeometry = false;

				self.options.requests[layer.featureId] = {
					url:layer.layer.url,
					params: params,
					featureId:layer.featureId,
					fields:layer.fields,
					count: false,
					result: false,
					title: title,
					showGeometry: showGeometry,
					themeId: layer.themeId,
					layerId: layer.layerId
				};
				self._countFeatures(layer.featureId, layer.fields);
			});
		},
		
		_countFeatures: function(featureId, fields) {
			var self = this;
			
			var params = $.extend({}, self.options.requests[featureId].params);
			params.RESULTTYPE = 'HITS';
			
			$.ajax({
				url: self.options.requests[featureId].url,
				type: 'POST',
				data: params,
				dataType: 'xml',
				success: function(data) {
					// get the numberOfFeatures attributes from the returned DOM
					var count = $(data).children().attr('numberOfFeatures');

					// update the requests object with the number of features returned
					self.options.requests[featureId].count = parseInt(count);
					self._checkCount();
				},
				error: function() {
					var string = OpenLayers.i18n('Error counting ${feature} results. They will be excluded from the result set', {feature:featureId});
					gisclient.componentObjects.errorHandler.show(string);
					self.options.requests[featureId].count = 0;
				}
			});
		},
		
		_checkCount: function() {
			var self = this;
			
			var allDone = true; // flag to know if all the requests are returned
			var total = 0; // init the features count
			var requests = self.options.requests;
			$.each(requests, function(featureId, request) {
				// if the count var is not set, the the request has not finished
				if(request.count === false) {
					// set the flag to false and return
					allDone = false;
					return;
				}
				// this will be executed only when all the requested are returned
				total += request.count;
			});
			
			// if all the requests are returned...
			if(allDone && total > 0) {
				// check the total number of returned features
				if(total > self.options.limitVectorFeatures) {
					// if the total exceed the limit, ask for a confirmation to the user
					var string = OpenLayers.i18n('Your request returned with ${count} results. The visualization of these results may take several minutes. Do you want to continue?', {count:total});
					if(!confirm(string)) {
						gisclient.componentObjects.loadingHandler.hide();
						return false;
					}
				}
				$.each(requests, function(featureId, request) {
					// if the user confirmed or the total is lower than the limit, start the requests (one for each feature)
					if(request.count > 0) self.request(featureId, request.fields);
					else self.options.requests[featureId].result = null;
				});
			} else if(allDone && total == 0) {
				// TODO: nessun risultato un errore o no?
				//gisclient.componentObjects.loadingHandler.hide();
				gisclient.componentObjects.errorHandler.show(OpenLayers.i18n(self.internalVars.noResultsMsg));
			}
		},
		
		request: function(featureId, fields) {
			var self = this;

			var params = $.extend({}, self.options.requests[featureId].params);
			// HACK: OL has problems parsing geometries in GML3, force GML2 instead (this cause WFS to handle the request as VERSIONE 1.0.0)
            if (!gisclient.options.supportsGml3) {
			    params.OUTPUTFORMAT = 'text/xml; subtype=gml/2.1.2';
            }
            // con mapserver 6, usare versioni > di 1.0.0 significa avere problemi con xy/yx e con il parsing del gml
            //così sembra funzionare bene, se da problemi con ms5, bisogna mettere in configurazione
            params.VERSION = '1.0.0';

			$.ajax({
				url: self.options.requests[featureId].url,
				type: 'POST',
				data: params,
				dataType: 'xml',
				success: function(data) {
					var format = new OpenLayers.Format.GML();
					var resp=format.read(data);
					
					// build the jqgrid table options
					var links = gisclient.componentObjects.gcLayersManager.getFeatureLink(featureId);
					var link = '<div class="search_results_buttons"><a href="#" data-action="export_xls" data-feature_id="'+featureId+'">Export</a>';
                    if(typeof(gisclient.componentObjects.viewTable) != 'undefined') {
                        link += ' <a href="#" data-action="view_in_table" data-feature_id="'+featureId+'">'+OpenLayers.i18n('View results in a table')+'</a>';
                    }
                    link += '</div>';
					var domFeatureId = featureId.replace('.','_');
					var tableOptions = {
						datatype:'local',
						caption:self.options.requests[featureId].title+' <input name="show_tooltips_options_'+domFeatureId+'" type="checkbox"> Tooltips'+link,
						onSelectRow: self.highlightFeature, // when the user select a table row, highlight the corresponding feature
						ondblClickRow: self.handleDoubleClick,
						width: 250,
                        rowNum: 1000,
						height: 'auto',
						//toolbar: [true, 'top'],
						self: self //HACK: we need to pass the self variable to jqgrid to use it on highlightFeature function
					};
					// build the colModel
					var colModel = [];
					// insert an hidden column to store the feature id
					colModel.push({name:'GCfid',index:'GCfid',key:true,hidden:true,sortable:false,resizable:true});
					// store the columns in the cols object
					self.options.cols[featureId] = {};
					// iterate the fields to add columns to table and cols object
					$.each(fields, function(key, col) {
						var fieldType=(col.dataType==1)?('text'):((col.dataType==2)?('float'):('date'));
						colModel.push({name:key,index:key,label:col.fieldHeader,sorttype:fieldType});
						self.options.cols[featureId][key] = col.fieldHeader;
					});
					if(links) colModel.push({name:'gc_tools',index:'gc_tools',label:OpenLayers.i18n('Tools'),sortable:false,resizable:true,width:20,fixed:true});
					// add the colModel to the jqgrid table options
					tableOptions.colModel = colModel;
					
					// init the data array
					var data = [];
					if(resp.length > 0) {
                        var featureConfig = gisclient.componentObjects.gcLayersManager.getQueryableLayer(featureId);
						// populate the data array
						$.each(resp, function(e, feature) {
							var attributes = feature.attributes;
							// add to the feature attributes the GCfid id and the featureType name
							attributes.GCfid = feature.id;
							attributes.featureId = featureId;
							data.push(attributes);
                            if(typeof(featureConfig.relation1n) == 'object') {
                                var countField = null;
                                $.each(featureConfig.fields, function(key, field) {
                                    if(typeof(field.is1nCountField) != 'undefined' && field.is1nCountField) {
                                        countField = key;
                                    }
                                });
                                if(countField && typeof(attributes[countField]) != 'undefined') {
                                    if(attributes[countField] > 0) {
                                        attributes[countField] = '<a href="#" title="'+OpenLayers.i18n('Visualizza dati collegati')+'" data-action="show1ntable" data-qtrelation_id="'+featureConfig.relation1n.qtrelation_id+'" data-f_key_value="'+attributes[featureConfig.relation1n.data_field_1]+'">'+attributes[countField]+'</a>';
                                    }
                                }
                            }
						});
					}
					// build the table object and pass it to the collectFeatures function
					var table = {tableOptions:tableOptions,tableData:data};
					self._collectFeatures(featureId, table, resp);
				},
				error: function() {
					var string = OpenLayers.i18n('Error reading results, the request has been aborted');
					gisclient.componentObjects.errorHandler.show(string, {feature:featureId});
					self.options.requests[featureId].result = null;
					return false;
				}
			});
			
		},
		
		_collectFeatures: function(featureId, table, features) {
			var self = this;
			
			// add to the requests object the jqgrid table data
			self.options.requests[featureId].result = table;
			self.options.requests[featureId].features = features;
			// check if all the requests are returned
			var allDone = true;
			$.each(self.options.requests, function(featureId, request) {
				if(request.result === false) {
					allDone = false;
					return;
				}
			});
			
			var gcLayersManager = gisclient.componentObjects.gcLayersManager;
			
			// add returned features to the selection layer
			if(self.options.requests[featureId].showGeometry) {
				var selectionLayer = gcLayersManager.getSelectionLayer();
				if(self.options.displayFeatures) selectionLayer.addFeatures(features);
			}
			
			if(!gcLayersManager.layerIsActive(self.options.requests[featureId].themeId, self.options.requests[featureId].layerId)) {
				gcLayersManager.activateLayer(self.options.requests[featureId].themeId, self.options.requests[featureId].layerId);
			}
			
			// if all the requests are returned
			if(allDone) {
				$.each(self.options.requests, function(featureId, request) {
                    $('#dataListTab').show();
					var table = request.result;
					if(table == null) return;
					// create the table element to init jqgrid
					var domFeatureId = featureId.replace('.','_');
					var tableElement = '<table id="searchResults_'+domFeatureId+'"></table>';
					// append the table element to the container element
					$('#datalist_searchresults').append(tableElement);
					// init the jqgrid table
					$('#searchResults_'+domFeatureId).jqGrid(table.tableOptions);
					var data = table.tableData;
					
					// add table rows
					if(data.length > 0) {
						for(var i=0;i<data.length;i++) {
							var links = gcLayersManager.getFeatureLink(featureId);
							if(links && typeof(links.objectLink) != 'undefined') {
								var link = null;
								var checkFieldReplacer = links.objectLink.indexOf('@');
								if(checkFieldReplacer > -1) {
                                    var linkWithParams = links.objectLink;
                                    var f = 0; // per sicurezza...
                                    while(linkWithParams.indexOf('@') > -1) {
                                        f++;
                                        var pos1 = linkWithParams.indexOf('@');
                                        var pos2 = linkWithParams.indexOf('@', pos1+1);
                                        if(pos2 > -1) {
                                            var fieldName = linkWithParams.substr(pos1+1, (pos2-(pos1+1)));
                                            if(typeof(data[i][fieldName]) != 'undefined') {
                                                linkWithParams = linkWithParams.replace('@'+fieldName+'@', data[i][fieldName]);
                                            }
                                        } else {
                                            linkWithParams = linkWithParams.substr(0, pos1);
                                        }
                                        if(f == 50) break;
                                    }
                                    link = linkWithParams;
								} else {
									if(typeof(data[i][links.objectIdField]) != 'undefined') {
										var separator = '?';
										if(links.objectLink.indexOf('?') != -1) separator = '&';
										link = links.objectLink+separator+links.objectIdField.toLowerCase()+'='+data[i][links.objectIdField];
									}
								}
								if(link != null) {
									var openFunction = 'gisclient.parentGoTo';
									if(typeof(links.objectLinkType) != 'undefined') {
										if(links.objectLinkType == 'dialog') openFunction = 'gisclient.parentOpenDialog';
										else if(links.objectLinkType == 'popup') openFunction = 'gisclient.openPopup';
                                        else if(links.objectLinkType == 'js' && typeof(eval(links.customJsFunction)) == 'function') openFunction = links.customJsFunction;
									}
									data[i].gc_tools = '<a href="#" onclick="'+openFunction+'(\''+link+'\')"><img src="'+OpenLayers.ImgPath+'application_view.png" border="0"></a>';
								}
							}
							$('#searchResults_'+domFeatureId).jqGrid('addRowData',data[i].GCfid,data[i]); 
						}
					}

					$('input[name="show_tooltips_options_'+domFeatureId+'"]').click(function(event) {
						self._toggleToolTipOption($(this), domFeatureId);
					});
				});
				$('#datalist_searchresults a[data-action="export_xls"]').click(function(event) {
                    event.preventDefault();
					self.exportXls($(this).attr('data-feature_id'));
				}).addClass('gc_ui-icon-minimized').button({ icons: { primary: "ui-icon-arrowthickstop-1-s" }, text:false });
				$('#datalist_searchresults a[data-action="view_in_table"]').click(function(event) {
                    event.preventDefault();
					self.viewInTable($(this).attr('data-feature_id'));
				}).addClass('gc_ui-icon-minimized').button({ icons: { primary: "ui-icon-newwin" }, text:false });
				// show the data tab
				$('#'+self.options.idTree).tabs('select', '#'+self.options.idDataList);
                
                $('#datalist_searchresults a[data-action="show1ntable"]').click(function(event) {
                    event.preventDefault();
                    
                    gisclient.componentObjects.detailTable.show($(this).attr('data-qtrelation_id'), $(this).attr('data-f_key_value')); 
                });
				
				// action after selection
				var after_selection = $('#'+self.options.actionSelectionParent).find('input[name="after_selection_action"]:checked').val();
				if(after_selection != 'none') {
						// create a bounds object and extend it with the bounds of the selected features
                    var bounds = new OpenLayers.Bounds();
                    $.each(features, function(i, feature) { bounds.extend(feature.bounds); });
					if(after_selection == 'zoom') {
						var extendedBounds = new OpenLayers.Bounds(
							bounds.left-50,
							bounds.bottom-50,
							bounds.right+50,
							bounds.top+50
						);
						gisclient.map.zoomToExtent(extendedBounds);
					} else if(after_selection == 'center') {
						var center = bounds.getCenterLonLat();
						gisclient.map.setCenter(center);
					}
				}
				
				gisclient.componentObjects.loadingHandler.hide();
			}
		},
		
		_highlightTableRow: function(event) {
			// when the user hover on a selected feature, highlight the corrisponding table row
			var self = this;
			var feature = event.feature;
			var tableRowId = feature.id; // every table row has the same id of the feature
			if(typeof(feature.attributes) == 'undefined' || typeof(feature.attributes.featureId) == 'undefined') return;
			var featureId = feature.attributes.featureId;
			// select the corrisponding row
			var domFeatureId = featureId.replace('.','_');
			$('#searchResults_'+domFeatureId).jqGrid('setSelection',tableRowId,false);
			// show a tooltip for the selected feature
			if(self.options.tooltips == domFeatureId) self._showPopup(feature);
		},
		
		_showPopup: function(feature) {
			var self = this;
			// destroy other popups
			$.each(gisclient.map.popups, function(e, popup) {
				popup.destroy();
			});
			// get columns
			if(typeof(feature.attributes) == 'undefined' || typeof(feature.attributes.featureId) == 'undefined') return;
			var cols = self.options.cols[feature.attributes.featureId];
			// if not exists, create a temp tooltip container to measure the content height
			if($('#temp_tooltip').length < 1) $('body').append('<div id="temp_tooltip" style="display:none;width:'+self.options.tooltipWidth+';"></div>');
			// create the tooltip html
			var html = '<div class="tooptip">';
			$.each(cols, function(key, label) {
				html += '<strong>'+label+'</strong>: '+feature.attributes[key]+'<br />';
			});
			html += '</div>';
			// put the tooltip html in the temp div and measure its height
			$('#temp_tooltip').html(html);
			var h = ($('#temp_tooltip').height())+20;
			// create the popup and add it to the map
			feature.popup = new OpenLayers.Popup.Anchored('',feature.geometry.getBounds().getCenterLonLat(),new OpenLayers.Size(self.options.tooltipWidth,h),html,null,false);
			gisclient.map.addPopup(feature.popup);
		},
		
		_hidePopup: function(feature) {
			if(feature.popup != null) feature.popup.destroy();
		},
		
		_unhighlightTableRow: function(event) {
			var self = this;
			var feature = event.feature;
			if(typeof(feature.attributes) == 'undefined' || typeof(feature.attributes.featureId) == 'undefined') return;
			var tableId = feature.featureId;
			// on feature unhighlight, deselect the table row and eventually destroy the tooltip
			$('#searchResults_'+tableId).jqGrid('resetSelection');
			if(self.options.tooltips == tableId && feature.popup != null) self._hidePopup(feature);
		},
		
		highlightFeature: function(id) {
			// HACK: get self from the jqgrid object
			var self = $(this).jqGrid('getGridParam','self');

			// highlight the feature
			var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
			var feature = selectionLayer.getFeatureById(id);
			self.options.hoverControl.unselectAll();
			if(feature != null) self.options.hoverControl.select(feature);
		},
		
		handleDoubleClick: function(id) {
			var self = $(this).jqGrid('getGridParam', 'self');
			
			
		},
		
		_toggleToolTipOption: function(checkbox, domFeatureId) {
			var self = this;
			var checked = checkbox.attr('checked');
						
			if(checked) {
				var tooltipCheckboxes = $('input[name^="show_tooltips_options_"]');
				$.each(tooltipCheckboxes, function(e, tooltipCheckbox) {
					if($(checkbox).attr('name') != $(tooltipCheckbox).attr('name')) $(tooltipCheckbox).attr('checked', false);
				});
			}
			
			// get the selected features to eventually show or hide the active tooltips
			var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
			$.each(selectionLayer.selectedFeatures, function(i, feature) {
				if(checked) self._showPopup(feature);
				else self._hidePopup(feature);
			});
			
			// update the tooltips option
			if(!checked) self.options.tooltips = false;
			else self.options.tooltips = domFeatureId;
		},
		
		exportXls: function(featureId) {
			var self = this;

			gisclient.exportXls(featureId, self.options.requests[featureId].features);
		},
        
        viewInTable: function(featureId) {
            var self = this;
            
            gisclient.componentObjects.viewTable.showTable(self.options.requests[featureId], self.options.requests[featureId].features);
        },

		unSelectAll: function() {
			var self = this;
			
			var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
			selectionLayer.removeAllFeatures();
			while(gisclient.map.popups.length > 0) {
				gisclient.map.removePopup(gisclient.map.popups[0]);
			}
			$('#datalist_searchresults').empty();
			self.options.requests = {};
            $('#dataListTab').hide();
			
			//gisclient.componentObjects.loadingHandler.hide();
			
		}


	};
})( jQuery );
