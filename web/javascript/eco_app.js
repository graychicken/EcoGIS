var IFrameObj;                                  /* Screen lock object */
var decimalSeparator = ',';
var thousandsSeparator = '.';

var ajaxTimer;                                  /* Ajax timer */
var ajaxCallFaildMsg = 'Ajax call faild';       /* Standard ajax error merrage */
var ajaxTimeout = 10000;                        /* Ajax timeout (in ms)*/
var euroSymbol = String.fromCharCode(0x20AC);   /* Euro symbol */

var txtChoose = '-- choose --';
var txtRemoveUpload = 'x';
var txtDeniedUpload = 'You cannot select a $ext file.';
var txtDuplicateUpload = 'This file has already been selected:\n$file';

var lastDialogOverflow;

//trimming space from both side of the string
String.prototype.trim = function () {
    return this.replace(/^\s+|\s+$/g, "");
};

//trimming space from left side of the string
String.prototype.ltrim = function () {
    return this.replace(/^\s+/, "");
};

//trimming space from right side of the string
String.prototype.rtrim = function () {
    return this.replace(/\s+$/, "");
};

//pads left
String.prototype.lpad = function (padString, length) {
    var str = this;
    while (str.length < length) {
        str = padString + str;
    }
    return str;
};

//pads right
String.prototype.rpad = function (padString, length) {
    var str = this;
    while (str.length < length) {
        str = str + padString;
    }
    return str;
};

// Cambio anno da menù principale
function onChangeDomain() {
    $('#frmDomain').submit();
    $('#global_domain').prop('disabled', true);
}

// Show/hide the ajax wait div
function ajaxWait(show) {
    if (show) {
        if ($("#ajaxWait").length > 0) {
            $('#ajaxWait').css('display', '');
        } else {
            if (typeof parent != 'undefined') {
                if (parent.$("#ajaxWait").length > 0) {
                    parent.$('#ajaxWait').css('display', '');
                } else {
                    if (typeof parent.parent != 'undefined') {
                        parent.parent.$('#ajaxWait').css('display', '');
                    }
                }
            }
        }
    } else {
        if ($("#ajaxWait").length > 0) {
            $('#ajaxWait').css('display', 'none');
        } else {
            if (typeof parent != 'undefined' && typeof parent.$ != 'undefined') {
                if (parent.$("#ajaxWait").length > 0) {
                    parent.$('#ajaxWait').css('display', 'none');
                } else {
                    if (typeof parent.parent != 'undefined') {
                        parent.parent.$('#ajaxWait').css('display', 'none');
                    }
                }
            }
        }
    }
}

// Disable all the form buttons
function disableButton(disabled, selector) {
    if (typeof selector == 'undefined') {
        selector = '';
    } else {
        selector = selector + ' ';
    }
    $(selector + "input[type='button']").prop('disabled', disabled);
    $(selector + "input[type='submit']").prop('disabled', disabled);
    $(selector + "button").prop('disabled', disabled);
}

// Clear the ajax timer
function clearAjaxTimer() {

    if (ajaxTimer) {
        clearTimeout(ajaxTimer);
        ajaxTimer = null;
    }
}

// Start the ajax-timeout timer
function startAjaxTimer(timeout) {

    if (!ajaxTimer) {
        ajaxTimer = setTimeout("xajaxCallFaild()", ajaxTimeout);
    }
}

// Ajax call faild
function xajaxCallFaild() {
    clearAjaxTimer();
    alert(ajaxCallFaildMsg);
    ajaxWait(false);
    disableButton(false);
}


// Generic list
function listObject(on, init, lastId) {
    if (typeof on == "undefined") {
        on = $('#on').val();
    }
    if (typeof lastId == "undefined") {
        lastId = $('#id').val();
    }
    ajaxWait(true);
    disableButton(true);
    var url = 'list.php?on=' + on + '&';
    if (typeof lastId != "undefined") {
        url = url + 'last_id=' + lastId + '&';
    }
    if (typeof init != "undefined" && init == true) {
        url = url + 'init&';
    }
    document.location = url;
}

// Apply the filter
function applyFilter() {
    ajaxWait(true);
    $('#filterform').submit();
    disableButton(true);
}

