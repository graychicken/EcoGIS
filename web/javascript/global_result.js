function submitFormDataGlobalResult() {
    submitData('#modform');
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneGlobalResult(id) {
    if ($('#act').val() == 'add') {
        ajaxWait(true);
        modObject(id);
    } else {
        listObject($('#on').val());
    }
}

/**
 * Add a new work (contatore)
 * param integer bu_id     the building id
 */
function delGlobalResult(ge_id) {
    $.getJSON('edit.php', {'on': $('#on').val(),
        'id': ge_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        listObject()
    });
}

/**
 * Ask for a work deletion (contatore)
 */
function askDelGlobalResult(ge_id) {
    ajaxConfirm('edit.php', {'on': $('#on').val(),
        'id': ge_id,
        'method': 'askDelGlobalResult'}, function () {
        delGlobalResult(ge_id);
    });
}

function importGlobalResult() {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=global_result_import&act=import&', txtImportGlobalResult, 600, 300, {'target': target});
}

function reloadAllGlobalResultTabs(exclude) {
    var ge_id = $('#ge_id').val();
    var act = $('#act').val();
    var d = new Date();
    var tabs = ['consumption', 'emission', 'energy_production', 'heath_production'];
    $.each(tabs, function (dummy, name) {
        if (typeof exclude == 'undefined' || name != exclude) {
            $('#tabs iframe#' + name + '_src')[0].contentWindow.location = '../images/ajax_loader.gif';
        }
    });
    setTimeout(function () {
        $.each(tabs, function (dummy, name) {
            if (typeof exclude == 'undefined' || name != exclude) {
                var url = 'edit.php?on=global_result_table&kind=' + name + '&ge_id=' + ge_id + '&parent_act=' + act + '&t=' + d.getTime();
                $('#tabs iframe#' + name + '_src')[0].contentWindow.location = url;
            }
        });
    }, 250);
}