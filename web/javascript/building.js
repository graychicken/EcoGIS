/**
 * Enable/disable Load Fraction, street, Catastal munic. data
 */
function disableFR_ST_CMButton(disabled) {
    jQuery('#fr_id,#st_id,#cm_id').prop('disabled', disabled);
    jQuery('#btnAddFraction,#btnAddStreet,#btnAddCatMunic').prop('disabled', disabled);
}

/**
 * Enable/disable Load Fraction, street, Catastal munic. data
 */
function checkFR_ST_CM() {
    var fr_disabled = $('select#fr_id option').length <= 1;
    var st_disabled = $('select#st_id option').length <= 1;
    var cm_disabled = $('select#cm_id option').length <= 1;
    jQuery('select#fr_id').prop('disabled', fr_disabled).prop('readonly', fr_disabled);
    jQuery('select#st_id').prop('disabled', st_disabled).prop('readonly', st_disabled);
    jQuery('select#cm_id').prop('disabled', cm_disabled).prop('readonly', cm_disabled);
}

/**
 * Load Fraction, street, Catastal munic. data
 */
function loadFR_ST_CM() {
    disableFR_ST_CMButton(true);
    $('#btnMap').prop('disabled', true);
    $.loadMultiSelect('edit.php', {
        'method': 'fetch_fr_st_cm',
        'on': $('#on').val(),
        'mu_id': $('#mu_id').val(),
        'mu_name': $('#mu_name').val()
    }, loadFR_ST_CMDone);
}

function loadFR_ST_CMDone(response) {
    $('#mu_id').val(response.data.mu_id_selected);
    if (response.data.mu_id_selected > 0) {
        disableFR_ST_CMButton(false);
        checkFR_ST_CM();
        $('#btnMap').prop('disabled', !($('#mu_id').val() > 0));
    }
}

/**
 * Open a dialog to add a new fraction
 */
function addFractionDlg() {
    openR3Dialog('edit.php?on=building_fr_st_cm&act=add&kind=fraction&mode=dialog&mu_id=' + $('#mu_id').val(), txtNewFraction, 500, 120);
}
function addFractionDlgDone(id) {
    closeR3Dialog();
    refreshSelect('#fr_id', 'edit.php', {
        'method': 'fetch_fraction',
        'on': $('#on').val(),
        'mu_id': $('#mu_id').val()
    }, id, function () {
        disableButton(false)
    });
}

function addCatMunicDlg() {
    openR3Dialog('edit.php?on=building_fr_st_cm&act=add&kind=catmunic&mode=dialog&&mu_id=' + $('#mu_id').val(), txtNewCatMunic, 500, 120);
}
function addCatMunicDlgDone(id) {
    closeR3Dialog();
    refreshSelect('#cm_id', 'edit.php', {
        'method': 'fetch_catmunic',
        'on': $('#on').val(),
        'mu_id': $('#mu_id').val()
    }, id, function () {
        disableButton(false)
    });
}

function getEnergyClassLimit() {
    $('#ecl_id').prop('disabled', true);
    if ($('#ez_id').val() == '' || $('#ec_id').val() == '') {
        $('#ecl_id').emptySelect();
    } else {
        refreshSelect('#ecl_id', 'edit.php', {
            'method': 'fetch_eneryClassLimit',
            'on': $('#on').val(),
            'ez_id': $('#ez_id').val(),
            'ec_id': $('#ec_id').val()
        });
    }
}

function min2Str(min) {
    if (min < 0)
        return '';
    var h = Math.floor(min / 60);
    if (h < 10)
        h = '0' + h;
    var m = min % 60;
    if (m < 10)
        m = '0' + m;
    return h + ':' + m;
}

function calcUsageMinutes(sFrom, sTo) {
    if (sFrom == '' || sTo == '') {
        return -1;
    } else {
        sFrom = sFrom.replace('.', ':').split(':');
        sTo = sTo.replace('.', ':').split(':');
        var dFrom = new Date(1970, 1, 1, sFrom[0], sFrom[1]);
        var dTo = new Date(1970, 1, 1, sTo[0], sTo[1]);
        var min = (dTo.getTime() - dFrom.getTime()) / 1000 / 60;
        if (isNaN(min) || min < 0) {
            return -1;
        }
        return min;
    }
}

function calcUsageHours() {
    var min = calcUsageMinutes($('#bu_usage_h_from').val(), $('#bu_usage_h_to').val());
    $('#bu_daily_use_h').val(min2Str(min));
}

function calcUsageYears() {
    var min = parseInt(calcUsageMinutes($('#bu_usage_h_from').val(), $('#bu_usage_h_to').val()));
    var days = parseInt($('#bu_usage_days').val());
    var weeks = parseInt($('#bu_usage_weeks').val());
    if (min >= 0 && days >= 1 && weeks >= 1 && weeks <= 52) {
        $('#bu_hour_year_use').val(min2Str(weeks * days * min));
    } else {
        $('#bu_hour_year_use').val('');
    }
}


/**
 * Add a new work (contatore)
 * param integer bu_id     the building id
 */
