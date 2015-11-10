/*
 */


(function($, undefined) {


    $.widget("gcTool.toStreetView", $.ui.gcTool, {

        widgetEventPrefix: "toStreetView",

        options: {
            label: OpenLayers.i18n('Go to Street View'), // TODO: use as default value OpenLayers.i18n...
            icons: {
                primary: 'toStreetView'
            },
            correctionParameters: {
                x:0, 
                y:0
            },
            text: false
        },

        internalVars: {
            points: []
        },

        _create: function() {
            var self = this;
			
            var html = '<div id="tostreetview_settings" style="display:none;">';
            html += '<div class="instructions instructions ui-state-highlight ui-cornel-all" style="padding:2px;"><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span>'+OpenLayers.i18n('Click on the desired point, then double-click on a second point to direct the Street View camera. After the double-click, a StreetView popup will be opened')+'<br>'+OpenLayers.i18n('If there\'s no data on the selected position, the StreetView map will be centered elsewhere')+'</div>';
            html += '</div>';
			
            $('body').append(html);
			
            var dialogOptions = $.extend(gisclient.options.dialogDefaultPosition, {
                draggable:true,
                title:OpenLayers.i18n('StreetView'),
                autoOpen:false
            });
            $('#tostreetview_settings').dialog(dialogOptions);
			
            $.ui.gcTool.prototype._create.apply(self, arguments);
        },
		
        _handleFeature: function(event) {
            var self = this;
			
            var points = [];
            points.push(event.feature.geometry.components[0]);
            points.push(event.feature.geometry.components[1]);
            self._openStreetViewWindow(points);
            gisclient.componentObjects.gcLayersManager.getEditingLayer().removeAllFeatures();
        },
		
        _openStreetViewWindow: function(points) {
            var self = this;
			
            var p1 = points[0];
            var p2 = points[1];
            var p3 = new OpenLayers.Geometry.Point(points[0].x, points[1].y);
			
            var ab = p2.distanceTo(p3);
            var ac = p1.distanceTo(p3);
            var bc = p1.distanceTo(p2);
			
            var cos = (Math.pow(ac, 2) + Math.pow(bc, 2) - Math.pow(ab, 2)) / (2 * ac * bc);
            var degrees = (Math.acos(cos)/Math.PI)*180;

            var quadrant = self._getQuadrant(p1, p2);
            if(quadrant == 2) {
                degrees = 180 - degrees;
            } else if(quadrant == 3) {
                degrees = 180 + degrees;
            } else if(quadrant == 4) {
                degrees = 360 - degrees;
            }
            
            var p1_srid = new OpenLayers.Projection(gisclient.getProjection());
            if(self.options.correctionParameters.x != 0 || self.options.correctionParameters.y != 0) {
                p1.x += self.options.correctionParameters.x;
                p1.y += self.options.correctionParameters.y;
                if (self.options.correctionParameters.srid)
                    p1_srid = new OpenLayers.Projection(self.options.correctionParameters.srid);
            }
            
            var p1_4326 = p1.transform(p1_srid, new OpenLayers.Projection('EPSG:4326'));
            var url = 'http://maps.google.it/maps?cbll='+p1_4326.y+','+p1_4326.x+'&cbp=12,'+Math.round(degrees)+',,0,10&layer=c&z=15';
			
            var winw = Math.min(window.screen.availWidth, 1200);
            var winh = Math.min(window.screen.availHeight - 80, 800);
            var mapw = Math.min(window.screen.availWidth, 1200);
            var maph = Math.min(window.screen.availHeight, 800);
            l = Math.max(0, ((window.screen.availWidth - mapw) * .5));
            t = Math.max(0, ((window.screen.availHeight - maph) * .5));

            // Open map
            var hWin = window.open(url,'StreetViewWindow', 'width='+mapw+',height='+maph+',scrollbars=yes,toolbar=no,resizable=yes,menubar=no,status=yes,top='+t+',left='+l);
            if (hWin == null) alert(OpenLayers.i18n('Error opening StreetView window'));  //Mettere un altro testo
            else hWin.focus();
			
        },
		
        _getQuadrant: function(p1, p2) {
            if(p2.x > p1.x) {
                if(p2.y > p1.y) return 1;
                else return 2;
            } else {
                if(p2.y < p1.y) return 3;
                else return 4;
            }
        },
		
        _click: function(event) {
            var self = event.data.self;
			
            var editingLayer = gisclient.componentObjects.gcLayersManager.getEditingLayer();
            self.options.control = new OpenLayers.Control.DrawFeature(editingLayer, OpenLayers.Handler.Path);
            self.options.control.handler.callbacks.point = function() {
                var editingLayer = gisclient.componentObjects.gcLayersManager.getEditingLayer();
                if(editingLayer.features.length > 0) editingLayer.removeAllFeatures();
            }
            self.options.control.events.register("featureadded", self, self._handleFeature);
            gisclient.map.addControl(self.options.control);
			
            $('#tostreetview_settings').dialog('open')
			
            $.ui.gcTool.prototype._click.apply(self, arguments);
        },
		
        _deactivate: function() {
            var self = this;
            if($('#tostreetview_settings').dialog('isOpen')) $('#tostreetview_settings').dialog('close');
			var editingLayer = gisclient.componentObjects.gcLayersManager.getEditingLayer();
			editingLayer.removeAllFeatures();
        }
		
    });

    $.extend($.gcTool.toStreetView, {
        version: "3.0.0"
    });
})(jQuery);