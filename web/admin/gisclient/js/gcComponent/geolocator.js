(function($){

    $.widget("gcComponent.geolocator", $.ui.gcComponent, {
		
		options: {
			widgetElementPrefix: 'geolocator',
			geolocatorServiceUrl: null
		},
		
		internalVars: {
			selectedLayer: null,
			selectedOpacity: null
		},
		
        _create: function(){
            var self = this;
			
            $('#geolocator').autocomplete({
                minLength: 2,
                source: self.autocompleteSource,
                select: self.handleSelect
            });
			
			if(self.options.geolocatorServiceUrl == null) self.options.geolocatorServiceUrl = gisclient.getMapOptions().geolocatorServiceUrl;
			
            $.ui.gcComponent.prototype._create.apply(self, arguments);
			
        },
        
        autocompleteSource: function(request, response) {
            var self = this;
            
            var params = {
                key: request.term,
                mapset: gisclient.getMapOptions().mapsetName,
                action: 'search',
                lang: gisclient.getLanguage()
            };
            
            $.ajax({
                type: 'GET',
                url: gisclient.getMapOptions().geolocatorServiceUrl,
                data: params,
                dataType: 'json',
                success: function(getdata) {
                    if(typeof(getdata) != 'object' || typeof(getdata.result) == 'undefined' || getdata.result != 'ok') {
                        response([]);
                        return;
                    }
                    var data = [];
                    
                    var returnData = [];
                    $.each(getdata.data, function(e, row) {
                        returnData.push({
                            label: row.name,
                            value: row.id
                        });
                    });

                    response(returnData);
                },
                error: function() {
                }
            });
        },
        
        handleSelect: function(event, ui) {
            var self = this;
            
            event.preventDefault();
            $('#geolocator').val(ui.item.label);
            
            var params = {
                id: ui.item.value,
                mapset: gisclient.getMapOptions().mapsetName,
                action: 'get-geom',
                lang: gisclient.getLanguage()
            };
            
            $.ajax({
                type: 'GET',
                url: gisclient.getMapOptions().geolocatorServiceUrl,
                data: params,
                dataType: 'json',
                success: function(getdata) {
                    try {
                        var geom = OpenLayers.Geometry.fromWKT(getdata.data);
                        gisclient.zoomOn(geom.getBounds());
                    } catch(e) {
                    }
                },
                error: function() {
                }
            });
        }
		
    });

    $.extend($.gcComponent.geolocator, {
        version: "3.0.0"
    });
})(jQuery);
