function addActionCatalogFromBuilding(bu_id) {
    var width = 850;
    var height = 650;
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=action_catalog&act=add&bu_id=' + bu_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtAddActionCatalog, width, height, {'target': target, 'iframe': true});
}

function showActionCatalog(bu_id, ac_id) {
    return showObject(ac_id);
}

function showActionCatalogFromBuilding(bu_id, ac_id) {
    var width = 850;
    var height = 650;
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=action_catalog&act=show&bu_id=' + bu_id + '&id=' + ac_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtShowActionCatalog, width, height, {'target': target, 'iframe': true});
}


function modActionCatalog(bu_id, ac_id) {
    return modObject(ac_id);
}

function modActionCatalogFromBuilding(bu_id, ac_id) {
    var width = 850;
    var height = 650;
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=action_catalog&act=mod&bu_id=' + bu_id + '&id=' + ac_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtModActionCatalog, width, height, {'target': target, 'iframe': true});
}



function submitFormDataActionCatalog() {
    setDefaultValueForActionCatalog();
    submitData('#modform');
}

function submitFormDataActionCatalogFromBuilding() {
    setDefaultValueForActionCatalog();
    submitData('#modform');
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneActionCatalog(id) {
    listObject($('#on').val());
}

function submitFormDataDoneActionCatalogFromBuilding(id) {
    parent.hideR3Help();
    parent.reloadTab(undefined, undefined, undefined, {'last_id': id});
    parent.closeR3Dialog();
    parent.ajaxWait(false);
    parent.disableButton(false);
}



function delActionCatalog(bu_id, id) {
    ajaxWait(true);
    $.getJSON('edit.php', {
        'on': 'action_catalog',
        'id': id,
        'act': 'del',
        'method': 'submitFormData'
    }, function (response) {
        isAjaxResponseOk(response);
        listObject()
    });
}

function delActionCatalogFromBuilding(bu_id, id) {
    ajaxWait(true);
    $.getJSON('edit.php', {
        'on': 'action_catalog',
        'id': id,
        'act': 'del',
        'method': 'submitFormData'
    }, function (response) {
        isAjaxResponseOk(response);
        parent.reloadTab();
    });
}

function askDelActionCatalog(bu_id, id) {
    ajaxConfirm('edit.php', {
        'on': 'action_catalog',
        'id': id,
        'method': 'askDelActionCatalog'
    }, function () {
        delActionCatalog(bu_id, id);
    });
}

function askDelActionCatalogFromBuilding(bu_id, id) {
    ajaxConfirm('edit.php', {
        'on': 'action_catalog',
        'id': id,
        'method': 'askDelActionCatalog'
    }, function () {
        delActionCatalogFromBuilding(bu_id, id);
    });
}

function updateMainGlobalCategory() {
    var theSelect = $('#gc_id');
    theSelect.prop('disabled', true);
    ajaxWait(true);
    $.getJSON('edit.php',
            {
                on: 'action_catalog',
                parent_id: $('#gc_id_parent').val(),
                method: 'getGlobalCategory'
            },
            function (response) {
                if (isAjaxResponseOk(response)) {
                    fillSelectWithExtradata(theSelect, response.data);
                    theSelect.prop('disabled', $('#gc_id option').length <= 1);
                    ajaxWait(false);
                }
            });
}

function updateSubCategory() {
    ajaxWait(true);
    $('#ac_object_id').loadSelectData('edit.php',
            {
                on: 'action_catalog',
                mu_id: $('#mu_id').val(),
                gc_id: $('#gc_id').val(),
                method: 'getGlobalSubCategory'
            }, function () {
        ajaxWait(false);
    });
}

function sanitarizeGlobalEnergySourceByType(type) {
    if (type == 'CONSUMPTION') {
        return 'consumption';
    } else if (type == 'ENERGY_PRODUCTION') {
        return 'production';
    } else {
        alert('Unknown type "' + type + '"');
        return '';
    }
}

function setValueForBenefitStartDate() {
    if ($('#ac_benefit_start_date').val() == '') {
        $('#ac_benefit_start_date').val($('#ac_end_date').val());
    }
}

function setDefaultValueForActionCatalog() {
    // DD -> TODO: using names!!!!
    $('input[name^=es_id_consumption]').each(function (idx, element) {
        $(element).val($(element).parent().find('select[name^=es_id_consumption_helper]').val());
    });
    $('input[name^=udm_id_consumption]').each(function (idx, element) {
        $(element).val($(element).parent().find('select[name^=udm_id_consumption_helper]').val());
    });
    $('#es_id_production_default').val($('#es_id_production').val());
    $('#udm_id_production_default').val($('#udm_id_production').val());
}

function calculateAutoFinancing() {
    var estimated_cost = locale2float($('#ac_estimated_cost').val());
    var estimated_public_financing = locale2float($('#ac_estimated_public_financing').val());
    var estimated_other_financing = locale2float($('#ac_estimated_other_financing').val());
    $('#ac_estimated_auto_financing').val(float2locale(estimated_cost - estimated_public_financing - estimated_other_financing, 2));

    var effective_cost = locale2float($('#ac_effective_cost').val());
    var effective_public_financing = locale2float($('#ac_effective_public_financing').val());
    var effective_other_financing = locale2float($('#ac_effective_other_financing').val());
    $('#ac_effective_auto_financing').val(float2locale(effective_cost - effective_public_financing - effective_other_financing, 2));
}

/**
 * Update the action name if needed (via ajax, because the 2-language)
 */
function updateActionName(forceChange) {
    ajaxWait(true);
    $.getJSON('edit.php',
            {
                on: 'action_catalog',
                method: 'updateActionName',
                force: forceChange,
                gpa_id: $('#gpa_id').val(),
                gpa_extradata_1: $('#gpa_extradata_1').val(),
                gpa_extradata_2: $('#gpa_extradata_2').val(),
                ac_name_1: $('#ac_name_1').val(),
                ac_name_2: $('#ac_name_2').val(),
                bu_id: $('#bu_id').val()
            },
            function (response) {
                ajaxWait(false);
                if (isAjaxResponseOk(response)) {
                    if (response.data.ac_name_1 != '') {
                        $('#ac_name_1').val(response.data.ac_name_1);
                    }
                    if (response.data.ac_name_2 != '') {
                        $('#ac_name_2').val(response.data.ac_name_2);
                    }
                }
            });
}

function toggleBenefitYear() {
    if ($('#enable_benefit_year').prop('checked')) {
        $('.enable_benefit_year_row').show();
    } else {
        $('.enable_benefit_year_row').hide();
    }
}

function initExpectedEnergySavings() {
    // Remove old events (prevent multiple data conversion)
    $('#tblExpectedEnergySavings input[name^=ac_expected_energy_saving]').unbind('focus').unbind('blur');
    var jqTable = $('#tblExpectedEnergySavings');
    jqTable.delegate('input[name^=ac_expected_energy_saving]', 'focus', function () {
        adjFloatField(this, true);
    }).delegate('input[name^=ac_expected_energy_saving]', 'blur', function () {
        adjFloatField(this, false);
    });

    $('#tblExpectedEnergySavings').delegate('select[name^=ges_id_consumption]', 'change', function () {
        updateEnergySourceForPAES('#modform', this, 'CONSUMPTION');
    });
    $('#tblExpectedEnergySavings').delegate('select[name^=es_id_consumption_helper]', 'change', function () {
        updateEnergyUDMForPAES('#modform', this, 'CONSUMPTION');
    });
    $('#tblExpectedEnergySavings').delegate('select[name^=udm_id_consumption_helper],input[name^=ac_expected_energy_saving]', 'change', function () {
        setTimeout("performPAESEnergySourceCalc('#modform')", 10)
    });  // fast-timer needed
    $('#tblExpectedEnergySavings').delegate('img.btnRemoveExpectedEnergySavings', 'click', function () {
        if (confirm(askDeleteCurrentExpectedEnergySavings)) {
            $(this).parent().parent().remove();
            if ($('#tblExpectedEnergySavings').find('.tplExpectedEnergySavings').length == 0) {
                addExpectedEnergySavings();
            }
            performPAESEnergySourceCalc('#modform');
        }

    });
    $('#btnAddExpectedEnergySavings').click(addExpectedEnergySavings);
}
function addExpectedEnergySavings() {
    $('#tblExpectedEnergySavings').append($('#action_catalog_template_form .tplExpectedEnergySavings').parent().html());
}

function setRelatedSelectStatus() {
    var tot = $('#related_action_template_form .tplRelatedActions select option').length;
    $('select[rel="related_actions"]').prop('disabled', tot < 2);  // 2 is the count of 2x --selezionare--
}

function initRelatedActions() {
    $('#tblRelatedActions').delegate('img.btnRemoveRelatedActions', 'click', function () {
        if (confirm(askDeleteCurrentRelatedActions)) {
            $(this).parent().parent().remove();
            if ($('#tblRelatedActions').find('.tplRelatedActions').length == 0) {
                addRelatedActions();
            }
        }
    });
    $('#btnAddRelatedActions').click(addRelatedActions);
}
function addRelatedActions() {
    $('#tblRelatedActions').append($('#related_action_template_form .tplRelatedActions').parent().html());
}

function initRelatedRequiredActions() {
    $('#tblRelatedRequiredActions').delegate('img.btnRemoveRelatedRequiredActions', 'click', function () {
        if (confirm(askDeleteCurrentRelatedRequiredActions)) {
            $(this).parent().parent().remove();
            if ($('#tblRelatedRequiredActions').find('.tplRelatedRequiredActions').length == 0) {
                addRelatedRequiredActions();
            }
        }
    });
    $('#btnAddRelatedRequiredActions').click(addRelatedRequiredActions);
}
function addRelatedRequiredActions() {
    $('#tblRelatedRequiredActions').append($('#related_required_action_template_form .tplRelatedRequiredActions').parent().html());
}

function initRelatedExcludedActions() {
    $('#tblRelatedExcludedActions').delegate('img.btnRemoveRelatedExcludedActions', 'click', function () {
        if (confirm(askDeleteCurrentExcludedRequiredActions)) {
            $(this).parent().parent().remove();
            if ($('#tblRelatedExcludedActions').find('.tplRelatedExcludedActions').length == 0) {
                addRelatedExcludedActions();
            }
        }
    });
    $('#btnAddRelatedExcludedActions').click(addRelatedExcludedActions);
}
function addRelatedExcludedActions() {
    $('#tblRelatedExcludedActions').append($('#related_excluded_action_template_form .tplRelatedExcludedActions').parent().html());
}

function initBenefitYear() {
    // Remove old events (prevent multiple data conversion)
    $('#tblBenefitYear input[name^=benefit_year]').unbind('focus').unbind('blur');
    $('#tblBenefitYear input[name^=benefit_benefit]').unbind('focus').unbind('blur');

    var jqBenefitYear = $('#tblBenefitYear');
    jqBenefitYear.delegate('input[name^=benefit_year]', 'focus', function () {
        adjYearField(this, true);
    }).delegate('input[name^=benefit_year]', 'blur', function () {
        adjYearField(this, false);
    });
    jqBenefitYear.delegate('input[name^=benefit_benefit]', 'focus', function () {
        adjFloatField(this, true);
    }).delegate('input[name^=benefit_benefit]', 'blur', function () {
        adjFloatField(this, false);
    });

    jqBenefitYear.delegate('img.btnRemoveBenefitYear', 'click', function () {
        if (confirm(askDeleteCurrentBenefitYear)) {
            $(this).parent().parent().remove();
            if ($('#tblBenefitYear').find('.tplBenefitYear').length == 0) {
                addBenefitYear();
            }
        }
    });
    $('#btnAddBenefitYear').click(addBenefitYear);
}
function addBenefitYear() {
    $('#tblBenefitYear').append($('#benefit_year_template_form .tplBenefitYear').parent().html());

}

function updateRelatedActionsList() {
    ajaxWait(true);
    $.ajax({
        url: 'edit.php',
        dataType: 'json',
        data: {
            on: 'action_catalog',
            mu_id: $('#mu_id').val(),
            ac_id: $('#ac_id').val(),
            method: 'getRelatedActionsList'
        },
        type: 'GET',
        success: function (response) {
            ajaxWait(false);
            if (typeof (response) != 'object' || typeof (response.status) == 'undefined' || response.status != 'OK') {
                // ERRORE!
                return;
            }
            var tot = 0;
            var html = '<option value=""> -- Selezionare -- </option>';
            $.each(response.data, function (e, actionContainer) {
                $.each(actionContainer, function (e, action) {
                    html += '<option value="' + action.ac_id + '" label="' + action.name + '">' + action.name + '</option>';
                    tot++;
                });
            });
            $('select[rel="related_actions"]').html(html);
            $('select[rel="related_actions"]').prop('disabled', tot == 0);
        },
        error: function () {
            ajaxWait(false);
        }
    });
}