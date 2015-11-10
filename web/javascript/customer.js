var changeFilterTimer = null;

function askVacuum() {
    if (confirm('Questa operazione durerà pareccho tempo. Procedere?')) {
        $('input[name=btnVacuum]').prop('disabled', true);
        $.getJSON('edit.php', {'on': 'customer', 'method': 'vacuum'}, function (response) {
            $('input[name=btnVacuum]').prop('disabled', false);
        });
    }
}

function generateGrid() {
    var do_id = $('#do_id').val();
    var size = $('#do_grid_size').val();
    if (size > 0) {
        if (confirm("Questa operazione durerà pareccho tempo, non potrà essere interrotta e sostituirà un eventuale griglia precedente.\n" +
                "Il salvataggio sarà disabilitato fino a completamento dell'operazione.\n" +
                "Procedere?")) {
            $('input[type=button]').prop('disabled', true);
            $.getJSON('edit.php', {'on': 'customer', 'method': 'create_grid', 'do_id': do_id, 'sg_size': size}, function (response) {
                $('input[type=button]').prop('disabled', false);
            });
        }
    } else {
        if (confirm('Sei sicuro di voler eliminare la griglia per questo dominio?')) {
            $('input[type=button]').prop('disabled', true);
            $.getJSON('edit.php', {'on': 'customer', 'method': 'create_grid', 'do_id': do_id, 'sg_size': 0}, function (response) {
                $('input[type=button]').prop('disabled', false);
            });
        }
    }
}


/**
 * Submit form data
 */
function submitFormDataCustomer() {
    ajaxWait(true);
    // Unselect items & convert multiple select into CSV data
    $('#mu_selected option:selected').removeAttr("selected");
    $('#mu_list option:selected').removeAttr("selected");
    var muVals = '';
    jQuery.each($('#mu_selected option'), function (i, val) {
        muVals += val.value + ',';
    });
    $('#municipality').val(muVals);
    if ($('#skip_geometry_check').prop('checked')) {
        // Submit with no timer
        submitData('#modform', {start_timer: false});  // Long timeout...
    } else {
        // Submit with (long) timer
        submitData('#modform', {start_timer: false});  // Long timeout...
    }
    setTimeout('disableButton(false);', 30000);
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneCustomer(ids) {
    document.location = 'list.php?on=' + $('#on').val() + '&';
}

/**
 * Validate the domain name
 */
function validateDomain(isAlias) {
    $.getJSON('edit.php', {'on': 'customer',
        'dn_name': $('#dn_name').val(),
        'dn_name_alias': $('#dn_name_alias').val(),
        'is_alias': isAlias,
        'method': 'validateDomain'}, function (response) {
        validateDomainDone(response)
    });
}

function validateDomainDone(response) {
    if (!isAjaxResponseOk(response))
        return false;
    $('#dn_name').val(response.dn_name);

    if (typeof response.dn_name_alias == 'string')
        $('#dn_name_alias').val(response.dn_name_alias);
    if (typeof response.cus_name_1 == 'string')
        $('#cus_name_1').val(response.cus_name_1);
    if (typeof response.cus_name_2 == 'string')
        $('#cus_name_2').val(response.cus_name_2);
    if (typeof response.do_database_login == 'string')
        $('#do_database_login').val(response.do_database_login);
    if (typeof response.do_database_password == 'string')
        $('#do_database_password').val(response.do_database_password);
    if (typeof response.us_name == 'string')
        $('#us_name').val(response.us_name);
    if (typeof response.us_login == 'string')
        $('#us_login').val(response.us_login);
    if (typeof response.us_password == 'string')
        $('#us_password').val(response.us_password);
    if (typeof response.do_schema == 'string')
        $('#do_schema').val(response.do_schema);
    if (typeof response.dn_name_lower == 'string')
        $('#us_login_domain').val(response.dn_name_lower);
    if (typeof response.do_gc_mapset == 'string')
        $('#do_gc_mapset').val(response.do_gc_mapset);
    if (typeof response.do_gc_project == 'string')
        $('#do_gc_project').val(response.do_gc_project);
}

function changeSRID() {
    $.getJSON('edit.php', {'on': 'customer',
        'cus_srid': $('#cus_srid').val(),
        'method': 'getSRIDDesc'}, function (response) {
        changeSRIDDone(response)
    });
    if ($('#act').val() == 'mod') {
        alert(txtChangeSRIDWarning);
    }
}

function changeSRIDDone(response) {
    if (!isAjaxResponseOk(response))
        return false;
    $('#cus_srid_text').val(response.text);
}

function changeProvinceFilterTimer(timeout) {
    if (changeFilterTimer)
        clearTimeout(changeFilterTimer);
    changeFilterTimer = setTimeout("changeProvinceFilter()", timeout);
}

function changeProvinceFilter() {
    ajaxWait(true);
    $.getJSON('edit.php', {'on': 'customer',
        'pr_id': $('#pr_id').val(),
        'mu_name': $('#mu_name').val(),
        'method': 'getMunicipality'}, function (response) {
        changeProvinceFilterDone(response)
    });
}

function changeProvinceFilterDone(response) {
    if (isAjaxResponseOk(response)) {
        $('#mu_list').emptySelect().loadSelect(response.data);
    }
    ajaxWait(false);
}

/**
 * Ask for a meter deletion (contatore)
 */
function askDelCustomer(do_id) {
    ajaxConfirm('edit.php', {'on': 'customer',
        'id': do_id,
        'method': 'confirmDeleteCustomer'}, function () {
        delCustomer(do_id);
    });

}

function delCustomer(do_id) {
    ajaxWait(true);
    var target = $('#tab_tab_mode').val() == 'iframe' ? parent : document;
    $.getJSON('edit.php', {'on': 'customer',
        'id': do_id,
        'act': 'del',
        'method': 'submitFormData'}, function (response) {
        isAjaxResponseOk(response);
        listObject()
    });
}
