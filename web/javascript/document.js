var documentWindowWidth = 650;
var documentWindowHeight = 360;

if (!popupAlreadyOpen) {
    var popupAlreadyOpen = 'Popup already open';
}

/**
 * Download a document
 */
function downloadDocument(doc_file_id, on) {
    if (typeof on == 'undefined') {
        on = 'document';
    }
    document.location = 'edit.php?on=' + on + '&act=open&file_id=' + doc_file_id + '&disposition=download';
}

/**
 * open a document
 */
function openDocument(doc_file_id) {
    hWin = OpenWindowResizable('edit.php?on=document&act=open&file_id=' + doc_file_id, 'DOCUMENT_SHOW', 1920, 1200);
    if (!hWin) {
        alert(popupAlreadyOpen);
    }
}

/**
 * Add a new document (contatore)
 * param integer bu_id     the building id
 */
function addDocument(type, doc_object_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=document&act=add&type=' + type + '&doc_object_id=' + doc_object_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtAddDocument, documentWindowWidth, documentWindowHeight, {'target': target});
}

/**
 * Add a new document (contatore)
 * param integer bu_id     the building id
 */
function showDocument(doc_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=document&act=show&id=' + doc_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtShowDocument, documentWindowWidth, documentWindowHeight, {'target': target});
}

/**
 * Add a new document (contatore)
 * param integer bu_id     the building id
 */
function modDocument(doc_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? 'parent' : null;
    openR3Dialog('edit.php?on=document&act=mod&id=' + doc_id + '&tab_mode=' + $('#tab_tab_mode').val(), txtModDocument, documentWindowWidth, documentWindowHeight, {'target': target});
}

/**
 * Add a new document (contatore)
 * param integer bu_id     the building id
 */
function delDocument(doc_id) {
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : self;  // Self nel caso di tab ajax
    $.getJSON('edit.php', {'on': 'document',
        'id': doc_id,
        'act': 'del',
        'type': $('#tab_type').val(),
        'method': 'submitFormData'}, function (response) {
        target.reloadTab()
    });
}

/**
 * Ask for a document deletion (contatore)
 */
function askDelDocument(doc_id) {
    ajaxConfirm('edit.php', {'on': 'document',
        'id': doc_id,
        'type': $('#tab_type').val(),
        'method': 'confirm_delete_document'}, function () {
        delDocument(doc_id);
    });

}

/**
 * Submit form data
 */
function submitFormDataDocument(selector) {
    if (typeof selector == 'undefined') {
        selector = '#popup_modform';
    }
    $('#progressbar_wrapper').show();
    submitData(selector, {start_timer: false});
}
function submitDataErrorCustom(response) {
    $('#progressbar_wrapper').hide();
    return submitDataError(response);
}
/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneDocument(id) {
    hideR3Help();
    reloadTab(undefined, undefined, undefined, {'last_id': id});
    closeR3Dialog();
    ajaxWait(false);
    disableButton(false);
}

/**
 * Submit form data
 */
function submitFormDataDocumentVirusError() {
    openR3Help('building', 'document', 'virus');
    ajaxWait(false);
    $('#progressbar_wrapper').hide();
    alert(txtUploadVirus);
    disableButton(false);
}