// Cancel the filter
function cancelFilter(on, extraParams) {
    if (typeof on == "undefined") {
        on = $('#on').val();
    }
    if (typeof extraParams == "undefined") {
        extraParams = '';
    }
    ajaxWait(true);
    disableButton(true);
    document.location = 'list.php?on=' + on + '&init&reset&' + extraParams;
}

// Add an object
function showObject(id, on) {
    if (typeof id == "undefined") {
        id = $('#id').val();
    }
    if (typeof on == "undefined") {
        on = $('#on').val();
    }
    ajaxWait(true);
    disableButton(true);
    document.location = 'edit.php?on=' + on + '&id=' + id + '&act=show';
}

// Add an object
function addObject(on, params) {
    if (typeof on == "undefined") {
        on = $('#on').val();
    }
    ajaxWait(true);
    disableButton(true);
    var url = 'edit.php?on=' + on + '&act=add';
    if (params) {
        url = url + '&' + jQuery.param(params);
    }
    document.location = url;
}

// edit an object
function modObject(id, on) {
    if (typeof id == "undefined") {
        id = $('#id').val();
    }
    if (typeof on == "undefined") {
        on = $('#on').val();
    }
    ajaxWait(true);
    disableButton(true);
    document.location = 'edit.php?on=' + on + '&id=' + id + '&act=mod';
}

function delObject(id, on) {
    alert('delObject NOT IMPLEMENTED IN eco_app.js');
}

function askDelObject(id, on) {
    disableButton(true);
    if (typeof deleteObjectText == 'undefined') {
        txt = 'Are you sure to delete the selected object?';
    } else {
        txt = deleteObjectText;
    }
    if (confirm(txt)) {
        delObject(id, on);
    }
}

function showObjectOnMap(id, on) {
    if (typeof id == "undefined") {
        id = $('#id').val();
    }
    if (typeof on == "undefined") {
        on = $('#on').val();
    }
    ZoomToMap('generic', on, id);
}

function isAjaxResponseOk(response) {
    try {
        if (typeof response != 'object') {
            throw new Error('Server error: Invalid server response: ' + response);
        }
        if (typeof response.exception == 'string') {
            throw new Error("Server error: " + response.exception);
        }
        if (response.status && (response.status.toUpperCase() == 'ERROR' || response.status == '1')) {
            if (typeof response.error == 'object' && typeof response.error.text == 'string') {
                throw new Error(response.error.text);
            }
            throw new Error(response.error);
        }
        return true;
    } catch (e) {
        alert(e.message);
        return false;
    }
}

/**
 * default ajax form submit error
 * param object params                 json parameters from server
 */
function submitDataError(response) {

    ajaxWait(false);
    clearAjaxTimer();
    if (typeof response.error == 'object' && typeof response.error.text == 'string') {
        alert(response.error.text);
    } else {
        alert('Unknown error in submitDataError');
    }
    disableButton(false);
    if (typeof response.error == 'object' && typeof response.error.element == 'string') {
        if (response.error.element) {
            if ($('#' + response.error.element).length > 0) {
                $('#' + response.error.element).focus();
            } else {
                // Popup prefix
                $('#popup_' + response.error.element).focus();
            }
        }
    }
}

/**
 * default ajax form submit done
 * param object params                 json parameters from server
 */
function submitDataDone(response) {
    if (typeof response.js == 'string') {
        eval(response.js);
    } else if (typeof response.location == 'string') {
        // Server return the new location
        document.location = response.location;
    } else if (typeof gotoList == 'function') {
        // Standard list function
        gotoList(response);
    } else {
        // No action defined. 
        ajaxWait(false);
        alert('Submit data done!');
        disableButton(false);
    }
}

/**
 * default ajax form submit
 * param mixed e                       e can be: 
 *                                     - not given: get the 1st form (only 1 form must be in the html)
 *                                     - string: the id of the form (without #)
 *                                     - object: the input control in the form to submit
 */
