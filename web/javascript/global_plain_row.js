function updateGlobalAction(selectSelecter, gcSelector) {
    var theSelect = $(selectSelecter);
    theSelect.prop('disabled', true);
    ajaxWait(true);
    $.getJSON('edit.php',
            {
                on: 'global_plain_row',
                gc_id: $(gcSelector).val(),
                method: 'getGlobalAction'
            },
            function (response) {
                if (isAjaxResponseOk(response)) {
                    fillSelectWithExtradata(theSelect, response.data);
                    theSelect.prop('disabled', $(selectSelecter + ' option').length <= 1);
                    ajaxWait(false);
                }
            });
}

function submitFormDataGlobalPlainRow(selector) {
    submitData(selector);
}