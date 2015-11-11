function submitFormDataMunicipalityCollection() {
    ajaxWait(true);
    // Unselect items & convert multiple select into CSV data
    $('#mu_selected option:selected').removeAttr("selected");
    $('#mu_list option:selected').removeAttr("selected");
    var muVals = '';
    jQuery.each($('#mu_selected option'), function(i, val) {
        muVals += val.value + ',';
    });
    $('#municipality').val(muVals);
    submitData('#modform');
}

function submitFormDataDoneMunicipalityCollection(ids) {
    listObject($('#on').val());
}

function loadAvailableMunicipalityForCollection() {
    ajaxWait(true);
    $.getJSON('edit.php', {'on': 'municipality_collection',
        'do_id_collection': $('#do_id_collection').val(),
        'mu_name': $('#mu_name').val(),
        'method': 'getAvailableMunicipalityForCollection'}, function(response) {
        loadAvailableMunicipalityForCollectionDone(response);
    });
}

function loadAvailableMunicipalityForCollectionDone(response) {
    if (isAjaxResponseOk(response)) {
        $('#mu_list').emptySelect().loadSelect(response.data);
    }
    ajaxWait(false);
}

function askDelMunicipalityCollection(mu_id) {
    ajaxConfirm('edit.php', {'on': 'municipality_collection',
        'id': mu_id,
        'method': 'confirmDeleteMunicipalityCollection'}, function() {
        delMunicipalityCollection(mu_id);
    });

}

function delMunicipalityCollection(mu_id) {
    ajaxWait(true);
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': 'municipality_collection',
        'id': mu_id,
        'act': 'del',
        'method': 'submitFormData'}, function(response) {
        isAjaxResponseOk(response);
        listObject();
    });
}

