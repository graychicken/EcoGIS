(function($, undefined) {
    $.widget("gcTool.unselectFeatures", $.ui.gcTool, {

        widgetEventPrefix: "unselectFeatures",

        options: {
            label: OpenLayers.i18n('Unselect features'),
            icons: {
                primary: 'unselect_features'
            },
            text: false,
            selectionLayer: null
        },
        
        _create: function() {
            var self = this;
            $.extend(this, $.searchEngine);
            
            $.ui.gcTool.prototype._create.apply(self, arguments);
            self.options.selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
            self.options.selectionLayer.events.register('featuresadded', self, self._checkSelectionLayerStatus);
            self.options.selectionLayer.events.register('featuresremoved', self, self._checkSelectionLayerStatus);
            self._checkSelectionLayerStatus();
        },
        
        _click: function(event) {
            var self = event.data.self;
            
            $.ui.gcTool.prototype._click.apply(self, arguments);

            self.unSelectAll();
        },

        _checkSelectionLayerStatus: function () {
            var self = this;

            if (self.options.selectionLayer.features.length > 0) {
                self._enableButton();
            } else {
                self._disableButton();
            }
        },

        _enableButton: function() {
            $('#unselect_features').button('option', 'disabled', false);
        },

        _disableButton: function() {
            $('#unselect_features').button('option', 'disabled', true);
        }
        
    });

    $.extend($.gcTool.selectFeatures, {
        version: "3.0.0"
    });
})(jQuery);
