var globalResultSmallPopupHeight = 100;
var globalResultPopupWidth = 800

function showBuilding(id) {
    OpenWindowResizable('edit.php?on=building&act=show&parent_act=show&id=' + id, 'BUILDING', 1024, 768);
}

function showStreetLighting(id) {
    OpenWindowResizable('edit.php?on=street_lighting&act=show&parent_act=show&id=' + id, 'BUILDING', 1024, 768);
}

function cantEditMessage() {
    alert(txtCantEditManagedObject);
}

/**
 * Add a new meter (contatore)
 * param integer bu_id     the building id
 */
function delGlobalConsumptionRow(gs_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': 'global_consumption_row',
        'id': gs_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        //target.reloadTab()
        target.reloadTab('#tabs', 'consumption');
        target.reloadTab('#tabs', 'emission');
        target.reloadTab('#tabs', 'energy_production');
        target.reloadTab('#tabs', 'heath_production');
    });
    ajaxWait(false);
}

/**
 * Ask for a meter deletion (contatore)
 */
function askDelGlobalConsumptionRow(gs_id) {
    ajaxWait(true);
    ajaxConfirm('edit.php', {'on': 'global_consumption_row',
        'id': gs_id,
        'method': 'confirmDeleteGlobalConsumptionRow'}, function () {
        delGlobalConsumptionRow(gs_id);
    });

}

/**
 * Show a global consumptions row detail
 * param integer bu_id     the building id
 */
function showGlobalConsumptionRow(gs_id, items, small) {
    var height = 160 + (80 * numLanguages) + (small == 'T' ? globalResultSmallPopupHeight : 22 * items);
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=global_consumption_row&act=show&id=' + gs_id + '&kind=' + $('#tab_kind').val() + '&tab_mode=' + $('#tab_tab_mode').val(), txtShowGlobalConsumption, globalResultPopupWidth, height, {'target': target, resizable: true});
}

/**
 * Add a new global consumptions row
 * param integer bu_id     the building id
 */
function addGlobalConsumptionRow(gc_id, items, small) {
    var height = 160 + (80 * numLanguages) + (small == 'T' ? globalResultSmallPopupHeight : 22 * items);
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    var ge_id = $('#tab_ge_id').val();
    openR3Dialog('edit.php?on=global_consumption_row&act=add&ge_id=' + ge_id + '&kind=' + $('#tab_kind').val() + '&gc_id=' + gc_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtAddGlobalConsumption, globalResultPopupWidth, height, {'target': target, resizable: true});
}

/**
 * Edit a global consumptions row
 * param integer bu_id     the building id
 */
function modGlobalConsumptionRow(gs_id, items, small) {
    var height = 160 + (80 * numLanguages) + (small == 'T' ? globalResultSmallPopupHeight : 22 * items);
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=global_consumption_row&act=mod&id=' + gs_id + '&kind=' + $('#tab_kind').val() + '&tab_mode=' + $('#tab_tab_mode').val(), txtModGlobalConsumption, globalResultPopupWidth, height, {'target': target, resizable: true});
}

function submitSubcategoryOpenStatus() {
    var catList = [];
    $('table.emissions tr[data-type=category]').each(function () {
        var cat_id = $(this).attr('data-cat_id');
        if ($('.sub_cat_' + cat_id + ':first').is(":visible")) {
            catList.push(cat_id);
        }
    });

    $.getJSON('edit.php', {'on': 'global_result_table',
        'ge_id': $('#tab_ge_id').val(),
        'kind': $('#tab_kind').val(),
        'open_categories': catList.join(','),
        'method': 'toggleSubcategory'});
}

/**
 * Toggle single subcategory
 */
function toggleSubcategory(element_or_id, open, submitStatus) {
    if (typeof element_or_id == 'object') {
        var id = $(element_or_id).attr('sub_cat_id');
    } else {
        var id = element_or_id;
    }
    $('.sub_cat_' + id).toggle(open);
    $('.sub_cat_' + id + '_closed').toggle(typeof open != 'undefined' ? !open : undefined);
    $('.sub_cat_' + id + '_opened').toggle(open);
    if (submitStatus) {
        submitSubcategoryOpenStatus();
    }
}

function toggleAllSubcategory(open, submitStatus) {
    var i = 0;
    $('#open_all').toggle(!open);
    $('#close_all').toggle(open);

    $('#tab_toggle_subcategory').val(open ? 'T' : 'F');
    $.each($('.toggler'), function (index, e) {
        if (i % 2 == 0) {
            toggleSubcategory(e, open);
        }
        i++;
    });
    if (submitStatus) {
        submitSubcategoryOpenStatus();
    }
    $.getJSON('edit.php', {'on': 'global_result_table',
        'last_openclose_status': open ? 'OPEN' : 'CLOSE',
        'method': 'updateLastOpenCloseStatus'});
}

function applyUdmDivider() {
    ajaxWait(true);
    document.location = 'edit.php?on=global_result_table&kind=' + $('#tab_kind').val() +
            '&ge_id=' + $('#tab_ge_id').val() + '&udm_divider=' + $('#udm_divider').val() +
            '&merge_municipality_data=' + ($('#merge_municipality_data').prop('checked') ? 'T' : 'F') +
            '&toggle_subcategory=' + $('#tab_toggle_subcategory').val() +
            '&parent_act=' + $('#tab_parent_act').val();
}

function showInventoryObjectList(ge_id, gc_id, kind) {
    OpenWindowMaximized('edit.php?on=global_result_object_list&ge_id=' + ge_id + '&gc_id=' + gc_id + '&kind=' + kind, 'INVENTORY_OBJECT_LIST');
}

