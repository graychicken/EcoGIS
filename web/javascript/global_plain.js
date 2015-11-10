/**
 * Add a new work (contatore)
 * param integer bu_id     the building id
 */
function delGlobalPlain(gp_id) {
    $.getJSON('edit.php', {'on': $('#on').val(),
        'id': gp_id,
        'act': 'del',
        'method': 'submitFormData'},
            function (response) {
                if (isAjaxResponseOk(response)) {
                    listObject();
                }
            });
}

/**
 * Ask for a work deletion (contatore)
 */
function askDelGlobalPlain(gp_id) {
    ajaxConfirm('edit.php', {'on': $('#on').val(),
        'id': gp_id,
        'method': 'askDelGlobalPlain'}, function () {
        delGlobalPlain(gp_id);
    });
}

function submitFormDataGlobalPlain() {
    submitData('#modform');
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneGlobalPlain(id) {
    listObject($('#on').val());
}
