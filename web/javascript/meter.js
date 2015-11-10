/**
 * Submit form data
 */
function submitFormDataMeter() {
    $('#popup_modform input[name=up_id]').val($('#popup_modform select[name=up_id_dummy]').val());
    $('#popup_modform input[name=es_id]').val($('#popup_modform select[name=es_id]').val());
    $('#popup_modform input[name=udm_id]').val($('#popup_modform select[name=udm_id]').val());
    submitData('#popup_modform');
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneMeter(id) {
    hideR3Help();
    reloadTab(undefined, undefined, undefined, {'meter_last_id': id, 'device_last_id': '', 'consumption_last_id': ''});
    closeR3Dialog();
    ajaxWait(false);
    disableButton(false);
}

function updateMeterType(init) {
    var isProduction = $('#popup_em_is_production').val() == 'T';
    $('#popup_utility_supplier_row').toggle(!isProduction);
    if (typeof init == 'undefined' || init == false) {
        $('#popup_modform select[name=us_id]').val('');
        updateUtilitySupplier();
        $('#popup_modform select[name=es_id]').loadSelectData('edit.php',
                {on: 'meter',
                    kind: $('#popup_modform input[name=kind]').val(),
                    em_is_production: $('#popup_em_is_production').val(),
                    method: 'getEnergySourceList'}, function () {
            updateEnergySourceFromMeter();
        });
    }
}

function updateEnergySourceFromMeter() {
    var hasESU = $('#popup_es_id').val() != '';
    $('#popup_us_id').prop('disabled', hasESU);
    $('#popup_us_id').prop('disabled', hasESU || $('#popup_modform select[name=us_id] option').length <= 1);
    $('#popup_udm_id').loadSelectData('edit.php',
            {on: 'meter',
                kind: $('#popup_modform input[name=kind]').val(),
                es_id: $('#popup_modform select[name=es_id]').val(),
                bu_id: $('#popup_modform input[name=bu_id]').val(),
                method: 'fetchUDM'});
}

function setUtilityProduct() {
    var hasSupplier = $('#popup_modform select[name=us_id]').val() != '';
    $('#popup_up_id_label_lbl,#popup_up_id_label_cbx').toggle(hasSupplier);
}

function updateUtilitySupplier() {
    var hasSupplier = $('#popup_modform select[name=us_id]').val() != '';
    $('#popup_es_id').prop('disabled', hasSupplier);
    $('#popup_udm_id').prop('disabled', hasSupplier || $('#popup_udm_id option').length <= 1);
    setUtilityProduct();
    $('#popup_up_id').loadSelectData('edit.php',
            {on: 'meter',
                us_id: $('#popup_modform select[name=us_id]').val(),
                kind: $('#popup_modform input[name=kind]').val(),
                method: 'getUtilityProductList'});
    if (hasSupplier) {
        $('#popup_es_id,#popup_udm_id').val('');
    }
}
