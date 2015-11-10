
(function($, undefined) {

    $.widget('r3.r3previewmap', $.r3.r3core, {
        
        options: {
            range: 50,
            feature_type: null,
            obj_t: null,
            obj_key: null,
            obj_id: null,
            highlight: false,
            force_contains_object: false,
            windowMode: false,
            rangeSize: [25, 50, 100],
            width: 200,
            height: 200,
            buffer: null,
            hash: null
        },
        
        _create: function() {
            var self = this,
            element = self.element[0];
            
            self._showLoading();
           
            //create buttonset
            if (!self.options.force_contains_object && self.options.rangeSize){
                
                $(element).after();
                buttons = "<div id='mappreview-ranges'>";
                $.each(self.options.rangeSize, function(attrIndex, attrName) {
                    
                    buttons += "<input type='radio' id='mappreview-range-"+attrName+"' name='mappreview-range' value='"+attrName+"'  /><label for='mappreview-range-"+attrName+"'>"+attrName+"x"+attrName+"m</label>";
                });
                buttons += "</div>";
                $(element).after(buttons);
                
                $("input[type=radio]#mappreview-range-"+self.options.range).attr('checked', true);
                
                $("#mappreview-ranges").buttonset();
                $("input[type=radio][name=mappreview-range]").bind('click', function() {
                    self.setRange($(this).val());
                });
            }
            
            $(element).click([self], self._click);
            self._refreshMap();
            
        },
        
        _click: function(ui) {
            var self = ui.data[0];
            
            $.fn.zoomToMap({
                obj_t: self.options.obj_t,
                obj_key: self.options.obj_key,
                obj_id: self.options.obj_id,
                highlight: self.options.highlight,
                windowMode: self.options.windowMode,
                featureType: self.options.feature_type
            });
        },
        
        _showLoading: function() {
            var self = this,
            element = self.element[0];
            
            var imgLoading = new Image();
            imgLoading.src = '../images/loading.gif';
            
            $(element).attr('src', imgLoading.src);
        },
        
        _refreshMap: function() {
            var self = this,
            element = self.element[0];
                
            var imgLoading = new Image();
            var src = 'files/previewmap/'+self.options.obj_t+'/'+self.options.obj_key+'/'+self.options.obj_id+'/'+self.options.width+'x'+self.options.height+'-'+self.options.range+'x'+self.options.range+'.png';
            
            if (self.options.force_contains_object) {
                var urlSeparator = src.indexOf('?') < 0 ? '?' : '&';
                src += urlSeparator + 'force_contains_object';
            }
            
            if(self.options.buffer){
                var urlSeparator = src.indexOf('?') < 0 ? '?' : '&';
                src += urlSeparator + 'buffer='+self.options.buffer;
            }
            
            if(self.options.hash){
                var urlSeparator = src.indexOf('?') < 0 ? '?' : '&';
                src += urlSeparator + 'hash='+self.options.hash;
            }

            imgLoading.src = src;
            $(element).attr('src', imgLoading.src); // TODO: add eventually time
            
        },
        
        setRange: function(range) {
            var self = this;
            self.options.range = range;
            
            self._showLoading();
            self._refreshMap();
        },
        
        
        setHash: function(hash) {
            var self = this;
            self.options.hash = hash;

            self._showLoading();
            self._refreshMap();
        },
        
        getHash: function() {
            var self = this;
            return self.options.hash;
        }
        
    });

    $.extend($.r3.r3previewmap, {
        version: "1.0.0"
    });
    
})(jQuery);