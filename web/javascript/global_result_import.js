function submitFormDataImport() {
    $('#progressbar_wrapper').show();
    submitData('#popup_modform', {start_timer: false});
}

function submitFormDataDoneGlobalResultImport(id) {
    ajaxWait(false);
    closeR3Dialog();
    alert(txtImportDone);
    ajaxWait(true);
    document.location = 'list.php?on=global_result';
}