function submitData(e, opt) {
    var startTimer = true;
    if (typeof opt != 'undefined') {
        if (typeof opt.start_timer != 'undefined') {
            startTimer = opt.start_timer;
        }
        if (typeof opt.timeout != 'undefined') {
            ajaxTimeout = opt.timeout;
        }

    }

    try {
        if (typeof e == 'undefined') { // e is missing: get the first form
            e = $('form');
        } else if (typeof e == 'string') { // e is the id of the form
            e = $(e);
        } else if (typeof e == 'object') { // e is the submitted button
            e = $(e).parents("form");
        } else {
            throw new Error("Invalid parameter in submitFormData");
        }
        if (e.length == 0) {  // No form found
            throw new Error("No form found");
        } else if (e.length > 1) {  // More than 1 form found
            throw new Error("You have " + e.length + " forms on your page. Please select the form to submit!");
        }
    } catch (exc) {
        alert('submitFormData error: ' + exc.message);
    }
    if (startTimer) {
        startAjaxTimer();
    }
    disableButton(true);
    ajaxWait(true);
    e.ajaxSubmit({
        dataType: 'json',
        success: function (response) {
            clearAjaxTimer();
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
                if (response.status.toUpperCase() == 'ERROR' || response.status == '1') {
                    if (typeof submitDataErrorCustom == 'function') {
                        submitDataErrorCustom(response);
                    } else {
                        submitDataError(response);
                    }
                } else {
                    submitDataDone(response);
                }
            } catch (exc) {
                ajaxWait(false);
                disableButton(false);
                alert(exc.message);
            }
        }
    });
}

/**
 * default ajax confirm function
 */
function ajaxConfirm(url, data, confirmCallback) {
    ajaxWait(true);
    $.getJSON(url, data, function (response) {
        try {
            if (typeof response != 'object') {
                throw new Error('ajaxConfirm error: Invalid server response: ' + response);
            }
            if (typeof response.exception == 'string') {
                throw new Error("Server error: " + response.exception);
            }
            if (typeof response.status == 'undefined') {
                throw new Error("ajaxConfirm error: Missing or invalid server response: Missing status");
            }
            if (response.status.toUpperCase() == 'ERROR' || response.status == '1') {
                if (typeof response.error == 'object' && typeof response.error.text == 'string') {
                    throw new Error(response.error.text);
                } else {
                    throw new Error('Unknown error in ajaxConfirm');
                }
            } else {
                ajaxWait(false);
                if (typeof response.alert == 'string') {
                    alert(response.alert);
                }
                if (typeof response.confirm == 'string') {
                    if (confirm(response.confirm)) {
                        confirmCallback(response);
                    }
                }
            }
        } catch (e) {
            ajaxWait(false);
            disableButton(false);
            alert(e.message);
        }
    });


}

function lockScreen() {

    if (!lockIFrame) {
        var lockIFrame = top.document.createElement('iframe');
        lockIFrame.setAttribute('id', 'lockIFrame');
        lockIFrame.style.border = '0px';
        lockIFrame.scrolling = 'no';
    } else {
        lockIFrame.style.display = '';
    }
    lockIFrame.style.position = "absolute";
    lockIFrame.style.left = '0px';
    lockIFrame.style.top = '0px';
    lockIFrame.style.width = '100%';
    lockIFrame.style.height = '100%';
    lockIFrame.style.cursor = "wait";

    lockIFrame.style.filter = 'alpha(opacity=50)';
    lockIFrame.style.opacity = '0.50';
    lockIFrame.style.background = '#999999';
    lockIFrame.style.zIndex = 1000000;  // very high number

    IFrameObj = top.document.body.appendChild(lockIFrame);

}

function unlockScreen() {

    if (!IFrameObj) {
        // No lock frame
        return;
    }
    IFrameObj.style.display = 'none';
}

/**
 * Call the print preview screen. Actually not supported! Call the standard print
 */
function printPreview() {
    window.print();
}

/**
 * Return a number string with thousand separator and comma
 */
function addThousandsSeparatorAndComma(nr, fixedDecimals) {
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
        S = S.substr(0, dec) + decimalSeparator + S.substr(dec + 1, S.length);
    }
    for (j = 0; j <= L; j++) {
        T += C = S.charAt(j);
        if (j < P && (P - j) % 3 == 0 && C != "-") {
            T += thousandsSeparator;
        }
    }
    return T;
}

/**
 * Adjust an year (integer without thousand separator) field
 * param object e      The control
 * parma bool enter    true on enter(focus), false on exit(blur)
 */
