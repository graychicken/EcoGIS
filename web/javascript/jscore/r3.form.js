
(function($, undefined) {
    
    $.fn.r3formTimers = {};
    $.fn.r3formTimeout = 10000;
    
    $.fn.r3form_prepare = function (form) {
        this.r3formTimers[form] = setTimeout("$.fn.r3form_failed('"+form+"')", $.fn.r3formTimeout);
        this.r3form_freeze(form);
    };
    
    $.fn.r3form_freeze = function(form){
        // for the time being:
        // later on: diable all enabled controls and save these into a
        // variable, from which they can be thawn
        $('#'+form+' input[name=btnSave]').attr('disabled', true);
        $('#'+form+' input[name=btnCancel]').attr('disabled', true);
    };
    
    $.fn.r3form_thaw = function (form) {
        // for the time being:
        // later on: diable all enabled controls and save these into a
        // variable, from which they can be thawn
        $('#'+form+' input[name=btnSave]').attr('disabled', false);
        $('#'+form+' input[name=btnCancel]').attr('disabled', false);
    };
    
    $.fn.r3form_display_errors = function(errors, form) {
        for(var name in errors) {
            alert("Error: " + name + " - "+errors[name])
        }
    };
    
    $.fn.r3form_submitted = function(response) {
        // if form is set, clear timeout for this form
        if (response.form) {
            clearTimeout($.fn.r3formTimers[response.form]);
            $.fn.r3form_thaw(response.form);
        } else if ($.fn.r3formTimers) {
            // else clear all timeouts
            for (var form in $.fn.r3formTimers){
                clearTimeout($.fn.r3formTimers[form]);
                $.fn.r3form_thaw(form);
            }
        }

        if (response.status != undefined) {
            if (response.status == 0) {

            } else {
                $.fn.r3form_display_errors(response.errors, response.form);
                
                $.fn.r3form_after_submitted(response);
            }
        }
        
        if (response.location) {
            if (response.location == '*') {
                // code for "close window"
                // alert('*');
                if (response.ins_fields) {
                    // check if any fields in the opener should be filled
                    for (f in response.ins_fields) {
                        opener.document.getElementById(f).value = response.ins_fields[f];
                    }
                }
                var reloadOpener = true;
                if (typeof response.reload_opener != 'undefined')
                    reloadOpener = response.reload_opener;
                
                if (response.callback) {
                    $.fn.r3form_after_submitted(response);
                }
                
                $.fn.r3form_close(reloadOpener);
            } else {
                // open location in new window
                if (response.target) {
                    $(document).r3core('openWindow', response.location, response.target, {
                        width: response.width,
                        height: response.height
                    });
                    $.fn.r3form_after_submitted(response);
                } else if (response.callback) {
                    $.fn.r3form_after_submitted(response);
                } else {
                    location.href = response.location;
                }
            }
        }
    };
    
    $.fn.r3form_after_submitted = function(response) {};
    
    $.fn.r3form_failed = function() {
        alert('Data submit failed');
        if ($.fn.r3formTimers) {
            // else clear all timeouts
            for (var form in $.fn.r3formTimers){
                clearTimeout($.fn.r3formTimers[form]);
                $.fn.r3form_thaw(form);
            }
        }
    };
    
    $.fn.r3form_submit = function() {
        var form = this;
        $(form).ajaxSubmit({
            dataType: 'json',
            beforeSubmit: function() {
                form.r3form_prepare($(form).attr('name'))
            },
            success: form.r3form_submitted
        });
    };
    
    /**
     * Default action for cancel button
     * requires R3BaseFramework
     * @todo gather form (from button) to find obj_t
     */
    $.fn.r3form_new = function(url, popupTarget, popupWidth, popupHeight, customSettings) {
        var defaultSettings = {
            act: 'add',
            inplace: $(document).find('input[name=inplace]').val()
        };
        
        if (customSettings)
            $.extend(defaultSettings, customSettings);
        
        url = url + $.fn.getQueryStringSeparator(url) + $(document).getPageSettings(defaultSettings).join('&');
        url += $.fn.getQueryStringSeparator(url) + $('#filterform').ignorePageSettings().join('&');
        
        if (defaultSettings.inplace == 1) {
            location.href = url;
        } else {
            $(document).r3core('openWindow', url, popupTarget, {
                width: popupWidth,
                height: popupHeight
            });
        }
    };
    
    /**
     * Default action for export button
     * requires R3BaseFramework
     * @todo gather form (from button) to find obj_t
     */
    $.fn.r3form_export = function(format) {
        url = 'export.php';
        
        url = url + $.fn.getQueryStringSeparator(url) + $(document).getPageSettings().join('&');
        url += $.fn.getQueryStringSeparator(url) + 'format='+format;
        if ($('#filterform').length > 0) {
            url += $.fn.getQueryStringSeparator(url) + $('#filterform').ignorePageSettings().join('&');
        } else {
            url += $.fn.getQueryStringSeparator(url) + $('#list').ignorePageSettings().join('&');
        }
        
        location.href = url;
    };
    
    /**
     * Default action for export button
     * requires R3BaseFramework
     * @todo gather form (from button) to find obj_t
     */
    $.fn.r3form_print = function() {
        url = 'print.php';
        
        url = url + $.fn.getQueryStringSeparator(url) + $(document).getPageSettings().join('&');
        url += $.fn.getQueryStringSeparator(url) + $('#filterform').ignorePageSettings().join('&');
        
        location.href = url;
    };
    
    /**
     * Default action for cancel button
     * requires R3BaseFramework
     * @todo gather form (from button) to find obj_t
     */
    $.fn.r3form_cancel = function() {
        // TODO: check with inplace
        if ($(document).find('input[name=inplace]').val() == 0)
            $.fn.r3form_close();
        else
            location.href = 'edit.php?'+$(document).getPageSettings({act: 'cancel'}).join('&');
    };
    
    /**
     * Default action for modify button
     * @todo gather form (from button) to find obj_t
     */
    $.fn.r3form_modify = function() {
        location.href = 'edit.php?'+$(document).getPageSettings({act: 'mod'}).join('&');
    };
    
    /**
     * Default action for modify button
     * @todo gather form (from button) to find obj_t
     */
    $.fn.r3form_advanced_search = function() {
        location.href='search.php?'+$(document).getPageSettings().join('&');
    };
    
    /**
     * Default action for modify button
     * @todo gather form (from button) to find obj_t
     */
    $.fn.r3form_modify_advanced_search = function() {
        url = 'search.php';
        
        url = url + $.fn.getQueryStringSeparator(url) + $(document).getPageSettings().join('&');
        if ($('#filterform').length > 0) {
            url += $.fn.getQueryStringSeparator(url) + $('#filterform').ignorePageSettings().join('&');
        } else {
            url += $.fn.getQueryStringSeparator(url) + $('#list').ignorePageSettings().join('&');
        }
        
        location.href = url;
    };
    
    /**
     * Default action for close button
     */
    $.fn.r3form_close = function(reloadOpener) {
        try {
            if (reloadOpener)
                opener.location.href = opener.location.href;
            opener.top.focus();
        } catch(e) {
        } finally {
            window.close();
        }
    };
    
    /**
     * Default action for delete button
     * @todo gather form (from button) to find obj_t
     */
    $.fn.r3form_delete = function() {
        // TODO: translate
        if (confirm("Cancellare l'oggetto?")) {
            $.getJSON('edit.php?'+$(document).getPageSettings({act: 'del'}).join('&'), {
                ajax: 1
            }, function(response) {
                // TODO: check response
                $.fn.r3form_close();
            });
        }
    };
    
})(jQuery);