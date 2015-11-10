var changeFilterTimer = null;

/**
 * Submit form data
 */
function submitFormDataGlobalResultTableBuilder() {
    ajaxWait(true);
    // Unselect items & convert multiple select into CSV data
    $('#ges_list option:selected').removeAttr("selected");
    $('#gest_list option:selected').removeAttr("selected");
    var gestVals = '';
    jQuery.each($('#gest_list option'), function (i, val) {
        gestVals += val.value + ',';
    });
    $('#global_energy_source_type').val(gestVals);

    var catVals = '';
    jQuery.each($('#gc_selected option'), function (i, val) {
        catVals += val.value + ',';
    });
    $('#global_category').val(catVals);

    submitData('#modform', false);
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneGlobalResultTableBuilder(ids) {
    document.location = 'list.php?on=' + $('#on').val() + '&';
}

/**
 * Ask for a meter deletion (contatore)
 */
function askDelGlobalResultTable(gt_id) {
    ajaxConfirm('edit.php', {'on': $('#on').val(),
        'id': gt_id,
        'method': 'askDelGlobalResultTable'}, function () {
        delGlobalResultTable(gt_id);
    });

}

function delGlobalResultTable(gt_id) {
    ajaxWait(true);
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': $('#on').val(),
        'id': gt_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        isAjaxResponseOk(response);
        listObject()
    });
}

