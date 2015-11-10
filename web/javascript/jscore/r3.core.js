
(function($, undefined) {
    
    $.fn.getQueryStringSeparator = function(url) {
        if(url.indexOf('?') == -1) {
            return '?';

        }
        if(url.substr(-1) == '?') {
            return '';
        } else if(url.substr(-1) != '&') {
            return '&';
        }
        return '';
    };
    
    $.fn.getURLParameterByName = function(name) {
        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        var regexS = "[\\?&]" + name + "=([^&#]*)";
        var regex = new RegExp(regexS);
        var results = regex.exec(window.location.search);
        if(results == null)
            return "";
        else
            return decodeURIComponent(results[1].replace(/\+/g, " "));
    };
    
    $.fn.cleanUrlFromHash = function(url) {
        return url.replace(/#/g, '');
    };
    
    $.fn.getPageSettings = function(newPageSettings) {
        var self = this;
        var pageSettingsParameter = ['obj_t', 'act', 'embedded', 'inplace'];
        
        // init new page settings
        if ( !newPageSettings )
            newPageSettings = {};
        
        // add pkey field
        var inputPkeyName = $(this).find('input[name=id_key]');
        if ($(inputPkeyName).length > 0) {
            pageSettingsParameter.push($(inputPkeyName).val());
        }
        
        // get values
        var pageSettings = jQuery.map(pageSettingsParameter, function(settingName, i) {
            if ( typeof newPageSettings[settingName] != 'undefined') {
                return settingName+"="+newPageSettings[settingName];
            } else {
                var input = $(self).find('input[name='+settingName+']');

                if ($(input).length > 0) {
                    return settingName+"="+$(input).val();
                }
            }
        });
        
        return pageSettings;
    };
    
    $.fn.ignorePageSettings = function() {
        var pageSettingsParameter = ['obj_t', 'act', 'embedded', 'inplace'];
        
        // add pkey field
        var inputPkeyName = $(this).find('input[name=id_key]');
        if ($(inputPkeyName).length > 0) {
            pageSettingsParameter.push($(inputPkeyName).val());
        }
        
        var filterform = $(this).serializeArray();
        var result = $.map(filterform, function(val) {
            if ($.inArray(val.name, pageSettingsParameter) < 0) {
                return val.name + '=' + val.value;
            }
        });
          
        return result;
    };
    
    $.fn.getFormValues = function(fieldPrefix) {
        var self = this;
        
        // init new page settings
        if ( !fieldPrefix )
            fieldPrefix = '';
        
        var params = [];
        
        var values = $(self).formSerialize().split('&');
        $.each(values, function(i, val) {
            params.push(fieldPrefix + val);
        });
        
        return params.join('&');
    };
    
    $.fn.confirmDelete = function(url, msg) {
        if (confirm(msg)) {
            url = url + $.fn.getQueryStringSeparator(url) + $('#filterform').getPageSettings().join('&');
            url += $.fn.getQueryStringSeparator(url) + 'do_filter=1&' + $('#filterform').getFormValues('flt_');
            
            window.location.href = url;
        }
    };
    
    $.fn.confirmDeletePost = function(url, msg, data) {
        if (confirm(msg)) {
            $.ajax({
                type: 'POST',
                url: url,
                data: data,
                success: $.fn.confirmDeletePost.success,
                error: $.fn.confirmDeletePost.error,
                dataType: 'json'
            });
        }
    };
    
    $.fn.confirmDeletePost.success = function(data, textStatus, jqXHR) {
        if (data.status == 0) {
            window.location.reload(true);
        } else {
            alert(data.errors.generic_msg);
        }
    };
    
    $.fn.confirmDeletePost.error = function(jqXHR, textStatus, errorThrown) {
            alert(textStatus);
    }
    
    $.fn.emptySelect = function() {
        return this.each(function(){
            if (this.tagName=='SELECT') this.options.length = 0;
        });
    };

    $.fn.loadSelect = function(optionsDataArray) {
        return this.emptySelect().each(function(){
            if (this.tagName=='SELECT') {
                var selectElement = this;
                
                $.each(optionsDataArray,function(index,optionData){
                    if(optionData.caption == null) optionData.caption = '';
                    var option = new Option(optionData.caption, optionData.value); 
                    if ($.browser.msie) { 
                        selectElement.add(option); 
                    } else { 
                        selectElement.add(option,null); 
                    }    
                });
            }
        });
    };
    
    $.fn.addOptionToSelect = function(optionsDataArray) {
        return this.each(function(){
            if (this.tagName=='SELECT') {
                var selectElement = this;
                $.each(optionsDataArray,function(index,optionData){
                    var option = new Option(optionData.caption,
                        optionData.value);
                    if ($.browser.msie) {
                        selectElement.add(option);
                    }
                    else {
                        selectElement.add(option,null);
                    }
                });
            }
        });
    };
    
    $.fn.zoomToMap = function(options) {
        var defaultOptions = {
            action: 'zoomon', // TODO: this is needed only for window mode
            obj_t: '',
            obj_key: '',
            obj_id: '',
            obj_t_edit: '',
            obj_id_edit: '',
            highlight: false,
            windowMode: false,
            featureType: null,
            dependents: [],
            vectorlayers: []
        };
        options = $.extend(true, defaultOptions, options);
        
        if (options.windowMode) {
            // TODO: put the UserMapWidth/Height in r3core options or something like that
            var r3core = new $.r3.r3core;
            
            options.dependents = options.dependents.join(',');
            
            r3core.openWindow('gisclient.php', 'GisClient', {
                width: UserMapWidth, 
                height: UserMapHeight
            }, options);
        } else {
            // TODO: use intern var for the map reference
            $('#jQueryDialog').dialog('open');
            
            var featureType = (options.featureType == null) ? "g_" + options.obj_t + "." + options.obj_t : options.featureType;

            var gcSearchObj = {
                featureType: featureType,
                field: options.obj_key,
                value: options.obj_id
            };
            $.extend(gcSearchObj, options);
            
            // disable highlight if layer isn't queryable
            var layers = gisclient.componentObjects.gcLayersManager.getQueryableLayers(false, true);
            if (typeof layers[gcSearchObj.featureType] == 'undefined')
                gcSearchObj.highlight = false;

            // zoom to the given search information
            gisclient.zoomOn(gcSearchObj, gcSearchObj.highlight);
            
            var targetLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
            
            if (options.vectorlayers !== null) {
                for(vectorFeatureType in options.vectorlayers) {
                    var gcVectorObj = {
                        featureType: vectorFeatureType,
                        field: options.vectorlayers[vectorFeatureType].field,
                        value: options.vectorlayers[vectorFeatureType].value
                    };
                    
                    gisclient.addVectorFeatures(targetLayer, gcVectorObj);
                }
            }
            
            $.each(options.dependents, function(e, dependentFeatureType) {
                gisclient.componentObjects.gcLayersManager.activateLayerByFeatureType(dependentFeatureType);
            });
        }
    }
    
    $.fn.changeLanguage = function(language) {
        $.ajax({
            type: 'GET',
            url: 'ajax.php',
            dataType: 'json',
            data: {
                obj_t: 'user',
                method: 'change_language',
                language: language
            },
            success: function(response) {
                if (response.status == 0) {
                    document.location.href = document.location.href;
                }
            }
        });
    }

    $.widget('r3.r3core', {
        
        options: {
            popups: {}
        },
        
        _create: function() {
            var self = this;
            
            // hide header and footer if screen has a small height
            if (screen.height > 0 && screen.height <= 768) {
                self.hideHeader();
                self.hideFooter();
            }
            // add functions to show/hide menu if screen has a small width
            if (screen.width > 0 && screen.width <= 1024) {
                self.initializeMenuBar();
                self.toggleMenuBar();
            }
        },
        
        /**
         * hide menu and logos
         */
        hideHeader: function() {
            $('#tr_logo').hide();
        },
        
        /**
         * hide footer
         */
        hideFooter: function() {
            $('#tr_bottom').hide();
        },
        
        /**
         * Apply function to show/hide menu
         */
        initializeMenuBar: function() {
            var self = this;
            
            $('#menu_bar_separator,#menu_bar_close').click(self.toggleMenuBar);
            $('#menu_bar_close').show();
        },
        
        toggleMenuBar: function() {
            $('#menu_bar,#menu_bar_separator').toggle();
        },
        
        /**
         * openWindow: open a new window
         * @param string url: url to open
         * @param string target: target of the new window
         * @param object options: options of the new window
         * @param object data: parameter to give in get
         */
        openWindow: function(url, target, options, data) {
            var self = this;
            
            var defOptions = {
                scrollbars: 'yes',
                toolbar: 'no',
                location: 'no',
                status: 'no',
                menubar: 'no',
                resizable: 'yes',
                width: window.screen.availWidth,
                height: window.screen.availHeight,
                rememberPopup: false
            };
            options = $.extend(defOptions, options);

            // calculate left and top
            options.left = Math.max(0, ((window.screen.availWidth - options.width - 10) * .5));
            options.top = Math.max(0, ((window.screen.availHeight - options.height - 10) * .5));

            // create parameter string
            var param = new Array();
            for(paramName in options)
                param.push(paramName + '=' + options[paramName]);

            var getValues = new Array();
            if (typeof data === 'object') {
                $.each(data, function(getName, getValue) {
                    getValues.push( getName + '=' + getValue);
                });
            }
            if (getValues.length > 0)
                url += '?' + getValues.join('&');

            // open window
            if (self.options.popups[target] && self.options.popups[target].closed) { // Chrome: fixed bug
                self.options.popups[target] = null;
            }
            
            target = target.replace(".", ""); // IE: fixed bug
            if (!self.options.popups[target]) {
                self.options.popups[target] = window.open(url, target, param.join(', '));
            } else {
                self.options.popups[target].location.href = url;
            }
        
            try {
                self.options.popups[target].focus();
            } catch(e) {
            }
            
            if (!options.rememberPopup)
                self.options.popups[target] = null;
        },
        
        getWindow: function(target) {
            var self = this;
            if (self.options.popups[target])
                return self.options.popups[target];
            return null;
        },
        
        closeWindow: function(target) {
            var self = this;
            if (self.options.popups[target]) {
                self.options.popups[target].close();
                self.options.popups[target] = null;
            }
        },
        
        /**
         * openDialog: open a new jquery dialog
         * @param string url: url to open
         * @param string target: target of the new window (window, top, parent, opener)
         * @param object options: options of the new window
         * @param object data: parameter to give in get
         */
        openDialog: function(url, target, options, data) {
            var defOptions = {
                loadingText: 'Loading...',
                title: '',
                width: 'auto',
                height: 'auto',
                autoOpen: false,
                bgiframe: true,
                modal: true,
                resizable: false,
                load: function() {
                    
                }
            };
            options = $.extend(defOptions, options);
            
            // if dialog does not exists create it
            if (target.$('#r3_dialog').length == 0) {
                target.$('<div id="r3_dialog"></div>').hide().appendTo('body');
                target.$('#r3_dialog').dialog(options);
                target.$('#r3_dialog').dialog('close', function() {
                    target.$("#r3_dialog").remove();
                });
            } else {
                target.$('#r3_dialog').dialog('option', options);
            }
            
            // add get parameters
            var getValues = new Array();
            if (typeof data === 'object') {
                $.each(data, function(getName, getValue) {
                    getValues.push( getName + '=' + getValue);
                });
            }
            if (getValues.length > 0)
                url += '?' + getValues.join('&');
            
            target.$('#r3_dialog').html(options.loadingText);
            target.$('#r3_dialog').dialog('open').load(url, options.load);
        },
        
        /**
         * zoomToMap: open gisclient with zoom on the given credentials, if highlight is set true then the object will be highlighted
         * @param string searchLayer: name of the layer to zoom on
         * @param string searchField: name of the field to search on
         * @param mixed searchValue: value to search on
         * @param boolean highlight: if true, object will be highlighted
         * @param boolean windowMode: if true, gisclient is open in new window
         */
        zoomToMap: function(obj_t, obj_key, obj_id, highlight, windowMode, getParameters) {
            var zoomParameters = {
                obj_t: obj_t,
                obj_key: obj_key,
                obj_id: obj_id,
                highlight: highlight,
                windowMode: windowMode
            };
            $.extend(zoomParameters, getParameters);
            $.fn.zoomToMap(zoomParameters);
        },
        
        beforeSubmitForm: function() {
            $.each($('.r3inputnumber'), function(i, e) {
                var val = $(e).r3inputnumber('getJSFormat');
                $(e).val(val);
            });
        },
        
        afterSubmitForm: function() {
            $.each($('.r3inputnumber'), function(i, e) {
                var val = $(e).r3inputnumber('getUserFormat');
                $(e).val(val);
            });
        },
        
        applyReadonlyStyle: function(selector) {
            $(selector).addClass('input_readonly').attr('readonly', true);
            $(selector).filter('[type=checkbox],[type=radio]').attr('disabled', true);
        },
        
        selectToInput: function(element) {
            // hidden value
            var hasId = ($(element).attr('id') != undefined);
            var newHiddenElement = '<input type="hidden" name="'+$(element).attr('name')+'" value="'+$(element).val()+'"';
            if(hasId) newHiddenElement += ' id="'+$(element).attr('id')+'" ';
            newHiddenElement += '>';
            $(newHiddenElement).insertAfter(element);

            // text value
            var textValue = '';
            if ($(element).val() != '')
                textValue = $(element).find('option:selected').html();
            var newElement = '<input type="text" name="'+$(element).attr('name')+'" value="'+textValue+'" ';
            if(hasId) newElement += ' id="'+$(element).attr('id')+'_text" ';
            newElement += '>';
            $(newElement).insertAfter(element);
            
            // apply width
            if ($(element).css('width') != '') {
                if(hasId) {
                    $('#'+$(element).attr('id')+'_text').css('width', $(element).css('width'));
                } else {
                    $('input[name="'+$(element).attr('name')+'"]').css('width', $(element).css('width'));
                }
            }
        },
        
        /**
         * showForm: transform editable form into readonly form
         * @todo move this function into r3.form and rename it to readonly??
         * @param string scope: sizzle selector
         */
        showForm: function(scope) {
            var self = this;
            if (typeof scope === 'undefined')
                scope = window.document;
            
            // convert selectboxes to input
            var selectElements = $(scope).find('select');
            $.each(selectElements, function(elementIndex, element) {
                self.selectToInput(element);
            });
            
            $(selectElements).remove();
            
            // TODO: only when not using smarty plugin for datepicker
            // $('.r3datepicker').datepicker( "destroy" );
            
            // apply readonly style
            self.applyReadonlyStyle($(scope).find('input[type!=hidden][type!=button][type!=submit],textarea'));
        },
        
        createNotifyTemplates: function() {
            $(document.body).append("<div id='notifyTemplates'>\n\
                <div id='notifyErrorTpl' style='display:none' class='ui-state-error'>\n\
                <span style='float:left; margin:0 5px 0 0;' class='ui-icon ui-icon-alert'></span>\n\
                <h1>#{title}</h1>\n\
                <p>#{text}</p>\n\
                </div>\n\
                <div id='notifyInfoTpl' style='display:none' class='ui-state-highlight'>\n\
                <span style='float:left; margin:0 5px 0 0;' class='ui-icon ui-icon-info'></span>\n\
                <h1>#{title}</h1>\n\
                <p>#{text}</p>\n\
                </div>\n\
                </div>\n\
                ");
            $("#notifyTemplates").notify();
        },
        
        notify: function(type, title, text) {            
            switch(type) {
                case 'error':
                    jQuery("#notifyErrorTpl").show();
                    jQuery("#notifyTemplates").notify("create", "notifyErrorTpl", {
                        title: title,
                        text: text
                    }, {
                        custom: true,
                        expires: 6000
                    });
                    break;
                default:
                    jQuery("#notifyInfoTpl").show();
                    jQuery("#notifyTemplates").notify("create", "notifyInfoTpl", {
                        title: title,
                        text: text
                    }, {
                        custom: true,
                        expires: 6000
                    });
            }
        }
    });

    $.extend($.r3.r3core, {
        version: "1.0.0"
    });
    
})(jQuery);