/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 *
 * NOTE: for lat/lon transformation the proj4js library is required
 */


(function($, undefined) {

	// TODO: handle snap layer change/load
	$.widget("gcComponent.snapPoint", $.ui.gcComponent, {

		widgetEventPrefix: "snapPoint",

		options: {
			control: null,
			queryLayers: null,
			styleMap: null,
			tolerance: 10,
			editingLayer: null,
			limitVectorFeatures: 100
		},

		internalVars: {
			snappedPoints: {},
			selectedLayer: null,
			html: null,
			currentElement: null,
			queryLayers: null,
			snapLayer: null,
			pointSnapLayer: null
		},

		_create: function() {
			var self = this;

			if(typeof(gisclient.componentObjects.snapPoint) == 'object') {
				if(self.internalVars.currentElement != null) {
					$('#snap_select_layer').unbind();
					$(self.internalVars.currentElement).empty();
				}
				$(self.element).html(self.internalVars.html);
			} else {

				$.ui.gcComponent.prototype._create.apply(self, arguments);

				var html = '<fieldset><legend>Snap</legend><div id="editing_snap" class="noflow"><label>'+OpenLayers.i18n('Snap layer')+':</label> <select id="snap_select_layer"><option value="0">'+OpenLayers.i18n('Snap Off')+'</option>';

				if(self.options.queryLayers != null) self.internalVars.queryLayers = self.options.queryLayers;
				else self.internalVars.queryLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers();

				if(self.internalVars.queryLayers == null) return false;
				$.each(self.internalVars.queryLayers, function(featureId, layer) {
					html += '<option value="'+featureId+'">'+layer.title+'</option>';
				});
				html += '</select><div style="clear: both; padding: 10px 0 10px 0;"><input type="checkbox" name="highlight_vertices" value="yes"> '+OpenLayers.i18n('Highlight vertices')+'</div><div id="tollerance_container">'+OpenLayers.i18n('Tolerance')+': <span id="snap_tolerance_value">10</span><div id="snap_tolerance_selector" style="width:300px;margin-left:20px;"></div></div></div></fieldset>';

				$(self.element).html(html);
				self.internalVars.html = html;
			}
			self.internalVars.currentElement = self.element;

			$('#snap_tolerance_selector').slider({value: 10}).bind('slidechange', {self:self}, self._snapToleranceChange);

			$('#snap_select_layer option[value="0"]').attr('selected', 'selected');
			$('#snap_select_layer').change(function(event) {
				self._snapLayerChange($(this).val());
				$(this).blur();
			});

			$('#editing_snap input[name="highlight_vertices"]').click(function() {
				self.highlightVertexes();
			});

			if(self.options.styleMap == null) {
				self.options.styleMap = new OpenLayers.StyleMap({
					strokeColor: "red",
					strokeWidth: 2,
					pointRadius: 2,
					fillColor: 'black',
					strokeLinecap: 'square',
					fill: false
				});
			}
			self.options.pointsStyleMap = new OpenLayers.StyleMap({
				pointRadius: 2,
				fillColor: 'black'
			});

			if(self.options.editingLayer == null) {
				self.options.editingLayer = gisclient.componentObjects.gcLayersManager.getEditingLayer();
			}
		},

		_activateSnapControl: function(event) {
			var self = this;

            self.options.control = new OpenLayers.Control.Snapping({
                layer: self.options.editingLayer,
                targets: [{layer:self.internalVars.snapLayer,tolerance: self.options.tolerance}],
                greedy: false
            });

			// if the control become inactive, uncheck the checkbox
			//self.options.control.events.register('deactivate',self,self._uncheckSnapCheckbox);
			self.options.control.events.register('snap', self, self._snappedPointHandler);
			self.options.control.events.register('unsnap', self, self._unsnappedPointHandler);
			//self.options.control.events.register('activate',self,self._checkSnapCheckbox);
			gisclient.map.addControl(self.options.control);
			self.options.control.activate();
		},

		_snapToleranceChange: function(event, ui) {
			var self = event.data.self;

			if(self.options.control != null) {
				self.options.control.removeTargetLayer(self.internalVars.snapLayer);
				self.options.control.addTarget({layer:self.internalVars.snapLayer, tolerance:ui.value});
			}
			$('#snap_tolerance_value').html(ui.value);
			self.options.tolerance = ui.value;
		},

		_snapLayerChange: function(selectedLayer) {
			var self = this;

			if(selectedLayer == '0') {
				self._destroySnapLayer();
				self._destroySnapControl();
				return;
			}

			self.internalVars.selectedLayer = selectedLayer;

			if(self.options.control != null && self.options.control.active) {
				self._destroySnapControl();
			}

			self._reloadSnapLayer();
		},

		changeEditingLayer: function(layer) {
			var self = this;

			self.options.editingLayer = layer;

			if($('#snap_select_layer').val() == '0') return;

			if(self.options.control != null && self.options.control.active) {
				self._destroySnapControl();
			}

			if(self.internalVars.selectedLayer != null && self.internalVars.selectedLayer != '0') {
				self._reloadSnapLayer();
			}
		},

		destroySnap: function() {
			var self = this;

			if(self.options.control != null) self._destroySnapControl();
			if(self.internalVars.selectedLayer != null) self._destroySnapLayer();
			self._uncheckSnapCheckbox();
			gisclient.componentObjects.loadingHandler.unlock();
			gisclient.componentObjects.loadingHandler.hide();
		},

		_destroySnapControl: function() {
			var self = this;

			gisclient.map.removeControl(self.options.control);
			self.options.control.destroy();
			self.options.control = null;
		},

		_reloadSnapLayer: function() {
			var self = this;
			self._lock();

			if(self.internalVars.snapLayer != null) self._destroySnapLayer();

			var layer = self.internalVars.queryLayers[self.internalVars.selectedLayer];
			var separator = gisclient.getQueryStringSeparator(layer.layer.url);
			var url = layer.layer.url+separator+'PROJECT='+gisclient.getProject()+'&MAP='+layer.layer.parameters.map+'&gcRequestType=OLWFS';

			var wfs = new OpenLayers.Layer.Vector("GisClientSnap", {
				strategies: [new OpenLayers.Strategy.BBOX()],
				protocol: new OpenLayers.Protocol.WFS({
                                version: "1.0.0",
                                srsName: gisclient.getProjection(),
                                url:  url,
                                featureType: self.internalVars.selectedLayer,
                                featureNS: "http://mapserver.gis.umn.edu/mapserver",
                                propertyNames: ['the_geom']
				}),
				styleMap: self.options.styleMap
			});
			self.internalVars.snapLayer = wfs;
			wfs.events.register('featuresadded',self,self.snapLayerLoaded);
			gisclient.map.addLayer(wfs);

			self.internalVars.pointSnapLayer = new OpenLayers.Layer.Vector('GisClientSnapPoints', {styleMap: self.options.pointsStyleMap});
			gisclient.map.addLayer(self.internalVars.pointSnapLayer);

			var snapLayerIndex = gisclient.map.getLayerIndex(wfs);
			var editingLayer = gisclient.componentObjects.gcLayersManager.getEditingLayer();
			var editingLayerIndex = gisclient.map.getLayerIndex(editingLayer);
			if(snapLayerIndex >= editingLayerIndex) gisclient.map.raiseLayer(editingLayer, (snapLayerIndex-editingLayerIndex)+1);

			var strategy = wfs.strategies[0];
			strategy.calculateBounds(gisclient.map.getExtent());
			var bounds = strategy.bounds;

			filter = new OpenLayers.Filter.Comparison({
				type: OpenLayers.Filter.Spatial.BBOX,
				property: self.internalVars.selectedLayer,
				value: bounds
			});

			var filter_1_1 = new OpenLayers.Format.Filter({version: "1.1.0"});
			var xml = new OpenLayers.Format.XML();
			var filterValue = xml.write(filter_1_1.write(filter));

			var params = {
				SERVICE: 'WFS',
				VERSION: '1.1.0', // required, because RESULTTYPE=HITS is only implemented in WFS >= 1.1.0
				REQUEST: 'GETFEATURE',
				SRS: gisclient.getProjection(),
				TYPENAME: self.internalVars.selectedLayer,
				FILTER: filterValue,
				RESULTTYPE: 'HITS'
			};

			$.ajax({
				url: url,
				type: 'GET',
				dataType: 'xml',
				data: params,
				success: function(response, status, jqXHR) {
					var count = parseInt($(response).children().attr('numberOfFeatures'));
					if(count > 0) {
						if(count > self.options.limitVectorFeatures) {
							var string = OpenLayers.i18n('Your request returned with ${count} results. The visualization of these results may take several minutes. Do you want to continue?', {count:count});
							if(!confirm(string)) {
								self.destroySnap();
								self.snapRequestAborted();
								return false;
							}
						}
						strategy.bounds = null;
						strategy.update();
						self._activateSnapControl();
					} else {
						self.destroySnap();
						self.snapRequestAborted();
					}

				},
				error: function(response, status, jqXHR) {
					var string = OpenLayers.i18n('Error counting results, the request has been aborted');
					gisclient.componentObjects.errorHandler.show(string);
					gisclient.log(jqXHR.responseText);
					return false;
				}
			});
		},

		snapLayerLoaded: function() {
			var self = this;

			self._unlock();

			self.highlightVertexes();
		},

		highlightVertexes: function() {
			var self = this;

			self.internalVars.pointSnapLayer.removeAllFeatures();

			if(!$('#editing_snap input[name="highlight_vertices"]').prop('checked')) return;

			var points = [];
			$.each(self.internalVars.snapLayer.features, function(e, feature) {
				if(feature.geometry instanceof OpenLayers.Geometry.Point) return;
				var featurePoints = feature.geometry.getVertices();
				$.each(featurePoints, function(e, point) { points.push(point); });
			});
			if(points.length == 0) return;
			var feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.MultiPoint(points));
			self.internalVars.pointSnapLayer.addFeatures([feature]);
		},

		_destroySnapLayer: function() {
			var self = this;

			if(self.internalVars.snapLayer != null) self.internalVars.snapLayer.destroy();
			if(self.internalVars.pointSnapLayer != null) self.internalVars.pointSnapLayer.destroy();
		},

		_uncheckSnapCheckbox: function(event) {
			$('#snap_select_layer option[value="0"]').attr('selected', 'selected');
		},

		_checkSnapCheckbox: function(event) {
		},

		showSnapOptions: function() {
			$('#editing_snap').show();
		},

		hideSnapOptions: function() {
			$('#editing_snap').hide();
		},

		_lock: function() {
			var self = this;

			gisclient.componentObjects.loadingHandler.lock();
		},

		_unlock: function() {
			var self = this;

			gisclient.componentObjects.loadingHandler.unlock();
		},

		snapRequestAborted: function() {
			// to be overrided to catch user aborted the snap request from other tools
		},

		_snappedPointHandler: function(object) {
			var self = this;

			var pointId = object.point.id;
			var point = {
				x: object.point.x,
				y: object.point.y,
				snapType: object.snapType,
				featureType: self.internalVars.selectedLayer
			};
			self.internalVars.snappedPoints[pointId] = point;
		},

		_unsnappedPointHandler: function(object) {
			var self = this;

			var pointId = object.point.id;
			if(typeof(self.internalVars.snappedPoints[pointId]) != 'undefined') {
				delete self.internalVars.snappedPoints[pointId];
			}
		},

		getSnappedPoints: function() {
			var self = this;

			var snappedPoints = [];
			$.each(self.internalVars.snappedPoints, function(pointId, point) {
				if(typeof(point) != 'undefined') snappedPoints.push(point);
			});
			return snappedPoints;
		}
	});

	$.extend($.gcComponent.snapPoint, {
		version: "3.0.0"
	});
})(jQuery);
