
(function($, undefined) {

    $.widget('r3.r3export', $.ui.dialog, {
         
        i18n: {
            it: {
                'Export': 'Export',
                'Esportare': 'Esportare',
                "Errore durante l'export": "Errore durante l'export",
                'avviato': 'avviato',
                'Nome': 'Nome',
                "L'export è in fase di generazione": "L'export è in fase di generazione"
            },
            de: {
                'Export': 'Export',
                'Esportare': 'Exportieren',
                "Errore durante l'export": 'Fehler während dem Export',
                'avviato': 'gestartet',
                'Nome': 'Name',
                "L'export è in fase di generazione": "Export wird erstellt"
            }
        },
         
        options: {
            language: 'it',
            autoOpen: false,
            buttons: {
                btnPrint: {
                    click: function() {
                        $('#frmExport').submit();
                    },
                    text: 'Export'
                }
            },
            form: null,
            modal: true,
            export_title: '',
            export_templates: null
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
            self.options.buttons.btnPrint.text = self._i18n('Esportare');
            
            if (self.options.title == '') {
                self.options.title = self._i18n('Stampa') + ' - ' + $(document).find('h3').html();
            }
            if (self.options.export_title == '') {
                self.options.export_title = $(document).find('h3').html();
            }
            
            $.ui.dialog.prototype._create.apply(self, arguments);
            
            var form = $(element).append('<form id="frmExport" method="post" action="export.php"></form>').find('form');
            $(form).ajaxForm({
                dataType: 'json',
                success: function(response) {
                    if (response.status != 0) {
                        alert("Errore durante l'export");
                        return false;
                    }

                    alert(self._i18n("L'export è in fase di generazione"));
                    self.close();
                }
            });
            
            $(form).append('<div>' +
                           '    <span>'+self._i18n('Nome')+':</span>' +
                           '    <input type="text" id="export_title" name="export_title" value="'+self.options.export_title+'" class="export_title">' +
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
            self.options.filterSummary = $(form).append('<div id="export_filter_summary"></div>').find('#export_filter_summary');
            
            // add section for print types
            self.options.export_templates = $(form).append('<ul id="export_templates"></ul>').find('#export_templates');
            
            $(self.options.export_templates).delegate('li', 'click', function() {
                $(self.options.export_templates).find('li').removeClass('selected');
                $(self.options.export_templates).find('input:checkbox:checked').parent().addClass('selected');
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
            export_templates = self.options.export_templates;
            
            var radioId = "export_template_" + $(export_templates).find('input[type="checkbox"]').length;
            
            $(export_templates).append('<li><input type="checkbox" id="'+radioId+'" name="export_template[]" value="'+template+'">' +
                                     '<label for="'+radioId+'">'+title+'</li></label>');
            
            if ($(export_templates).find('input:checkbox').length == 1) {
                $(export_templates).find('input:checkbox').click();
                $(export_templates).find('input:checkbox').parent().click();
            }
        }
    });

    $.extend($.r3.r3export, {
        version: "1.0.0"
    });
    
})(jQuery);