function adjYearField(e, enter) {
    var orgVal = $(e).val();
    var val = parseInt(orgVal.replace(/\./g, '').replace(/\,/, '.'));
    if (enter) {
        if (isNaN(val)) {
            val = '';
        }
        $(e).val(val);
        $(e).select();
    } else {
        if (isNaN(val)) {
            if (orgVal.trim() != '' && typeof errInvalidYearText != 'undefined') {
                alert(errInvalidYearText);
            }
            val = '';
        } else {
            if (val < 50) {
                val = 2000 + val;
            } else if (val < 100) {
                val = 1900 + val;
            }
        }
        $(e).val(val);
    }
}

/**
 * Adjust an integer field
 * param object e      The control
 * parma bool enter    true on enter(focus), false on exit(blur)
 */
function adjIntegerField(e, enter) {
    var orgVal = $(e).val();
    var val = parseInt(orgVal.replace(/\./g, '').replace(/\,/, '.'));
    if (enter) {
        if (isNaN(val)) {
            val = '';
        }
        $(e).val(val);
        $(e).select();
    } else {
        if (isNaN(val)) {
            if (orgVal.trim() != '' && typeof errInvalidIntegerNumberText != 'undefined') {
                alert(errInvalidIntegerNumberText);
            }
            val = '';
        } else {
            val = addThousandsSeparatorAndComma(val);
        }
        $(e).val(val);
    }
}

/**
 * Adjust a float field
 * param object e      The control
 * parma bool enter    true on enter(focus), false on exit(blur)
 */
function adjFloatField(e, enter) {
    var orgVal = $(e).val();
    var dec = $(e).attr('data-dec');
    if (typeof dec == 'undefined') {
        var dec = $(e).attr('dec');
    }
    if (enter) {
        var val = parseFloat(orgVal.replace(/\./g, '').replace(/\,/, '.'));
        if (isNaN(val)) {
            val = '';
        } else {
            if (dec > 0) {
                val = String(val.toFixed(dec));
            } else {
                val = String(val);
            }
        }
        $(e).val(val.replace(/\./, ','));
        $(e).select();
    } else {
        var val = parseFloat(orgVal.replace(/\,/g, '.'));
        if (isNaN(val)) {
            if (orgVal.trim() != '' && typeof errInvalidFloatNumberText != 'undefined') {
                alert(errInvalidFloatNumberText);
            }
            val = '';
        } else {
            val = addThousandsSeparatorAndComma(val, dec);
        }
        $(e).val(val);
    }
}

function roundNumber(num, dec) {
    return Math.round(num * Math.pow(10, dec)) / Math.pow(10, dec);
}


/**
 * Open a standard R3 dialog from the specified url
 * param string url         the url to get
 * param string title       the dialog title or the object options
 * param integer width      the width of the dialog
 * param integer height     the height of the dialog
 * param object opt         json parameters
 */
function openR3Dialog(url, title, width, height, opt) {
    var context = window;  // Default context
    if (typeof loadingText == "undefined")
        loadingText = 'Loading...';
    if (typeof opt != "undefined") {
        if (opt.target == 'parent') {
            context = window.parent;  // Parent window context
        } else if (opt.target == 'top') {
            context = window.top;   // Top window context
        }
    }
    if (typeof title == "undefined")
        title = '';
    if (typeof width == "undefined")
        width = 'auto';
    if (typeof height == "undefined")
        height = 'auto';
    var defaultOpt = {
        autoOpen: false,
        bgiframe: true,
        modal: true,
        title: title,
        width: width,
        height: height,
        resizable: false,
        iframe: false,
        close: function (event, ui) {
            context.$("#r3_dialog").remove();
            context.hideR3Help();
            if (lastDialogOverflow) {
                context.$('body').css('overflow', lastDialogOverflow);
                lastDialogOverflow = null;
            }
        }
    };
    context.hideR3Help();
    if (typeof opt == "undefined") {
        opt = defaultOpt;
    } else {
        opt = $.extend(defaultOpt, opt);
    }
    if (context.$('#r3_dialog', context).length == 0) {
        context.$('<div id="r3_dialog" style="display: none; width: 0px; height: 0px"></div>').hide().appendTo('body');
    }

    if (defaultOpt.iframe) {
        // IE7
        if ($.browser.msie && parseInt($.browser.version, 10) === 7) {
            var iframe = '<iframe id="r3_dialog_iframe" frameborder="0" marginwidth="0" marginheight="0" width="' + (width - 1) + '" height="' + (height - 35) + '" style="margin-left: -10" src="' + url + '"/>';
            context.$('#r3_dialog').append(iframe);
            context.$('#r3_dialog').css('overflow', 'hidden');
            context.$('#r3_dialog').dialog('option', opt);
            context.$('#r3_dialog').dialog(opt).dialog('open');
        } else {
            var iframe = $('<iframe frameborder="0" marginwidth="0" marginheight="0" ></iframe>')
                    .attr("width", width - 1)
                    .attr("height", height - 35)
                    .css('margin-left', -10);
            context.$('#r3_dialog').append(iframe).appendTo("body").css('overflow', 'hidden');
            context.$('#r3_dialog').dialog('option', opt);
            context.$('#r3_dialog').dialog(opt).dialog('open');
            iframe.attr("src", url);
        }
    } else {
        context.$('#r3_dialog').html(loadingText);
        context.$('#r3_dialog').dialog('option', opt);
        context.$('#r3_dialog').dialog(opt).dialog('open').load(url);
    }
    lastDialogOverflow = context.$('body').css('overflow');
    context.$('body').css('overflow', 'hidden');
}

