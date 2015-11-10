function showGlobalResult(id) {
    OpenWindowResizable('edit.php?on=global_result&act=show&toggle_subcategory=F&parent_act=show&id=' + id, 'GLOBAL_RESULT', 1024, 768);
}
function showGlobalStrategy() {
    var id = $('#gst_id').val();
    OpenWindowResizable('edit.php?on=global_strategy&act=show&parent_act=show&id=' + id, 'GLOBAL_STRATEGY', 1024, 768);
}
/**
 * Refresh the tab summary
 */
function refreshSummary() {
    ajaxWait(true);
    var id_list = '';
    var perc_list = '';
    $('[name="ac_id[]"]').each(function (index) {
        if ($(this).prop("checked")) {
            var id = $(this).attr('id').substr(6);
            id_list += $(this).val() + ',';
            perc_list += $('#ac_perc_' + id).val() + ',';
        }
    });
    $.getJSON('edit.php', {
        'method': 'getSummaryTable',
        'on': $('#on').val(),
        'ac_id_list': id_list,
        'ac_perc_list': perc_list,
        'ss_type': $('#ss_type').val(),
        'ss_table': $('#ss_table').val(),
        'ss_category': $('#ss_category').val()
    },
            function (response) {
                if (isAjaxResponseOk(response)) {
                    $('#summary-table').html(response.html);
                }
                ajaxWait(false);
            });
}

function submitFormDataSimulation(generatePaes) {
    if (generatePaes == true) {
        if (!confirm(txtAskGeneratePaes)) {
            return;
        }
        $('input[name=generate_paes]').val('T');
    }
    var id_list = '';
    var perc_list = '';
    $('[name="ac_id[]"]').each(function (index) {
        if ($(this).prop("checked")) {
            var id = $(this).attr('id').substr(6);
            id_list += $(this).val() + ',';
            perc_list += $('#ac_perc_' + id).val() + ',';
        }
    });
    $('#ac_id_list').val(id_list);
    $('#ac_perc_list').val(perc_list);
    submitData('#modform', {timeout: 60000});
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneSimulation(id, gp_id) {
    if ($('#act').val() == 'add') {
        ajaxWait(true);
        disableButton(true);
        document.location = 'edit.php?on=' + $('#on').val() + '&id=' + id + '&act=mod&select_done=T';
    } else {
        if (gp_id > 0) {
            if (confirm(txtAskGotoPaes)) {
                modObject(gp_id, 'global_plain');
            } else {
                listObject($('#on').val());
            }
        } else {
            listObject($('#on').val());
        }
    }
}
/**
 * Add a new work (contatore)
 * param integer bu_id     the building id
 */
function delSimulation(sw_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {
        'on': $('#on').val(),
        'id': sw_id,
        'act': 'del',
        'method': 'submitFormData'
    }, function (response) {
        listObject();
    });
}

/**
 * Ask for a work deletion (contatore)
 */
function askDelSimulation(sw_id) {
    ajaxConfirm('edit.php', {
        'on': $('#on').val(),
        'id': sw_id,
        'method': 'askDelSimulation'
    }, function () {
        delSimulation(sw_id);
    });
}

// Not used
function refreshGlobalStrategy() {
    ajaxWait(true);
    $('#gst_id').loadSelectData('edit.php',
            {
                on: 'simulation',
                mu_id: $('#mu_id').val(),
                method: 'getGlobalStrategy'
            }, function (response) {
        ajaxWait(false);
        if (isAjaxResponseOk(response)) {
            $('#gst_id').prop('disabled', false); // Force (hidden) select to be enabled
            var tot = 0;
            $.each(response.data, function (n) {
                tot++;
            });
            $('#gst_id_row').toggle(tot > 1);
            $('#btnSave').prop('disabled', tot == 0);
            if ($('#mu_id').val() != '' && tot == 0) {
                alert(txtNoGlobalParametersDefined);
            }
        }
    });
}

/**
 * Show the compare-simulation-dialog
 */
function compareSimulation() {
    ajaxWait(true);
    openR3Dialog('edit.php?on=simulation&method=getCompareTableForm', txtCompareTable, 1000, 600, {
        resizable: true
    });
}

/**
 * Load the compare-simulation-table
 */
function getCompareSimulationTable() {
    ajaxWait(true);
    $.getJSON('edit.php', {
        'method': 'getCompareTable',
        'on': $('#on').val(),
        'pr_id': $('#popup_pr_id option').length > 1 ? $('#popup_pr_id').val() : 0,
        'mu_id': $('#popup_mu_id option').length > 1 ? $('#popup_mu_id').val() : 0,
        'ss_type': $('#ss_type').val(),
        'ss_category': $('#ss_category').val()
    },
            function (response) {
                if (isAjaxResponseOk(response)) {
                    $('#compare-table').html(response.data);
                }
                ajaxWait(false);
            });
}

function showActionOnMap() {
    showObjectOnMap($('#map_on').val() + ':' + $('#ac_object_id').val(), 'action_catalog');
}

function checkSubActionMapLink() {
    ajaxWait(true);
    $.getJSON('edit.php', {
        'method': 'checkSubActionMapLink',
        'on': $('#on').val(),
        'mu_id': $('#mu_id').val(),
        'gc_id': $('#gc_id').val(),
        'ac_object_id': $('#ac_object_id').val()
    },
            function (response) {
                if (isAjaxResponseOk(response)) {
                    $('#action_on_map_link').toggle(response.data.has_geomatry);
                    $('#map_on').val(response.data.emo_code);
                }
                ajaxWait(false);
            });


}

function checkEfe() {
    if ($('#sw_efe_is_calculated').prop('checked')) {
        $('#sw_efe').addClass('readonly');
        $('#sw_efe').prop('readonly', true);
        getEfe();
    } else {
        $('#sw_efe').removeClass('readonly');
        $('#sw_efe').removeProp('readonly');
    }
}

function getEfe() {
    $.getJSON('edit.php', {
        'method': 'getEFE',
        'on': $('#on').val(),
        'id': $('#id').val()
    },
            function (response) {
                if (isAjaxResponseOk(response)) {
                    $('#sw_efe').val(response.data);
                }
                ajaxWait(false);
            });
}
    