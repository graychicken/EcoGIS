/*****************************************************************************************************
 Author : Daniel Degasperi
 Last modified: R3 GIS (20/09/2005)
 Source : www.totallysmartit.com
 Date : 20/09/2005
 Version: 1.0
 *****************************************************************************************************/

// Default settings
if (!UserMapWidth)
    var UserMapWidth = 400;
if (!UserMapHeight)
    var UserMapHeight = 400;
if (!PopupErrorMsg)
    var PopupErrorMsg = "WARNING!\n\nA pop-up blocker is active on your computer. Disable it and try again";
if (!MapFileName)
    var MapFileName = "map.html";
if (!MapName)
    var MapName = "";

var hMap = null;

function OpenMapOLD(mapoper, width, height) {

    var winw = Math.min(window.screen.availWidth, width);
    var winh = Math.min(window.screen.availHeight - 150, height);
    var mapw = Math.min(window.screen.availWidth, width);
    var maph = Math.min(window.screen.availHeight, height);
    l = Math.max(0, ((window.screen.availWidth - mapw) * .5));
    t = Math.max(0, ((window.screen.availHeight - maph) * .5));

    // Open map
    hWin = window.open('../map/index.php?mapoper=' + mapoper + '&winwidth=' + winw + '&winheight=' + winh, 'PLAY_MAP', 'width=' + mapw + ',height=' + maph + ',scrollbars=yes,toolbar=no,resizable=yes,location=no,menubar=no,status=yes,top=' + t + ',left=' + l);
    if (hWin == null)
        alert('" . $s . "');
    else
        hWin.focus();
}

function OpenMap_param(mapoper, params, width, height) {

    var winw = Math.min(window.screen.availWidth, width);
    var winh = Math.min(window.screen.availHeight - 150, height);
    var mapw = Math.min(window.screen.availWidth, width);
    var maph = Math.min(window.screen.availHeight, height);
    l = Math.max(0, ((window.screen.availWidth - mapw) * .5));
    t = Math.max(0, ((window.screen.availHeight - maph) * .5));

    // Open map
    hWin = window.open('../map/index.php?mapoper=' + mapoper + '&winwidth=' + winw + '&winheight=' + winh + '&' + params, 'PLAY_MAP', 'width=' + mapw + ',height=' + maph + ',scrollbars=yes,toolbar=no,resizable=yes,location=no,menubar=no,status=yes,top=' + t + ',left=' + l);
    if (hWin == null)
        alert('" . $s . "');
    else
        hWin.focus();

}


// Main open map function
function DoOpenMap(url, name) {

    var width = Math.min(window.screen.availWidth, UserMapWidth);
    var height = Math.min(window.screen.availHeight, UserMapHeight);
    var l = Math.max(0, ((window.screen.availWidth - width) * 0.5));
    var t = Math.max(0, ((window.screen.availHeight - height) * 0.5));

    var features = 'width=' + width + ',' +
            'height=' + height + ',' +
            'scrollbars=no,' +
            'toolbar=no,' +
            'resizable=yes,' +
            'location=no,' +
            'menubar=no,' +
            'status=yes,' +
            'top=' + t + ',' +
            'left=' + l;

    try {
        hMap.close();
    } catch (e) {
    } finally {
        hMap = window.open(url, name, features);
    }
    if (hMap == null) {
        alert(PopupErrorMsg);
    } else {
        hMap.focus();
    }
}

// Main open map function
function DoOpenMapNoResize(url, name) {

    var width = Math.min(window.screen.availWidth, UserMapWidth);
    var height = Math.min(window.screen.availHeight, UserMapHeight);
    var l = Math.max(0, ((window.screen.availWidth - width) * 0.5));
    var t = Math.max(0, ((window.screen.availHeight - height) * 0.5));

    var features = 'width=' + width + ',' +
            'height=' + height + ',' +
            'scrollbars=no,' +
            'toolbar=no,' +
            'resizable=no,' +
            'location=no,' +
            'menubar=no,' +
            'status=yes,' +
            'top=' + t + ',' +
            'left=' + l;

    try {
        hMap.close();
    } catch (e) {
    } finally {
        hMap = window.open(url, name, features);
    }
    if (hMap == null) {
        alert(PopupErrorMsg);
    } else {
        hMap.focus();
    }
}

// Generic open map
function GenericOpenMap(mapoper) {
    DoOpenMap(MapFileName + '?mapoper=' + mapoper, MapName);
}


function GenericOpenMapNoResize(mapoper) {
    DoOpenMapNoResize(MapFileName + '?mapoper=' + mapoper, MapName);
}

function ZoomToMap(mapoper, type, id) {
    if (!id)
        DoOpenMap(MapFileName + '?mapoper=' + mapoper + '&mapoper_zoom=' + type + '&zoom_type=zoomextent', MapName);
    else
        DoOpenMap(MapFileName + '?mapoper=' + mapoper + '&mapoper_zoom=' + type + '&mapoper_id=' + id + '&zoom_type=zoomextent', MapName);
}
