var changeFilterTimer = null;

/**
 * Submit form data
 */
function submitFormDataUtility() {
    ajaxWait(true);
    // Unselect items & convert multiple select into CSV data
    $('#mu_selected option:selected').removeAttr("selected");
    $('#mu_list option:selected').removeAttr("selected");
    var muVals = '';
    jQuery.each($('#mu_selected option'), function (i, val) {
        muVals += val.value + ',';
    });
    $('#municipality').val(muVals);
    submitData('#modform', false);
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataUtilityDone(id, cantDelete) {
    if (cantDelete == 'T') {
        alert(txtCantDeleteProduct);
    }
    listObject();
}

function askDelUtility(us_id) {
    ajaxConfirm('edit.php', {'on': 'utility',
        'id': us_id,
        'method': 'askDelUtility'}, function () {
        delUtility(us_id);
    });

}

function delUtility(us_id) {
    ajaxWait(true);
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': 'utility',
        'id': us_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        isAjaxResponseOk(response);
        listObject()
    });
}

