$(document).ready(function () {
    if ($('.simpletable').length == 0)
        return false;

    /* Table Header */
    var header = $('.simpletable').find('.header.sortable');
    $(header).bind('click', function () {
        var simpletable = $(this).parents("table.simpletable");

        // get order name
        var tableId = $(simpletable).attr('id');

        // get value
        var order = $(simpletable).find('.header').index(this) + 1;
        if ($(this).hasClass('status-desc'))
            order += "D";
        else
            order += "A";

        // call new location
        jqSimpletableChangePageLocation(tableId, null, order);
    });

    /* Table Row */
    // apply hover effect to buttons
    $('.simpletable').find('.row').bind('mouseover mouseout', function () {
        $(this).toggleClass('ui-state-hover');
    });

    /* Navigation Bar */
    var buttons = $('.navigation').find('.buttons:not(.ui-state-highlight):not(.ui-state-disabled)');

    // apply hover effect to buttons
    $(buttons).bind('mouseover mouseout', function () {
        $(this).toggleClass('ui-state-hover');
    });

    // apply change-page action
    $(buttons).bind('click', function () {
        $('.navigation').find('.search').prop('disabled', true);
        // TODO: apply this section
        /*
         if (typeof simpletable_onCustomPageChange == 'function') {
         if (!simpletable_onCustomPageChange(table, page, form));
         return;
         }
         */
        // get next page number
        var page;
        if ($(this).hasClass('backward') || $(this).hasClass('forward')) {
            page = $(this).parent().find('.buttons.ui-state-highlight').text();
            if ($(this).hasClass('backward'))
                page = parseInt(page) - 1;
            else
                page = parseInt(page) + 1;
        } else {
            page = parseInt($(this).text());
        }

        // call new location
        var tableId = $(this).parents("ul.navigation").attr('id').replace('-navi', '');
        jqSimpletableChangePageLocation(tableId, page, null);
    });

    // apply search action
    $('.navigation').find('input[name=navi_pg_edit]').bind('keyup', function (e) {
        if (e.keyCode == '13') {
            var page = Number($(this).val());
            if (isNaN(page))
                page = 1;
            var pageMax = parseInt($(this).parent().find('input[name=navi_pg_max]').val());
            if (page > pageMax)
                page = pageMax;

            // call new location
            var tableId = $(this).parents("ul.navigation").attr('id').replace('-navi', '');
            jqSimpletableChangePageLocation(tableId, page, null);
        }
    });
});
function jqSimpletableChangePageLocation(tableId, page, order) {
    jQuery('.navigation').find('.search').find('input').prop('disabled', true).addClass('ui-state-disabled');

    // prepare params
    var params = new Array();
//    params.push("load-simpletable="+tableId)

    // page parameter
    if (page) {
        if (tableId == 'simpletable')
            paramName = "pg";
        else
            paramName = tableId + "pg";
        params.push(paramName + "=" + page);
    }
    // order parameter
    if (order) {
        if (tableId == 'simpletable')
            paramName = "order";
        else
            paramName = tableId + "order";
        params.push(paramName + "=" + order);
    }

    // apply new location
    var uriTiles = window.location.href.split("?");
    if (uriTiles.length > 1) {
        var paramTiles = uriTiles[1].split("&");
        for (k in paramTiles)
            if (paramTiles[k].search('list_init') < 0 && paramTiles[k].search('btnFilter') < 0 && paramTiles[k].search(paramName) < 0)
                params.push(paramTiles[k]);
    }
    ;
    //$(window.location).attr( "href", uriTiles[0]+"?"+params.join("&"));
    document.location.href = uriTiles[0] + "?" + params.join("&");
}


/* ---------- OLD Functions ---------- */


function simpletable_onHeaderCheckboxClick(elem) {
    if (typeof simpletable_onCustomHeaderCheckboxClick == 'function') {
        simpletable_onCustomHeaderCheckboxClick();
    }
    window['simpletable_' + elem.name.replace('_header', '') + '_off_amount'] = 0;
    var targetName = elem.getAttribute('name').replace('_header', '');
    var elems = document.getElementsByTagName('input');
    if (!elem.checked)
        elem.className = '';
    for (var i = 0; i < elems.length; i++) {
        reqType = elems[i].getAttribute('type');
        if (typeof reqType == 'string' && reqType.toUpperCase() == 'CHECKBOX') {
            if (elems[i].name == targetName + '[]' && elem.checked) {
                elems[i].checked = true;
            } else if (elems[i].name == targetName + '[]' && !elem.checked) {
                elems[i].checked = false;
            }
        }
    }
    if (typeof simpletable_afterCustomHeaderCheckboxClick == 'function') {
        simpletable_afterCustomHeaderCheckboxClick(elem);
    }
}
function simpletable_setHeaderCheckboxStatus(elem) {
    var targetName = elem.getAttribute('name').replace('[]', '');
    var elems = document.getElementsByName(targetName + '_header');
    if (elem.checked) {
        window['simpletable_' + elem.name.replace('[]', '') + '_off_amount'] = window['simpletable_' + elem.name.replace('[]', '') + '_off_amount'] - 1;
    } else {
        window['simpletable_' + elem.name.replace('[]', '') + '_off_amount'] = window['simpletable_' + elem.name.replace('[]', '') + '_off_amount'] + 1;
    }
    // FOR DEBUG USE
    // alert(window['simpletable_'+elem.name.replace('[]', '')+'_off_amount']);
    if (elems[0].checked && window['simpletable_' + elem.name.replace('[]', '') + '_off_amount'] > 0) {
        elems[0].className = 'header_checkbox_intermediate';
    } else if (window['simpletable_' + elem.name.replace('[]', '') + '_off_amount'] <= 0) {
        elems[0].className = '';
    }
    if (typeof simpletable_afterHeaderCheckboxStatus == 'function') {
        if (!simpletable_afterHeaderCheckboxStatus(elem))
            ;
        return;
    }
}