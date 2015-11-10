var initialHelpText;

function getHelpContext() {
    if (window.parent && window.parent.$('#help_container').length > 0) {
        return window.parent;
    }
    return window;
}

function hideR3Help() {
    var context = getHelpContext();


    context.$('#help_container').fadeOut(500, function () {
        $('#help_container_body').html(initialHelpText)
    });
}

function showR3Help(section, name) {
    var context = getHelpContext();

    if (typeof initialHelpText == 'undefined') {
        initialHelpText = $('#help_container_body').html();
    }
    var id = $(name).attr('for');
    if (!id) {
        id = $(name).attr('id');
    }
    context.$('#help_container_loader').show();

    context.$('#help_container').fadeIn(500);
    $.getJSON('edit.php', {'on': $('#on').val(),
        'method': 'getHelp',
        'section': section,
        'id': id}, showR3HelpDone);
}

function openR3Help(on, section, name) {
    var context = getHelpContext();

    if (typeof initialHelpText == 'undefined') {
        initialHelpText = $('#help_container_body').html();
    }
    context.$('#help_container_loader').show();
    context.$('#help_container').fadeIn(500);
    $.getJSON('edit.php', {'on': on,
        'method': 'getHelp',
        'section': section,
        'id': name}, showR3HelpDone);
}

function showR3HelpDone(data) {
    var context = getHelpContext();

    if (typeof data.exception == 'string') {
        alert(data.exception);
    } else {
        context.$('#help_container_loader').hide();
        if (typeof data.data == 'undefined' || data.data == '') {
            hideR3Help()
        } else {
            context.$('#help_container_title').toggle(data.data.title != '');
            context.$('#help_container_title').html(data.data.title);
            context.$('#help_container_body').html(data.data.body);
        }
    }
}

/**
 * Apply the calendar settings
 */
function setupHelp(selector, on) {
    if (typeof selector == 'undefined') {
        selector = '';
    }
    if (typeof on == "undefined") {
        on = $('#on').val();
    }
    $(selector + ' .help').bind('click', function () {
        showR3Help(on, this)
    });
}

$(document).ready(function () {
    setupHelp();
});