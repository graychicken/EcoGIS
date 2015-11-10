/*
 */


(function($, undefined) {


	$.widget("gcTool.easySelectFromMap", $.ui.gcTool, {

		widgetEventPrefix: "easySelectFromMap",

		options: {
			label: OpenLayers.i18n('Info'),
			icons: {
				primary: 'info' // TODO: choose better name
			},
			text: false,
			idDataList: null,
			idDialog: null, // dialog container id
			hoverControl: null,
			controls: [], // array of the control handlers
			control: null,
			limitVectorFeatures: 100, // if the selected features are more of this limit, the user must to confirm the selection
			tooltips: true,
			tooltipWidth: 200,
			cols: {},
			actionSelectionParent: 'after_selection_action', // the parent of the after selection action radio button
			requests: {}, // object to store the requests, because we need to check if all the requests are returned
			pointSelectionDefaultTolerance: 10, // the default tolerance for the point selection
			displayFeatures: true
		},

		_create: function() {
			var self = this;
			
			$.extend(this, $.searchEngine);

			$.ui.gcTool.prototype._create.apply(self, arguments);
			
			// create the custom control to handle the selection
			self.options.control = new OpenLayers.Control({autoActivate:false});
			OpenLayers.Util.extend(self.options.control, {
				draw: function () {
					this.box = new OpenLayers.Handler.Box(self.options.control,
						{"done": self._handleSelection},
						{boxDivClassName: 'ui-state-highlight ui-priority-secondary'}
					);
				},
				CLASS_NAME: 'OpenLayers.Control.selectByBox'
			});
			
			gisclient.map.addControl(self.options.control);
			
			// create a control to hilight table rows when hovering features
			var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
			var options = {
				hover: true,
				callbacks: {
					click: self._handleFeatureClick
				}
			};
			self.options.hoverControl = new OpenLayers.Control.SelectFeature(selectionLayer, options);
			self.options.hoverControl.events.register('featurehighlighted', self, self._highlightTableRow);
			self.options.hoverControl.events.register('featureunhighlighted', self, self._unhighlightTableRow);
			gisclient.map.addControl(self.options.hoverControl);			
		},
		
		_click: function(event) {
			var self = event.data.self;
			
			$.ui.gcTool.prototype._click.apply(self, arguments);
			
			// toggle the control (handler)
			self.options.control.box.activate();
			
			// check if hoverControl is active and eventually active it
			if(!self.options.hoverControl.active) self.options.hoverControl.activate();
		},
		
		_handleSelection: function(geom) {
			var self = gisclient.toolObjects.easySelectFromMap;

			gisclient.componentObjects.loadingHandler.show();
			
			// check the geometry drown by the user and assign a filter type and value
			var value, type;
      			if(geom.CLASS_NAME == 'OpenLayers.Bounds') {
				type = OpenLayers.Filter.Spatial.BBOX;
				var lb = gisclient.map.getLonLatFromPixel(new OpenLayers.Pixel(geom.left, geom.bottom)); 
				var rt = gisclient.map.getLonLatFromPixel(new OpenLayers.Pixel(geom.right, geom.top));
				value = new OpenLayers.Bounds(lb.lon, lb.lat, rt.lon, rt.lat);
				self.options.selectionExtent = value;
			} else if(geom.CLASS_NAME == 'OpenLayers.Pixel') {
				var lonLat = gisclient.map.getLonLatFromPixel(geom);
				var point = new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat);
				value = OpenLayers.Geometry.Polygon.createRegularPolygon(point, self.options.pointSelectionDefaultTolerance, 30, 90);
				type = OpenLayers.Filter.Spatial.INTERSECTS;
				self.options.selectionExtent = value.getBounds();
			}
			
			// create the openlayers spatial filter
			var filter = new OpenLayers.Filter.Spatial({
				type: type,
				value: value,
				projection: gisclient.getProjection(),
				property: 'the_geom'
			});

			queryLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers(true);
			
			// start the query
			self._query(queryLayers, filter);
		},
		
		_handleFeatureClick: function() {
			var self = gisclient.toolObjects.easySelectFromMap;
			
			var mpControl = gisclient.map.getControlsByClass('OpenLayers.Control.MousePosition');
			self._handleSelection(mpControl[0].lastXy);
		},
		
		_abort: function() {
			var self = this;

			gisclient.componentObjects.loadingHandler.hide();
			
			self.options.control.box.deactivate();
			self.options.control.deactivate();
		},
		
		_deactivate: function() {
			var self = this;
			
            if(typeof(gisclient.toolObjects.selectFromMap) == 'undefined') {
                self.unSelectAll();
            }
			self._abort();
		}

	});

	$.extend($.gcTool.easySelectFromMap, {
		version: "3.0.0"
	});
})(jQuery);