/**
 * Show the specified dialog (already loaded)
 */
function showR3Dialog(id, opt) {
    $("#" + id).dialog(opt).dialog('open');
}

/**
 * Close a standard R3 dialog
 * param string id          the dialog id (default r3_dialog)
 */
function closeR3Dialog(id, opt) {
    if (typeof id == "undefined")
        id = 'r3_dialog';
    var context = window;  // Default context
    if (typeof opt != "undefined") {
        if (opt.target == 'parent') {
            context = window.parent;  // Parent window context
        } else if (opt.target == 'top') {
            context = window.top;   // Top window context
        }
    }
    context.$("#" + id).dialog('close');

    hideR3Help();
    ajaxWait(false);
}

function autocomplete(selector, opt) {
    var defaultOpt = {
        url: 'edit.php',
        on: $('#on').val(),
        limit: 20,
        minLength: 2
    };
    if (typeof opt == "undefined" || opt.method == "undefined") {
        alert('autocomplete error: Missing method');
    } else {
        opt = $.extend(defaultOpt, opt);
        $(selector).autocomplete({
            source: function (request, response) {
                opt = $.extend(opt, {
                    term: request.term
                });
                $.getJSON('edit.php', opt,
                        function (data) {
                            var newData = new Array;
                            $.each(data.data, function (val, lbl) {
                                if (typeof lbl == 'object') {
                                    $.each(lbl, function (st_id, st_name) {
                                        newData.push(st_name);
                                    });
                                } else {
                                    newData.push(lbl);
                                }
                            });
                            response(newData);
                        })
            },
            minLength: opt.minLength
        });
    }
}

/**
 * Convert a locale number to float
 * param string val    The value to convert
 */
function locale2float(inVal) {
    outVal = '';
    if (typeof inVal != 'undefined') {
        outVal = parseFloat(inVal.replace(/\./g, '').replace(/\,/, '.'));
        if (isNaN(outVal)) {
            outVal = '';
        }
    }
    return outVal;
}
/**
 * Convert a float number to a locale number
 * param string val    The value to convert
 */
function float2locale(val, fixedDecimals) {
    val = parseFloat(val);
    if (isNaN(val)) {
        return '';
    }
    if (typeof fixedDecimals != 'undefined') {
        e = Math.pow(10, fixedDecimals);
        val = Math.round(val * e) / e;
    }
    val = addThousandsSeparatorAndComma(val, fixedDecimals);
    return val;
}

/**
 * Apply the calendar settings
 */
function setupCalendarSettings(selector) {
    if (typeof selector == 'undefined') {
        selector = '';
    }
    $.datepicker.setDefaults({
        showAnim: "fadeIn",
        showOn: "button",
        buttonImage: "../images/ico_cal.gif",
        buttonImageOnly: true,
        duation: 'fast',
        changeMonth: true,
        changeYear: true
    });
    $(selector + ' .date').css('width', 75);
    $(selector + ' .date').datepicker();
}

/**
 * Refresh a single select
 * param selector         jQuery selector
 * param string url       the url to catch
 * param object opt       json options
 * param mixed selval     the value to select
 * param callback         the callback function to call on done
 */
