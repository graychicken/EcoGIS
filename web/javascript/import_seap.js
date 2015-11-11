function submitFormDataDoneImportSeap(id) {
    modObject(id);
}

function delImportSeap(doc_id, callback) {
    ajaxWait(true);
    $.getJSON('edit.php', {
        'on': 'import_seap',
        'id': doc_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        callback();
    });
}