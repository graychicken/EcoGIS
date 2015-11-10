
(function($, undefined) {

    $.widget('r3.r3help', $.r3.r3core, {
        
        options: {
            template: null,
            id: null,
            initialHelpText: 'waiting',
            data: {}
        },
        
        _create: function() {
            var self = this,
            element = self.element[0];
            
            $(element).addClass('help');
            
            $(element).click([self], self._click);
        },
        
        _click: function(ui) {
            var self = ui.data[0];
            
            self._trigger('beforeClick');
            
            // TODO: call parent showloading if exists
            //$('#help_container_loader').show();
            $('#help_container').fadeIn(500);
            $.getJSON('help/' + self.options.template + '/' + self.options.id, self.options.data, function(response) {
                self._showHelp(self, response);
            });
        },
        
        _showHelp: function(ui, response) {
            if (typeof response.exception == 'string') {
                // TODO: call parent exception handling method
                alert(response.exception);
            } else {    
                // TODO: call parent hideloading if exists
                if (typeof response.data == 'undefined' || response.data == '') {
                    ui._hideHelp(ui);
                } else {
                    $('#help_container_close').click([ui], ui._hideHelp);
                    $('#help_container_title').toggle(response.data.title != '');
                    $('#help_container_title').html(response.data.title);
                    $('#help_container_body').html(response.data.body);
                }
            }    
        },
        
        _hideHelp: function(ui) {
            $('#help_container').fadeOut(500, function() {$('#help_container_body').html('waiting')}); // TODO: use ui.options.initialHelpText
        }
    });

    $.extend($.r3.r3help, {
        version: "1.0.0"
    });
    
})(jQuery);