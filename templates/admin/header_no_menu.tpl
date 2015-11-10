<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <title>{if $USER_CONFIG_APPLICATION_TITLE<>''}{$USER_CONFIG_APPLICATION_TITLE}{else}R3 ECOGIS{/if}</title>
        {$meta_contenttype}
        <link rel="stylesheet" href="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/jquery/jquery-ui/css/orange/ui.all.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="{$smarty.const.R3_CSS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/{$smarty.const.APPLICATION_CODE|lower}_orange.css" type="text/css" />
        {if $smarty.const.USE_JQGRID == true}<link rel="stylesheet" href="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/jquery/plugins/jquery.jqGrid/css/ui.jqgrid.css" type="text/css" media="screen" />{/if}
        {if isset($mapDialog) && isset($gisclient_folder)}<link type="text/css" href="{$gisclient_folder}css/style.css" rel="stylesheet"  media="all" />{/if}
        {if isset($mapDialog) && isset($gisclient_folder)}<link type="text/css" href="{$gisclient_folder}css/jqueryUi.icons.css" rel="Stylesheet" />{/if}

        {if isset($mapDialog) && isset($gisclient_folder)}
            <!-- Gis Client, before jQuery -->

            <script type="text/javascript" src="{$gisclient_folder}external/OpenLayers/OpenLayers.js"></script>
            <script type="text/javascript" language="javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/gisclient_part1.all.js" ></script>
            <script type="text/javascript" language="javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/gisclient_part1.all.i18n.{$lang_code}.js" ></script>
        {/if}
        {literal}
            <script type="text/javascript">
                var langId = '{/literal}{$lang}{literal}';
                if (typeof OpenLayers != 'undefined') {
                OpenLayers.Lang.setCode('{/literal}{$lang_code}{literal}');
                }
                if (typeof Proj4js != 'undefined') {
                Proj4js.defs["EPSG:{/literal}{$proj4js.srid}{literal}"] = "{/literal}{$proj4js.proj4text}{literal}";
                }
            </script>
        {/literal}
        <script type="text/javascript" language="javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/jquery.all.js" ></script>
        <script type="text/javascript" language="javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/jquery.all.i18n.{$lang_code}.js" ></script>
        <script type="text/javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/ecogis2_core.all.js" ></script>
        <script type="text/javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/ecogis2_all.js" ></script>

        {if isset($mapDialog) && isset($gisclient_folder)}
            <script type="text/javascript" language="javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/gisclient_part2.all.js" ></script>
        {/if}
        <script type="text/javascript">
            {if $smarty.const.GISCLIENT}
            var isGisClient = true;
            var gisClientURL = '{$smarty.const.GC_URL}';
            {else}
            var isGisClient = false;
            {/if}
            {literal}
                $(document).ready(function() {
                $(document).r3core();
            {/literal}
            {if !empty($GCPreviewmap)}
                $('#previewMap').r3previewmap({ldelim}
                    obj_t: '{$GCPreviewmap.object_type}',
                            obj_key: '{$GCPreviewmap.id_key}',
                            obj_id: '{$GCPreviewmap.object_id}',
                            feature_type: '{$GCPreviewmap.featureType}',
                            windowMode: true,
                            highlight: {$GCPreviewmap.highlight},
                            rangeSize: null,
                            hash: {if $vlu.last_change_time<>0}{$vlu.last_change_time}{else}0{/if}
                {rdelim});
            {/if}
                    });
        </script>

        <!-- init GisClient Dialog Mode -->
        {if isset($mapDialog) && isset($gisclient_folder)}
            {literal}
                <script type="text/javascript">
                    var GCMAP;
                    $(window).load(function() {

                {/literal}
                    OpenLayers.ImgPath = "{$gisclient_folder}images/icons/";
                    var openDialogButtonSelector = "{$openDialogButtonSelector}";
                {literal}

                    if (openDialogButtonSelector != '') {
                    $(openDialogButtonSelector).click(function() {
                    $('#jQueryDialog').dialog('open');
                    });
                    }
                    $('#jQueryDialog').dialog({
                    width: 550,
                            position: [50, 50],
                            modal: false,
                            autoOpen: false,
                            open: function(event, ui) {
                            if (!gisclient.mapStarted) gisclient.startMap();
                            if (typeof (onDialogOpen) == 'function') onDialogOpen(event, ui);
                            }
                    });
                    GCMAP = $("#dialogMap").gisclientmap({
                    'project_name':{/literal}"{$USER_CONFIG_GISCLIENT_PROJECT}",{literal}
                            'mapsetName':{/literal}"{$USER_CONFIG_GISCLIENT_MAPSET}",{literal}
                            'mapsetURL' : {/literal}"{$smarty.const.GC_MAP_SET_URL}",{literal}
                            "displayposition":'coordinates',
                            "displaymeasure":'coordinates',
                            "legend":true,
                            "querytemplate":true,
                            "baseLayerFirst":false,
                            mapOptions:{
                            fractionalZoom: {/literal}{if $USER_CONFIG_GISCLIENT_FRACTIONAL_ZOOM=='T'}true{else}false{/if}{literal}
                                        },
                {/literal}
                {if count($mapTools) > 0}
                    tools: {ldelim}
                    {foreach from=$mapTools key=toolName item=toolvalue}
                        {$toolName}: '{$toolvalue}',
                    {/foreach}
                        foo:'bar'
                    {rdelim},
                {/if}
                {literal}
                    "divs": {
                    toolBar: 'toolbar',
                            scaleDropDown: 'scaleDropDown',
                            loading: 'loading_indicator',
                            errors: 'errors_indicator',
                            mapDialogId: 'jQueryDialog',
                            snapOptionsId: 'snap_options',
                            selectionSettings: 'selection_settings',
                            lineMeasure: 'misure',
                            lineMeasurePartial: 'misure_partial',
                            areaMeasure: 'misure',
                            redlineDialog: 'redline_dialog',
                            footer: 'footer',
                            mapInfoScale: 'mapInfoScale',
                            mapInfoMousePosition: 'mapInfoMousePosition',
                            mapInfoMousePositionLatLon: 'mapInfoMousePositionLatLon',
                            customSearch: 'div_customsearch',
                            mapInfoRefSystem: 'mapInfoRefSystem',
                            searchList: 'searchList',
                            dataList: 'dataList',
                            tree: 'treeDiv'
                    },
                            'gisclientready': function() {
                            $('#dialog_to_popup').dialogToPopup();
                            },
                            callbacks: {
                {/literal}
                {if count($mapCallbacks) > 0}
                    {foreach from=$mapCallbacks key=toolName item=functionName}
                        {$toolName}: {$functionName},
                    {/foreach}
                            foo:'bar'
                {/if}
                {literal}
                            },
                            "applicationRootUrl":{/literal}"{$smarty.const.GC_APP_ROOT_URL}"{literal}
                    });
                    return false;
                    });
                </script>
            {/literal}
        {/if}

        {if $smarty.const.USE_JQGRID == true}
            <script type="text/javascript">
                if (jQuery.jgrid)
                        jQuery.jgrid.useJSON = true;
            </script>
            <script type="text/javascript" language="javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/jquery/plugins/jquery.jqGrid/js/jquery.jqGrid.min.js"></script>
        {/if}

        <!-- jQuery Datepicker -->
        <script type="text/javascript">
            $.datepicker.setDefaults($.datepicker.regional['{$lang}']);
        </script>

        {if count($js_vars) > 0}
            <!-- JS initialization vars -->
            <script type="text/javascript">
                {foreach from=$js_vars key=key item=val}
                    {if $val === null}  var {$key} = null; {elseif is_numeric($val)}  var {$key} ={$val}; {else}  var {$key} = "{$val}"; {/if}

                {/foreach}
            </script>
        {/if}

        {if $USER_CONFIG_APPLICATION_INLINE_JS <> 'T'} {* ONLY FOR EXTERNAL JS *}
                <!-- Extra JS files -->
                {foreach from=$js_files item=file}
                    <script type="text/javascript" src="{$file}"></script>
                {/foreach}
            {/if}

            {if $xajax_js_include != ''}
                <!-- xajax library -->
                {$xajax_js_include}
                <!-- end of xajax library -->
            {/if}
            <!-- default JS settings -->
            <script type="text/javascript">
                {* Map settings *}
                {if $USER_CONFIG_SETTINGS_MAP_RES==''} {* Default map resoluzion *}
                        {assign var=mapsize value='x'|explode:"1024x768"}
                    {else}
                        {assign var=mapsize value='x'|explode:$USER_CONFIG_SETTINGS_MAP_RES}
                    {/if}
                var UserMapWidth ={$mapsize[0]};
                var UserMapHeight ={$mapsize[1]};
                var PopupErrorMsg = "{t}ATTENZIONE!\n\nBlocco dei popup attivo. Impossibile aprire la mappa. Disabilitare il blocco dei popup del browser e riprovare{/t}";
                    var MapFileName = "../map/index.php";
                    var MapName = "ECOGIS";
                    var errInvalidFloatNumberText = "{t}Numero non valido{/t}";
                        var errInvalidIntegerNumberText = "{t}Numero non valido{/t}";
                            var errInvalidYearText = "{t}Anno non valido{/t}";
                </script>

                {if $USER_CONFIG_APPLICATION_INLINE_JS == 'T'}
                    <!-- Inline javascript -->
                    <script type="text/javascript">
                        {foreach from=$js_files item=data}
                            {$data}
                        {/foreach}
                    </script>
                {/if}
                {* togliere da qui *}
                <style type="text/css">
                    {literal}
                        .ui-progressbar-value { background-image: url({/literal}{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD|lower}/pbar-ani.gif{literal}); }
                        .ui-resizable-se { bottom: 17px; }
                    {/literal}
                </style>

            </head>

            <body class="border" {if $smarty.get.padding <> ''}style="padding: {$smarty.get.padding}px"{/if}>
                <!-- jQuery GisClient Dialog -->
                {if isset($mapDialog) && isset($gisclient_folder)}
                    <div id="jQueryDialog" style="display:none;overflow:hidden;">
                        <div id="toolbar" class="fg-toolbar ui-widget-header ui-corner-all">
                            {if isset($mapTools.zoomFull) && isset($mapTools.zoomPrev) && isset($mapTools.zoomNext)}
                                <span> <!-- navigazione -->
                                    {if isset($mapTools.zoomFull)}
                                        <button id="zoom_full">Zoom estensione</button>
                                    {/if}
                                    {if isset($mapTools.zoomPrev)}
                                        <button id="zoom_prev">Vista precedente</button>
                                    {/if}
                                    {if isset($mapTools.zoomNext)}
                                        <button id="zoom_next">Vista successiva</button>
                                    {/if}
                                </span>
                            {/if}

                            {if isset($mapTools.Pan) && isset($mapTools.zoomIn) && isset($mapTools.zoomOut)}
                                <span> <!-- zooms -->
                                    {if isset($mapTools.Pan)}
                                        <input type="radio" id="pan" name="gc-toolbar-button" checked="checked" /><label for="pan">Pan</label>
                                    {/if}
                                    {if isset($mapTools.zoomIn)}
                                        <input type="radio" id="zoom_in" name="gc-toolbar-button" /><label for="zoom_in">Zoom in</label>
                                    {/if}
                                    {if isset($mapTools.zoomOut)}
                                        <input type="radio" id="zoom_out" name="gc-toolbar-button" /><label for="zoom_out">Zoom out</label>
                                    {/if}
                                    <input type="text" name="scaleDropDown" id="scaleDropDown">
                                </span>
                            {/if}
                            {if isset($mapTools.measureLine) && isset($mapTools.measureArea)}
                                <span> <!-- misure -->
                                    {if isset($mapTools.measureLine)}
                                        <input type="radio" id="measure_line" name="gc-toolbar-button" /><label for="measure_line">Misura lunghezza</label>
                                    {/if}
                                    {if isset($mapTools.measureArea)}
                                        <input type="radio" id="measure_polygon" name="gc-toolbar-button" /><label for="measure_polygon">Misura area</label>
                                    {/if}
                                </span>
                            {/if}

                            {if isset($mapTools.drawFeature)}
                                <span> <!-- strumenti disegno -->
                                    <input type="radio" id="draw_feature" name="gc-toolbar-button" /><label for="draw_feature">Disegna</label>
                                </span>
                            {/if}

                            {if isset($mapTools.reloadLayers)}
                                <span> <!-- reload -->
                                    <button id="reload_layers">Ricarica</button>
                                </span>
                            {/if}

                            {if isset($mapTools.mapPrint)}
                                <span> <!-- print -->
                                    <button id="print">Stampa</button>
                                </span>
                            {/if}

                            {if isset($mapTools.redline)}
                                <span> <!-- redline -->
                                    <input type="radio" id="redline" name="gc-toolbar-button" /><label for="redline">Annotazione</label>
                                </span>
                            {/if}

                            {if isset($mapTools.toolTip)}
                                <span> <!-- tooltip -->
                                    <input type="radio" id="tooltip" name="gc-toolbar-button" /><label for="tooltip">Tooltip</label>
                                </span>
                            {/if}

                            {if isset($mapTools.selectPoint)}
                                <span> <!-- select point -->
                                    <input type="radio" id="select_point" name="gc-toolbar-button" /><label for="select_point">Seleziona Punto</label>
                                </span>
                            {/if}

                            {if isset($mapTools.selectBox)}
                                <span> <!-- select box -->
                                    <input type="radio" id="select_box" name="gc-toolbar-button" /><label for="select_box">Seleziona Box</label>
                                </span>
                            {/if}

                            {if isset($mapTools.dialogToPopup)}
                                <span> <!-- select box -->
                                    <button id="dialog_to_popup">Apri mappa</button>	
                                </span>
                            {/if}
                        </div>
                        <div id="dialogMap" style="height:400px;"></div>
                        <div id="snap_options"> <!-- snap --></div>
                        <div id="misure_partial"></div>
                        <div id="misure"></div>
                        <div id="altro_da_posizionare">
                            <div id="loading_indicator" style="background-color:white;position:absolute;top:150px;left:600px;display:none;">Sto caricando...
                            </div>
                            <div id="errors_indicator" style="background-color:red;position:absolute;top:150px;left:600px;display:none;">Errore!<br /><span></span>
                            </div>
                            <div id="editing_settings" style="display:none;"></div>
                            <div id="div_layermanager" style="display:none;"></div>
                            <div id="div_customsearch" style="display:none;"></div>
                        </div>
                        <br><br><br>
                    </div>
                {/if}
                <!-- End Gisclient Dialog -->
