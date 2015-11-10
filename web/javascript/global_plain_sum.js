/**
 * Submit form data
 */
function submitFormDataGlobalPlainSum() {
    submitData('#popup_modform');
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneGlobalPlainSum(id, kind) {
    ajaxWait(false);
    hideR3Help();
    reloadTab();
    closeR3Dialog();
    disableButton(false);
}



