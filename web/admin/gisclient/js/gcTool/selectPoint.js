/*
 */


(function($, undefined) {


    $.widget("gcTool.selectPoint", $.ui.gcTool, {

        widgetEventPrefix: "selectPoint",

        options: {
            label: OpenLayers.i18n('Select point'),
            icons: {
                primary: 'select_point' // TODO: choose better name
            },
            text: false,
            snapOptionsId: null
        },

        _create: function() {
            var self = this;

            $.ui.gcTool.prototype._create.apply(self, arguments);
			
            var vectorLayer = gisclient.componentObjects.gcLayersManager.getEditingLayer();
            self.options.control = new OpenLayers.Control.DrawFeature(vectorLayer, OpenLayers.Handler.Point);
            self.options.control.events.register("featureadded", this, self._handleFeature);
            gisclient.map.addControl(self.options.control);
        },
		
        _click: function(event) {
            var self = event.data.self;
			
            $.ui.gcTool.prototype._click.apply(self, arguments);
			
            if(self.options.snapOptionsId != null && typeof(gisclient.componentObjects.snapPoint) != 'undefined') {
                $('#'+self.options.snapOptionsId).snapPoint({
                    gisclient:gisclient
                });
                gisclient.componentObjects.snapPoint.showSnapOptions();
            }
        },
		
        _handleFeature: function(event) {
            var self = this;
            var uiHash = self._getUIHash();
            uiHash.point = event.feature.geometry;

            // remove previous point
            var vectorLayer = gisclient.componentObjects.gcLayersManager.getEditingLayer();
            if (vectorLayer.features.length > 1)
                vectorLayer.removeFeatures(vectorLayer.features[0]);
            vectorLayer.redraw(); // IE does not auto-refresh of the layer
     
            $('#'+gisclient.divs.mapDialogId).dialog('close');
            
            // call event change
            self._trigger( "handleFeature", event, uiHash);
        }
    });

    $.extend($.gcTool.selectPoint, {
        version: "3.0.0"
    });
})(jQuery);