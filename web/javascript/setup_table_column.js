var txtResetToDefault = '';

function submitFormDataSetupTableColumn() {
    var ord = [];

    $('#table_form tr').each(function (index, e) {
        ord.push(e.id.substr(4));
    });
    $('#fields_position').val(ord.join(','));
    submitData('#popup_modform');
}

function submitFormDataDoneSetupTableColumn() {
    listObject();
}


function resetSetupTableColumnEdit() {
    if (confirm(txtResetToDefault)) {
        disableButton(true);
        ajaxWait(true);
        $.getJSON('edit.php', {
            'on': popup_on,
            'module': $('#module').val(),
            'method': 'resetTableColumnToDefault'
        },
                function (response) {
                    listObject();
                });
    }
}

function moveSetupTableRowToDown(e) {
    var tr1 = $(e).parents('tr');
    var tr2 = tr1.next();
    $('#' + tr1.attr('id')).before($('#' + tr2.attr('id')));
    $('#table_form tr').css('border', '0px').css('background-color', '#ffffff');
    $('#' + tr1.attr('id')).css('border', '1px dashed #cccccc').css('background-color', '#efefef');
    updateMoveSetupTableArrowsVisibility();
}

function moveSetupTableRowToUp(e) {
    var tr1 = $(e).parents('tr');
    var tr2 = tr1.prev();
    $('#' + tr1.attr('id')).after($('#' + tr2.attr('id')));
    $('#table_form tr').css('border', '0px').css('background-color', '#ffffff');
    $('#' + tr1.attr('id')).css('border', '1px dashed #cccccc').css('background-color', '#efefef');
    updateMoveSetupTableArrowsVisibility();
}

function updateMoveSetupTableArrowsVisibility() {
    // Show all the button
    $('#table_form .moveup,#table_form .movedown').css('visibility', '');
    // Hide 1st arrow up and last arrow down
    $('#table_form tr').first().find('td .moveup').css('visibility', 'hidden');
    $('#table_form tr').last().find('td .movedown').css('visibility', 'hidden');
}