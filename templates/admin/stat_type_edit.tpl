{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}
<h3 id="page_title">{$page_title}<span id="page_subtitle" style="display: none"></span></h3>

{literal}
    <script language="JavaScript" type="text/javascript">

        $(document).ready(function () {
            $('#btnSave').bind('click', function () {
                submitFormDataStatType()
            });

            $('#btnCancel,#btnBack').bind('click', function () {
                listObject()
            });

            $('#btnGenerateAbsoluteClass').bind('click', function () {
                $.getJSON('edit.php', {
                    'on': $('#on').val(),
                    'id': $('#id').val(),
                    'kind': 'absolute',
                    'method': 'generateStatisticClass'
                }, function (response) {
                    if (isAjaxResponseOk(response)) {
                        generateClassTables('absolute', response.data);
                    }
                });
            });

            $('#btnGenerateRelativeClass').bind('click', function () {
                $.getJSON('edit.php', {
                    'on': $('#on').val(),
                    'id': $('#id').val(),
                    'kind': 'relative',
                    'method': 'generateStatisticClass'
                }, function (response) {
                    if (isAjaxResponseOk(response)) {
                        generateClassTables('relative', response.data);
                    }
                });
            });

            initClassTables($('#is_value_stat').val() == '' ? 'expression' : 'value');
            generateClassTables('absolute', $.parseJSON($('input[name=absolute_class]').val()));
            generateClassTables('relative', $.parseJSON($('input[name=relative_class]').val()));

        });

    </script>
{/literal}

