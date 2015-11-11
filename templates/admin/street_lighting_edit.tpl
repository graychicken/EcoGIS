{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

<h3 id="page_title">{$page_title}<span id="page_subtitle" style="display: none"></span></h3>
    {assign var=photo_preview_size value='x'|explode:$USER_CONFIG_APPLICATION_PHOTO_PREVIEW_SIZE}
    {assign var=map_preview_size value='x'|explode:$USER_CONFIG_APPLICATION_MAP_PREVIEW_SIZE}

{literal}
    <script language="JavaScript" type="text/javascript">

    {/literal}
        var adminURL = '{$smarty.const.R3_ADMIN_URL}';
        var photoPreviewWidth = {$photo_preview_size[0]};
        var photoPreviewHeight = {$photo_preview_size[1]};
        var mapPreviewWidth = {$map_preview_size[0]};
        var mapPreviewHeight = {$map_preview_size[1]};
    {literal}

        function after_done_map_editing() {
            // Mettere anche in strade e paes
            $('#geometryStatus').val('changed');
            $('#map_tr').show();  // Show the map tr
            $("#map_container").show();
            showPreviewMapBySession('edit_street_lighting', $('#session_id').val(), $('#lang').val(), $('#tollerance').val());
            updateStreetLength(true);
        }

        function afterGCDigitize(geometries) {
            $('#geometryStatus').val('changed');
            $('#map_tr').show();  // Show the map tr
            $("#map_container").show();
            $("#previewMap").show();
            storeFeatureToTemporaryTable('street_lighting', geometries, function () {
                updateStreetLength(true);
                updatePreviewMap(adminURL + 'files/previewmap/tmp/session_id/0/' + mapPreviewWidth + 'x' + mapPreviewHeight + '-50x50.png');
            });
        }

        $(document).ready(function () {
            $('#btnSave').bind('click', function () {
                submitFormDataStreetLighting('#modform')
            });
            $('#btnCancel,#btnBack').bind('click', function () {
                listObject()
            });
            $('#btnClose').bind('click', function () {
                window.close()
            });
            $('#btnEdit').bind('click', function () {
                modObject()
            });
            $('#btnMap').bind('click', function () {
                openStreetLightingMap($("#gisclient").val());
            });
            $('#btnAddStreet').bind('click', function () {
                addStreetDlg()
            });
            $('#mu_id,#mu_name').bind('change', function () {
                changeMunicipality();
            });

            autocomplete("#mu_name", {url: 'edit.php',
                on: 'street_lighting',
                method: 'getMunicipalityList',
                do_id: $('#do_id').val(),
                pr_id: $('#pr_id').val(),
                limit: 20,
                minLength: 2
            });

            if ($('#act').val() == 'show') {
                setupShowMode();  // Setup the show mode
                setupInputFormat('#modform', false);
            } else {
                setupInputFormat('#modform');
                setupRequired('#modform');
                $('#bu_survey_date').datepicker('option', {yearRange: '-20:+0'});
            }
            setupReadOnly('#modform');
            if ($("#tabs").length > 0) {
                // Tabs not always enabled
                $("#tabs").tabs({cache: true, ajaxOptions: {cache: true}});
                $("#tabs ul").css('padding-left', '35px').parent().prepend('<img id="btnTabsResize" src="../images/tabresize.png">');
                $('#btnTabsResize')
                        .bind('mouseenter', function () {
                            $(this).addClass('tr_hover')
                        })
                        .bind('mouseleave', function () {
                            $(this).removeClass('tr_hover')
                        })
                        .bind('click', function () {
                            $('#form_controls_container').toggle();
                            resizeTabHeight();
                            if ($('#sl_descr_1').val() == '') {
                                $('#page_subtitle').html(' - ' + $('#st_id option:selected').text()).toggle();
                            } else {
                                $('#page_subtitle').html(' - ' + $('#st_id option:selected').text() + ' - ' + $('#sl_descr_1').val()).toggle();
                            }
                        });
            }

            $('#modform').toggle(true);  // Show the form
            initChangeRecord();

            var hasGeometry = $("#has_geometry").val() == '1';
            $("#map_container").show(hasGeometry);
            $("#previewMap").toggle(hasGeometry);
            if (hasGeometry) {
                $('#map_preview').bind('click', function () {
                    ZoomToMap('generic', 'street_lighting', $('#id').val());
                });
            }
            updateMapButtonStatus();
            $('#tabs').toggle(true);
            focusTo('#mu_id,#mu_name,#st_id,#st_name');

        });

        $(window).resize(function () {
            resizeTabHeight();
        });
    </script>
{/literal}

{include file=inline_help.tpl}

<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" style="display:none">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="id" value="{$vlu.sl_id}">
    <input type="hidden" name="has_geometry" id="has_geometry" value="{$vlu.has_geometry}">
    <input type="hidden" name="lang" id="lang" value="{$lang}">
    <input type="hidden" name="geometryStatus" id="geometryStatus" value="">
    <input type="hidden" name="gisclient" id="gisclient" value="{$smarty.const.GISCLIENT}">
    {foreach from=$vars key=key item=val}
        {if $key <> 'tabs'}<input type="hidden" name="{$key}" id="{$key}" value="{$val}" />{/if}
    {/foreach}
    <div id="form_controls_container">
        <table class="table_form">
            {if $lkp.mu_values|@count > 1}
                <tr>
                    <th><label class="help required" for="mu_id">{t}Comune{/t}:</label></th>
                    <td colspan="3">
                        {if $USER_CONFIG_APPLICATION_BUILDING_MUNICIPALITY_MODE <> 'COMBO'}
                            {* <input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}"> *}
                            <input type="text" name="mu_name" id="mu_name" value="{$vlu.mu_name}" style="width:700px;">
                        {else}
                            <input type="hidden" name="mu_id" id="mu_id_dummy" value="{$vlu.mu_id}" />
                            <select name="mu_id" id="mu_id" style="width:700px" {if $act <> 'add'}class="readonly" disabled{/if}>
                                {if $act == 'add'}<option value="">{t}-- Selezionare --{/t}</option>{/if}
                                {html_options options=$lkp.mu_values selected=$vlu.mu_id}
                            </select>
                        {/if}
                    </td>
                </tr>
            {else}
                <input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}">
            {/if}

            {if $USER_CAN_SHOW_STREET}  {* L'ente gestisce le strade *}
                    <tr>
                        <th><label class="help required" for="st_id">{t}Via{/t}:</label></th>
                        <td colspan="3">
                            {if $USER_CONFIG_APPLICATION_BUILDING_STREET_MODE <> 'COMBO'}
                                    <input type="text" name="st_name" id="st_id" value="{$vlu.st_name}" maxlength="80" style="width:700px;" />
                                {else}
                                    <select name="st_id" id="st_id" style="width:600px;" {if $lkp.st_values|@count == 0}disabled{/if} >
                                        <option value="">{t}-- Selezionare --{/t}</option>
                                        {html_options options=$lkp.st_values selected=$vlu.st_id}
                                    </select>
                                {if $act != 'show'}{if $USER_CAN_ADD_STREET}<input type="button" name="btnAddStreet" id="btnAddStreet" value="{t}Aggiungi{/t}" style="width:80px;" {if $vlu.mu_id==''}disabled{/if} />{/if}{/if}
                            {/if}
                        </td>
                    </tr>
                {/if}
                <tr>
                    <th><label class="help" for="sl_descr_1">{t}Descrizione tratto{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                    <td colspan="3"><input type="text" name="sl_descr_1" id="sl_descr_1" value="{$vlu.sl_descr_1}" style="width:700px;"></td>
                </tr>
                {if $NUM_LANGUAGES>1}
                    <tr>
                        <th><label class="help" for="sl_descr_2">{t}Descrizione tratto{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                        <td colspan="3"><input type="text" name="sl_descr_2" id="sl_descr_2" value="{$vlu.sl_descr_2}" style="width:700px;"></td>
                    </tr>
                {/if}

                <tr>
                    <th><label class="help" for="sl_length">{t}Lunghezza{/t}:</label></th>
                    <td><input type="text" name="sl_length" id="sl_length" value="{$vlu.sl_length}" class="float" data-dec="2" style="width:100px"> {t}m{/t}</td>
                    <th><input type="checkbox" id="sl_to_check" name="sl_to_check" value="T" {if $vlu.sl_to_check == 'T' || $vlu.sl_to_check == 'TRUE'}checked{/if}></th>
                    <td><label for="sl_to_check" class="help">{t}Da controllare{/t}</label></td>
                </tr>


                <tr>
                    <th>{t}Mappa{/t}:</th>
                    <td colspan="3">


                        {if $smarty.const.GISCLIENT}
                            <img id="previewMap" style='cursor: pointer' title='{t}Visualizza su mappa{/t}' />
                        {else}    
                            <div id="map_container" style="height: {$photo_preview_size[1]}px" class="image_container">
                                {if $vlu.map_preview_url<>''}<img src="{$vlu.map_preview_url}" id="map_preview" class="photo clickable_image" />{/if}
                            </div>
                        {/if}
                        {if $act != 'show'}<input type="button" name="btnMap" id="btnMap" value="{t}Digitalizza su mappa{/t}" style="width:150px;height:25px;">{/if}
                    </td>
                </tr>

                <tr>
                    <th><label class="" for="sl_text_1">{t}Note{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                    <td colspan="3">
                        {if $act!='show'}
                            <textarea style="width:700px; height:50px;" name="sl_text_1" id="sl_text_1">{$vlu.sl_text_1}</textarea>
                        {else}
                            <div class="textarea_readonly">{$vlu.sl_text_1}&nbsp;</div>
                        {/if}
                    </td>
                </tr>
                {if $NUM_LANGUAGES>1}
                    <tr>
                        <th><label class="" for="sl_text_1">{t}Note{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                        <td colspan="3">
                            {if $act!='show'}
                                <textarea style="width:700px; height:50px;" name="sl_text_2" id="sl_text_2">{$vlu.sl_text_2}</textarea>
                            {else}
                                <div class="textarea_readonly">{$vlu.sl_text_2}&nbsp;</div>
                            {/if}
                        </td>
                    </tr>
                {/if}
                <tr><td colspan="6">{include file="record_change.tpl"}</td></tr>
                {if $vlu.im_id<>''}<tr><td colspan="6" style="padding-left: 20px"><i>{t}Questo tratto di illuminazione stradale è stato importato automaticamente{/t}</i></td></tr>{/if}
            </table>
            <br />
            {if $vars.parent_act == 'show'}
                <input type="button" id="btnClose" name="btnClose"  value="{t}Chiudi{/t}" style="width:120px;height:25px;" />
            {else}
                {if $act != 'show'}
                    {if $act == 'add'}
                        <input type="button" id="btnSave" name="btnSave"  value="{t}Salva e continua{/t}" style="width:160px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
                    {else}
                        <input type="button" id="btnSave" name="btnSave"  value="{t}Salva{/t}" style="width:75px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
                    {/if}
                    <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" style="width:75px;height:25px;">
                {else}
                    {if $USER_CAN_MOD_STREET_LIGHTING}
                        <input type="button" name="btnEdit" id="btnEdit" value="{t}Modifica{/t}" style="width:75px;height:25px;">&nbsp;&nbsp;&nbsp;&nbsp;
                    {/if}
                    <input type="button" name="btnBack" id="btnBack"  value="{t}Indietro{/t}" style="width:75px;height:25px;">
                {/if}
            {/if}
        </div>
    </form>

    {if $act != 'add'}
        <br />
        {r3tab id='tabs' items=$vars.tabs style="display: none; height: 300px" istyle="height: 250px; width: 100%" autoInit=false onLoad="resizeTabHeight()" mode=$vars.tab_mode}
    {/if}
{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}