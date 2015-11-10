{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}
<h3 id="page_title">{$page_title}<span id="page_subtitle" style="display: none"></span></h3>

{* Map settings *}
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
        var langId = {$lang};
    {literal}

        function after_done_map_editing() {
            $('#geometryStatus').val('changed');
            $('#map_tr').show();  // Show the map tr
            $("#map_container").show();
            showPreviewMapBySession('edit_building', $('#session_id').val(), $('#lang').val(), $('#tollerance').val());
        }

        function afterGCDigitize(geometries) {
            $('#geometryStatus').val('changed');
            $('#map_tr').show();  // Show the map tr
            $("#map_container").show();
            $("#previewMap").show();
            storeFeatureToTemporaryTable('building', geometries, function () {
                updatePreviewMap(adminURL + 'files/previewmap/tmp/session_id/0/' + mapPreviewWidth + 'x' + mapPreviewHeight + '-50x50.png');
            });
        }

        $(document).ready(function () {
            $('#mu_id,#mu_name').bind('change', function () {
                loadFR_ST_CM();
            });
            $('#bt_id').bind('change', function () {
                updateForExtraData('#bt_id', '#bt_extradata');
            });
            $('#bpu_id').bind('change', function () {
                updateForExtraData('#bpu_id', '#bpu_extradata');
            });
            $('#ez_id,#ec_id').bind('change', function () {
                getEnergyClassLimit(this)
            });
            $('#bu_usage_h_from,#bu_usage_h_to').bind('change', function () {
                calcUsageHours();
                calcUsageYears()
            });
            $('#bu_usage_days,#bu_usage_weeks').bind('change', function () {
                calcUsageYears()
            });
            $('#openclose').bind('click', function () {
                toggleTable('table_form_part2', 'img_close', 'img_open');
            });
            $('#btnAddFraction').bind('click', function () {
                addFractionDlg()
            });
            $('#btnAddStreet').bind('click', function () {
                addStreetDlg()
            });
            $('#btnAddCatMunic').bind('click', function () {
                addCatMunicDlg()
            });
            $('#btnSave').bind('click', function () {
                submitFormDataBuilding()
            });
            $('#btnClose').bind('click', function () {
                window.close()
            });
            $('#btnCancel,#btnBack').bind('click', function () {
                listObject()
            });
            $('#btnEdit').bind('click', function () {
                modObject()
            });
            $('#btnMap').bind('click', function () {
                openBuildingMap($("#gisclient").val());
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
            autocomplete("#mu_name", {url: 'edit.php',
                on: 'building',
                method: 'fetch_municipality',
                pr_id: $('#pr_id').val(),
                limit: 20,
                minLength: 1});
            autocomplete("#fr_name", {url: 'edit.php',
                on: 'building',
                method: 'fetch_fraction',
                mu_id: $('#mu_id').val(),
                limit: 20,
                minLength: 1});
            autocomplete("#st_name", {url: 'edit.php',
                on: 'building',
                method: 'getStreetList',
                mu_id: $('#mu_id').val(),
                limit: 20,
                minLength: 1});

            updateForExtraData('#bt_id', '#bt_extradata');
            updateForExtraData('#bpu_id', '#bpu_extradata');
            calcUsageHours();
            calcUsageYears();

            if ($('#act').val() != 'add') {
                $('#table_form_part2').toggle(false);
            }
            // Calendar problem
            $('#ui-datepicker-div').css('display', 'none');

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
                            $('#page_subtitle').html(' - ' + $('#bu_name_' + langId).val()).toggle();
                        });
            }
            $("#progressbar_wrapper_photo").progressbar({value: 100});
            $("#progressbar_wrapper_label").progressbar({value: 100});
            $("#progressbar_wrapper_thermo").progressbar({value: 100});

            initializePhotos();
            // initializeMapPreview();
            //map_tr
            var hasGeometry = $("#has_geometry").val() == '1';
            $("#map_container").show(hasGeometry);
            if (hasGeometry) {
                $('#map_preview').bind('click', function () {
                    ZoomToMap('generic', 'building', $('#id').val());
                });
            }
            initChangeRecord();

            // Show element
            $('#modform').toggle(true);
            $('#tabs').toggle(true);
            updateMapButtonStatus();
            focusTo('#mu_id,#mu_name,#bu_code,#bu_name_1');

            $.each($('#readonly_fields').val().split(','), function (i, fieldId) {
                fieldId = $.trim(fieldId);
                if (fieldId != '') {
                    var e = $('#' + $.trim(fieldId));
                    if (e.get(0).tagName == 'SELECT') {
                        e.prop('disabled', true).addClass('input_readonly');
                    } else {
                        e.prop('readonly', true).addClass('input_readonly');
                    }
                }
            });
        });

        $(window).resize(function () {
            resizeTabHeight();
        });

    </script>
{/literal}

