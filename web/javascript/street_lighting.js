
function changeMunicipality(newStreetId) {
    updateMapButtonStatus();
    if ($('#st_name').length > 0) {
        $('#st_name').val('');
        $('#st_name').prop('disabled', $('#mu_id').val() == '' && $('#mu_name').val() == '');
        autocomplete("#st_name", {
            url: 'edit.php',
            on: 'street_lighting',
            method: 'getStreetList',
            mu_id: $('#mu_id').val(),
            mu_name: $('#mu_name').val(),
            autocomplete: 'T',
            limit: 20,
            minLength: 2
        });
    } else {
        // Street: select
        ajaxWait(true);
        $('#st_id').loadSelectData('edit.php',
                {
                    on: 'street_lighting',
                    mu_id: $('#mu_id').val(),
                    mu_name: $('#mu_name').val(),
                    method: 'getStreetList'
                }, function () {
            $('#btnAddStreet').prop('disabled', false);
            ajaxWait(false);
            if (typeof newStreetId != 'undefined')
                $('#st_id').val(newStreetId);
        });
    }
}

function delStreetLighting(id) {
    ajaxWait(true);
    $.getJSON('edit.php', {
        'on': 'street_lighting',
        'id': id,
        'act': 'del',
        'method': 'submitFormData'
    }, function (response) {
        isAjaxResponseOk(response);
        listObject()
    });
}

function askDelStreetLighting(id) {
    ajaxConfirm('edit.php', {
        'on': 'street_lighting',
        'id': id,
        'method': 'confirmDeleteStreetLighting'
    }, function () {
        delStreetLighting(id);
    });
}

/**
 * Submit form data
 */
function submitFormDataStreetLighting() {
    submitData('#modform');
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneStreetLighting(id) {
    if ($('#act').val() == 'add') {
        ajaxWait(true);
        modObject(id);
    } else {
        listObject($('#on').val());
    }
}


function openStreetLightingMap(isGisClient) {

    var params = 'layer=street_lighting&' +
            'act=' + $('#act').val() + '&' +
            'geometryStatus=' + $('#geometryStatus').val() + '&' +
            'zoom_type=zoomextent&';
    if ($('#id').val() > 0) {
        params += 'mapoper_zoom=street_lighting&' +
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
        if ($('#sl_id').val() > 0) {
            params += 'sl_id=' + $('#sl_id').val() + '&';
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


function updateStreetLength(useTempGeometry) {
    useTempGeometry = useTempGeometry != true ? 'F' : 'T';
    $.getJSON('edit.php', {
        'on': $('#on').val(),
        'id': $('#id').val(),
        'useTempGeometry': useTempGeometry,
        'method': 'getStreetLength'
    }, function (response) {
        if (isAjaxResponseOk(response)) {
            if ($('#sl_length').val() == '' ||
                    confirm(askReplaceLength)) {
                $('#sl_length').val(response.length);
                adjFloatField('#sl_length', false);
            }
        }
    });

}


