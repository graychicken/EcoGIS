/**
 * Enable/disable Load Fraction, street, Catastal munic. data
 */
function loadGE_GS() {
    jQuery('#ge_id,#ge_id_2,#gp_id').prop('disabled', true);
    $.loadMultiSelect('edit.php', {
        'method': 'loadGE_GS',
        'on': $('#on').val(),
        'mu_id': $('#mu_id').val(),
        'mu_name': $('#mu_name').val()
    }, loadGE_GSDone);
}

function loadGE_GSDone(response) {
    $('#mu_id').val(response.data.mu_id_selected);
    $('#ge_id').prop('disabled', $('#ge_id option').length <= 1);
    $('#ge_id_2').prop('disabled', $('#ge_id_2 option').length <= 1);
    $('#gp_id').prop('disabled', $('#gp_id option').length <= 1);
    if (response.data.info_text == '') {
        $('#info_container').hide();
    } else {
        $('#info_container').html(response.data.info_text);
        $('#info_container').show();
    }

}

/**
 * Add a new work (contatore)
 * param integer bu_id     the building id
 */
function delGlobalStrategy(gst_id) {
    $.getJSON('edit.php', {
        'on': $('#on').val(),
        'id': gst_id,
        'act': 'del',
        'method': 'submitFormData'
    }, function (response) {
        listObject()
    });
}

/**
 * Ask for a work deletion (contatore)
 */
function askDelGlobalStrategy(gst_id) {
    ajaxConfirm('edit.php', {
        'on': $('#on').val(),
        'id': gst_id,
        'method': 'askDelGlobalStrategy'
    }, function () {
        delGlobalStrategy(gst_id);
    });
}

function submitFormDataGlobalStrategy() {
    submitData('#modform');
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneGlobalStrategy(id) {
    if ($('#export_paes').val() == 'T') {
        $('#export_paes').val('F');
        exportPAES($('#id').val(), $('#paes_format').val());
    } else {
        if ($('#stay_to_edit').val() == 'T') {
            ajaxWait(false);
            alert(txtSaveDone);
            disableButton(false);
        } else {
            listObject($('#on').val());
        }
    }
}

function btnCancelClick() {
    if ($('#stay_to_edit').val() == 'T') {
        modObject();
    } else {
        listObject();
    }
}

function exportPAESDlg(id, save) {
    openR3Dialog('edit.php?on=global_strategy&method=exportPAESDlg&id=' + id + '&save=' + save, txtExportPAES, 500, 200);
}

var exportToken = null;
var exportDoneUrl = null;

function showExportPAESStatus() {
    $('#progressbar_container').show();
    $.getJSON('edit.php', {
        'on': $('#on').val(),
        'token': exportToken,
        'method': 'getExportPAESStatus'
    }, function (response) {
        var repeat = true;
        if (response.data) {
            $("#progressbar").progressbar({
                value: response.data.progress
            });
            $('#progress_status').html(response.data.text);
            repeat = !response.data.done;
        }
        if (repeat) {
            setTimeout('showExportPAESStatus()', 250);
        } else {
            closeR3Dialog();
            disableButton(false);
            $('#progress_status').html('');
            document.location = exportDoneUrl;
        }
    });
}

function exportPAES(id, driver) {
    exportToken = null;
    exportDoneUrl = null;
    if ($('#export_paes').val() == 'T') {
        // Save data
        submitData('#modform');
    } else {
        // Export file
        disableButton(true);
        ajaxWait(true);
        $.getJSON('edit.php', {
            'on': $('#on').val(),
            'id': id,
            'driver': driver,
            'method': 'exportPAES'
        }, function (response) {
            validateDomainDone(response);
            ajaxWait(false);
            if (response.status == 'OK') {
                exportToken = response.token;
                exportDoneUrl = response.url;
                showExportPAESStatus();
            }
        });
    }
}