function refreshSelect(selector, url, data, selval, callback) {
    $(selector).prop('disabled', true);
    $.getJSON(url,
            data,
            function (data) {
                if (typeof data.status != 'undefined' && typeof data.data != 'undefined') {
                    data = data.data;
                }
                $(selector).emptySelect().loadSelect(data);
                if ($(selector + ' option').length >= 1)
                    $(selector).prop('disabled', false);
                if (typeof selval != 'undefined')
                    jQuery(selector).val(selval);
                if (typeof callback == 'function')
                    callback(data, selval);
            });
}

// Set the focus to the first founded control nor hidded, readonly or disabled
function focusTo(selectors) {
    $.each(selectors.split(','), function (dummy, selector) {
        if ($(selector).length > 0) {
            if ($(selector).prop('readonly') || $(selector).prop('disabled'))
                return true;
            var tagName = $(selector)[0].tagName;
            if (tagName == 'INPUT' && $(selector).attr('type') != 'hidden') {
                $(selector).focus();
                return false;
            } else if (tagName == 'SELECT') {
                $(selector).focus();
                return false;
            }
        }
    });
}


/**
 * return true if the element has the extra data value
 */
function hasExtradata(selector) {
    if ($(selector).hasClass('has_extradata')) {
        return true;
    }
    // Old code compatibility 
    var has_extradata = $(selector).attr('data-has_extradata');
    if (typeof has_extradata == 'undefined') {
        var has_extradata = $(selector).attr('has_extradata');
    }
    if (has_extradata == 1 || has_extradata == 'T') {
        return true;
    }
    return false;
}

/**
 * Show hide the extra field. The id of the field must have the same prefix + extra_data
 * The control is shown if the attribute has_extradata is 'T'
 * param object e       che control (this)
 */
function applyExtraData(e, prefix2) {
    var id = $(e).attr('id');
    if (typeof prefix2 == 'string') {
        prefix2 = prefix2 + '_';
        id = id.substr(prefix2.length, id.length);
    } else {
        prefix2 = '';
    }
    var prefix = id.substr(0, id.indexOf('_'));
    var id2 = prefix2 + prefix + '_extradata';
    $('#' + id2).toggle(hasExtradata('#' + $(e).attr('id') + ' option:selected'));
}

/**
 * Setup the extra data field (setup the change event + call once)
 */
function setupExtraData(selector, prefix) {
    applyExtraData($(selector), prefix);
    $(selector).bind('change', function () {
        applyExtraData(this, prefix)
    });
}

/*
 * Return the tab index by the tab id
 */
function getTabIndexById(selector, searchedId) {
    var index = -1;
    var i = 0, els = $(selector).find("a");
    var l = els.length, e;
    while (i < l && index == -1)
    {
        e = els[i];
        if ("#" + searchedId == $(e).attr('href'))
        {
            index = i;
        }
        i++;
    }
    ;
    return index;
}

/**
 * Set (add or change) an url parameter
 */
function setURLParams(url, params) {
    var pos = url.indexOf('?');
    if (pos >= 0) {
        var urlParams = url.substr(pos + 1);
        var url = url.substr(0, pos);
    } else {
        var urlParams = '';
    }
    $.each(params, function (key, val) {
        //alert(key + ' ' + val);
        var pos = urlParams.indexOf(key + '=');
        if (pos >= 0) {
            var len = urlParams.indexOf('&', pos);
            if (len >= 0) {
                urlParams = urlParams.substr(0, pos) + key + '=' + escape(val) + urlParams.substr(len);
            } else {
                urlParams = urlParams.substr(0, pos) + key + '=' + escape(val);
            }
        } else {
            urlParams = urlParams + '&' + key + '=' + escape(val);
        }
    });
    return url + '?' + urlParams;
}


/**
 * Reload a tab content
 */
