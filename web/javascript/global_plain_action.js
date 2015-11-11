function updateMainGlobalCategoryFromGlobalPlainAction() {
    var gcSelect = $('#gc_id');
    var gpaSelect = $('#gpa_id');

    if ($('#gc_id_parent').val() == '') {
        gcSelect.find('option').not(':first').remove();
        gcSelect.prop('disabled', true);
        $('#gc_extradata').hide();

        gpaSelect.find('option').not(':first').remove();
        gpaSelect.prop('disabled', true);
        $('#gpa_extradata').hide();

        return;
    }

    gcSelect.prop('disabled', true);
    ajaxWait(true);
    $.getJSON('edit.php',
            {
                on: 'action_catalog',
                parent_id: $('#gc_id_parent').val(),
                method: 'getGlobalCategory'
            },
            function (response) {
                if (isAjaxResponseOk(response)) {
                    fillSelectWithExtradata(gcSelect, response.data);
                    gcSelect.prop('disabled', $('#gc_id option').length <= 1);
                    ajaxWait(false);
                }
            });
}

function delGlobalPlainRowFromGauge(gpr_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': 'global_plain_row',
        'id': gpr_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        listObject();
    });
}
function askDelGlobalPlainRowFromGauge(gpr_id) {
    ajaxConfirm('edit.php', {'on': 'global_plain_row',
        'id': gpr_id,
        'method': 'askDelGlobalPlainRow'}, function () {
        delGlobalPlainRowFromGauge(gpr_id);
    });
}
