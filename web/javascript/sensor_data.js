/**
 * Prepare the url to get data
 */
function prepareGraphURL(method) {
    var url = 'edit.php?';
    var now = new Date();

    var params = {'on': 'sensor_data',
        'method': method,
        'bu_id': $('#tab_bu_id').val(),
        'sd_start_date': $('#tab_sd_start_date').val(),
        'time': now.getTime()};
    var sensorId = $('#tab_sd_sensor_id');
    if (sensorId.length > 0) {
        $.extend(params, {'sd_sensor_id': sensorId.val()});
    }
    var kindId = $('#tab_sd_kind');
    if (kindId.length > 0) {
        $.extend(params, {'sd_kind': kindId.val()});
    }
    if (typeof params == 'object') {
        jQuery.each(params, function (i, val) {
            url = url + i + '=' + escape(val) + '&';
        });
    }
    return url;
}

/**
 * Load the specified graph image
 */
function loadGraphImage() {
    disableButton(true);
    $('#graph_spinner').toggle(true);
    $('#graph').attr('src', prepareGraphURL('get_graph_image'));
}

/**
 * Export the data
 */
function exportData() {
    disableButton(true);
    document.location = prepareGraphURL('download_graph_data');
    setTimeout("exportDataDone()", 2000);
}

function exportDataDone() {
    disableButton(false);
}

$(document).ready(function () {
    $('#graph').bind('load', function () {
        $('#graph_spinner').toggle(false);
        disableButton(false);
    });
});