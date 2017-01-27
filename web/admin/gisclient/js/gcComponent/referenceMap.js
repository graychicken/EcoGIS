(function($, undefined) {
    
    $.widget("gcComponent.referenceMap", $.ui.gcComponent, {

        widgetEventPrefix: "referenceMap",

        options: {
            layers: [],
            gisclient: null,
            mapOptions: null, // mapOptions from the main map
            maxRatio: 32,
            minRatio: 8
        },

        _create: function() {
            var self = this;

            $.ui.gcComponent.prototype._create.apply(self, arguments);
			
            var html = '<div id="referenceMap" style="width:250px;height:150px;position:relative;border:1px solid black; display:block; background-image: url(about:blank)">'
            + '<div id="referenceMap_rect" style="width:250px;height:150px;border:1px solid red;position:absolute;top:0px;left:0px;z-index:1050;cursor:move"></div>'
            + '<div id="referenceMap_vAxis" style="width:250px;height:150px;border:1px solid #a0a0a0;background-color: #505050; opacity: 0.3; position:absolute;top:0px;left:0px;z-index:1049;display:none"></div>'
            + '<div id="referenceMap_hAxis" style="width:250px;height:150px;border:1px solid #a0a0a0;background-color: #505050; opacity: 0.3; position:absolute;top:0px;left:0px;z-index:1049;display:none"></div></div>'
            + OpenLayers.i18n('Zoom to')+': <a href="#" rel="zoomToMapViewport">'+OpenLayers.i18n('map viewport')+'</a> | <a href="#" rel="zoomToMaxExtent">'+OpenLayers.i18n('max extent')+'</a>';
			
            $(self.element).html(html);
            $(self.element).find('a[rel="zoomToMapViewport"]').click(function(event) {
                event.preventDefault();
                self.zoomToMapViewport(event);
            });
            $(self.element).find('a[rel="zoomToMaxExtent"]').click(function(event) {
                event.preventDefault();
                self.zoomToMaxExtent(event);
            });
			
			
            // delete useless options
            var mapOptions = $.extend(true, {}, self.options.mapOptions);
            mapOptions.controls = [];
            mapOptions.eventListeners = null;
            mapOptions.fractionalZoom = true;
            mapOptions.size = new OpenLayers.Size(mapOptions.size);
            mapOptions.projection = new OpenLayers.Projection(mapOptions.projection);
            mapOptions.maxExtent = new OpenLayers.Bounds.fromArray(mapOptions.maxExtent);
			
			// force the reference map to use higher resolutions, because of the smaller viewport
            var refMaxResolution = mapOptions.resolutions[0]*6;
			var refNumZoomLevels = mapOptions.resolutions.length+3;
			
            // create the reference map
            gisclient.referenceMap = new OpenLayers.Map(document.getElementById('referenceMap'), mapOptions);
            var baseLayer = new OpenLayers.Layer.Image('BASE_LAYER', gisclient.options.mapsetURL +'images/pixel.png', gisclient.map.maxExtent, new OpenLayers.Size(1,1), {
                isBaseLayer: true,
				maxResolution: refMaxResolution,
				numZoomLevels: refNumZoomLevels,
                displayInLayerSwitcher: false
            });
			var refLayers = [baseLayer];
			$.each(self.options.layers, function(e, layer) {
				layer.options.maxResolution = refMaxResolution;
				layer.options.numZoomLevels = refNumZoomLevels;
				refLayers.push(layer);
			});
            gisclient.referenceMap.addLayers(refLayers);
            gisclient.referenceMap.zoomToExtent(gisclient.map.getExtent());
			
            gisclient.map.events.register('moveend',self,self.updateRefRect); //update the rectangle on main map moveend

            // init the drag control for the rectangle
            $('#referenceMap_rect').draggable({
                containment: 'parent'
            });
            $('#referenceMap_rect').bind('dragstop',{
                self:self
            },self.updateMapViewport);
			
            // update the rectangle
            self.updateRefRect();
        },
		
        updateRefRect: function() { // update the rectangle
            var self = this;
            var bounds = gisclient.map.getExtent(); // get the extent of the main map
            var refSize = gisclient.referenceMap.getCurrentSize(); // get the size of the ref map
            // get the left-bottom and right-top pixel of the refmap, given the main map bounds
            var lb = gisclient.referenceMap.getViewPortPxFromLonLat(new OpenLayers.LonLat(bounds.left, bounds.bottom));
            var rt = gisclient.referenceMap.getViewPortPxFromLonLat(new OpenLayers.LonLat(bounds.right, bounds.top));
            // check if pixels found above are contained in the ref map
            var left = (lb.x>0) ? lb.x : 0;
            var top = (rt.y>0) ? rt.y : 0;
            var width = ((rt.x-lb.x)<refSize.w) ? (rt.x-lb.x) : refSize.w;
            var height = ((lb.y-rt.y)<refSize.h) ? (lb.y-rt.y) : refSize.h;
            var displayAxis = (width < 0.05 * refSize.w || height < 0.05 * refSize.h) ? 'inline' : 'none'; 
            if((left+width)>refSize.w) width = refSize.w-left;
            if((top+height)>refSize.h) height = refSize.h-top;
            
            $('#referenceMap_rect').css({
                'left':left,
                'top':top,
                'width':width,
                'height':height
            });
            $('#referenceMap_vAxis').css({
                'left':left,
                'width':width,
                'display':displayAxis
            });
            $('#referenceMap_hAxis').css({
                'top':top,
                'height':height,
                'display':displayAxis
            });
        },
		
        updateMapViewport: function(event) { // on rectangle drag, update the main map viewport
            var self = event.data.self;
            // get the rectangle position
            var pos = $(this).position();
            // get the left-boom and right-top LonLat, given the rectangle position
            //var lb = gisclient.referenceMap.getLonLatFromPixel(new OpenLayers.Pixel(pos.left, (pos.top+$(this).height())));
            //var rt = gisclient.referenceMap.getLonLatFromPixel(new OpenLayers.Pixel((pos.left+$(this).width()), pos.top));
            
            var center = new OpenLayers.Pixel((pos.left+$(this).width()/2), (pos.top+$(this).height()/2));
            var centerLonLat = gisclient.referenceMap.getLonLatFromPixel(center);
            
            // update the map viewport with the bounds calculated above
            gisclient.map.setCenter(centerLonLat);
        },
		
        zoomToMapViewport: function() { // update the refmap viewport
            var self = this;
            var bounds = gisclient.map.getExtent(); 
            gisclient.referenceMap.zoomToExtent(bounds);
            self.updateRefRect();
            return false;
        },
		
        zoomToMaxExtent: function() { // back to refmap max extent
            var self = this;
            gisclient.referenceMap.zoomToMaxExtent();
            self.updateRefRect();
            return false;
        }
			
    });

    $.extend($.gcComponent.referenceMap, {
        version: "3.0.0"
    });
})(jQuery);