(function ($) {
    $.fn.loadSelectData = function (url, data, callback) {
        var selectElement = this.prop('disabled', true);
        $.getJSON(url, data, function (response) {
            try {
                if (typeof response != 'object') {
                    throw new Error('submitData error: Invalid server response: ' + response);
                }
                if (typeof response.exception == 'string') {
                    throw new Error("Server error: " + response.exception);
                }
                if (typeof response.status == 'undefined') {
                    throw new Error("submitData error: Missing or invalid server response: Missing status");
                }
                if (response.status.toUpperCase() == 'ERROR') {
                    throw new Error(response.error.text);
                }
                selectElement.loadSelect(response.data);
                var tot = 0;
                $.each(response.data, function () {
                    tot++;
                });
                if (tot > 1) {
                    selectElement.removeProp('disabled');
                }
            } catch (e) {
                alert(e.message);
            }
            if (typeof callback == 'function') {
                callback(response);
            }
        });
    }
})(jQuery);

(function ($) {
    $.fn.loadSelect = function (data) {
        return this.emptySelect().each(function () {
            if (this.tagName == 'SELECT') {
                var selectElement = this;
                $.each(data, function (name, value) {
                    if (typeof value == 'object') {
                        // array of json (sort problem)
                        $.each(value, function (key, label) {
                            // alert(key + '=' + label);
                            var option = new Option(label, key);
                            if ($.browser.msie) {
                                selectElement.add(option);
                            } else {
                                selectElement.add(option, null);
                            }
                        });
                    } else {
                        // alert(name + value);
                        var option = new Option(value, name);
                        if ($.browser.msie) {
                            selectElement.add(option);
                        } else {
                            selectElement.add(option, null);
                        }
                    }
                });
            }
        });
    };
})(jQuery);


/**
 * jQuery extension to load multiple select once
 */
jQuery.extend({
    /**
     * Load Fraction, street, Catastal munic. data  // SS: TRY WITH LOAD MULTI DATA (not only for select!!!)
     */
    loadMultiSelect: function (url, data, callback, type) {
        // shift arguments if data argument was ommited
        if (jQuery.isFunction(data)) {
            callback = data;
            data = null;
        }
        loadMultiSelectCallback = callback;

        // Default json request
        if (typeof type == 'undefined') {
            type = 'json';
        }

        return jQuery.ajax({
            type: "GET",
            url: url,
            data: data,
            success: jQuery.loadMultiSelectDone,
            dataType: type
        });

    },
    loadMultiSelectDone: function (data) {
        // Parse error
        if ((data.status == 0 || data.status == 'OK') && typeof data.data == 'object') {
            jQuery.each(data.data, function (name, val) {
                var tot = 0;
                var selectElement = jQuery('select#' + name)[0];

                // Clear the select options
                jQuery('select#' + name).emptySelect();

                // Populate the select options
                if (typeof val.options == 'object') {
                    jQuery.each(val.options, function (value, caption) {
                        if (typeof caption == 'object') {
                            // array of json (sort problem)
                            $.each(caption, function (key, label) {
                                // alert(key + '=' + label);
                                var option = new Option(label, key);
                                if (typeof selectElement != 'undefined') {
                                    if ($.browser.msie) {
                                        selectElement.add(option);
                                    } else {
                                        selectElement.add(option, null);
                                    }
                                }
                            });
                        } else {
                            tot++;
                            var option = new Option(caption, value);
                            if (typeof selectElement != 'undefined') {
                                if (jQuery.browser.msie) {
                                    selectElement.add(option);
                                } else {
                                    selectElement.add(option, null);
                                }
                            }
                        }
                    });
                }

                // Assign the selected value select options
                if (typeof val.value == 'string') {
                    jQuery('select#' + name).val(val.value);
                }

                // Enable controls if items > 1
                if (tot > 1) {
                    jQuery('select#' + name).removeProp('disabled')
                            .removeAttr('readonly');
                }
            });
        }
        if (jQuery.isFunction(loadMultiSelectCallback)) {
            loadMultiSelectCallback(data);
        }
    }
});




