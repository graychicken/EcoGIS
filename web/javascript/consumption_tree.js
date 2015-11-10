var meterWindowWidth = 560;
var meterWindowHeight = 260;

var deviceWindowWidth = 680;
var deviceWindowHeight = 280;

var consumptionWindowWidth = 920;
var consumptioWindowInsertHeight = 400;
var consumptioWindowHeight = 190;

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function addMeter(bu_id, kind) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=meter&act=add&kind=' + kind + '&bu_id=' + bu_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtAddMeter, meterWindowWidth, meterWindowHeight, {'target': target});
    removeSelectedRow();
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function showMeter(em_id, kind) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=meter&act=show&kind=' + kind + '&id=' + em_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtShowMeter, meterWindowWidth, meterWindowHeight, {'target': target});
    setSelectedRowById('COUNTER_' + em_id);
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function modMeter(em_id, kind) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=meter&act=mod&kind=' + kind + '&id=' + em_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtModMeter, meterWindowWidth, meterWindowHeight, {'target': target});
    setSelectedRowById('COUNTER_' + em_id);
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function delMeter(em_id, kind) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': 'meter',
        'kind': kind,
        'id': em_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        target.reloadTab()
    });
    ajaxWait(false);
}

/**
 * Ask for a meter deletion (contatore)
 */
function askDelMeter(em_id, kind) {
    setSelectedRowById('COUNTER_' + em_id);
    ajaxWait(true);
    ajaxConfirm('edit.php', {'on': 'meter',
        'kind': kind,
        'id': em_id,
        'method': 'confirmDeleteMeter'}, function () {
        delMeter(em_id, kind);
    });

}


/**
 * Show the message to prevent the meter deletion
 */
function delMeterMessage(em_id) {
    setSelectedRowById('COUNTER_' + em_id);
    alert(txtCantDeleteMeter);
}


/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function addDevice(em_id, kind) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=device&act=add&kind=' + kind + '&em_id=' + em_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtAddDevice, deviceWindowWidth, deviceWindowHeight, {'target': target});
    removeSelectedRow();
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function showDevice(dev_id, kind) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=device&act=show&kind=' + kind + '&id=' + dev_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtShowDevice, deviceWindowWidth, deviceWindowHeight, {'target': target});
    setSelectedRowById('DEVICE_' + dev_id);
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function modDevice(dev_id, kind) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=device&act=mod&kind=' + kind + '&id=' + dev_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtModDevice, deviceWindowWidth, deviceWindowHeight, {'target': target});
    setSelectedRowById('DEVICE_' + dev_id);
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function delDevice(dev_id, kind) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': 'device',
        'kind': kind,
        'id': dev_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        target.reloadTab()
    });
}

/**
 * Ask for a meter deletion (contatore)
 */
function askDelDevice(dev_id, kind) {
    setSelectedRowById('DEVICE_' + dev_id);
    ajaxConfirm('edit.php', {'on': 'device',
        'kind': kind,
        'id': dev_id,
        'method': 'confirm_delete_device'}, function () {
        delDevice(dev_id, kind);
    });
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function addConsumptionFromTree(em_id, kind, isProduction) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    var caption = isProduction == true ? txtAddConsumption : txtAddConsumption;
    openR3Dialog('edit.php?on=consumption&act=add&kind=' + kind + '&em_id=' + em_id + '&tab_mode=' + $('#tab_tab_mode').val(), caption, consumptionWindowWidth, consumptioWindowInsertHeight, {'target': target});
    removeSelectedRow();
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function showConsumptionFromTree(co_id, kind, isProduction) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    var caption = isProduction == true ? txtAddConsumption : txtAddConsumption;
    openR3Dialog('edit.php?on=consumption&act=show&kind=' + kind + '&id=' + co_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtShowConsumption, consumptionWindowWidth, consumptioWindowHeight, {'target': target});
    setSelectedRowById('CONSUMPTION_' + co_id);
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function modConsumptionFromTree(co_id, kind, isProduction) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    var caption = isProduction == true ? txtAddConsumption : txtAddConsumption;
    openR3Dialog('edit.php?on=consumption&act=mod&kind=' + kind + '&id=' + co_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtModConsumption, consumptionWindowWidth, consumptioWindowHeight, {'target': target});
    setSelectedRowById('CONSUMPTION_' + co_id);
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function delConsumptionFromTree(co_id, kind) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': 'consumption',
        'kind': kind,
        'id': co_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        target.reloadTab()
    });
}

/**
 * Ask for a meter deletion (contatore)
 */
function askDelConsumptionFromTree(co_id, kind) {
    setSelectedRowById('CONSUMPTION_' + co_id);
    ajaxConfirm('edit.php', {'on': 'consumption',
        'kind': kind,
        'id': co_id,
        'method': 'confirm_delete_consumption'}, function () {
        delConsumptionFromTree(co_id, kind);
    });
}

