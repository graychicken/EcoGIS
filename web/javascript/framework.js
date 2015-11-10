var R3FrameworkID = 'R3FrameworkID';
var R3FrameworkMenuID = 'R3FrameworkMenuID';
var R3FrameworkDeltaHeight = 0;       // Value to add to the framework height.
var R3FrameworkMenuDeltaHeight = 0;   // Value to add to the menu height.
var R3FrameworkMinHeightHeader = 1024;
var R3FrameworkMinWidthMenu = 1024;
var menuFadeoutDiration = 1000;
var menuMargin = null;
var trmCloseMenu;

function frameworkNavigate(url) {
    top.location = url;
}

function frameworkResize() {
    if ($('#' + R3FrameworkID).length > 0) {
        var pos = $('#' + R3FrameworkID).position();
        var height = $(document.body).height() - pos.top + R3FrameworkDeltaHeight;
        var theFrame = $('#' + R3FrameworkID, parent.document.body);
        theFrame.height(height);
    }

    if ($('#' + R3FrameworkMenuID).length > 0) {
        var pos = $('#' + R3FrameworkMenuID).position();
        var height = $(document.body).height() - pos.top + R3FrameworkMenuDeltaHeight;
        var theMenu = $('#' + R3FrameworkMenuID, parent.document.body);
        theMenu.height(height);
    }
}

function closeHeader() {
    var height = $('#R3WorkAreaTitle').height();
    $('#Logos').hide();
    $('.R3WorkAreaSpacer').height(height);
    $('#R3WorkAreaHeader').height(height);
}

function closeMenu() {
    $('#R3WorkAreaMenuOff').effect("slide", "fast");
    $('#R3WorkAreaMenu').effect("drop", "slow", function () {

        $('#right').css('margin-left', 25);
    });
}

function openMenu() {
    $('#R3WorkAreaMenuOff').hide(); //effect("drop", "slow");
    $('#R3WorkAreaMenu').effect("slide", "slow", function () {
        $('#right').css('margin-left', menuMargin);
    });
}

function initMenuOpenClose() {
    menuMargin = $('#right').css('margin-left');

    trmCloseMenu = setTimeout(function () {
        closeMenu();
    }, menuFadeoutDiration);
    $('#R3WorkAreaMenuOff').bind('mouseenter', function () {
        openMenu();
    });
    $('#R3WorkAreaMenu').bind('mouseleave', function () {
        trmCloseMenu = setTimeout(function () {
            closeMenu();
        }, menuFadeoutDiration);
    }).bind('mouseenter', function () {
        if (trmCloseMenu) {
            clearTimeout(trmCloseMenu);
        }
    });
}

function frameworkInit() {
    $('body').attr('style', 'overflow:hidden');
    document.documentElement.style.overflow = "hidden";
    $('#' + R3FrameworkID).css('display', '');

    if (screen.height > 0 && screen.height < R3FrameworkMinHeightHeader) {
        closeHeader();
    }

    if (screen.width > 0 && screen.width < R3FrameworkMinWidthMenu && !($.browser.msie && $.browser.version <= 9.0)) {
        initMenuOpenClose();
    }
    frameworkResize();
}