function delBuilding(bu_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {
        'on': $('#on').val(),
        'id': bu_id,
        'act': 'del',
        'method': 'submitFormData'
    }, function (response) {
        listObject()
    });
}

/**
 * Ask for a work deletion (contatore)
 */
function askDelBuilding(bu_id) {
    ajaxConfirm('edit.php', {
        'on': $('#on').val(),
        'id': bu_id,
        'method': 'askDelBuilding'
    }, function () {
        delBuilding(bu_id);
    });
}

function submitFormDataBuilding() {
    if ($('.upload_photo').val() != '') {
        $('#progressbar_wrapper_photo').show();
    }
    if ($('.upload_label').val() != '') {
        $('#progressbar_wrapper_label').show();
    }
    if ($('.upload_thermo').val() != '') {
        $('#progressbar_wrapper_thermo').show();
    }
    submitData('#modform', {
        start_timer: false
    });
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneBuilding(id) {
    if ($('#act').val() == 'add') {
        ajaxWait(true);
        modObject(id);
    } else {
        listObject($('#on').val());
    }
}

/**
 * Show the photo
 */
function openPhoto(doc_file_id) {
    hWin = OpenWindowResizable('edit.php?on=photo&act=open&file_id=' + doc_file_id + '&', 'PHOTO_SHOW', 1920, 1200);
    if (!hWin) {
        alert(popupAlreadyOpen);
    }
}

function initializePhotos() {
    $('.graph_spinner').each(function (i, e) {
        //var id = $(e).attr('img_id');
        //var kind = $(e).attr('img_kind');
        var id_kind = $(e).attr('id').split('_');
        var kind = id_kind[0];
        var id = id_kind[1];
        //alert(id_kind + ' - ' + id + ' - ' + kind);
        var html = '<img src="edit.php?on=photo&act=open&file_id=' + id + '&type=building&kind=' + kind + '&preview" id="image_' + id + '" class="photo clickable_image" />';
        $(e).parent().append(html).bind('click', function () {
            openPhoto(id)
        })
                .ready(function () {
                    $(e).hide()
                });
    });
}

function openBuildingMap(isGisClient) {
    var params = 'layer=building&' +
            'act=' + $('#act').val() + '&' +
            'geometryStatus=' + $('#geometryStatus').val() + '&' +
            'zoom_type=zoomextent&';
    if ($('#id').val() > 0 && $('#has_geometry').val()) {
        params += 'mapoper_zoom=building&' +
                'mapoper_id=' + $('#id').val() + '&';
    } else {
        // Mixed zoom oper look for zoom on street, fraction, municipality
        params += 'mapoper_zoom=mixed&';
        if ($('#mu_id').val() > 0) {
            params += 'mu_id=' + $('#mu_id').val() + '&';
        }
        if ($('#fr_id').val() > 0) {
            params += 'fr_id=' + $('#fr_id').val() + '&';
        }
        if ($('#st_id').val() > 0) {
            params += 'st_id=' + $('#st_id').val() + '&';
        }
        if ($('#bu_id').val() > 0) {
            params += 'bu_id=' + $('#bu_id').val() + '&';
        }
        params += 'mapoper_id=&';
    }
    params += 'ecogis_digitize=T&';

    if (isGisClient) {
        var url = gisClientURL;
        url = url + (url.indexOf('?') < 0 ? '?' : '&') + params;
        openGisClient(url);
    } else {
        GenericOpenMap('edit_layer&' + params);
    }
}

// Generic list
var exportBuildingToken = null;
var exportBuildingFormat = null;
var exportBuildingDoneUrl = null;
function showExportBuildingStatus() {
    $.getJSON('edit.php', {
        'on': $('#on').val(),
        'token': exportBuildingToken,
        'format': exportBuildingFormat,
        'method': 'getExportBuildingStatus'
    }, function (response) {
        var repeat = true;
        if (response.data) {
            repeat = !response.data.done;
        }
        if (repeat) {
            setTimeout('showExportBuildingStatus()', 1000);
        } else {
            closeR3Dialog();
            $('#exportform').find('input,select').prop('disabled', false);
            document.location = exportBuildingDoneUrl;
        }
    });
}

function exportBuildings() {
    exportBuildingToken = null;
    exportBuildingFormat = null;
    exportBuildingDoneUrl = null;
    ajaxWait(true);
    $('#exportform').find('input,select').prop('disabled', true);
    
    var filter = {};
    $.each( $('fieldset.filter').find('input,select'), function(dummy, e) {
        var key = e.name;
        var val = $(e).val();
        if (e.type == 'submit' || e.type == 'button') {
            return;
        }
        if (e.type == 'checkbox') {
            if (e.checked) {
                filter[key] = val;
            }
        } else {
            filter[key] = val;
        }
    });
    
    $.getJSON('edit.php', {
            'on': $('#on').val(),
            'format': $('#exportform select[name=format]').val(),
            'method': 'exportBuilding',
            'filter': filter
        }, function (response) {
            validateDomainDone(response);
            if (response.status == 'OK') {
                exportBuildingToken = response.token;
                exportBuildingFormat = response.format;
                exportBuildingDoneUrl = response.url;
                showExportBuildingStatus();
            }
        });
}