function modGlobalPlainSum(gc_id, gp_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=global_plain_sum&act=mod&gc_id=' + gc_id + '&gp_id=' + gp_id + '&kind=' + $('#tab_kind').val() + '&tab_mode=' + $('#tab_tab_mode').val(), txtModGlobalPlainSum, 520, 200, {'target': target, resizable: true});
}

function addGlobalPlainRow(gc_id, gp_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=global_plain_row&act=add&gc_id=' + gc_id + '&gp_id=' + gp_id + '&kind=' + $('#tab_kind').val() + '&tab_mode=' + $('#tab_tab_mode').val(), txtAddGlobalPlainRow, 750, 520, {'target': target, resizable: true});
}

function modGlobalPlainRow(gc_id, gp_id, gpr_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=global_plain_row&act=mod&gc_id=' + gc_id + '&gp_id=' + gp_id + '&gpr_id=' + gpr_id + '&kind=' + $('#tab_kind').val() + '&tab_mode=' + $('#tab_tab_mode').val(), txtModGlobalPlainRow, 750, 520, {'target': target, resizable: true});
}

function delGlobalPlainSum(gc_id, gp_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': 'global_plain_sum',
        'gc_id': gc_id,
        'gp_id': gp_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        target.reloadTab()
    });
}
function askDelGlobalPlainSum(gc_id, gp_id) {
    ajaxConfirm('edit.php', {'on': 'global_plain_sum',
        'gc_id': gc_id,
        'gp_id': gp_id,
        'method': 'askDelGlobalPlainSum'}, function () {
        delGlobalPlainSum(gc_id, gp_id);
    });
}
function delGlobalPlainRow(gpr_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': 'global_plain_row',
        'id': gpr_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        target.reloadTab()
    });
}
function askDelGlobalPlainRow(gpr_id) {
    ajaxConfirm('edit.php', {'on': 'global_plain_row',
        'id': gpr_id,
        'method': 'askDelGlobalPlainRow'}, function () {
        delGlobalPlainRow(gpr_id);
    });
}
