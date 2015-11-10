
(function($, undefined) {
    

    $.fn.add_thousands_separator = function(value, dec_point, thousands_sep) {
        var S = String(value);
        var T = "";
        var L = S.length - 1, C, j, P = S.indexOf('.') - 1;
        if (P < 0) {
            P = L;
        }
        var dec = S.indexOf('.');
        if (dec >= 0) {
            S = S.substr(0, dec) + dec_point + S.substr(dec + 1, S.length);
        }
        for (j = 0; j <= L; j++) {
            T += C = S.charAt(j);
            if (j < P && (P - j) % 3 == 0 && C != "-") {
                T += thousands_sep;
            }
        }
        return T;
    };
    
    $.fn.number_format = function(value, decimals, dec_point, thousands_sep, original_dec_point) {
        value = String(value);
        
        // recognize original decimal separator
        if (!original_dec_point) {
            var original_dec_point = value.match(/(\.|,)[0-9]+$/);
            if (original_dec_point && original_dec_point.length > 0)
                original_dec_point = original_dec_point[1];
            else
                original_dec_point = '';
        }
        
        // parse value to float
        switch(original_dec_point) {
            case '.':
                value = parseFloat(value.replace(/\,/g, ''));
                break;
            case ',':
                value = parseFloat(value.replace(/\./g, '').replace(/\,/, '.'));
                break;
            default:
                value = parseFloat(value);
        }
        
        // reset value if it's not a number
        // TODO: check if this is a good procedure (eventually put this action into a separate method
        if (isNaN(value)) {
            value = '';
        } else {
            // apply decimals
            if (!isNaN(decimals) && decimals >= 0) {
                value = String(value.toFixed(decimals));
            } else {
                value = String(value);
            }
        }
        
        return this.add_thousands_separator(value, dec_point, thousands_sep);
    };

    $.widget('r3.r3inputnumber', $.r3.r3core, {
        options: {
            decimals: 0,
            decimalSeparator: ',',
            thousandsSeparator: '.'
        },
        
        _create: function() {
            var self = this,
            element = self.element[0];
            
            // TODO: Avoid init inputnumber for normal text input (debug/error message?) (using data attribute: data-r3-dbtype?)
            
            // read customized decimal attribute
            var decimals = $(element).data('r3-decimals');
            if (!isNaN(decimals) && Math.abs(decimals) >= 0) {
                self.options.decimals = Math.abs(decimals);
            }
            
            if ($(element).is("input")) {
                $(element).focus([self], self._switchToEditFormat);
                $(element).blur([self], self._switchToUserFormat).blur();
            } else {
                self._switchToUserFormat({data: [self]});
            }
        },
        
        _switchToEditFormat: function(event) {
            var self = event.data[0];
                
            self.toEditFormat();
            
            self._trigger( "enter", event, {});
        },
        
        _switchToUserFormat: function(event) {
            var self = event.data[0];
            
            self.toUserFormat();
            
            self._trigger( "exit", event, {});
        },
        
        /**
         * Return a number string with thousand separator and comma
         */
        _addThousandsSeparatorAndComma: function(nr, fixedDecimals) {
            var self = this;
            
            if (fixedDecimals > 0) {
                S = String(nr.toFixed(fixedDecimals));
            } else {
                S = String(nr);
            }
            var T = "";
            var L = S.length - 1, C, j, P = S.indexOf('.') - 1;
            if (P < 0) {
                P = L;
            }
            var dec = S.indexOf('.');
            if (dec >= 0) {
                S = S.substr(0, dec) + self.options.decimalSeparator + S.substr(dec + 1, S.length);
            }
            for (j = 0; j <= L; j++) {
                T += C = S.charAt(j);
                if (j < P && (P - j) % 3 == 0 && C != "-") {
                    T += self.options.thousandsSeparator;
                }
            }
            return T;
        },
        
        toEditFormat: function() {
            var self = this;
            self.setVal(self.getEditFormat());
        },
        
        toUserFormat: function() {
            var self = this;
            self.setVal(self.getUserFormat());
        },
        
        getJSFormat: function() {
            var self = this;
            return self.getEditFormat('.');
        },
        
        getVal: function() {
            var self = this,
                element = self.element[0];
            if ($(element).is("input"))
                return $(element).val();
            else
                return $(element).html();
        },
        
        setVal: function(val) {
            var self = this,
                element = self.element[0];
            if ($(element).is("input"))
                return $(element).val(val);
            else
                return $(element).html(val);
        },
        
        getEditFormat: function(separator) {
            var self = this;
            if (!separator)
                separator = self.options.decimalSeparator;
            return $.fn.number_format(self.getVal(), self.options.decimals, separator, '', self.options.decimalSeparator);
        },
        
        getUserFormat: function() {
            var self = this;
            return $.fn.number_format(self.getVal(), self.options.decimals, self.options.decimalSeparator, self.options.thousandsSeparator);
        }
    }); 
        
    $.extend($.r3.r3inputnumber, {
        version: "1.0.0"
    });
    
})(jQuery);