{include file=inline_help.tpl}
<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="id" value="{$vlu.st_id}">
    <input type="hidden" name="is_value_stat" id="is_value_stat" value="{$vlu.capabilities.is_value_stat}">
    <input type="hidden" name="absolute_class" value="{$vlu.classes.absolute|@json_encode}">
    <input type="hidden" name="relative_class" value="{$vlu.classes.relative|@json_encode}">

    {foreach from=$vars key=key item=val}
        {if $key <> 'tabs'}<input type="hidden" name="{$key}" id="{$key}" value="{$val}" />{/if}
    {/foreach}

    <table class="table_form" >
        <tr>
            <th><label class="required" for="st_code">{t}Codice{/t}:</label></th>
            <td><input type="text" name="st_code" id="st_code" value="{$vlu.st_code}" style="width: 600px" class="input_readonly" readonly /></td>
        </tr>
        <tr>
            <th><label class="required" for="st_title_short_1_parent">{t}Categoria principale{/t}:</label></th>
            <td><input type="text" name="st_title_short_1_parent" id="st_title_short_1_parent" value="{$vlu.st_title_short_1_parent}" style="width: 600px" class="input_readonly" readonly /></td>
        </tr>
        <tr>
            <th width="150"><label class="required" for="st_title_short_1">{t}Titolo corto{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="5">
                <input type="text" name="st_title_short_1" id="st_title_short_1" value="{$vlu.st_title_short_1}" style="width:600px;" />
            </td>
        </tr>
        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
            <tr>
                <th><label class="required" for="st_title_short_2">{t}Titolo corto{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="5"><input type="text" name="st_title_short_2" id="st_title_short_2" value="{$vlu.st_title_short_2}" style="width:600px;" />
            </tr>
        {/if}

        <tr>
            <th width="150"><label class="" for="st_title_long_1">{t}Titolo lungo{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="5">
                <input type="text" name="st_title_long_1" id="st_title_long_1" value="{$vlu.st_title_long_1}" style="width:600px;" />
            </td>
        </tr>
        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
            <tr>
                <th><label class="" for="st_title_long_2">{t}Titolo lungo{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="5"><input type="text" name="st_title_long_2" id="st_title_long_2" value="{$vlu.st_title_long_2}" style="width:600px;" />
            </tr>
        {/if}

        <tr>
            <th width="150"><label class="" for="st_udm_1">{t}Unità di misura assoluta{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="5">
                <input type="text" name="st_udm_1" id="st_udm_1" value="{$vlu.st_udm_1}" style="width:200px;" />
            </td>
        </tr>
        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
            <tr>
                <th><label class="" for="st_udm_2">{t}Unità di misura assolut{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="5"><input type="text" name="st_udm_2" id="st_udm_2" value="{$vlu.st_udm_2}" style="width:200px;" />
            </tr>
        {/if}

        <tr>
            <th width="150"><label class="" for="st_udm_relative_1">{t}Unità di misura relativa{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="5">
                <input type="text" name="st_udm_relative_1" id="st_udm_relative_1" value="{$vlu.st_udm_relative_1}" style="width:200px;" />
            </td>
        </tr>
        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
            <tr>
                <th><label class="" for="st_udm_relative_2">{t}Unità di misura assoluta{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="5"><input type="text" name="st_udm_relative_2" id="st_udm_relative_2" value="{$vlu.st_udm_relative_2}" style="width:200px;" />
            </tr>
        {/if}
        <tr>
            <th>Mostra dato testuale in tabella</th>
            <td>
                <input type="checkbox" id="st_show_text_value" name="st_show_text_value" value="T" {if $vlu.st_show_text_value == 'T'}checked{/if}>
                <label for="st_show_text_value" >{t}Si{/t}</label>
            </td>
        </tr>
        <tr>
            <th width="150"><label class="" for="st_text_value_title_1">{t}Titolo dato testuale{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="5"><input type="text" name="st_text_value_title_1" id="st_text_value_title_1" value="{$vlu.st_text_value_title_1}" style="width:500px;" /></td>
        </tr>
        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
            <tr>
                <th width="150"><label class="" for="st_text_value_title_2">{t}Titolo dato testuale{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="5"><input type="text" name="st_text_value_title_2" id="st_text_value_title_2" value="{$vlu.st_text_value_title_2}" style="width:500px;" /></td>
            </tr>
        {/if}
        <tr>
            <th><label for=st_descr_1" class="">{t}Descrizione superiore{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td>
                <textarea name="st_descr_1" id="st_descr_1" style="width:600px;height:50px;" >{$vlu.st_descr_1}</textarea>
            </td>
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label for=st_descr_2" class="">{t}Descrizione superiore{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                <td>
                    <textarea name="st_descr_2" id="st_descr_2" style="width:600px;height:50px;" >{$vlu.st_descr_2}</textarea>
                </td>
            </tr>
        {/if}


        <tr>
            <th><label for=st_lower_descr_1" class="">{t}Descrizione inferiore{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td>
                <textarea name="st_lower_descr_1" id="st_lower_descr_1" style="width:600px;height:50px;" >{$vlu.st_lower_descr_1}</textarea>
            </td>
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label for=st_lower_descr_2" class="">{t}Descrizione inferiore{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                <td>
                    <textarea name="st_lower_descr_2" id="st_lower_descr_2" style="width:600px;height:50px;" >{$vlu.st_lower_descr_2}</textarea>
                </td>
            </tr>
        {/if}

        <tr>
            <th><label class="required" for="st_order">{t}Ordinamento{/t}:</label></th>
            <td><input type="text" name="st_order" id="st_order" value="{$vlu.st_order}" style="width: 100px" /></td>
        </tr>

        <tr>
            <th colspan="2"><hr></th>
        </tr>
        <tr>
            <th>Attiva (calcola)</th>
            <td>
                <input type="checkbox" id="st_enable" name="st_enable" value="T" {if $vlu.st_enable == 'T'}checked{/if}>
                <label for="st_enable" >{t}Si{/t}</label>
            </td>
        </tr>
        <tr>
            <th>Visibile (su portale pubblico)</th>
            <td>
                <input type="checkbox" id="st_visible" name="st_visible" value="T" {if $vlu.st_visible == 'T'}checked{/if}>
                <label for="st_visible" >{t}Si{/t}</label>
            </td>
        </tr>
        <tr>
            <th>Richiede autenticazione</th>
            <td>
                <input type="checkbox" id="st_private" name="st_private" value="T" {if $vlu.st_private == 'T'}checked{/if}>
                <label for="st_private" >{t}Si{/t}</label>
            </td>
        </tr>

        <tr>
            <th>Rendering con griglia</th>
            <td>
                <input type="checkbox" id="st_render_map_as_grid" name="st_render_map_as_grid" value="T" {if $vlu.st_render_map_as_grid == 'T'}checked{/if}>
                <label for="st_render_map_as_grid" >{t}Si{/t}</label>
            </td>
        </tr>
        <tr>
            <th>Rendering anteprima con griglia</th>
            <td>
                <input type="checkbox" id="st_render_preview_as_grid" name="st_render_preview_as_grid" value="T" {if $vlu.st_render_preview_as_grid == 'T'}checked{/if}>
                <label for="st_render_preview_as_grid" >{t}Si{/t}</label>
            </td>
        </tr>




        <tr>
            <th colspan="2"><hr></th>
        </tr>

        <tr>
            <th>Statistica con ambito comunale</th>
            <td>
                <input type="checkbox" id="st_has_municipality_data" name="st_has_municipality_data" value="T" {if $vlu.st_has_municipality_data == 'T'}checked{/if}>
                <label for="st_has_municipality_data" >{t}Si{/t}</label>
            </td>
        </tr>

        <tr>
            <th>Statistica con ambito aggregazione di comuni</th>
            <td>
                <input type="checkbox" id="st_has_municipality_community_data" name="st_has_municipality_community_data" value="T" {if $vlu.st_has_municipality_community_data == 'T'}checked{/if}>
                <label for="st_has_municipality_community_data" >{t}Si{/t}</label>
            </td>
        </tr>

        <tr>
            <th>Statistica con ambito provinciale</th>
            <td>
                <input type="checkbox" id="st_has_province_data" name="st_has_province_data" value="T" {if $vlu.st_has_province_data == 'T'}checked{/if}>
                <label for="st_has_province_data" >{t}Si{/t}</label>
            </td>
        </tr>

        <tr>
            <th colspan="2"><hr></th>
        </tr>
        <tr>
            <th>Dati assoluti</th>
            <td>
                <input type="checkbox" id="st_has_absolute_data" name="st_has_absolute_data" value="T" {if $vlu.st_has_absolute_data == 'T'}checked{/if}>
                <label for="st_has_absolute_data" >{t}Si{/t}</label>
            </td>
        </tr>

        <tr>
            <th>Dati relativi</th>
            <td>
                <input type="checkbox" id="st_has_relative_data" name="st_has_relative_data" value="T" {if $vlu.st_has_relative_data == 'T'}checked{/if}>
                <label for="st_has_relative_data" >{t}Si{/t}</label>
            </td>
        </tr>
        <tr>
            <th>Statistica su base annua</th>
            <td>
                <input type="checkbox" id="st_has_year" name="st_has_year" value="T" {if $vlu.st_has_year == 'T'}checked{/if}>
                <label for="st_has_year" >{t}Si{/t}</label>
            </td>
        </tr>

        <tr>
            <th>Filtrabile per destinazione d'uso edificio</th>
            <td>
                <input type="checkbox" id="st_has_building_purpose_use" name="st_has_building_purpose_use" value="T" {if $vlu.st_has_building_purpose_use == 'T'}checked{/if}>
                <label for="st_has_building_purpose_use" >{t}Si{/t}</label>
            </td>
        </tr>

        <tr>
            <th>Filtrabile per anno di costruzione edificio</th>
            <td>
                <input type="checkbox" id="st_has_building_build_year" name="st_has_building_build_year" value="T" {if $vlu.st_has_building_build_year == 'T'}checked{/if}>
                <label for="st_has_building_build_year" >{t}Si{/t}</label>
            </td>
        </tr>



        <tr>
            <th>Filtrabile per categorie inventario/PAES</th>
            <td>
                <input type="checkbox" id="st_has_category_data" name="st_has_category_data" value="T" {if $vlu.st_has_category_data == 'T'}checked{/if}>
                <label for="st_has_category_data" >{t}Si{/t}</label>
            </td>
        </tr>
        <tr>
            <th>Filtrabile per alimentazione inventario/PAES</th>
            <td>
                <input type="checkbox" id="st_has_energy_source_data" name="st_has_energy_source_data" value="T" {if $vlu.st_has_energy_source_data == 'T'}checked{/if}>
                <label for="st_has_energy_source_data" >{t}Si{/t}</label>
            </td>
        </tr>

    </table>
    <br />

    <hr>
    Classi assolute (<input type="button" name="btnGenerateAbsoluteClass" id="btnGenerateAbsoluteClass" value="{t}Genera automaticamente{/t}">)
    <table class="legend absolute_class" border="1">
        <tr>
            <th class="expression">{t}Testo{/t}{$LANG_NAME_SHORT_FMT_1}</th>
            <th class="expression" {if $NUM_LANGUAGES<=1}style="display: none"{/if}>{t}Testo{/t}{$LANG_NAME_SHORT_FMT_2}</th>
            <th class="value">Valore</th>
            <th class="expression value">Colore</th>
            <th class="expression value">Colore bordo</th>
            <th class="expression">Espressione</th>
            <th class="expression value">Ordine</th>
            <th class="expression value">Azione <a class="add_row" href="#"><img src="../images/ico_add.gif" /></a></th>
        </tr>
        <tr class="template">
            <td class="expression"><input type="hidden" name="stc_type[]" value="absolute" ><input type="text" name="stc_text_1[]" value="" style="width: 200px" /></td>
            <td class="expression" {if $NUM_LANGUAGES<=1}style="display: none"{/if}><input type="text" name="stc_text_2[]" value="" style="width: 200px" /></td>
            <td class="value"><input type="text" name="stc_value[]" value="" ></td>
            <td class="expression value"><input type="text" name="stc_color[]" value="" style="width: 80px" /></td>
            <td class="expression value"><input type="text" name="stc_outline_color[]" value="" style="width: 80px"></td>
            <td class="expression"><input type="text" name="stc_expression[]" value="" style="width: 200px" /></td>
            <td class="expression value"><input type="text" name="stc_order[]" value="" style="width: 50px; text-align: right" /></td>
            <td class="expression value"><a class="delete_row" href="#"><img src="../images/ico_del.gif" /></a></td>
        </tr>
    </table>
    <br />

    <hr>
    Classi relative (<input type="button" name="btnGenerateRelativeClass" id="btnGenerateRelativeClass" value="{t}Genera automaticamente{/t}">)
    <table class="legend relative_class" border="1">
        <tr>
            <th class="expression">{t}Testo{/t}{$LANG_NAME_SHORT_FMT_1}</th>
            <th class="expression" {if $NUM_LANGUAGES<=1}style="display: none"{/if}>{t}Testo{/t}{$LANG_NAME_SHORT_FMT_2}</th>
            <th class="value">Valore</th>
            <th class="expression value">Colore</th>
            <th class="expression value">Colore bordo</th>
            <th class="expression">Espressione</th>
            <th class="expression value">Ordine</th>
            <th class="expression value">Azione <a class="add_row" href="#"><img src="../images/ico_add.gif" /></a></th>
        </tr>
        <tr class="template">
            <td class="expression"><input type="hidden" name="stc_type[]" value="relative" ><input type="text" name="stc_text_1[]" value="" style="width: 200px" /></td>
            <td class="expression" {if $NUM_LANGUAGES<=1}style="display: none"{/if}><input type="text" name="stc_text_2[]" value="" style="width: 200px" /></td>
            <td class="value"><input type="text" name="stc_value[]" value="" ></td>
            <td class="expression value"><input type="text" name="stc_color[]" value="" style="width: 80px" /></td>
            <td class="expression value"><input type="text" name="stc_outline_color[]" value="" style="width: 80px" /></td>
            <td class="expression"><input type="text" name="stc_expression[]" value="" style="width: 200px" /></td>
            <td class="expression value"><input type="text" name="stc_order[]" value="" style="width: 50px; text-align: right" /></td>
            <td class="expression value"><a class="delete_row" href="#"><img src="../images/ico_del.gif" /></a></td>
        </tr>
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



{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}