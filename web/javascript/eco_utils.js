var hGCAuthor = null;
var hGClient = null;
var gisClientURL = 'gisclient.php?';

/**
 * Toggle the detail data of a building
 */
function toggleTable(tableId, img1, img2) {
    $('#' + tableId).toggle();
    $('#' + img1).toggle();
    $('#' + img2).toggle();
    resizeTabHeight();
}

function initChangeRecord() {
    $('table.change_record tr.openclose_evidence').live('click', function () {
        $(this).find('img').toggle();
        $(this).parent().find('.openclose_evidence_row').toggle();
        resizeTabHeight();
    });
}

function addStreetDlg() {
    var url = 'edit.php?on=building_fr_st_cm&act=add&kind=street&mode=dialog&';
    if ($('#mu_id').length > 0) {
        var url = url + 'mu_id=' + $('#mu_id').val() + '&';
    }
    if ($('#mu_name').length > 0) {
        var url = url + 'mu_name=' + $('#mu_name').val() + '&';
    }
    openR3Dialog(url, txtNewStreet, 500, 120);
}

function addStreetDlgDone(id) {
    closeR3Dialog();
    refreshSelect('#st_id', 'edit.php', {
        'method': 'getStreetList',
        'on': $('#on').val(),
        'mu_id': $('#mu_id').val()
    }, id, function () {
        disableButton(false);
        ajaxWait(false);
    });
}

function updateMapButtonStatus() {
    $('#btnMap').prop('disabled', !($('#mu_id').val() > 0));
}

function moveMunicipality(src, dest, all) {
    if (all) {
        $(src + ' option').remove().appendTo(dest);
    } else {
        $(src + ' option:selected').remove().appendTo(dest);
    }
}

function setupTableColumn(module) {
    if (typeof module == "undefined") {
        module = $('#on').val();
    }
    var url = 'edit.php?on=setup_table_column&act=mod&module=' + module;
    openR3Dialog(url, '', 500, 300);
}

function updateEnergySourceForActionCatalog(container, select_ges_id, gesType) {
    ajaxWait(true);
    var suffix = sanitarizeGlobalEnergySourceByType(gesType);

    var select_es_id = $(select_ges_id).parent().find('select[name^=es_id_' + suffix + '_helper]');
    $(select_es_id).loadSelectData('edit.php',
            {
                on: $(container + ' input[name="on"]').val(),
                ges_id: $(select_ges_id).val(),
                type: gesType,
                method: 'getEnergySource'
            }, function (result) {
        updateEnergyUDMForActionCatalog(container, select_es_id, gesType);
    });
}

function updateEnergyUDMForActionCatalog(container, select_es_id, gesType) {
    ajaxWait(true);
    var suffix = sanitarizeGlobalEnergySourceByType(gesType);

    var select_ges_id = $(select_es_id).parent().find('select[name^=ges_id_' + suffix + ']');
    var select_udm_id = $(select_es_id).parent().find('select[name^=udm_id_' + suffix + '_helper]');

    $(select_udm_id).loadSelectData('edit.php',
            {
                on: $(container + ' input[name="on"]').val(),
                ges_id: $(select_ges_id).val(),
                es_id: $(select_es_id).val(),
                type: gesType,
                method: 'getEnergyUDM'
            }, function () {
        $(select_udm_id).find('option:contains(MWh)').attr('selected', 'selected');  // Select by udm (MWh next)
        performPAESEnergySourceCalc(container)
    });
}

/** PAES FUNCTIONS */
function updateEnergySourceForPAES(container, select_ges_id, gesType) {
    ajaxWait(true);
    var suffix = 'consumption';  // Fix Inventory production

    var select_es_id = $(select_ges_id).parent().find('select[name^=es_id_' + suffix + '_helper]');
    $(select_es_id).loadSelectData('edit.php',
            {
                on: $(container + ' input[name="on"]').val(),
                ges_id: $(select_ges_id).val(),
                type: gesType,
                method: 'getEnergySource'
            }, function (result) {
        updateEnergyUDMForPAES(container, select_es_id, gesType);
    });
}

function updateEnergyUDMForPAES(container, select_es_id, gesType) {
    ajaxWait(true);
    var suffix = 'consumption';  // Fix Inventory production
    var select_ges_id = $(select_es_id).parent().find('select[name^=ges_id_' + suffix + ']');
    var select_udm_id = $(select_es_id).parent().find('select[name^=udm_id_' + suffix + '_helper]');

    $(select_udm_id).loadSelectData('edit.php',
            {
                on: $(container + ' input[name="on"]').val(),
                ges_id: $(select_ges_id).val(),
                es_id: $(select_es_id).val(),
                type: gesType,
                method: 'getEnergyUDM'
            }, function () {
        $(select_udm_id).find('option:contains(MWh)').attr('selected', 'selected');  // Select by udm (MWh next)
        performPAESEnergySourceCalc(container)
    });
}

function performPAESEnergySourceCalc(container) {
    clearAjaxTimer();
    startAjaxTimer();
    ajaxWait(true);
    setDefaultValueForActionCatalog();
    $(container).ajaxSubmit({
        url: 'edit.php?method=performActionCatalogCalc',
        'type': 'get',
        dataType: 'json',
        success: function (response) {
            clearAjaxTimer();
            if (isAjaxResponseOk(response)) {
                $.each(response.data, function (id, val) {
                    if ($.isArray(val)) {
                        $.each(val, function (idx, val2) {
                            $($(container + ' input[name^=' + id + ']')[idx]).val(val2);
                        })
                    } else {
                        $(container + ' #' + id).val(val);
                    }
                });
            }
            ajaxWait(false);
        }
    });
}

// get cookie/html5 storage
function getPersistentValue(key) {
    return null;
}

function setPersistentValue(key, value) {

}

// open GisClient Authon in a new tab
function openGCAuthor(url) {

    name = 'GCAuthor';
    try {
        hGCAuthor.close();
    } catch (e) {
    } finally {
        hGCAuthor = window.open(url, name); //, features);
    }
    if (hGCAuthor == null) {
        alert(PopupErrorMsg);
    } else {
        hGCAuthor.focus();
    }
}

// open GisClient Authon in a new tab
function openGisClient(url) {
    var width = Math.min(window.screen.availWidth, UserMapWidth);
    var height = Math.min(window.screen.availHeight, UserMapHeight);
    var l = Math.max(0, ((window.screen.availWidth - width) * 0.5));
    var t = Math.max(0, ((window.screen.availHeight - height) * 0.5));

    var features = 'width=' + width + ',' +
            'height=' + height + ',' +
            'scrollbars=no,' +
            'toolbar=no,' +
            'resizable=yes,' +
            'location=no,' +
            'menubar=no,' +
            'status=no,' +
            'top=' + t + ',' +
            'left=' + l;


    gcTarget = 'GisClient';
    try {
        if (hGClient != null) {
            hGClient.close();
        }
    } catch (e) {
    } finally {
        hGClient = window.open(url, gcTarget, features);
    }
    if (hGClient == null) {
        alert(PopupErrorMsg);
    } else {
        hGClient.focus();
    }
}
 