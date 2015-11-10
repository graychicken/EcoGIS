
(function($, undefined) {

    $.widget('r3.r3print', $.ui.dialog, {
         
        i18n: {
            it: {
                'Stampa': 'Stampa',
                'Stampare': 'Stampa',
                'Errore nella stampa': 'Errore nella stampa',
                'è avviata': 'è avviata',
                'Nome': 'Nome'
            },
            de: {
                'Stampa': 'Druckauftrag',
                'Stampare': 'Drucken',
                'Errore nella stampa': 'Fehler beim Drucken',
                'è avviata': 'gestartet',
                'Nome': 'Name'
            }
        },
         
        options: {
            language: 'it',
            autoOpen: false,
            buttons: {
                btnPrint: {
                    click: function() {
                        $('#frmPrint').submit();
                    },
                    text: 'Stampa'
                }
            },
            form: null,
            modal: true,
            print_title: '',
            print_templates: null,
            print_options: null
        },
        
        _i18n: function(text) {
            var self = this;
            try {
                return self.i18n[self.options.language][text];
            } catch(e) {
                return text;
            }
        },
        
        _create: function() {
            var self = this,
            element = self.element[0];
            
            // change text from button
            self.options.buttons.btnPrint.text = self._i18n('Stampare');
            
            if (self.options.title == '') {
                self.options.title = self._i18n('Stampa') + ' - ' + $(document).find('h3').html();
            }
            if (self.options.print_title == '') {
                self.options.print_title = $(document).find('h3').html();
            }
            
            $.ui.dialog.prototype._create.apply(self, arguments);
            
            var form = $(element).append('<form id="frmPrint" method="post" action="print.php"></form>').find('form');
            $(form).ajaxForm({
                dataType: 'json',
                success: function(response) {
                    if (response.status != 0) {
                        alert('Errore nella stampa');
                        return false;
                    }

                    alert(self._i18n('Stampa') + ' ' + response.select.print_id + ' ' + self._i18n('è avviata'));
                    self.close();
                }
            });
            
            $(form).append('<div>' +
                           '    <span>'+self._i18n('Nome')+':</span>' +
                           '    <input type="text" id="print_title" name="print_title" value="'+self.options.print_title+'" class="print_title">' +
                           '</div>');
            
            // append page settings
            $.each($(document).getPageSettings(), function(i, value) {
                var param = value.split('=');
                $(form).append('<input type="hidden" name="'+param[0]+'" value="'+param[1]+'">');
            });
            
            // append filter settings
            $.each($('#filterform').ignorePageSettings(), function(i, value) {
                var param = value.split('=');
                $(form).append('<input type="hidden" name="'+param[0]+'" value="'+param[1]+'">');
            });
            
            self.options.form = form;
            
            // add section for filter summary
            self.options.filterSummary = $(form).append('<div id="print_filter_summary"></div>').find('#print_filter_summary');
            
            // add section for print types
            self.options.print_templates = $(form).append('<ul id="print_templates"></ul>').find('#print_templates');
            
            $(self.options.print_templates).delegate('li', 'click', function() {
                $(self.options.print_templates).find('li').removeClass('selected');
                $(self.options.print_templates).find('input:radio:checked').parent().addClass('selected');
            });
        },
        
        open: function() {
            var self = this,
            form = self.options.form;
            
            $.ui.dialog.prototype.open.apply(self, arguments);
            
            // update filter settings
            var filterSummary = self.options.filterSummary;
            $(form).find(filterSummary).children().remove();
            
            
            $.each($('#filterform').ignorePageSettings(), function(i, value) {
                var param = value.split('=');
                $(form).find('input[name="'+param[0]+'"][value="'+param[1]+'"]').val(param[1]);
                
                // update filter summary
                if (param[1] != '') {
                    var filterField = $('#filterform').find('[name="'+param[0]+'"]');
                    if ($(filterField).length > 1) {
                        filterField = $('#filterform').find('[name="'+param[0]+'"][value="'+param[1]+'"]');
                    }
                    
                    switch($(filterField)[0].tagName.toUpperCase()) {
                        case 'INPUT':
                            switch($(filterField).attr('type').toUpperCase()) {
                                case 'HIDDEN':
                                    break;
                                case 'CHECKBOX':
                                    var label = $(filterField).next().html();
                                    var text_value = 'no';
                                    if ($(filterField).prop('checked'))
                                        text_value = 'si';
                                    $(filterSummary).append('<div><span>'+label+':</span> '+text_value);
                                    break;
                                default:
                                    var label = $(filterField).prevAll("span").html();
                                    $(filterSummary).append('<div><span>'+label+':</span> '+param[1]);
                            }
                            break;
                        case 'SELECT':
                            var label = $(filterField).prev().html();
                            var text_value = $(filterField).find('option[value="'+param[1]+'"]').html();
                            $(filterSummary).append('<div><span>'+label+':</span> '+text_value);
                            break;
                    }
                }
            });
        },
        
        addTemplate: function(title, template) {
            var self = this,
            print_templates = self.options.print_templates;
            
            var radioId = "print_template_" + $(print_templates).find('input[type="radio"]').length;
            
            $(print_templates).append('<li><input type="radio" id="'+radioId+'" name="print_template" value="'+template+'">' +
                                     '<label for="'+radioId+'">'+title+'</li></label>');
            
            if ($(print_templates).find('input:radio').length == 1) {
                $(print_templates).find('input:radio').click();
                $(print_templates).find('input:radio').parent().click();
            }
        },
        
        addOption: function(name, type, data) {
            var self = this,
            print_templates = self.options.print_templates;
            
            if (self.options.print_options == null) {
                $(print_templates).after('<div id="print_options" class="ui-dialog-buttonpane ui-widget-content ui-helper-clearfix"></div>');
                self.options.print_options = $('#print_options');
            }
            
            var print_options = self.options.print_options;
            
            switch(type) {
                case 'checkbox':
                    $(print_options).append('<input type="checkbox" id="'+name+'" name="'+name+'" value="t" class="print_option">');
                    if (data.label) {
                        $(print_options).find('input[name='+name+']').after('<label for="'+name+'">'+data.label+'</label>');
                    }
                    break;
            }
        }
    });
    /*
    <div id="print_options" class="ui-dialog-buttonpane ui-widget-content ui-helper-clearfix"></div>
    */

    $.extend($.r3.r3print, {
        version: "1.0.0"
    });
    
})(jQuery);