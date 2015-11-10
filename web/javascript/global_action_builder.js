//var changeFilterTimer=null;

/**
 * Submit form data
 */
function submitFormDataGlobalActionBuilder() {
    ajaxWait(true);
    // Unselect items & convert multiple select into CSV data
    $('#gpa_id_selected option:selected').removeAttr("selected");
    $('#gpa_id_available option:selected').removeAttr("selected");
    var gestVals = '';
    jQuery.each($('#gpa_id_selected option'), function (i, val) {
        gestVals += val.value + ',';
    });
    $('#gpa_id_list').val(gestVals);
    submitData('#modform', false);
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneGlobalActionBuilder(ids) {
    listObject();
}
