/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function addConsumption(sl_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=consumption&act=add&sl_id=' + sl_id + '&kind=street_lighting&tab_mode=' + $('#tab_tab_mode').val(), txtAddConsumption, 920, 150, {'target': target});
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function showConsumption(co_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=consumption&act=show&kind=street_lighting&id=' + co_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtShowConsumption, 920, 150, {'target': target});
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function modConsumption(co_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=consumption&act=mod&kind=street_lighting&id=' + co_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtModConsumption, 920, 150, {'target': target});
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function delConsumption(id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': 'consumption',
        'kind': 'street_lighting',
        'id': id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        target.reloadTab()
    });
}

/**
 * Ask for a meter deletion (contatore)
 */
function askDelConsumption(co_id) {
    ajaxConfirm('edit.php', {'on': 'consumption',
        'kind': 'street_lighting',
        'id': co_id,
        'method': 'confirm_delete_consumption'}, function () {
        delConsumption(co_id);
    });
}

