(function($) {

	$.searchEngine = {
		internalVars: {
			noResultsMsg: 'No results',
			lastActiveTab: null
		},

		customQuery: function(queries) {
			var self = this;

			// populate the requests object with empty objects
			self.options.requests = {};
			$.each(queries, function(featureType, foo) {
				self.options.requests[featureType] = {};
			});

			self.unSelectAll();

			$.each(queries, function(e, query) {
				var layer = gisclient.componentObjects.gcLayersManager.getQueryableLayer(query.featureType);

				if(layer.defaultFilters != null) {
					var filters = $.extend(true, [], layer.defaultFilters);
					filters.push(query.filter);
					var finalFilter = new OpenLayers.Filter.Logical({
						type: OpenLayers.Filter.Logical.AND,
						filters: filters
					});
				} else finalFilter = query.filter;


				var filter_1_1 = new OpenLayers.Format.Filter({version: "1.1.0"});
				var xml = new OpenLayers.Format.XML();
				var filterValue = xml.write(filter_1_1.write(finalFilter));
				var title = layer.title;
				if(typeof title === 'undefined') title = layer.layer.title;

				var params = {
					PROJECT: gisclient.getProject(),
					MAP: layer.layer.parameters.map,
					SERVICE: 'WFS',
					LANG: gisclient.getLanguage(),
					VERSION: '1.0.0',
					REQUEST: 'GETFEATURE',
					SRS: gisclient.getProjection(),
					TYPENAME: layer.featureId,
					FILTER: filterValue
				};

				var showGeometry = true;
				if(typeof layer.showGeometry !== 'undefined' && layer.showGeometry == false) showGeometry = false;

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

				self.request(layer.featureId, layer.fields);
			});

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
			if($.isEmptyObject(queryLayers)){
				gisclient.componentObjects.errorHandler.show(OpenLayers.i18n('No layer active'));
			} else {
				$.each(queryLayers, function(i, layer) {
					if(layer.defaultFilters != null) {
						var filters = $.extend(true, [], layer.defaultFilters);
						filters.push(filter);
						var finalFilter = new OpenLayers.Filter.Logical({
							type: OpenLayers.Filter.Logical.AND,
							filters: filters
						});
					} else finalFilter = filter;

					var filter_1_1 = new OpenLayers.Format.Filter({version: "1.1.0"});
					var xml = new OpenLayers.Format.XML();
					var filterValue = xml.write(filter_1_1.write(finalFilter));
					var title = layer.title;
					if(typeof title === 'undefined') title = layer.layer.title;

					var params = {
						PROJECT: gisclient.getProject(),
						MAP: layer.layer.parameters.map,
						SERVICE: 'WFS',
						LANG: gisclient.getLanguage(),
						VERSION: '1.0.0',
						REQUEST: 'GETFEATURE',
						SRS: gisclient.getProjection(),
						TYPENAME: layer.featureId,
						FILTER: filterValue
					};

					var showGeometry = true;
					if(typeof layer.showGeometry !== 'undefined' && layer.showGeometry == false) showGeometry = false;

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
			}
		},

		_countFeatures: function(featureId, fields) {
			var self = this;

			var params = $.extend({}, self.options.requests[featureId].params);
			params.RESULTTYPE = 'HITS';
			params.VERSION = '1.1.0'; // required, because RESULTTYPE=HITS is only implemented in WFS >= 1.1.0

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
			// HACK: OL has problems parsing geometries in GML3, force GML2 instead (this cause WFS to handle the request as VERSION 1.0.0)
			if (!gisclient.options.supportsGml3) {
				params.OUTPUTFORMAT = 'text/xml; subtype=gml/2.1.2';
			}

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

					// Additional butons
					var link = '<div class="search_results_buttons">';
					if (self.options.additionalButtons) {
						$.each(self.options.additionalButtons, function(seq, button) {
							if (typeof button['callback'] !== 'function') {
								console.error("SearchEngine error: custom button #" + seq + " has no callback function");
							} else {
								if (typeof button['layers'] === 'undefined' || $.inArray(featureId, button['layers']) >= 0) {
									var title = button['title'] || '';
									link += '<a href="#" data-action="additional_buttons_' + seq + '" data-feature_id="'+featureId+'">' + title + '</a> ';
								}
							}
						});
					}

					// Export excel button
					var hasExportExcelButton = true;
					if (self.options.exportExcel && self.options.exportExcel.excludedLayers) {
						$.each(self.options.exportExcel.excludedLayers, function(seq, layer) {
							if (layer == featureId) {
								hasExportExcelButton = false;
							}
						});
					}
					if (hasExportExcelButton) {
						link += '<a href="#" data-action="export_xls" data-feature_id="'+featureId+'">Export</a> ';
					}

					// view-in-table button
					var hasViewInTableButton = typeof gisclient.componentObjects.viewTable !== 'undefined';
					if (self.options.viewTable && self.options.viewTable.excludedLayers) {
						$.each(self.options.viewTable.excludedLayers, function(seq, layer) {
							if (layer == featureId) {
								hasViewInTableButton = false;
							}
						});
					}

					if(hasViewInTableButton) {
						link += '<a href="#" data-action="view_in_table" data-feature_id="'+featureId+'">'+OpenLayers.i18n('View results in a table')+'</a>';
					}
					link += '</div>';
					var domFeatureId = featureId.replace('.','_');
					var tableOptions = {
						datatype:'local',
						caption:self.options.requests[featureId].title+' <input name="show_tooltips_options_'+domFeatureId+'" type="checkbox"> '+OpenLayers.i18n('Tooltips')+link,
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
					self.options.cols[featureId] = {}; //non viene usato?
					// iterate the fields to add columns to table and cols object
					$.each(fields, function(key, col) {
						var fieldType = 'text';
						var width;
						if(col.resultType == 10) return;
						switch(col.dataType) {
							case 2:
								fieldType = 'float';
							break;
							case 3:
								fieldType = 'date';
							break;
							case 10:
							case 15:
								if(!col.fieldHeader) col.fieldHeader = 'Link';
								//width = 30;
							break;
						}
						var colConfig = {name:key,index:key,label:col.fieldHeader,sorttype:fieldType};
						if(width) colConfig.width = width;
						colModel.push(colConfig);
						if(col.dataType != 10 && col.dataType != 15) self.options.cols[featureId][key] = col.fieldHeader;
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
							if(typeof featureConfig.relation1n === 'object') {
								var countField = null;
								$.each(featureConfig.fields, function(key, field) {
									if(typeof field.is1nCountField !== 'undefined' && field.is1nCountField) {
										countField = key;
									}
								});
								if(countField && typeof attributes[countField] !== 'undefined') {
									if (featureConfig.relation1n.data_field_1 in attributes) {
										if(attributes[countField] > 0) {
											attributes[countField] = '<a href="#" title="'+OpenLayers.i18n('Show linked data')+'" data-action="show1ntable" data-relation_id="'+featureConfig.relation1n.relation_id+'" data-f_key_value="'+attributes[featureConfig.relation1n.data_field_1]+'">'+attributes[countField]+'</a>';
										}
									} else {
										alert('ERROR: the field ' + featureConfig.relation1n.data_field_1 + ' is not in the feature attributes list. Please recheck your GisCient layer configuration');
									}
								}
							}
							$.each(featureConfig.fields, function(key, field) {
								if(!attributes[key] || attributes[key] == '') return;
								if(field.dataType === 10) {
									attributes[key] = '<a href="#" title="'+OpenLayers.i18n('Show image')+'" data-action="show-image" data-filename="'+attributes[key]+'"><img src="images/photo.png" style="margin: 2px 0 0 2px;"/></a>';
								} else if(field.dataType === 15) {
									attributes[key] = '<a href="#" title="'+OpenLayers.i18n('Show attachment')+'" data-action="show-attachment" data-filename="'+attributes[key]+'"><img src="images/attachment.png" style="margin: 2px 0 0 2px;"/></a>';
								}
							});
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
				console.debug('Activate ' + self.options.requests[featureId].themeId + '.' + self.options.requests[featureId].layerId);
				gcLayersManager.activateLayer(self.options.requests[featureId].themeId, self.options.requests[featureId].layerId);
			}

			// Activate dependends layer
			$.each(gisclient.options.mapQueryActivateLayers, function(themeIdAndLayerGroupId, depsLayers) {
				if ((self.options.requests[featureId].themeId == themeIdAndLayerGroupId) ||  // themeId match
					(self.options.requests[featureId].themeId + '.' + self.options.requests[featureId].layerId == themeIdAndLayerGroupId))   { // themeId + layerId match
					$.each(depsLayers, function(dummy, themeIdAndLayerGroupIdToActivate) {
						var res = themeIdAndLayerGroupIdToActivate.split('.');
						if (res.length == 1) {
							// Activate all the layergroupd for the given layer
							console.debug('Activate dependent thema ' + res[0]);
							gcLayersManager.activateTheme(res[0]);
						} else if (res.length == 2) {
							console.debug('Activate dependent layer ' + res[0] + '.' + res[1]);
							gcLayersManager.activateLayer(res[0], res[1]);
						}
					});
				}
			});

			// if all the requests are returned
			if(allDone) {

				$.each(self.options.requests, function(featureId, request) {

					// Save old tab (jQuery 1.8)
					var activeTab;
					if($('#treeDiv > ul > li.ui-tabs-selected').length > 0){
						activeTab = $('#treeDiv > ul > li.ui-tabs-selected').find('a').attr('href').substr(1);
					} else  {
						activeTab = $('#treeDiv > ul > li.ui-tabs-active').find('a').attr('href').substr(1);
					}
					if (activeTab != 'dataList') {
						self.internalVars.lastActiveTab = activeTab;
					}

					$('#dataListTab').show();
					var table = request.result;
					if(table == null) return;
					// create the table element to init jqgrid
					var domFeatureId = featureId.replace('.','_');
					var tableElement = '<table class="searchResults" id="searchResults_'+domFeatureId+'"></table>';
					// append the table element to the container element
					$('#datalist_searchresults').append(tableElement);
					// init the jqgrid table
					$('#searchResults_'+domFeatureId).jqGrid(table.tableOptions);
					var data = table.tableData;

					// add table rows
					if(data.length > 0) {
						for(var i=0;i<data.length;i++) {
							var row = data[i];
							var links = gcLayersManager.getFeatureLink(featureId);
							if(links && typeof links.objectLink !== 'undefined') {
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
											if(typeof row[fieldName] !== 'undefined') {
												linkWithParams = linkWithParams.replace('@'+fieldName+'@', row[fieldName]);
											}
										} else {
											linkWithParams = linkWithParams.substr(0, pos1);
										}
										if(f == 50) break;
									}
									link = linkWithParams;
								} else {
									if(typeof row[links.objectIdField] !== 'undefined') {
										var separator = '?';
										if(links.objectLink.indexOf('?') != -1) separator = '&';
										link = links.objectLink+separator+links.objectIdField.toLowerCase()+'='+row[links.objectIdField];
									}
								}
								if(link != null) {
									var openFunction = 'gisclient.parentGoTo';
									var openFuncOptionsStr = '{}';
									if(typeof links.objectLinkType !== 'undefined') {
										if(links.objectLinkType == 'dialog') {
											openFunction = 'gisclient.parentOpenDialog';
										} else if(links.objectLinkType == 'popup') {
											openFunction = 'gisclient.openPopup';

											openFuncOptionsStr = '{width: ' + (links.objectLinkWidth || 'null') + ', height: ' + (links.objectLinkHeight  || 'null') + '}';
										} else if(links.objectLinkType == 'js' && typeof eval(links.customJsFunction) === 'function') {
											openFunction = links.customJsFunction;
										}
									}
									row.gc_tools = '<a href="#" onclick="'+openFunction+'(\''+link+'\', ' + openFuncOptionsStr + ')"><img src="'+OpenLayers.ImgPath+'application_view.png" border="0"></a>';
								}
							}
							$('#searchResults_'+domFeatureId).jqGrid('addRowData',row.GCfid,row);
						}
					}

					$('input[name="show_tooltips_options_'+domFeatureId+'"]').click(function(event) {
						self._toggleToolTipOption($(this), domFeatureId);
					});
				});

								// Additional buttons
								if (self.options.additionalButtons) {
									$.each(self.options.additionalButtons, function(seq, button) {
										var icon = button['icon'] || 'ui-icon-info';
										$('#datalist_searchresults a[data-action="additional_buttons_' + seq + '"]').click(function(event) {
											event.preventDefault();
											var featureId = $(this).attr('data-feature_id');
											button.callback.call(self, $(this).attr('data-feature_id'), self.options.requests[featureId]);
										}).addClass('gc_ui-icon-minimized').button({ icons: { primary: icon }, text:false });
									});
								}

				$('#datalist_searchresults a[data-action="export_xls"]').click(function(event) {
					event.preventDefault();
					self.exportXls($(this).attr('data-feature_id'));
				}).addClass('gc_ui-icon-minimized').button({ icons: { primary: "ui-icon-arrowthickstop-1-s" }, text:false });
				$('#datalist_searchresults a[data-action="view_in_table"]').click(function(event) {
					event.preventDefault();
					self.viewInTable($(this).attr('data-feature_id'));
				}).addClass('gc_ui-icon-minimized').button({ icons: { primary: "ui-icon-newwin" }, text:false });

				// show the data tab
				try {
					$('#'+self.options.idTree).tabs('select', '#'+self.options.idDataList);
				} catch (e) {
					// Older version
					$('#'+self.options.idTree).tabs('option', 'active', $(self.options.idDataList + "Selector").index());
				}


				$('#datalist_searchresults a[data-action="show1ntable"]').click(function(event) {
					event.preventDefault();

					gisclient.componentObjects.detailTable.show($(this).attr('data-relation_id'), $(this).attr('data-f_key_value'));
				});

				$('#datalist_searchresults a[data-action="show-attachment"]').click(function(event) {
					event.preventDefault();

					gisclient.showAttachment($(this).attr('data-filename'));
				});

				$('#datalist_searchresults a[data-action="show-image"]').click(function(event) {
					event.preventDefault();

					gisclient.showImage($(this).attr('data-filename'));
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
			if(typeof feature.attributes === 'undefined' || typeof feature.attributes.featureId === 'undefined') return;
			var featureId = feature.attributes.featureId;
			// select the corrisponding row
			var domFeatureId = featureId.replace('.','_');
			$('#searchResults_'+domFeatureId).jqGrid('setSelection',tableRowId,false);
			// show a tooltip for the selected feature
			if(self.options.tooltips == domFeatureId) self._showPopup(feature);
		},

		_showPopup: function(feature) {
			var self = this;
			var pixel = gisclient.map.getPixelFromLonLat(feature.geometry.getBounds().getCenterLonLat());
			var x = pixel.x;
			var y = pixel.y;
			var dialogOptions = {
				position: [x+20,y+20]
			};

			var html = '<div class="tooltip">';
			//create a template of popup
			if($('#temp_tooltip').length < 1){
				$('body').append('<div id="temp_tooltip" style="display:none;width:'+self.options.tooltipWidth+';"></div>');
			}
			if(feature) {
				// add vector features to selection layer
				var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();

				var cols = self.options.cols[feature.attributes.featureId];
				$.each(cols, function(key, label) {
					if(feature.attributes[key] === null){
						feature.attributes[key] = '';
					}
					html += '<strong>'+label+'</strong>: '+feature.attributes[key]+'<br />';
				});
				html += '<hr>';
			} else {
				html += OpenLayers.i18n('No results');
			}

			html += '</div>';
			$('#temp_tooltip').html(html);
			var h = ($('#temp_tooltip').height())+10;
			var dialogs = $('.tooltipDialog');
			if(dialogs.length === 0){
				$('<div class="tooltipDialog"></div>').html($('#temp_tooltip').html()).dialog(dialogOptions);
			} else {
				for (var i = 1; i < dialogs.length; i++) {
					$(dialogs[i]).dialog('destroy').remove();
				}
				$(dialogs[0]).html($('#temp_tooltip').html()).dialog(dialogOptions);
			}

		},

		_hidePopup: function(feature) {
			if(feature.popup != null) feature.popup.destroy();
		},

		_unhighlightTableRow: function(event) {
			var self = this;
			var feature = event.feature;
			if(typeof feature.attributes === 'undefined' || typeof feature.attributes.featureId === 'undefined') return;
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
			var checked = checkbox.prop('checked');

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
			if (self.internalVars.lastActiveTab) {
				$('#'+self.options.idTree).tabs('option', 'active', $('li[aria-controls=' + self.internalVars.lastActiveTab + ']').index());
				self.internalVars.lastActiveTab = null;
			} else {
				$('#'+self.options.idTree).tabs('option', 'active', 0);
			}
		}


	};
})( jQuery );
