/**
 * Submit form data
 */
function submitFormDataDevice() {
    submitData('#popup_modform');
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneDevice(id) {
    reloadTab(undefined, undefined, undefined, {'meter_last_id': '', 'device_last_id': id, 'consumption_last_id': ''});
    closeR3Dialog();
    ajaxWait(false);
    disableButton(false);
}
