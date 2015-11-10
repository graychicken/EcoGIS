/**
 * Submit form data
 */
function submitFormDataEnergySourceUDM() {
    submitData('#modform');
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataEnergySourceUDMDone(id, changed) {
    if (changed == 1) {
        alert(txtChangeMade);
    }
    listObject($('#on').val(), true);
}

function updateEnergySourceFromESU() {
    $.loadMultiSelect('edit.php', {'method': 'fetchUDM',
        'on': $('#on').val(),
        'es_id': $('#es_id').val()
    }, updateEnergySourceFromESUDone);
}

function updateEnergySourceFromESUDone(response) {
    $('#esu_kwh_factor').val(response.data.esu_kwh_factor);
    $('#udm_id_selected').val(response.data.udm_id_selected);
    $('#esu_co2_factor').val(response.data.esu_co2_factor);
    $('#esu_tep_factor').val(response.data.esu_tep_factor);
    $('#esu_is_consumption').prop('checked', response.data.esu_is_consumption == 'T');
    $('#esu_is_production').prop('checked', response.data.esu_is_production == 'T');
    $('#ges_name').val(response.data.ges_name);
}


function delESU(esu_id) {
    $.getJSON('edit.php', {'on': $('#on').val(),
        'id': esu_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        listObject()
    });
}

/**
 * Ask for a work deletion (contatore)
 */
function askDelESU(esu_id) {
    ajaxConfirm('edit.php', {'on': $('#on').val(),
        'id': esu_id,
        'type': '',
        'method': 'askDelESU'}, function () {
        delESU(esu_id);
    });
}

/**
 * Ask for a work deletion (contatore)
 */
function askDelMunicipalityESU(esu_id) {
    ajaxConfirm('edit.php', {'on': $('#on').val(),
        'id': esu_id,
        'type': 'MUNICIPALITY',
        'method': 'askDelESU'}, function () {
        delESU(esu_id);
    });
}
