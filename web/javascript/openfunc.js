/*****************************************************************************************************
 Author : Daniel Degasperi
 Last modified: R3 GIS (20/09/2005)
 Date : 25/11/2008
 Version: 1.1
 *****************************************************************************************************/

if (!PopupErrorMsg) {
    var PopupErrorMsg = "WARNING!\n\nA pop-up blocker is active on your computer. Disable it and try again";
}


function doOpenWindow(url, target, width, height, resizeable) {

    if (!target) {
        target = '_blank';
    }
    if (!width) {
        width = 300;
    }
    if (!height) {
        height = 200;
    }
    if (resizeable == true) {
        resizeable = 'yes';
    } else {
        resizeable = 'no';
    }
    width = Math.min(window.screen.availWidth, width);
    height = Math.min(window.screen.availHeight, height);
    var left = Math.max(0, ((window.screen.availWidth - width) * 0.5));
    var top = Math.max(0, ((window.screen.availHeight - height) * 0.5));

    var features = 'width=' + width + ',' +
            'height=' + height + ',' +
            'scrollbars=yes,' +
            'toolbar=no,' +
            'resizable=' + resizeable + ',' +
            'location=no,' +
            'menubar=no,' +
            'status=no,' +
            'top=' + top + ',' +
            'left=' + left;
    try {
        var hWin = window.open('about:blank',
                target,
                features);
    } catch (e) {
    }
    if (hWin == null) {
        alert(PopupErrorMsg);
    } else {
        try {
            setTimeout(function () {
                hWin.resizeTo(width, height);
                hWin.moveTo(left, top);
            }, 50);
        } catch (e) {
        }
        try {
            hWin.location.href = url;
        } catch (e) {
            // Popup already open
            return null;
        }
        hWin.focus();
    }
    return hWin;
}

function OpenWindow(url, target, width, height) {

    return doOpenWindow(url, target, width, height, false);
}

function OpenWindowResizable(url, target, width, height) {

    return doOpenWindow(url, target, width, height, true);
}

function OpenWindowMaximized(url, target) {

    return doOpenWindow(url, target, window.screen.availWidth, window.screen.availHeight, true);
}


function CloseWindow(hWin) {

    try {
        hWin.close();
    } catch (e) {
        return false;
    }
    return true;
}
