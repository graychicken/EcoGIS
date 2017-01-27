<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>{if $USER_CONFIG_APPLICATION_TITLE<>''}{$USER_CONFIG_APPLICATION_TITLE}{else}R3 ECOGIS{/if} - {t}Mappa{/t}</title>
        {$meta_contenttype}

        <!-- CSS -->
        <link rel="stylesheet" href="{$smarty.const.R3_CSS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/{$smarty.const.APPLICATION_CODE|lower}_orange.css" type="text/css" />
        <link type="text/css" href="{$gisclient_folder}css/main.css" rel="Stylesheet" />
        <link type="text/css" href="{$gisclient_folder}external/jquery-ui/smoothness/jquery-ui-1.10.4.custom.min.css" rel="Stylesheet" media="screen">
            <link type="text/css" href="{$gisclient_folder}external/jquery-ui/jqueryUi.icons.css" rel="Stylesheet" />

            <!-- JS -->
            <script type="text/javascript" src="{$gisclient_folder}external/OpenLayers/OpenLayers.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}languages/lang-{$lang_code}.js"></script>
            <script type="text/javascript">
                OpenLayers.Lang.setCode('{$lang_code}');
            </script>
            <script type="text/javascript" src="{$gisclient_folder}js/PanZoomBar.js"></script> <!-- fix OL bug with https on IE -->
            <script type="text/javascript" src="{$gisclient_folder}external/proj4js/proj4.js"></script>
            <script type="text/javascript">
                Proj4js.defs["EPSG:{$proj4js.srid}"] = "{$proj4js.proj4text}";
            </script>
            <script type="text/javascript" src="{$gisclient_folder}external/jquery/jquery-1.11.1.min.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}external/jquery-ui/jquery-ui-1.10.4.min.js"></script>
            <script type="text/javascript" src="{$smarty.const.R3_JS_URL}jquery/plugins/jquery.form.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}external/jstree/jquery.jstree.min.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}external/plugin-jquery/jquery.maxzindex.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}external/plugin-jquery/jquery.ie-select-width.min.js"></script>

            <!-- R3layout -->

            <link type="text/css" href="{$gisclient_folder}js/R3layout/css/R3layout.css" rel="Stylesheet" />
            <!--[if lt IE 9]>  
                <script type="text/javascript" src="{$gisclient_folder}js/R3layout/js/forIE.js"></script>   
                <link type="text/css" href="{$gisclient_folder}js/R3layout/css/forIE.css" rel="Stylesheet" />
            <![endif]-->
            <script type="text/javascript" src="{$gisclient_folder}js/R3layout/js/R3layout.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/init-r3layout.js"></script>

            <link rel="stylesheet" href="{$gisclient_folder}css/layout.css" />

            <!-- GisClient -->

            <!-- JSTS -->
            <script type="text/javascript" src="{$gisclient_folder}external/jsts/javascript.util.js"></script> 
            <script type="text/javascript" src="{$gisclient_folder}external/jsts/jsts.js"></script>

            <!-- jqgrid -->
            <link type="text/css" href="{$gisclient_folder}external/jqGrid/ui.jqgrid.css" rel="Stylesheet" />
            <script type="text/javascript" src="{$gisclient_folder}external/jqGrid/grid.locale-{$lang_code}.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}external/jqGrid/jquery.jqGrid.min.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}external/jqGrid/jquery.fmatter.js"></script>


            <!-- OpenLayers style -->
            <link type="text/css" href="{$gisclient_folder}external/OpenLayers/theme/default/style.css" rel="stylesheet"  media="all" />

            <script type="text/javascript" src="{$gisclient_folder}js/widgetGisClient.js"></script>
            <script typE="text/javascript" src="{$gisclient_folder}js/searchEngine.js"></script>

            <!-- Gc Tools -->
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/zoomToMaxExtent.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/zoomToHistoryPrevious.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/zoomToHistoryNext.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/pan.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/zoomIn.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/zoomOut.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/selectFromMap.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/measureLine.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/measureArea.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/drawFeature.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/reloadLayers.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/redline.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/toolTip.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/mapHelp.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/mapPrint.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/selectBox.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/selectPoint.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/selectFeatures.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/unselectFeatures.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/toStreetView.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcTool/wfstEdit.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/NavigationHistory.js"></script>
            <script type="text/javascript" src="{$gisclient_modules_folder}ecogisDigitize/ecogisDigitize.js"></script>


            <!-- Gc Components -->
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/gcLayersManager.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/gcLayerTree.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/gcLegendTree.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/mapInfo.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/snapPoint.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/mapImageDialog.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/referenceMap.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/scaleDropDown.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/searchForm.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/viewTable.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/errorHandler.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/loadingHandler.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/contextHandler.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/layerTools.js"></script>
            <script type="text/javascript" src="{$gisclient_folder}js/gcComponent/geolocator.js"></script>

            {literal}
                <script type="text/javascript">
                {/literal}
                    var ecogisDigitizeTarget = {$customDigitizeTarget|@json_encode};
                    var ecogisDigitizeHasSelection = {$gisclientOptions.digitize_has_selection};
                    var ecogisDigitizeHasEditing = {$gisclientOptions.do_gc_digitize_has_editing};
                    var toStreetviewOptions = {$gisclientOptions.streeview_options};
                    var printLogoDx = '{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/logo/{$DOMAIN_NAME|lower}/logo_dx.png';
                    var printLogoSx = '{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/logo/{$DOMAIN_NAME|lower}/logo_sx.png';
                {literal}

                    $(document).ready(function() {
                    //$(document).r3core();
                {/literal}
                    OpenLayers.ImgPath = "{$gisclient_folder}images/icons/";
                {literal}

                    $('#zoomToLocality').button({icons: {primary: 'ui-icon-search'}, text: false}).click(function() {
                    gisclient.zoomOn({
                    featureType: autocompleteFeatureType.featureType,
                            field: autocompleteFeatureType.field,
                            value: $('#to_id').val()
                    }, false);
                    });
                    $('#clearZoomToLocality').button({icons: {primary: 'ui-icon-cancel'}, text: false}).click(function() {
                    $('#to_id').val('');
                    $('#to_name').val('');
                    });
                    GCMAP = $("#mapOL").gisclientmap({
                    'project_name':'{/literal}{$gisclientOptions.project}{literal}',
                            'mapsetName':'{/literal}{$gisclientOptions.mapset}{literal}',
                            'language': "{/literal}{$lang_code}{literal}",
                            'mapsetURL' : "{/literal}{$smarty.const.GC_MAP_SET_URL}{literal}",
                {/literal}
                {$initZoomOn}
                {if count($gc.tools) > 0}
                    tools: {ldelim}
                        dummy: 'dummy' // FIX: for IE
                    {foreach from=$gc.tools key=toolName item=toolvalue}
                        , {$toolName}: '{$toolvalue}'
                    {/foreach}
                    {rdelim},
                {/if}
                {literal}
                    mapOptions:{
                    fractionalZoom:{/literal}{if $gisclientOptions.fractional_zoom}true{else}false{/if}{literal}
                        },
                                "layerTree":'treeList',
                                "displayposition":'coordinates',
                                "displaymeasure":'coordinates',
                                "legend":true,
                                "baseLayerFirst":false,
                                "divs": {
                                selectionSettings: 'selection_settings',
                                        lineMeasure: 'misure',
                                        lineMeasurePartial: 'misure_partial',
                                        areaMeasure: 'misure',
                                        redlineDialog: 'redline_dialog',
                                        footer: 'footer',
                                        referenceMap: 'refMapContainer',
                                        mapInfoScale: 'mapInfoScale',
                                        mapInfoRefSystemDescription: 'mapInfoRefSystemDescription',
                                        mapInfoMousePosition: 'mapInfoMousePosition',
                                        mapInfoMousePositionLatLon: 'mapInfoMousePositionLatLon',
                                        mapInfoRefSystem: 'mapInfoRefSystem',
                                        toolBar: 'toolbar',
                                        scaleDropDown: 'scaleDropDown',
                                        searchList: 'searchList',
                                        editingSettings: 'editing_settings',
                                        snapOptionsId: 'snap_options',
                                        treeList: 'treeList',
                                        legendList: 'legendList',
                                        dataList: 'dataList',
                                        tree: 'treeDiv',
                                        viewTable: 'gc_view_table',
                                        loading: 'loading_indicator',
                                        errors: 'errors_indicator',
                                        geolocator: 'geolocator'
                                },
                                activateKeyboardControl: false,
                                callbacks: {
                {/literal}
                {if count($gc.callbacks) > 0}
                            dummy: 'dummy' // FIX: for IE
                    {foreach from=$gc.callbacks key=toolName item=functionName}
                            , {$toolName}: {$functionName}
                    {/foreach}
                {/if}
                {literal}
                            },
                            "toolsOptions": {
                            'toStreetView': toStreetviewOptions
                {/literal}
                {if count($gc.toolsOptions) > 0}
                    {foreach from=$gc.toolsOptions key=toolName item=toolOptions}
                            , {$toolName}: {$toolOptions}
                    {/foreach}
                {/if}
                {literal}
                            },
                            componentsOptions: {
                            gcLayerTree: {
                            showMoveLayersButtons: false,
                                    showLayerTools: true,
                                    showLayerMetadata:true,
                                    showViewTable: false,
                                    defaultThemeOptions: {
                                    radio: false,
                                            moveable: true,
                                            deleteable: false
                                    }
                            },
                                    mapImageDialog: {
                                    allowedPrintFormats: ['A4', 'A3', null, null, null],
                                            displayBox: true,
                                            logoSx: printLogoSx,
                                            logoDx: printLogoDx
                                    },
                                    contextHandler: {
                                    saveOnZoomEnd: false
                                    }
                            },
                            'gisclientready': function() {
                            gisclient.startMap();
                            $('#ecogis_digitize').ecogisDigitize({
                            targets: ecogisDigitizeTarget,
                                    // SS: Tool da abilitare
                                    allowSelection: ecogisDigitizeHasSelection,
                                    allowEditing: ecogisDigitizeHasEditing,
                                    preload: {method: 'getTemporaryFeature', on: 'gisclient'},
                                    save: function(event, ui) {
                                    window.opener.afterGCDigitize(ui.geometries);
                                    window.close();
                                    }
                            });
                            $('#ecogis_edit_building').wfstEdit();
                {/literal}

                {if isset($customGisclientReadyFunctions)}
                    {foreach from=$customGisclientReadyFunctions item=gcReadyJavaScript}
                        {$gcReadyJavaScript}
                    {/foreach}
                {/if}


                {if isset($zoomOn)}
                    {if isset($zoomOn.extent)}
                            var where = new OpenLayers.Bounds({$zoomOn.extent.0},{$zoomOn.extent.1},{$zoomOn.extent.2},{$zoomOn.extent.3});
                            gisclient.zoomOn(where);
                    {else}
                            var where = {ldelim}
                                        featureType: '{$zoomOn.featureType}',
                                                field: '{$zoomOn.field}',
                                                value: '{$zoomOn.value}'
                        {rdelim};
                                    gisclient.zoomOn(where, {$zoomOn.highlight});
                    {/if}
                {elseif isset($goToCenterZoom)}
                                    var center = new OpenLayers.LonLat({$goToCenterZoom.x}, {$goTo    CenterZoom.y});
                                    gisclient.map.setCenter(center, {$goToCenterZoom.zoom});
                {elseif isset($customSearch)}
                                    var url = decodeURI('{$customSearch}');
                                    gisclient.componentObjects.customSearch.search(url);
                {/if}
                {literal}

                            var queryableLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers(false, true);
                            if (typeof (autocompleteFeatureType) != 'undefined' && typeof (queryableLayers[autocompleteFeatureType.featureType]) != 'undefined') {
                            var feature = queryableLayers[autocompleteFeatureType.featureType];
                            $('#to_name').autocomplete({
                            delay: 0,
                                    feature: feature,
                                    selectedField: autocompleteFeatureType.field,
                                    source: gisclient.autocompleteFromQueryableLayer,
                                    search: function(event, ui) {
                                    $('#to_id').val('').trigger('change');
                                    },
                                    select: function(event, ui) {
                                    $('#to_id').val(ui.item.value).trigger('change');
                                    $('#zoomToLocality').trigger('click');
                                    },
                                    open: function(event, ui) {
                                    $(this).data('chooseFromMenu', true);
                                    },
                                    close: function(event, ui) {
                                    $(this).data('chooseFromMenu', false);
                                    }

                            }).bind('focus', function() {
                            $(this).select();
                            }).bind('blur', function() {});
                            }

                            var themes = gisclient.componentObjects.gcLayersManager.getThemes();
                            $.each(themes, function(themeName, data) {
                            var layers = gisclient.componentObjects.gcLayersManager.getLayers(themeName);
                            $.each(layers, function(layerName, data2) {
                            var theLayer = gisclient.componentObjects.gcLayersManager.getLayer(themeName, layerName);
                            if (theLayer) {
                            theLayer.olLayer.addOptions({transitionEffect: 'resize'}, true);
                            }
                            });
                            });
                            },
                            'gctreeloaded': function() {
                            $('#treeDiv a.up').button({ icons: { primary: "ui-icon-triangle-1-n" }, text:false });
                            $('#treeDiv a.down').button({ icons: { primary: "ui-icon-triangle-1-s" }, text:false });
                            $('#treeDiv a.opacity').button({ icons: { primary: "ui-icon-wrench" }, text:false });
                            $('#treeDiv a.delete').button({ icons: { primary: "ui-icon-trash" }, text:false });
                            $('#treeDiv a.info').button({ icons: { primary: "ui-icon-info" }, text:false });
                            },
                            'defaultFeatureFilters': {
                {/literal}
                {foreach from=$gc.defaultFeatureFilters key=featureType item=filters}
                            '{$featureType}': [
                    {foreach from=$filters item=filter}
                            new OpenLayers.Filter.Comparison({ldelim}
                                        type: OpenLayers.Filter.Comparison.{$filter.operator},
                                                property: '{$filter.field}',
                                                value: '{$filter.value}'
                        {rdelim})
                    {/foreach}
                                    ],
                {/foreach}
                {literal}
                            },
                            "externalFeatureLink": {
                            'g_building.building': {
                            objectIdField: 'bu_id',
                                    objectLink: 'edit.php?on=building&act=show',
                                    customJsFunction: 'open_edit_page',
                                    objectLinkType: 'js'
                            },
                                    'g_street_lighting.street_lighting': {
                                    objectIdField: 'sl_id',
                                            objectLink: 'edit.php?on=street_lighting&act=show',
                                            customJsFunction: 'open_edit_page',
                                            objectLinkType: 'js'
                                    },
                                    'g_inventory.global_subcategory': {
                                    objectIdField: 'pa_id',
                                            objectLink: 'edit.php?on=global_result&act=show&gs_id=@gs_id@&id=@ge_id@',
                                            customJsFunction: 'open_edit_page',
                                            objectLinkType: 'js'
                                    }
                            }
                    });
                    });
                    function edit_point(event, data) {
                    data.extent = gisclient.map.getExtent().toBBOX();
                    window.opener.handlePointSelection(event, data);
                    window.close();
                    }

                    function edit_box(event, data) {
                    window.opener.handleBoxSelection(event, data);
                    window.close();
                    }

                    function edit_geometry(event, ui) {
                    ui.extent = gisclient.map.getExtent().toBBOX();
                    window.opener.handleGeometrySelection(event, ui);
                    window.close();
                    }

                    function open_edit_page(url) {
                    if (typeof window.opener.parent != 'undefined') {
                    window.opener.parent.location = 'app_manager.php?url=' + escape(url);
                    } else {
                    window.opener.location = 'app_manager.php?url=' + escape(url);
                    }
                    try {
                    window.opener.focus();
                    } catch (e) {
                    //alert(e.message);
                    }
                    }
                </script>
            {/literal}
    </head>
    <body>
        <div id="layout_container">
            <div id="header" class="ui-layout-north">
                <div id="toolbar" class="fg-toolbar ui-widget-header ui-corner-all">
                    {if isset($gc.tools.zoomFull) || isset($gc.tools.zoomPrev) || isset($gc.tools.zoomNext) || isset($gc.tools.reloadLayers)}
                        <span> <!-- strumenti di gestione vista -->
                            {if isset($gc.tools.reloadLayers)}
                                <button id="reload_layers">{t}Ricarica{/t}</button>
                            {/if}
                            {if isset($gc.tools.zoomFull)}
                                <button id="zoom_full">{t}Zoom estensione{/t}</button>
                            {/if}
                            {if isset($gc.tools.zoomPrev)}
                                <button id="zoom_prev">{t}Vista precedente{/t}</button>
                            {/if}
                            {if isset($gc.tools.zoomNext)}
                                <button id="zoom_next">{t}Vista successiva{/t}</button>
                            {/if}
                        </span>
                    {/if}

                    {if isset($gc.tools.Pan) || isset($gc.tools.zoomIn) || isset($gc.tools.zoomOut)}
                        <span> <!-- strumenti di navigazione -->
                            {if isset($gc.tools.Pan)}
                                <input type="radio" id="pan" name="gc-toolbar-button" {if empty($smarty.request.dup_id)}checked="checked"{/if} /><label for="pan">{t}Pan{/t}</label>
                            {/if}
                            {if isset($gc.tools.zoomIn)}
                                <input type="radio" id="zoom_in" name="gc-toolbar-button" /><label for="zoom_in">{t}Zoom in{/t}</label>
                            {/if}
                            {if isset($gc.tools.zoomOut)}
                                <input type="radio" id="zoom_out" name="gc-toolbar-button" /><label for="zoom_out">{t}Zoom out{/t}</label>
                            {/if}
                            <input type="text" name="scaleDropDown" id="scaleDropDown">
                        </span>
                    {/if}

                    {if isset($gc.tools.measureLine) || isset($gc.tools.measureArea)}
                        <span class="gc-buttonset"> <!-- misure -->
                            {if isset($gc.tools.measureLine)}
                                <input type="radio" id="measure_line" name="gc-toolbar-button" /><label for="measure_line">{t}Misura lunghezza{/t}</label>
                            {/if}
                            {if isset($gc.tools.measureArea)}
                                <input type="radio" id="measure_polygon" name="gc-toolbar-button" /><label for="measure_polygon">{t}Misura area{/t}</label>
                            {/if}
                        </span>
                    {/if}

                    {if isset($gc.tools.selectFromMap) || isset($gc.tools.toolTip)}
                        <span> <!-- strumenti interrogazione -->
                            {if isset($gc.tools.selectFromMap)}
                                <input type="radio" id="select" name="gc-toolbar-button" /><label for="select">{t}Seleziona{/t}</label>
                            {/if}
                            <button id="unselect_features">{t}Deseleziona{/t}</button>
                            {if isset($gc.tools.toolTip)}
                                <input type="radio" id="tooltip" name="gc-toolbar-button" /><label for="tooltip">{t}Tooltip{/t}</label>
                            {/if}
                        </span>
                    {/if}

                    {if isset($gc.tools.drawFeature)}
                        <span class="gc-buttonset"> <!-- strumenti disegno -->
                            <input type="radio" id="draw_feature" name="gc-toolbar-button" /><label for="draw_feature">{t}Disegna{/t}</label>
                        </span>
                    {/if}


                    {if isset($gc.tools.redline) && isset($gc.tools.mapPrint)}
                        <span> <!-- redline -->
                            {if isset($gc.tools.redline)}
                                <input type="radio" id="redline" name="gc-toolbar-button" /><label for="redline">Annotazione</label>
                            {/if}
                            {if isset($gc.tools.mapPrint)} 
                                <button id="print">Stampa</button> 
                            {/if}
                        </span>
                    {/if}


                    {if isset($gc.tools.selectPoint)}
                        <span class="gc-buttonset"> <!-- select point -->
                            <input type="radio" id="select_point" name="gc-toolbar-button" /><label for="select_point">{t}Seleziona Punto{/t}</label>
                        </span>
                    {/if}

                    {if isset($gc.tools.selectBox)}
                        <span class="gc-buttonset"> <!-- select box -->
                            <input type="radio" id="select_box" name="gc-toolbar-button" /><label for="select_box">{t}Seleziona Box{/t}</label>
                        </span>
                    {/if}
                    {if $gisclientOptions.has_streeview && isset($gc.tools.toStreetView)}
                        <span>
                            {if $gisclientOptions.has_streeview && isset($gc.tools.toStreetView)}
                                <input type="radio" id="to_street_view" name="gc-toolbar-button" /><label for="to_street_view">{t}Visualizza su Street View{/t}</label>
                            {/if}
                        </span>
                    {/if}

                    {if isset($gc.tools.ecogisDigitize)}
                        <span class="gc-buttonset"> <!-- tooltip -->
                            <input type="radio" id="ecogis_digitize" name="gc-toolbar-button" /><label for="ecogis_digitize">{t}Digitize{/t}</label>
                        </span>
                    {/if}

                    {if $gisclientOptions.has_quick_search}
                        <span class="gc-buttonset" style="float:right !important;">
                            {if $smarty.const.R3_IS_MULTIDOMAIN}{t}COMUNE, VIA, NUMERO{/t}{else}{t}VIA, NUMERO{/t}{/if}: <input type="text" id="geolocator" name="geolocator" style="width:250px;">
                        </span>
                    {/if}

                </div>
            </div>
            <div id="wrapper">
                <div id="mapOL" class="ui-layout-center" tabindex="10">
                    <div id="ll_mouse"></div><div style="margin-left:50px" id="utm_mouse"></div>
                    <div id="searchForm"></div>
                </div>
                <div class="ui-layout-east" id="sidebarSx">
                    <div class="east-north" id="logo">
                        <div class="ui-widget-content" style="text-align:center;">
                            <div class="logo_sx"><img style="margin-top: 6px" height="40" src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/logo/{$DOMAIN_NAME|lower}/map_sx.png"></div>
                        </div>
                    </div>
                    <div class="east-center" style="overflow:auto !important;" id="treeDiv">
                        <ul>
                            <li><a href="#treeList">{t}Livelli{/t}</a></li>
                            <li><a href="#legendList">{t}Legenda{/t}</a></li>
                            <li><a href="#searchList">{t}Ricerca{/t}</a></li>
                            <li><a href="#dataList">{t}Dati{/t}</a></li>
                        </ul>
                        <div id="treeList" class="ui-layout-east"></div>
                        <div id="legendList">{t}Legenda{/t}</div>
                        <div id="dataList">{t}Data{/t}</div>
                        <div id="searchList">{t}Ricerca{/t}</div>
                    </div>
                    <div id="minimap">
                        <div class="ui-widget-content east-south" id="refMapContainer" style="padding:5px">
                        </div>
                    </div>
                </div>
            </div>
            <div id="footer" class="ui-layout-south">
                <div class="fg-toolbar ui-widget-header ui-corner-all ui-helper-clearfix">
                    <span id="misure"></span>&nbsp;
                    <span id="misure_partial"></span>
                    <span id="mapInfoScale"></span>&nbsp; | 
                    <span id="mapInfoRefSystemDescription">WGS84 UTM32</span> = <span id="mapInfoMousePosition"></span>&nbsp; | 
                    WGS84 = <span id="mapInfoMousePositionLatLon"></span>&nbsp;
                    <span id="mapInfoRefSystem"></span>
                    <span id="copyright" style="position:absolute; right:10px"><a href="http://www.r3-gis.com/r3-ecogis" target="_blank">R3 EcoGIS</a> | <a href="http://www.gisclient.net/" target="_blank">GisClient</a></span>
                </div>
            </div>
        </div>

        <div id="altro_da_posizionare">
            <div id="redline_dialog" style="display:none;">
            </div>
            <div id="snap_options" style="display:none;">
            </div>
            <div id="editing_settings" style="display:none;">
            </div>
            <div id="selection_settings" style="display:none;">
            </div>
            <div id="loading_indicator" style="background-color:white;position:absolute;top:150px;left:600px;display:none;">{t}Sto caricando...{/t}
            </div>
            <div id="errors_indicator" style="position:absolute;top:150px;left:600px;display:none;">{t}Errore!{/t}<br /><span></span>
            </div>
            <div id="div_layermanager" style="display:none;"></div>
            <div id="gc_view_table" style="display:none;"></div>
        </div>

    </body>
</html>