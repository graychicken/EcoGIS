(function($, undefined) {
    $.widget("gcComponent.contextHandler", $.ui.gcComponent, {

        widgetEventPrefix: "contextHandler",
        
        options: {
            mapContextServiceUrl: null,
            saveOnZoomEnd: false
        },
        
        internalVars: {
            timer: null
        },

        _create: function() {
            var self = this;
            
            $.ui.gcComponent.prototype._create.apply(self, arguments);
            
            if (!self.options.mapContextServiceUrl) {
                self.options.mapContextServiceUrl = gisclient.getMapOptions().mapContextServiceUrl;
            }
            
            if(self.options.saveOnZoomEnd) {
                //gisclient.map.baseLayer.events.register('loadend', self, self._zoomEnd);
                gisclient.map.events.register('moveend', self, self._loadEnd);
            }
        },

        getContextUrl: function(contextId) {
            var self = this;
            
            return gisclient.mapUrl+gisclient.getQueryStringSeparator(gisclient.mapUrl)+'context='+contextId;
        },
        
        createContext: function() {
            var self = this;
            
            var context = {
                bounds: gisclient.map.getExtent().toArray(),
                themesOrder: gisclient.componentObjects.gcLayersManager.getThemesOrder(),
                layers: {}
            };
            $.each(gisclient.map.layers, function(e, layer) {
                if(typeof(layer.gc_id) == 'undefined') return;
                context.layers[layer.gc_id] = {
                    opacity: layer.opacity,
                    visibility: layer.getVisibility()
                };
                if(typeof(layer.params.REDLINEID) != 'undefined') {
                    context.layers[layer.gc_id].redlineId = layer.params.REDLINEID;
                }
            });
            return context;
        },

        list: function(params) {
            var self = this;

            var defaultParams = {
                action:'list',
                success: function() {},
                error: function() {
                    alert('Error load list');
                },
                mapset: gisclient.getMapOptions().mapsetName
            };

            params = $.extend(defaultParams, params);
            var requestParams = {success:null, error:null};
            requestParams = $.extend({}, params, requestParams);

            $.ajax({
                type: 'GET',
                url: self.options.mapContextServiceUrl,
                dataType: 'json',
                data: requestParams,
                success: function(response) {
                    if(typeof(response) != 'object' || response == null || typeof(response.result) == 'undefined' || response.result != 'ok') {
                        params.error();
                    }
                    params.success(response);
                },
                error: function() {
                    params.error();
                }
            });
        },
        
        replace: function() {
            var self = this;

            self.save({action:'replace'});
        },
        
        save: function(params) {
            var self = this;
            
            var defaultParams = {
                context: self.createContext(),
                title: null,
                success: function() {},
                error: function() {},
                action: 'create',
                mapset: gisclient.getMapOptions().mapsetName
            };
            var params = $.extend(defaultParams, params);
            var requestParams = {success:null, error:null};
            requestParams = $.extend({}, params, requestParams);
            
            $.ajax({
                type: 'POST',
                url: self.options.mapContextServiceUrl,
                dataType: 'json',
                data: requestParams,
                success: function(response) {
                    if(typeof(response) != 'object' || response == null || typeof(response.result) == 'undefined' || response.result != 'ok') {
                        params.error.call(response);
                    }
                    params.success.call(response);
                },
                error: function() {
                    params.error.call();
                }
            });
        },
        
        _loadEnd: function() {
            var self = this;
            
            if(self.internalVars.timer != null) clearTimeout(self.internalVars.timer);
            self.internalVars.timer = setTimeout('gisclient.componentObjects.contextHandler.replace();', 500);
        },
        
        getContext: function(id, byUser) {
            var self = this;

            if(typeof(byUser) == 'undefined') var byUser = false;

            var params = {action:'get'};
            if(!byUser) params.id = id;

            $.ajax({
                type: 'GET',
                url: self.options.mapContextServiceUrl,
                dataType: 'json',
                data: params,
                success: function(response) {
                    console.log(response);
                    if(typeof(response) != 'object' || response == null || typeof(response.result) != 'string' || response.result != 'ok' || typeof(response.context) != 'object') {
                        return alert('Error');
                    }
                    self.loadContext(response.context);
                },
                error: function() {
                    alert('Error');
                }
            });

        },

        loadContext: function(context) {
            var self = this;
            if(typeof(context.bounds) != 'undefined') {
                var bounds = new OpenLayers.Bounds.fromArray(context.bounds);
                gisclient.map.zoomToExtent(bounds);
            }
            if(typeof(context.layers) == 'object') {
                gisclient.componentObjects.gcLayersManager.applyLayersOptions(context.layers);
            }
            if(typeof(context.themesOrder) == 'object') {
                gisclient.componentObjects.gcLayersManager.setThemesOrder(context.themesOrder);
                gisclient.componentObjects.gcLayersManager.resetLayerIndexes(true);
            }
        }

    });

    $.extend($.gcComponent.contextHandler, {
        version: "3.0.0"
    });
})(jQuery);

