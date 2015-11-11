var globalPlainGaugeWindowWidth = 560;
var globalPlainGaugeWindowHeight = 250;

function addGlobalPlainGauge(gpr_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=global_plain_gauge&act=add&gpr_id=' + gpr_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtAddGlobalPlainGauge, globalPlainGaugeWindowWidth, globalPlainGaugeWindowHeight, {'target': target});
    removeSelectedRow();
}

function showGlobalPlainGauge(gpg_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=global_plain_gauge&act=show&id=' + gpg_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtShowGlobalPlainGauge, globalPlainGaugeWindowWidth, globalPlainGaugeWindowHeight, {'target': target});
    setSelectedRowById('GLOBAL_PLAIN_GAUGE_' + gpg_id);
}

function modGlobalPlainGauge(gpg_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=global_plain_gauge&act=mod&id=' + gpg_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtShowGlobalPlainGauge, globalPlainGaugeWindowWidth, globalPlainGaugeWindowHeight, {'target': target});
    setSelectedRowById('GLOBAL_PLAIN_GAUGE_' + gpg_id);
}


function delGlobalPlainGauge(gpg_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': 'global_plain_gauge',
        'id': gpg_id,
        'act': 'del',
        'method': 'submitFormData'}, function(response) {
        target.reloadTab();
        if (parent && typeof parent.tabContentChanged == 'function') {
            parent.tabContentChanged('global_plain_gauge', gpg_id);
        }
    });
}

function askDelGlobalPlainGauge(gpg_id) {
    setSelectedRowById('GLOBAL_PLAIN_GAUGE_' + gpg_id);
    ajaxConfirm('edit.php', {'on': 'global_plain_gauge',
        'id': gpg_id,
        'method': 'askDelGlobalPlainGauge'}, function() {
        delGlobalPlainGauge(gpg_id);
    });
}

function submitFormDataGlobalPlainGauge() {
    submitData('#popup_modform');
}


function submitFormDataDoneGlobalPlainGauge(id) {
    hideR3Help();
    reloadTab(undefined, undefined, undefined, {'last_id': id});
    closeR3Dialog();
    ajaxWait(false);
    disableButton(false);
    if (typeof tabContentChanged == 'function') {
        tabContentChanged('global_plain_gauge', id);
    }
}