function reloadTab(selector, tabId, url, urlParams) {
    if (typeof selector == 'undefined') {
        selector = '#tabs';  // Standard tab name selector
    }
    var tabs = $(selector).tabs();
    if (typeof tabId == 'undefined') {
        tabId = tabs.tabs('option', 'selected');
    } else if (isNaN(tabId)) {
        // TabId is the tab id (String)
        tabId = getTabIndexById(selector, tabId);
    }
    // Is iframe tab?
    var tabNo = 0;
    var isFrameTab = false;
    $(selector + ' iframe').each(function () {
        if (tabNo == tabId) {
            // Reload the iframe content
            if (typeof url == 'undefined') {
                url = this.contentWindow.location.href;
            }
            if (typeof urlParams == 'object') {
                url = setURLParams(url, urlParams);
            }
            this.contentWindow.location.replace(url);
            isFrameTab = true;
        }
        tabNo++;
    });

    if (!isFrameTab) {
        if (typeof url != 'undefined') {
            tabs.tabs('url', tabId, url);
        }
        $(selector).tabs('load', tabId);
    }
}

function setupShowMode(prefix) {
    prefix = typeof prefix == 'undefined' ? '' : prefix + '_';

    // Convert select into text input
    $('#' + prefix + 'modform select').each(function (i, obj) {
        var s = '';
        var e = $(obj);
        var theId = e.attr('id');
        var theName = e.attr('name');
        var theValue = e.find('option:selected').text();
        if (e.val() == '')
            var theValue = '';
        var theWidth = e.css('width');
        if (theWidth == '0px') {
            theWidth = '150px';
        }
        s = s + (typeof theId == 'undefined' ? '' : 'id="' + theId + '" ');
        s = s + (typeof theName == 'undefined' ? '' : 'name="' + theName + '" ');
        s = s + (typeof theValue == 'undefined' ? '' : 'value="' + theValue + '" ');
        s = s + (typeof theWidth == 'undefined' ? '' : 'style="width:' + theWidth + '" ');
        e.after('<input type="text" ' + s + '>');
        e.remove();

    });

    // Disable all controls except buttons
    $('#' + prefix + 'modform :input[type!=button]').addClass('readonly').prop('readonly', true);
    $('#' + prefix + 'modform :input[type=checkbox]').prop('disabled', true);
    $('#' + prefix + 'modform :input[type=radio]').prop('disabled', true);
}

function setupInputFormat(selector, setupCalendar) {
    if (typeof selector == 'undefined') {
        selector = '';
    }
    $(selector + ' .year').bind('focus', function () {
        adjYearField(this, true)
    });
    $(selector + ' .year').bind('blur', function () {
        adjYearField(this, false)
    });
    $(selector + ' .integer').bind('focus', function () {
        adjIntegerField(this, true)
    });
    $(selector + ' .integer').bind('blur', function () {
        adjIntegerField(this, false)
    });
    $(selector + ' .float').bind('focus', function () {
        adjFloatField(this, true)
    });
    $(selector + ' .float').bind('blur', function () {
        adjFloatField(this, false)
    });
    $.fn.MultiFile.options.STRING.remove = txtRemoveUpload;
    $.fn.MultiFile.options.STRING.denied = txtDeniedUpload;
    $.fn.MultiFile.options.STRING.duplicate = txtDuplicateUpload;
    $(selector + ' .upload').MultiFile();

    if (setupCalendar === false) {
        $(selector + ' .date').css('width', 75);
    } else {
        setupCalendarSettings(selector);
    }
}

// Setup read only fields
function setupReadOnly(selector) {
    $(selector + ' input:text.readonly').prop('readonly', true);
}

// Setup required fields
function setupRequired(selector) {
    if (typeof selector == 'undefined') {
        selector = '';
    }
    $(selector + ' .required').append('<em>*</em>');
}

/**
 * Enable/disable the extra data field for 1 or 2 languages
 */
function updateForExtraData(selector, extraFieldSelector, allowConcat) {
    // If read-only input, attach extra text
    if (allowConcat == true && $(selector).is('input') && $(selector).hasClass('readonly') && $(extraFieldSelector + '_' + langId).val() != '') {
        $(selector).val($(selector).val() + ' - ' + $(extraFieldSelector + '_' + langId).val());
    }
    $(extraFieldSelector).toggle(hasExtradata(selector + " option:selected"));
}

// Disable all the form buttons
function disableControl(selector, disabled) {
    var isSelect = $(selector).attr('type') == 'select-one';
    var e = $(selector);
    if (disabled) {
        e.attr(isSelect ? 'disabled' : 'readonly', true).addClass('readonly');
    } else {
        e.attr(isSelect ? 'disabled' : 'readonly', false).removeClass('readonly');
    }
}

