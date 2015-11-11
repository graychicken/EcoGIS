function submitFormDataStatType() {
    submitData('#modform');
}
function submitFormDataDoneStatType(id) {
    listObject($('#on').val());
}

function attachClassTablesRowEvents() {

    var $row = $('table.legend').find('a.delete_row');
    $row.unbind('click');
    $row.bind('click', function (event) {
        event.preventDefault();
        $(this).closest('tr').remove();
    });
    /*$('table.legend').find('a.delete_row').click(function(event) {
     event.preventDefault();
     $(this).closest('tr').remove();
     });*/
}

function initClassTables(type) {
    $('table.legend').find('tr.template').hide();  // Hide table template
    $('table.legend').find('th').not('.' + type).hide();  // Hide specific columns
    $('table.legend').find('td').not('.' + type).hide();  // Hide specific columns

    $('table.legend').find('a.add_row').click(function (event) {
        event.preventDefault();
        var $template = $(this).closest('tr').parent().find('.template').clone().removeClass('template').show();
        var lastOrder = 0;
        $(this).closest('table').find('input[name^=stc_order]').each(function (dummy, e) {
            lastOrder = Math.max(lastOrder, $(e).val());
        });
        $template.find('input[name^=stc_order]').val(lastOrder + 10);
        $(this).closest('table').find('tr:last').after($template);
        // attach event
        attachClassTablesRowEvents();
    });
    attachClassTablesRowEvents();
}

function generateClassTables(tableType, jsonData) {
    var $table = $('table.' + tableType + '_class');
    $table.find('tr').not(':first').not('.template').remove();  // Hide table template

    $.each(jsonData, function (dummy, row) {
        var $template = $table.find('.template').clone().removeClass('template').show();
        $.each(row, function (key, val) {
            $template.find('input[name^=' + key + ']').val(val);
        });

        $table.find('tr:last').after($template);
    });
    attachClassTablesRowEvents();

}