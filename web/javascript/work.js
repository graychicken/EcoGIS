/**
 * Add a new work
 * param integer bu_id     the building id
 */
function addWork(bu_id) {
    var height = 600 + (30 * numLanguages);
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=work&act=add&bu_id=' + bu_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtAddWork, 800, height, {'target': target});
}

/**
 * Add a new work (contatore)
 * param integer bu_id     the building id
 */
function showWork(wo_id) {
    var height = 600 + (30 * numLanguages);
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=work&act=show&id=' + wo_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtShowWork, 800, height, {'target': target});
}

/**
 * Add a new work (contatore)
 * param integer bu_id     the building id
 */
function modWork(wo_id) {
    var height = 600 + (30 * numLanguages);
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=work&act=mod&id=' + wo_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtModWork, 800, height, {'target': target});
}

/**
 * Add a new work (contatore)
 * param integer bu_id     the building id
 */
function delWork(wo_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': 'work',
        'id': wo_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        target.reloadTab()
    });
}

/**
 * Ask for a work deletion (contatore)
 */
function askDelWork(wo_id) {
    ajaxConfirm('edit.php', {'on': 'work',
        'id': wo_id,
        'method': 'confirm_delete_work'}, function () {
        delWork(wo_id);
    });
}


/**
 * Submit form data
 */
function submitFormDataWork() {
    submitData('#popup_modform');
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneWork(id) {
    hideR3Help();
    reloadTab(undefined, undefined, undefined, {'last_id': id});
    closeR3Dialog();
    ajaxWait(false);
    disableButton(false);
}

/**
 * Work type onChange event
 * param boolean init     True if the function is called to init the form
 */
function workTypeChange(init) {
    updateForExtraData('#wt_id', '#wt_extradata');
    var message = $('#wt_id option:selected').attr('message');
    var save_primary = $('#wt_id option:selected').attr('save_primary') == 'T';
    var save_electricity = $('#wt_id option:selected').attr('save_electricity') == 'T';

    $('#wt_text').toggle(message != '');
    $('#wt_text').html(message);
    disableControl('#wo_primary_energy', !save_primary);
    disableControl('#esu_id_primary', !save_primary);
    disableControl('#es_id_primary', !save_primary);
    disableControl('#wo_electricity', !save_electricity);
}

/**
 * Work type onChange event
 * param boolean init     True if the function is called to init the form
 */
function primaryEnergySourceChange(init) {
    var udm = $('#esu_id_primary option:selected').attr('udm');
    var energyUdm = typeof udm == 'undefined' ? '' : euroSymbol + '/' + udm;
    $('#wo_primary_energy_price_udm').val(energyUdm);
    if (!init) {
        performCalc();
    }
}
function electricityEnergySourceChange(init) {
    var udm = $('#esu_id_electricity option:selected').attr('udm');
    var energyUdm = typeof udm == 'undefined' ? '' : euroSymbol + '/' + udm;
    $('#wo_electricity_energy_price_udm').val(energyUdm);
    if (!init) {
        performCalc();
    }
}

function getWorkEnergyClassLimit() {
    $('#ecl_id_work').prop('disabled', true);
    if ($('#ec_id_work').val() == '') {
        $('#ecl_id_work').emptySelect();
    } else {
        refreshSelect('#ecl_id_work', 'edit.php', {'method': 'getWorkEnergyClassLimit',
            'on': 'work',
            'ec_id': $('#ec_id_work').val()});
    }
}

/**
 * Send the calc request to the server
 * param boolean init     True if the function is called to init the form
 */
function performCalc(init) {

    clearAjaxTimer();
    startAjaxTimer();
    ajaxWait(true);
    $('#popup_modform').ajaxSubmit({url: 'edit.php?method=performCalc', 'type': 'get', dataType: 'json',
        success: function (response) {
            clearAjaxTimer();
            if (isAjaxResponseOk(response)) {
                $.each(response.data, function (id, val) {
                    $('#' + id).val(val);
                });
            }
            ajaxWait(false);
        }});
}

/**
 * Toggle the detail data of a building
 */
function toggleWorkTable(tableId, img1, img2) {
    $('#' + tableId).toggle();
    $('#' + img1).toggle();
    $('#' + img2).toggle();
}