function resizeTabHeight() {
    if ($("#tabs").length > 0) {
        var height = $(window).height() - $('#tabs').offset().top - 30;
        height = Math.max(250, height);
        $('#tabs').height(height);
        $('#tabs iframe').height(height - 40);
        $('.tab-resize').height(height - 40);
    }
}

// SELECTED ROW FUNCTION

// Remove all the selected row
function removeSelectedRow(container) {
    if (typeof container == "undefined") {
        container = '*';
    }
    $(container).removeClass('selected_row');
}

// Set all the selected row
function addSelectedRow(container) {
    $(container).addClass('selected_row');
}

// Remove all selected row and set one
function setSelectedRow(container, removeContainer) {
    removeSelectedRow(removeContainer);
    addSelectedRow(container);
}

// Remove all selected row and set one by id
function setSelectedRowById(container, removeContainer) {
    setTimeout(function () {
        removeSelectedRow(removeContainer);
        addSelectedRow('#' + container);
    }, 50);
}

// Simple table custon function
function simpletable_onCustomPageChange() {
    ajaxWait(true);
    return true;
}

function simpletable_onCustomOrderChange(e, url) {
    ajaxWait(true);
    document.location = url;
    return false;
}

// OLD MAP
function showPreviewMapBySession(layer, session_id, lang, tollerance) {
    var time = new Date().getTime();
    $('#map_preview').remove();  // remove the old map
    var html = '<img src="edit.php?on=map_preview&act=generate' +
            '&layer=' + layer +
            '&session_id=' + session_id +
            '&lang=' + lang +
            '&tollerance=' + tollerance + '&time=' + time + '" id="map_preview" class="map_preview" />';
    $('#map_container').append(html);
}

// NEW MAP
function updatePreviewMap(url) {
    var time = new Date().getTime();
    url = url + (url.indexOf(url, '?') < 0 ? '?' : '&') + 'time=' + time;
    $('#previewMap').attr('src', url);
}


function storeFeatureToTemporaryTable(geoLayer, geoData, callback) {
    $.post('edit.php',
            {
                on: 'gisclient',
                method: 'storeFeatureToTemporaryTable',
                layer: geoLayer,
                data: geoData
            },
            callback,
            'json');
}

/**
 * Setup a select with extra data option
 */
function fillSelectWithExtradata(selectElement, data) {
    selectElement.emptySelect();
    $.each(data, function (dummy, element) {
        $.each(element, function (value, name) {
            if (name.has_extradata == 'T') {
                selectElement.append($("<option></option>").attr("value", value).text(name.name).addClass('has_extradata'));
            } else {
                selectElement.append($("<option></option>").attr("value", value).text(name.name));
            }
        });
    });
}

/**
 * Update a dom width from calss (min_width_100 has a min width of 100px)
 */
function applyMinWidth() {
    $('[class^="min_width_"]').each(function (index) {
        var minWidth = this.className.match(/min_width_(\d+)/)[1];
        if ($(this).width() < minWidth) {
            $(this).width(parseInt(minWidth));
        }
    });
}

/**
 * Update menù and title
 */
function updateMenu(on) {
    if (typeof on == "undefined") {
        on = $('#on').val();
    }
    if (parent && parent.$ && parent.$('#application_title')) {
        var applicationTitle = parent.$('#application_title').html();
        if (applicationTitle == null) {
            applicationTitle = $('title').html();
        }
        var pageTitle = $('#page_title').text();
        if (pageTitle == null) {
            parent.document.title = applicationTitle;
        } else {
            parent.document.title = applicationTitle + ' - ' + pageTitle;
        }
        if (typeof on != "undefined") {
            if (parent.$('#' + on + '_list').length > 0) {
                parent.R3MenuSetActiveById(on + '_list');
            } else {
                parent.R3MenuSetActiveById(on);
            }
        }
    }
}

$(document).ready(function () {
    ajaxWait(false);
    updateMenu();

    if (!$.ui.dialog.prototype._makeDraggableBase) {
        $.ui.dialog.prototype._makeDraggableBase = $.ui.dialog.prototype._makeDraggable;
        $.ui.dialog.prototype._makeDraggable = function () {
            this._makeDraggableBase();
            this.uiDialog.draggable("option", "containment", false);
        };
    }
});
