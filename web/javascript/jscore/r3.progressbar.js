(function($, undefined) {

    $.widget('r3.r3progressbar', $.ui.progressbar, {
        
        options: {
            cancelText: 'Cancel'
        },
        
        _create: function() {
            var self = this;
            
            $.ui.progressbar.prototype._create.apply(self, arguments);
            
            this.cancelButton = $( "<span>"+self.options.cancelText+"</span>" )
			.prependTo( self.element )
                        .button({
                            icons: { primary: 'ui-icon-cancel' },
                            text: false
                        })
                        .css('float', 'right')
                        .click(function(event, ui) {
                            // call event change
                            self._trigger( "cancel", event, ui );
                        });
            
            this.element.css('height', 22);
        }
        
    });
    
    $.extend($.r3.r3progressbar, {
        version: "1.0.0"
    });
    
})(jQuery);