{include file=inline_help.tpl}
<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="id" value="{$vlu.bu_id}">
    <input type="hidden" name="has_geometry" id="has_geometry" value="{$vlu.has_geometry}">
    <input type="hidden" name="lang" id="lang" value="{$lang}">
    <input type="hidden" name="gisclient" id="gisclient" value="{$smarty.const.GISCLIENT}">
    <input type="hidden" name="readonly_fields" id="readonly_fields" value="{$USER_CONFIG_APPLICATION_BUILDING_READONLY_FIELDS}">
    <input type="hidden" name="geometryStatus" id="geometryStatus" value="">
    {foreach from=$vars key=key item=val}
        {if $key <> 'tabs'}<input type="hidden" name="{$key}" id="{$key}" value="{$val}" />{/if}
    {/foreach}

    {if $lkp.mu_values|@count <= 1}<input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}" />{/if}
    <div id="form_controls_container">
        {* TESTO EDIFICI *}
        {if $lang == 1 && $USER_CONFIG_APPLICATION_BUILDING_EDIT_INFO_1 <> ''}
            <div class="form_msg">{$USER_CONFIG_APPLICATION_BUILDING_EDIT_INFO_1}</div>
        {/if}
        {if $lang == 2 && $USER_CONFIG_APPLICATION_BUILDING_EDIT_INFO_2 <> ''}
            <div class="form_msg">{$USER_CONFIG_APPLICATION_BUILDING_EDIT_INFO_2}</div>
        {/if}
        <table class="table_form" id="table_form_part1" width="840">
            {if $lkp.mu_values|@count > 1}
                <tr>
                    <th><label class="help required" for="mu_id">{t}Comune{/t}:</label></th>
                    <td colspan="5">
                        {if $USER_CONFIG_APPLICATION_BUILDING_MUNICIPALITY_MODE <> 'COMBO'}
                            <input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}">
                            <input type="text" name="mu_name" id="mu_name" value="{$vlu.mu_name}" style="width:600px;">
                        {else}
                            <input type="hidden" name="mu_id" id="mu_id_dummy" value="{$vlu.mu_id}" />
                            <select name="mu_id" id="mu_id" style="width:600px" {if $act <> 'add'}class="readonly" disabled{/if}>
                                {if $act == 'add'}<option value="">{t}-- Selezionare --{/t}</option>{/if}
                                {html_options options=$lkp.mu_values selected=$vlu.mu_id}
                            </select>
                        {/if}
                    </td>
                </tr>
            {/if}

            {if $USER_CONFIG_APPLICATION_BUILDING_SHOW_ID == 'T' && $act != 'add'}
                    <tr>
                        <th><label class="help" for="bu_id_dummy">{t}ID edificio{/t}:</label></th>
                        <td colspan="5">
                            <input type="text" name="bu_id_dummy" id="bu_id_dummy" value="{$vlu.bu_id}" style="width: 80px" class="input_readonly" readonly />
                        </td>
                    </tr>
                {/if}


                {if $USER_CONFIG_APPLICATION_BUILDING_CODE_TYPE <> 'NONE'}
                        <tr>
                            <th><label class="help {if $USER_CONFIG_APPLICATION_BUILDING_CODE_REQUIRED == 'T'}required{/if}" for="bu_code">{t}Codice edificio{/t}:</label></th>
                            <td colspan="5">
                                {if $USER_CONFIG_APPLICATION_BUILDING_CODE_TYPE <> 'MANUAL' && $USER_CONFIG_APPLICATION_BUILDING_CODE_TYPE <> 'PROPOSED'}
                                        <input type="text" name="bu_code" id="bu_code" value="{$vlu.bu_code}" style="width: 100px" class="input_readonly" readonly />
                                    {else} {* Codice edificio NON editabile *}
                                        <input type="text" name="bu_code" id="bu_code" value="{$vlu.bu_code}" style="width: 100px" />
                                    {/if}
                                </td>
                            </tr>
                        {/if}

                        <tr>
                            <th width="150"><label class="required help" for="bu_name_1">{t}Nome edificio{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                            <td colspan="5">
                                <input type="text" name="bu_name_1" id="bu_name_1" value="{$vlu.bu_name_1}" style="width:600px;" />
                            </td>
                        </tr>
                        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
                            <tr>
                                <th><label class="required help" for="bu_name_2">{t}Nome edificio{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                                <td colspan="5"><input type="text" name="bu_name_2" id="bu_name_2" value="{$vlu.bu_name_2}" style="width:600px;" />
                            </tr>
                        {/if}

                        {if $USER_CAN_SHOW_FRACTION}  {* L'ente gestisce le frazioni *}
                                <tr>
                                    <th><label class="help" for="{if $USER_CONFIG_APPLICATION_BUILDING_FRACTION_MODE <> 'COMBO'}fr_name{else}fr_id{/if}">{t}Frazione{/t}:</label></th>
                                    <td colspan="5">
                                        {if $USER_CONFIG_APPLICATION_BUILDING_FRACTION_MODE <> 'COMBO'}
                                                <input type="text" name="fr_name" id="fr_name" value="{$vlu.fr_name}" style="width:600px;" />
                                            {else}
                                                <select name="fr_id" id="fr_id" style="width:500px;" {if $lkp.fr_values|@count == 0}disabled{/if}>
                                                    <option value="">{t}-- Selezionare --{/t}</option>
                                                    {html_options options=$lkp.fr_values selected=$vlu.fr_id}
                                                </select>
                                            {/if}
                                        {if $act != 'show'}{if $USER_CAN_ADD_FRACTION}<input type="button" name="btnAddFraction" id="btnAddFraction" value="{t}Aggiungi{/t}" style="width:80px;" {if $vlu.mu_id==''}disabled{/if} />{/if}{/if}

                                    </td>
                                </tr>
                            {/if}

                            {if $USER_CAN_SHOW_STREET}  {* L'ente gestisce le strade *}
                                    <tr>
                                        <th><label class="help" for="{if $USER_CONFIG_APPLICATION_BUILDING_STREET_MODE <> 'COMBO'}st_name{else}st_id{/if}">{t}Indirizzo{/t}:</label></th>
                                        <td>
                                            {if $USER_CONFIG_APPLICATION_BUILDING_STREET_MODE <> 'COMBO'}
                                                    <input type="text" name="st_name" id="st_name" value="{$vlu.st_name}" style="width:400px;" />
                                                {else}
                                                    <select name="st_id" id="st_id" style="width:350px;" {if $lkp.st_values|@count == 0}disabled{/if}>
                                                        <option value="">{t}-- Selezionare --{/t}</option>
                                                        {html_options options=$lkp.st_values selected=$vlu.st_id}
                                                    </select>
                                                {if $act != 'show'}{if $USER_CAN_ADD_STREET}<input type="button" name="btnAddStreet" id="btnAddStreet" value="{t}Aggiungi{/t}" style="width:80px;" {if $vlu.mu_id==''}disabled{/if} />{/if}{/if}
                                            {/if}
                                        </td>
                                        <th><label class="help" for="bu_nr_civic">{t}Nr. civico{/t}:</label></th>
                                        <td colspan="2">
                                            <input type="text" name="bu_nr_civic" id="bu_nr_civic" value="{$vlu.bu_nr_civic}" maxlength="5" class="integer" style="width: 50px;" > /
                                            <input type="text" name="bu_nr_civic_crossed" value="{$vlu.bu_nr_civic_crossed}" maxlength="3" style="width: 30px;" >
                                        </td>
                                    </tr>
                                {/if}

                                <tr id="openclose" class="openclose" title="{t}Apri/Chiudi{/t}">
                                    <td colspan="5">
                                        <img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_closed.gif" id="img_close" /><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_opened.gif" id="img_open" style="display:none" />
                                        {t}Apri/Chiudi{/t}
                                    </td>
                                </tr>
                            </table>

                            <table class="table_form" id="table_form_part2" width="840">
                                {if $act != 'add' && ($vlu.has_geometry || $vlu.images.building_photo|@count>0)}
                                    <!-- immagini -->
                                    <tr id="map_tr" align="center">
                                        <td colspan="3" valign="bottom">
                                            {foreach from=$vlu.images.building_photo item=doc_file_id}
                                                <div style="height: {$photo_preview_size[1]}px" class="image_container">
                                                    <img src="../images/ajax_loader.gif" class="graph_spinner" id="photo_{$doc_file_id}" />
                                                </div>
                                                <div style="height: 16px" class="image_label">{t}Foto{/t}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                    {if $act<>'show'}
                                                        <input type="checkbox" name="photo_{$doc_file_id}_delete" id="photo_{$doc_file_id}_delete" value="T" /><label for="photo_{$doc_file_id}_delete">{t}Cancella foto{/t}</label>
                                                    {/if}
                                                </div>
                                            {/foreach}
                                        </td>
                                        <td colspan="3" valign="bottom">
                                            {if $smarty.const.GISCLIENT}
                                                <img id="previewMap" style='cursor: pointer' title='{t}Visualizza su mappa{/t}'/>
                                            {else}    
                                                <div id="map_container" style="height: {$map_preview_size[1]}px" class="image_container">
                                                    {if $vlu.map_preview_url<>''}<img src="{$vlu.map_preview_url}" id="map_preview" class="photo clickable_image" />{/if}
                                                </div>
                                            {/if}
                                            <div style="height: 16px" class="image_label">{t}Mappa{/t}</div>
                                        </td>
                                    </tr>
                                    <tr align="center">
                                        <td colspan="3" valign="bottom">
                                            {foreach from=$vlu.images.building_label item=doc_file_id}
                                                <div class="image_container" style="height: {$photo_preview_size[1]}px">
                                                    <img src="../images/ajax_loader.gif" class="graph_spinner" id="label_{$doc_file_id}" />
                                                </div>
                                                <div style="height: 16px" class="image_label">{t}Targa energetica{/t}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                    {if $act<>'show'}
                                                        <input type="checkbox" name="label_{$doc_file_id}_delete" id="label_{$doc_file_id}_delete" value="T" /><label for="label_{$doc_file_id}_delete">{t}Cancella targa{/t}</label>
                                                    {/if}
                                                </div>
                                            {/foreach}
                                        </td>
                                        <td colspan="3" valign="bottom">
                                            {foreach from=$vlu.images.building_thermography item=doc_file_id}
                                                <div class="image_container" style="height: {$photo_preview_size[1]}px">
                                                    <img src="../images/ajax_loader.gif" class="graph_spinner" id="thermography_{$doc_file_id}" />
                                                </div>
                                                <div style="height: 16px" class="image_label building_schedule_css"><span>{t}Termografia{/t}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
                                                    {if $act<>'show'}
                                                        <div class="delete_building_schedule_css"><input type="checkbox" name="thermography_{$doc_file_id}_delete" id="thermography_{$doc_file_id}_delete" value="T" /><label for="thermography_{$doc_file_id}_delete">{t}Cancella termografia{/t}</label></div>
                                                        {/if}
                                                </div>
                                            {/foreach}
                                        </td>
                                    </tr>
                                    <tr class="separator building_separator_1"><td colspan="6"></td></tr>
                                    {else}
                                    <tr id="map_tr" style="display: none" align="center">
                                        <td colspan="3"></td>
                                        <td colspan="3">
                                            {if $smarty.const.GISCLIENT}
                                                <img id="previewMap" style='cursor: pointer' title='{t}Visualizza su mappa{/t}'/>
                                            {else}    
                                                <div id="map_container" style="height: {$map_preview_size[1]}px" class="image_container">
                                                    {if $vlu.map_preview_url<>''}<img src="{$vlu.map_preview_url}" id="map_preview" class="photo clickable_image" />{/if}
                                                </div>
                                            {/if}
                                            <div class="image_label">{t}Mappa{/t}</div>
                                        </td>
                                    </tr>
                                    <tr class="separator building_separator_2"><td colspan="6"></td></tr>
                                    {/if}

                                {if $USER_CONFIG_APPLICATION_CATASTRAL_TYPE == 'ITALY'}
                                        <tr class="building_cadastre_data">
                                            <th><label class="help" for="bu_section">{t}Sezione{/t}</label></th>
                                            <td colspan="5">
                                                <table border="0">
                                                    <tr>
                                                        <td><input type="text" name="bu_section" id="bu_section" value="{$vlu.bu_section}" style="width: 100px" ></td>
                                                        <th><label class="help" for="bu_sheet">{t}Foglio{/t}</label></th>
                                                        <td><input type="text" name="bu_sheet" id="bu_sheet" value="{$vlu.bu_sheet}" style="width: 100px" ></td>
                                                        <th><label class="help" for="bu_part">{t}Particella{/t}</label></th>
                                                        <td><input type="text" name="bu_part" id="bu_part" value="{$vlu.bu_part}" style="width: 100px" ></td>
                                                        <th><label class="help" for="bu_sub">{t}Subalterno{/t}</label></th>
                                                        <td><input type="text" name="bu_sub" id="bu_sub" value="{$vlu.bu_sub}" style="width: 100px" ></td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    {else}
                                        <tr class="building_cadastre_data">
                                            <th><label class="help" for="cm_id">{t}Comune catastale{/t}:</label></th>
                                            <td colspan="2">
                                                {if $USER_CONFIG_APPLICATION_BUILDING_CATASTRAL_MODE <> 'COMBO'}
                                                        <input type="text" name="cm_name" id="cm_id" value="{$vlu.cm_name}" style="width:250px;" />
                                                    {else}
                                                        <select name="cm_id" id="cm_id" style="width:200px;" {if $lkp.cm_values|@count == 0}disabled{/if}>
                                                            <option value="">{t}-- Selezionare --{/t}</option>
                                                            {html_options options=$lkp.cm_values selected=$vlu.cm_id}
                                                        </select>
                                                    {if $act != 'show'}{if $USER_CAN_ADD_CATMUNIC}<input type="button" name="btnAddCatMunic" id="btnAddCatMunic" value="{t}Aggiungi{/t}" style="width:80px;" tabindex="9999999999" {if $vlu.mu_id==''}disabled{/if} />{/if}{/if}
                                                {/if}
                                            </td>
                                            {* verificare campo address + ped/pf *}
                                            <th><label class="help" for="cm_number">{t}Particella{/t}:</label></th>
                                            <td colspan="2"><input type="text" name="cm_number" id="cm_number" value="{$vlu.cm_number}" style="width: 70px" ></td>
                                        </tr>
                                    {/if}

                                    <tr class="building_audit_data">
                                        <th><label class="help" for="bu_survey_date">{t}Data audit{/t}:</label></th>
                                        <td colspan="5"><input type="text" name="bu_survey_date" id="bu_survey_date" class="date" value="{$vlu.bu_survey_date}" style="width:100px;" /></td>
                                    </tr>

                                    <tr class="separator building_separator_3"><td colspan="6"></td></tr>
                                    <tr class="building_build_type_data">
                                        <th nowrap><label for="bt_id" class="help">{t}Tipologia costruttiva{/t}:</label></th>
                                        <td colspan="5">
                                            <select name="bt_id" id="bt_id" style="width:600px">
                                                <option value="">{t}-- Selezionare --{/t}</option>
                                                {foreach from=$lkp.bt_values key=key item=val}
                                                    <option label="{$val.bt_name}" {if $key==$vlu.bt_id || $lkp.bt_values|@count==1}selected{/if} value="{$key}" {if $val.bt_has_extradata=='T'}class="has_extradata"{/if}>{$val.bt_name}</option>
                                                {/foreach}
                                            </select>
                                        </td>
                                    </tr>
                                    <tr id="bt_extradata" class="building_build_type_data">
                                        <th></th>
                                        <td colspan="{if $NUM_LANGUAGES>1}2{else}5{/if}">
                                            <label>{t}Altro{/t}{$LANG_NAME_SHORT_FMT_1}:</label>
                                            <input type="text" id="bt_extradata_1" name="bt_extradata_1" style="width: {if $NUM_LANGUAGES>1}230px{else}500px{/if}" value="{$vlu.bt_extradata_1}">
                                        </td>
                                        {if $NUM_LANGUAGES>1}
                                            <td colspan="3">
                                                <label>{t}Altro{/t}{$LANG_NAME_SHORT_FMT_2}:</label>
                                                <input type="text" id="bt_extradata_2" name="bt_extradata_2" value="{$vlu.bt_extradata_2}" style="width: 230px">
                                            </td>
                                        {/if}
                                    </tr>

                                    <tr class="building_build_purpose_use_data">
                                        <th><label for="bpu_id" class="required help">{t}Destinazione d'uso{/t}:</label></th>
                                        <td colspan="5">
                                            <select name="bpu_id" id="bpu_id" style="width:600px;">
                                                <option value="">{t}-- Selezionare --{/t}</option>
                                                {foreach from=$lkp.bpu_values key=key item=val}
                                                    <option label="{$val.bpu_name}" {if $key==$vlu.bpu_id || $lkp.bpu_values|@count==1}selected{/if} value="{$key}" {if $val.bpu_has_extradata=='T'}class="has_extradata"{/if}>{$val.bpu_name}</option>
                                                {/foreach}
                                            </select>
                                        </td>
                                    </tr>
                                    <tr id="bpu_extradata" class="building_build_purpose_use_data">
                                        <th></th>
                                        <td colspan="{if $NUM_LANGUAGES>1}2{else}5{/if}">
                                            <label>{t}Altro{/t}{$LANG_NAME_SHORT_FMT_1}:</label>
                                            <input type="text" id="bpu_extradata_1" name="bpu_extradata_1" style="width: {if $NUM_LANGUAGES>1}230px{else}500px{/if}" value="{$vlu.bpu_extradata_1}">
                                        </td>
                                        {if $NUM_LANGUAGES>1}
                                            <td colspan="3">
                                                <label>{t}Altro{/t}{$LANG_NAME_SHORT_FMT_2}:</label>
                                                <input type="text" id="bpu_extradata_2" name="bpu_extradata_2" value="{$vlu.bt_extradata_2}" style="width: 230px">
                                            </td>
                                        {/if}
                                    </tr>

                                    <tr class="building_build_year_data">
                                        <th><label for="bby_id" class="help">{t}Anno costruzione{/t}:</label></th>
                                        <td colspan="2">
                                            {if $USER_CONFIG_APPLICATION_BUILDING_YEAR_TYPE=='TABLE'}
                                                <select name="bby_id" id="bby_id" style="width:130px;">
                                                    <option value="">{t}-- Selezionare --{/t}</option>
                                                    {html_options options=$lkp.bby_values selected=$vlu.bby_id}
                                                </select>
                                            {else}
                                                <input type="text" id="bu_build_year" class="year" name="bu_build_year" value="{$vlu.bu_build_year_as_string}" style="width: 80px">
                                            {/if}
                                        </td>
                                        <th><label for="bry_id" class="help">{t}Anno ristrutturazione{/t}:</label></th>
                                        <td colspan="2">
                                            {if $USER_CONFIG_APPLICATION_BUILDING_RESTRUCTURE_YEAR_TYPE=='TABLE'}
                                                <select name="bry_id" id="bry_id" style="width:130px;">
                                                    <option value="">{t}-- Selezionare --{/t}</option>
                                                    {html_options options=$lkp.bry_values selected=$vlu.bry_id}
                                                </select>
                                            {else}
                                                <input type="text" id="bu_restructure_year" class="year" name="bu_restructure_year" value="{$vlu.bu_restructure_year_as_string}" style="width: 80px">
                                            {/if}
                                        </td>
                                    </tr>

                                    <tr class="building_restructure_data">
                                        <th><label for="bu_restructure_descr_1" class="help">{t}Descrizione ristrutturazione{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                                        <td colspan="5">
                                            {if $act!='show'}<textarea name="bu_restructure_descr_1" id="bu_restructure_descr_1" style="width:600px;height:50px;" >{$vlu.bu_restructure_descr_1}</textarea>{else}<div class="textarea_readonly">{$vlu.bu_restructure_descr_1}&nbsp;</div>{/if}
                                        </td>
                                    </tr>
                                    {if $NUM_LANGUAGES>1}
                                        <tr class="building_restructure_data">
                                            <th><label for="bu_restructure_descr_2" class="help">{t}Descrizione ristrutturazione{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                                            <td colspan="5">
                                                {if $act!='show'}<textarea name="bu_restructure_descr_2" id="bu_restructure_descr_2" style="width:600px;height:50px;" >{$vlu.bu_restructure_descr_2}</textarea>{else}<div class="textarea_readonly">{$vlu.bu_restructure_descr_2}&nbsp;</div>{/if}
                                            </td>
                                        </tr>
                                    {/if}

                                    <tr class="building_dimension_data">
                                        <th><label for="bu_area_heating" class="help">{t}Sup.utile riscaldata{/t}:</label></th>
                                        <td colspan="2"><input type="text" id="bu_area_heating" name="bu_area_heating" class="float" data-dec="1" value="{$vlu.bu_area_heating}" style="width: 100px;" /> m²</td>
                                        <th nowrap><label for="bu_area" class="help">{t}Vol. lordo riscaldato{/t}:</label></th>
                                        <td colspan="2"><input type="text" id="bu_area" name="bu_area" value="{$vlu.bu_area}" class="float"  data-dec="1" style="width: 100px; " /> m³</td>
                                    </tr>

                                    <tr class="building_form_factor_data">
                                        <th><label for="bu_sv_factor" class="help">{t}Fattore forma S/V{/t}:</label></th>
                                        <td colspan="2">
                                            <input type="text" name="bu_sv_factor" id="bu_sv_factor" class="float" data-dec="2" value="{$vlu.bu_sv_factor}" style="width:80px;" >
                                        </td>
                                        <th><label for="bu_glass_area" class="help">{t}Superficie vetrata{/t}:</label></th>
                                        <td colspan="2"><input type="text" name="bu_glass_area" class="float" data-dec="1" value="{$vlu.bu_glass_area}" style="width: 100px;" > m²</td>
                                    </tr>


                                    <tr class="separator building_separator_4"><td colspan="6"></td></tr>
                                    <tr class="building_daily_usage_data">
                                        <th><label for="bu_usage_h_from" class="help">{t}Uso giorn. edificio{/t}:</label></th>
                                        <td colspan="2">
                                            <label for="bu_usage_h_from">{t}Dalle{/t}:</label>
                                            <span>
                                                <select name="bu_usage_h_from" id="bu_usage_h_from" style="width: 70px">
                                                    <option value="">--</option>
                                                    {html_options options=$lkp.bu_hour_from_values selected=$vlu.bu_usage_h_from}
                                                </select>
                                            </span>

                                            <label for="bu_usage_h_to">{t}alle{/t}:</label>
                                            <span>
                                                <select name="bu_usage_h_to" id="bu_usage_h_to" style="width: 70px">
                                                    <option value="">--</option>
                                                    {html_options options=$lkp.bu_hour_to_values selected=$vlu.bu_usage_h_to}
                                                </select>
                                            </span>
                                        </td>

                                        <th><label for="bu_daily_use_h" class="help">{t}Ore al giorno{/t}:</label></th>
                                        <td colspan="2">
                                            <input type="text" name="bu_daily_use_h" id="bu_daily_use_h"style="width: 80px;" class="readonly" tabindex="9999999999" />
                                        </td>
                                    </tr>

                                    <tr class="building_weekly_usage_data">
                                        <th><label for="bu_usage_days" class="help">{t}Uso sett. edificio{/t}:</label></th>
                                        <td colspan="2">
                                            <select name="bu_usage_days" id="bu_usage_days">
                                                <option value="">--</option>
                                                {html_options options=$lkp.bu_day_values selected=$vlu.bu_usage_days}
                                            </select>
                                            {t}giorni/settimana{/t}
                                        </td>
                                        <th><label for="bu_usage_weeks" class="help">{t}Uso annuale edificio{/t}:</label></th>
                                        <td colspan="2">
                                            <input type="text" name="bu_usage_weeks" id="bu_usage_weeks" class="integer" value="{$vlu.bu_usage_weeks}" style="width:80px" >
                                            {t}settimane/anno{/t}
                                        </td>
                                    </tr>
                                    <tr class="building_yearly_usage_data">
                                        <th><label for="bu_hour_year_use" class="help">{t}Ore anno uso{/t}:</label></th>
                                        <td colspan="2">
                                            <input type="text" name="bu_hour_year_use" id="bu_hour_year_use" class="integer input_readonly" value="{$vlu.bu_hour_year_use}" style="width: 80px;" readonly tabindex="9999999999" />
                                            {t}h/anno{/t}
                                        </td>
                                        <th><label for="bu_persons" class="help">{t}Occupanti edificio{/t}:</label></th>
                                        <td colspan="2">
                                            <input type="text" name="bu_persons" class="integer" value="{$vlu.bu_persons}" maxlength="5" style="width: 80px;" />
                                            {t}N° pers./gg{/t}
                                        </td>
                                    </tr>
                                    {if $lkp.ez_values|@count > 0 || $lkp.ec_values|@count > 0}
                                        <tr class="separator building_separator_5"><td colspan="6"></td></tr>
                                            {if $lkp.ez_values|@count > 0}
                                            <tr class="building_climatic_zone_data">
                                                <th>{t}Zona climatica{/t}:</th>
                                                <td colspan="5">
                                                    <select name="ez_id" id="ez_id" style="width:100px;">
                                                        <option value="">{t}--{/t}</option>
                                                        {html_options options=$lkp.ez_values selected=$vlu.ez_id}
                                                    </select>
                                                </td>
                                            </tr>
                                        {/if}
                                        {if $lkp.ec_values|@count > 0}
                                            <tr class="building_energy_class_data">
                                                <th>{t}Classe energetica{/t}:</th>
                                                <td colspan="2">
                                                    <select name="ec_id" id="ec_id" style="width:100px;">
                                                        <option value="">{t}--{/t}</option>
                                                        {html_options options=$lkp.ec_values selected=$vlu.ec_id}
                                                    </select>
                                                </td>

                                                <th class="building_climatic_zone_data">{t}Descrizione classe{/t}:</th>
                                                <td colspan="2" class="building_climatic_zone_data">
                                                    <select name="ecl_id" id="ecl_id" style="width:100px;" {if $lkp.ecl_values|@count <=1}disabled{/if}>
                                                        <option value="">{t}--{/t}</option>
                                                        {html_options options=$lkp.ecl_values selected=$vlu.ecl_id}
                                                    </select>
                                                    {t}kWh/m²*anno{/t}
                                                </td>
                                            </tr>
                                        {/if}
                                    {/if}

                                    <tr class="separator building_separator_6"><td colspan="6"></td></tr>

                                    <tr class="building_description_data">
                                        <th><label for="bu_descr_1" class="">{t}Note{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                                        <td colspan="5">
                                            {if $act!='show'}
                                                <textarea name="bu_descr_1" id="bu_descr_1" style="width:600px;height:50px;" >{$vlu.bu_descr_1}</textarea>
                                            {else}
                                                <div class="textarea_readonly">{$vlu.bu_descr_1}&nbsp;</div>
                                            {/if}
                                        </td>
                                    </tr>
                                    {if $NUM_LANGUAGES>1}
                                        <tr class="building_description_data">
                                            <th><label for="bu_descr_2" class="">{t}Note{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                                            <td colspan="5">
                                                {if $act!='show'}
                                                    <textarea name="bu_descr_2" id="bu_descr_2" style="width:600px;height:50px;" >{$vlu.bu_descr_2}</textarea>
                                                {else}
                                                    <div class="textarea_readonly">{$vlu.bu_descr_2}&nbsp;</div>
                                                {/if}
                                            </td>
                                        </tr>
                                    {/if}

                                    {if $USER_CONFIG_APPLICATION_BUILDING_EXTRA_DESCR == 'T'}
                                        <tr>
                                            <th><label for="bu_extra_descr_1" class="help">{t}Note sito pubblico{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                                            <td colspan="5">
                                                {if $act!='show'}
                                                    <textarea name="bu_extra_descr_1" id="bu_extra_descr_1" style="width:600px;height:50px;" >{$vlu.bu_extra_descr_1}</textarea>
                                                {else}
                                                    <div class="textarea_readonly">{$vlu.bu_extra_descr_1}&nbsp;</div>
                                                {/if}
                                            </td>
                                        </tr>
                                        {if $NUM_LANGUAGES>1}
                                            <tr>
                                                <th><label for="bu_extra_descr_2" class="help">{t}Note sito pubblico{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                                                <td colspan="5">
                                                    {if $act!='show'}
                                                        <textarea name="bu_extra_descr_2" id="bu_extra_descr_2" style="width:600px;height:50px;" >{$vlu.bu_extra_descr_2}</textarea>
                                                    {else}
                                                        <div class="textarea_readonly">{$vlu.bu_extra_descr_2}&nbsp;</div>
                                                    {/if}
                                                </td>
                                            </tr>
                                        {/if}
                                    {/if}

                                    <tr class="building_to_check_data">
                                        <th></th>
                                        <td colspan="5">
                                            <input type="checkbox" id="bu_to_check" name="bu_to_check" value="T" {if $vlu.bu_to_check == 'T'}checked{/if}>
                                            <label for="bu_to_check" class="help">{t}Da controllare{/t}</label>
                                        </td>
                                    </tr>
                                    {if $act != 'show'}
                                        <tr class="separator building_separator_7"><td colspan="6"></td></tr>
                                        <tr class="evidence"><td colspan="6">{t}Immagini{/t}:</td></tr>

                                        <tr class="building_picture_data">
                                            <th><label for="bu_photo" class="help">{t}Foto{/t} (Max {$config.upload_max_filesize}B):</label></th>
                                            <td colspan="5">
                                                <input type="file" id="foto_upload" class="upload upload_photo" style="width: 600px" maxlength="1" accept="gif|jpg|jpeg|png" name="bu_photo[]" size="100" >
                                                <div id="progressbar_wrapper_photo" style="height:7px; width: 200px; display: none" class="ui-widget-default">
                                                    <div class="progressbar" style="height:100%;"></div>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr class="building_map_data">
                                            <th><label for="bu_map" class="help">{t}Mappa{/t}:</label></th>
                                            <td colspan="5">
                                                <input type="button" name="btnMap" id="btnMap" value="{t}Digitalizza su mappa{/t}" style="width:150px;height:25px;">
                                            </td>
                                        </tr>
                                        <tr class="building_label_data">
                                            <th><label for="bu_label" class="help">{t}Targa energetica{/t} (Max {$config.upload_max_filesize}B):</label></th>
                                            <td colspan="5">
                                                <input type="file" class="upload upload_label" style="width: 600px" maxlength="1" accept="gif|jpg|jpeg|png" name="bu_label[]" size="100">
                                                <div id="progressbar_wrapper_label" style="height:7px; width: 200px; display: none" class="ui-widget-default">
                                                    <div class="progressbar" style="height:100%;"></div>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr class="building_thermography_data">
                                            <th><label for="bu_thermography" class="help">{t}Termografia{/t} (Max {$config.upload_max_filesize}B):</label></th>
                                            <td colspan="5">
                                                <input type="file" class="upload upload_thermo" style="width: 600px" maxlength="1" accept="gif|jpg|jpeg|png" name="bu_thermography[]" size="100">
                                                <div id="progressbar_wrapper_thermo" style="height:7px; width: 200px; display: none" class="ui-widget-default">
                                                    <div class="progressbar" style="height:100%;"></div>
                                                </div>
                                            </td>
                                        </tr>
                                    {/if}
                                    <tr><td colspan="6">{include file="record_change.tpl"}</td></tr>
                                    {if $vlu.im_id<>''}<tr><td colspan="6" style="padding-left: 20px"><i>{t}Questo edificio è stato importato automaticamente{/t}</i></td></tr>{/if}
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
                                        {if $USER_CAN_MOD_BUILDING}
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