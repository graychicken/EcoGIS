$(document).ready(function() {
    $('#toolbar span').buttonset();

    $('#toolbar span button#zoom_full').button({
        icons: {
            primary: "zoom_full"
        },
        text:false
    });
    $('#toolbar span button#zoom_prev').button({
        icons: {
            primary: "zoom_prev"
        },
        text:false
    });
    $('#toolbar span button#zoom_next').button({
        icons: {
            primary: "zoom_next"
        },
        text:false
    });

    $("#treeDiv").tabs().find(".ui-tabs-nav");


    var wrapper = document.getElementById('wrapper');
    var main = document.getElementById('mapOL');
    var sidebar = document.getElementById('sidebarSx');

    var callback = function(){
        window.setTimeout(function(){
        gisclient.map.updateSize();
        },400);
    };

    var x = new R3layout(wrapper,main,sidebar, 'right', 300);
    x.collapsible(callback);
    x.resizable(callback);

    var logo = document.getElementById('logo');
    var content = document.getElementById('treeDiv');

    var y = new R3layout(sidebar, content, logo, 'top', 57);
    y.collapsible();

    var minimap = document.getElementById('minimap');

    var z = new R3layout(sidebar, content, minimap, 'bottom',177);
    z.collapsible();
});
