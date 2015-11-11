{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

<h3 id="page_title">{$page_title}</h3>

{literal}
    <script language="JavaScript" type="text/javascript">
        var dataChanged = '';

        $(document).ready(function () {
            $('#mu_id,#mu_name').bind('change', function () {
                loadGE_GS()
            });
            $('#btnSave').bind('click', function () {
                submitFormDataGlobalStrategy()
            });
            $('#btnCancel,#btnBack').bind('click', function () {
                btnCancelClick()
            });
            $('#btnClose').bind('click', function () {
                window.close()
            });
            $('#btnExport').bind('click', function () {
                if (dataChanged != '') {
                    $('#export_paes').val('T');
                }
                exportPAESDlg($('#id').val(), dataChanged);
            });

            $('#btnDownload').css('display', 'none');

            $('#btnEdit').bind('click', function () {
                modObject()
            });

            $('#btnMap').bind('click', function () {
                GenericOpenMap('edit_layer&layer=building&act=' + $('#act').val() + '&id=' + $('#id').val())
            });

            if ($('#act').val() == 'show' || $('#view_mode').val() == 'T') {
                setupShowMode();  // Setup the show mode
                setupInputFormat('#modform', false);
            } else {
                setupInputFormat('#modform');
                setupRequired('#modform');
            }

            initChangeRecord();

            setupReadOnly('#modform');
            autocomplete("#mu_name", {url: 'edit.php',
                on: 'building',
                method: 'fetch_municipality',
                pr_id: $('#pr_id').val(),
                limit: 20,
                minLength: 1});

            $('#modform').show();
            focusTo('#mu_id,#mu_name,#gst_name_1');

            $('input,textarea,select').change(function () {
                dataChanged = 'T';
                $('#btnExport').val($('#btnExport').attr('data-alt-value'));
            });

        });

    </script>
{/literal}

{include file=inline_help.tpl}

<div id="info_container" class="info_container" {if $vars.info_text==''}style="display: none"{/if}>{$vars.info_text}</div>

<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" style="display: none">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="id" value="{$vlu.gst_id}">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}

    {if $lkp.mu_values|@count <= 1}<input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}" />{/if}
    {* tabella paes *}
    <table class="table_form" style="width: 850px;">

        <tr class="evidence"><td colspan="6">{t}Dati generali{/t}</td></tr>

        {if $lkp.mu_values|@count > 1}
            <tr>
                <th><label class="help required" for="mu_id">{if $lkp.mu_values.tot.collection > 0}{t}Comune/raggruppamento{/t}{else}{t}Comune{/t}{/if}:</label></th>
                <td colspan="5">
                    {if $USER_CONFIG_APPLICATION_BUILDING_MUNICIPALITY_MODE <> 'COMBO'}
                        <input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}" />
                        <input type="text" name="mu_name" id="mu_name" value="{$vlu.mu_name}" style="width:97%;" class="{if $act == 'mod'}readonly{/if}" />
                    {else}
                        <input type="hidden" name="mu_id" id="mu_id_dummy" value="{$vlu.mu_id}" />
                        {if $act <> 'add'}
                            <input type="text" name="mu_name" id="mu_name" value="{$vlu.mu_name}" style="width:97%" class="readonly"/>
                        {else}        
                            <select name="mu_id" id="mu_id" style="width:250px" >
                                {if $lkp.mu_values.tot.municipality > 1}<option value="">{t}-- Selezionare --{/t}</option>{/if}
                                {html_options options=$lkp.mu_values.data selected=$vlu.mu_id}
                            </select>
                        {/if}
                    {/if}
                </td>
            </tr>
        {/if}

        <tr>
            <th><label class="required help" for="gst_name_1">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="5"><input type="text" name="gst_name_1" id="gst_name_1" value="{$vlu.gst_name_1}" style="width:97%;" /></td>
        </tr>
        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
            <tr>
                <th><label class="required help" for="gst_name_2">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="5"><input type="text" name="gst_name_2" id="gst_name_2" value="{$vlu.gst_name_2}" style="width:97%;" /></td>
            </tr>
        {/if}
        <tr>
            <th><label for="gst_target_descr_1" class="help">{t}Target a lungo termine{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="5">
                {if $act!='show'}<textarea name="gst_target_descr_1" id="gst_target_descr_1" style="width:97%;height:50px;" >{$vlu.gst_target_descr_1}</textarea>{else}<div class="textarea_readonly">{$vlu.gst_target_descr_1}&nbsp;</div>{/if}
            </td>
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label for="gst_target_descr_2" class="help">{t}Target a lungo termine{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="5">
                    {if $act!='show'}<textarea name="gst_target_descr_2" id="gst_target_descr_2" style="width:97%;height:50px;" >{$vlu.gst_target_descr_2}</textarea>{else}<div class="textarea_readonly">{$vlu.gst_target_descr_2}&nbsp;</div>{/if}
                </td>
            </tr>
        {/if}

        <tr class="evidence"><td colspan="6">{t escape="no"}Obiettivi di riduzione delle emissioni di CO<sub>2</sub>{/t}</td></tr>
        <tr><td colspan="6">
                <table width="100%" class="table_form" style="border: none;">
                    <tr>
                        <th><label class="required help" for="gst_reduction_target">{t}Obiettivo previsto{/t}:</label></th>
                        <td><input type="text" name="gst_reduction_target" id="gst_reduction_target" value="{$vlu.gst_reduction_target}" class="float" data-dec="1" style="width:60px;" /> %</td>
                        <th><label class="required help" for="gst_reduction_target_year">{t}Anno{/t}:</label></th>
                        <td nowrap><input type="text" name="gst_reduction_target_year" id="gst_reduction_target_year" value="{$vlu.gst_reduction_target_year}" style="width:50px;" class="year" />
                            <label class="required help" for="gst_reduction_target_citizen">{t}Abitanti{/t}:</label>
                            <input type="text" name="gst_reduction_target_citizen" id="gst_reduction_target_citizen" value="{$vlu.gst_reduction_target_citizen}" style="width:80px;" class="integer" /></td>

                        <th><label class="required help" for="gst_reduction_target_absolute">{t}Riduzione{/t}:</label></th>
                        <td>
                            <input type="radio" name="gst_reduction_target_absolute" id="gst_reduction_target_absolute" value="T" {if $vlu.gst_reduction_target_absolute == 'T'}checked{/if} /> <label for="gst_reduction_target_absolute">{t}assoluta{/t}</label>
                            <input type="radio" name="gst_reduction_target_absolute" id="gst_reduction_target_percapita" value="F" {if $vlu.gst_reduction_target_absolute != 'T'}checked{/if} /> <label for="gst_reduction_target_percapita">{t}pro-capite{/t}</label>
                        </td>
                    </tr>
                    <tr>
                        <th><label class="help" for="gst_reduction_target_long_term">{t}Obiettivo a lungo termine{/t}:</label></th>
                        <td><input type="text" name="gst_reduction_target_long_term" id="gst_reduction_target_long_term" class="float" data-dec="1" value="{$vlu.gst_reduction_target_long_term}" style="width:60px;" /> %</td>
                        <th><label class="help" for="gst_reduction_target_year_long_term">{t}Anno{/t}:</label></th>
                        <td nowrap><input type="text" name="gst_reduction_target_year_long_term" id="gst_reduction_target_year_long_term" value="{$vlu.gst_reduction_target_year_long_term}" style="width:50px;" class="year" />
                            <label class="help" for="gst_reduction_target_citizen_long_term">{t}Abitanti{/t}:</label>
                            <input type="text" name="gst_reduction_target_citizen_long_term" id="gst_reduction_target_citizen_long_term" value="{$vlu.gst_reduction_target_citizen_long_term}" style="width:80px;" class="integer" /></td>
                        <th><label class="help" for="gst_reduction_target_absolute_long_term">{t}Riduzione{/t}:</label></th>
                        <td>
                            <input type="radio" name="gst_reduction_target_absolute_long_term" id="gst_reduction_target_absolute_long_term" value="T" {if $vlu.gst_reduction_target_absolute_long_term == 'T'}checked{/if} /> <label for="gst_reduction_target_absolute_long_term">{t}assoluta{/t}</label>
                            <input type="radio" name="gst_reduction_target_absolute_long_term" id="gst_reduction_target_absolute_long_term_percapita" value="F" {if $vlu.gst_reduction_target_absolute_long_term != 'T'}checked{/if} /> <label for="gst_reduction_target_absolute_long_term_percapita">{t}pro-capite{/t}</label>
                        </td>
                    </tr>
                </table>
            </td></tr>

        <tr class="separator"><td></td></tr>
        <tr>
            <th><label class="required help" for="gst_emission_factor_type_ipcc">{t}Tipologia fattori di emissione{/t}:</label></th>
            <td>
                <select name="gst_emission_factor_type_ipcc" id="gst_emission_factor_type_ipcc" style="width:60px">
                    {html_options options=$lkp.gst_emission_factor_type_ipcc_values selected=$vlu.gst_emission_factor_type_ipcc}
                </select>
            </td>
            <th><label class="required help" for="gst_emission_unit_co2">{t}Tipologia emissioni{/t}:</label></th>
            <td colspan="3">
                <select name="gst_emission_unit_co2" id="gst_emission_unit_co2" style="width:130px">
                    {html_options options=$lkp.gst_emission_unit_co2_values selected=$vlu.gst_emission_unit_co2}
                </select>
            </td>
        </tr>
        <tr class="evidence"><td colspan="6">{t}Aspetti organizzativi e finanziari{/t}</td></tr>
        <tr>
            <th><label class="help" for="gst_coordination_text_1">{t}Struttura organizzativa{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="5"><textarea name="gst_coordination_text_1" id="gst_coordination_text_1" style="width:97%;">{$vlu.gst_coordination_text_1}</textarea></td>
        </tr>
        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
            <tr>
                <th><label class="help" for="gst_coordination_text_2">{t}Struttura organizzativa{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="5"><textarea type="text" name="gst_coordination_text_2" id="gst_coordination_text_2" style="width:97%;" >{$vlu.gst_coordination_text_2}</textarea></td>
            </tr>
        {/if}
        <tr>
            <th><label class="help" for="gst_staff_nr">{t}Pers. assegnato{/t}:</label></th>
            <td colspan="5"><input type="text" name="gst_staff_nr" id="gst_staff_nr" value="{$vlu.gst_staff_nr}" maxlength="10" style="width:180px;" class="integer" /> {t}persone{/t}</td>
        </tr>
        {if $vlu.gst_staff_text_1<>''}
            <tr>
                <th><label class="help" for="gst_staff_text_1">{t}Pers. assegnato (Descrizione){/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                <td colspan="5"><textarea name="gst_staff_text_1" id="gst_staff_text_1" style="width:97%;">{$vlu.gst_staff_text_1}</textarea></td>
            </tr>
            {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
                <tr>
                    <th><label class="help" for="gst_staff_text_2">{t}Pers. assegnato (Descrizione){/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                    <td colspan="5"><textarea type="text" name="gst_staff_text_2" id="gst_staff_text_2" style="width:97%;" >{$vlu.gst_staff_text_2}</textarea></td>
                </tr>
            {/if}
        {/if}

        <tr>
            <th><label class="help" for="gst_citizen_text_1">{t}Coinvolgimento dei cittadini{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="5"><textarea name="gst_citizen_text_1" id="gst_citizen_text_1" style="width:97%;" >{$vlu.gst_citizen_text_1}</textarea></td>
        </tr>
        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
            <tr>
                <th><label class="help" for="gst_citizen_text_2">{t}Coinvolgimento dei cittadini{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="5"><textarea name="gst_citizen_text_2" id="gst_citizen_text_2" style="width:97%;" >{$vlu.gst_citizen_text_2}</textarea></td>
            </tr>
        {/if}
        <tr>
            <th><label class="help" for="gst_budget_text_1">{t}Stima risorse{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="5"><textarea name="gst_budget_text_1" id="gst_budget_text_1" style="width:97%;" >{$vlu.gst_budget_text_1}</textarea></td>
        </tr>
        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
            <tr>
                <th><label class="help" for="gst_budget_text_2">{t}Stima risorse{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="5"><textarea name="gst_budget_text_2" id="gst_budget_text_2" style="width:97%;" >{$vlu.gst_budget_text_2}</textarea></td>
            </tr>
        {/if}
        <tr>
            <th><label class="help" for="gst_budget">{t}Importo{/t}:</label></th>
            <td colspan="5"><input type="text" name="gst_budget" id="gst_budget" value="{$vlu.gst_budget}" maxlength="10" style="width:180px;" class="float" data-dec="2" /> &euro;</td>
        </tr>
        <tr>
            <th><label class="help" for="gst_financial_text_1">{t}Finanziamento{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="5"><textarea name="gst_financial_text_1" id="gst_financial_text_1" style="width:97%;" >{$vlu.gst_financial_text_1}</textarea></td>
        </tr>
        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
            <tr>
                <th><label class="help" for="gst_financial_text_2">{t}Finanziamento{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="5"><textarea name="gst_financial_text_2" id="gst_financial_text_2" style="width:97%;" >{$vlu.gst_financial_text_2}</textarea></td>
            </tr>
        {/if}
        <tr>
            <th><label class="help" for="gst_monitoring_text_1">{t}Sviluppo e monitoraggio{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="5"><textarea name="gst_monitoring_text_1" id="gst_monitoring_text_1" style="width:97%;" >{$vlu.gst_monitoring_text_1}</textarea></td>
        </tr>
        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
            <tr>
                <th><label class="help" for="gst_monitoring_text_2">{t}Sviluppo e monitoraggio{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="5"><textarea name="gst_monitoring_text_2" id="gst_monitoring_text_2" style="width:97%;" >{$vlu.gst_monitoring_text_2}</textarea></td>
            </tr>
        {/if}

        <tr class="evidence"><td colspan="6">{t}Inventario emissioni e piano d'azione{/t}</td></tr>
        <tr>
            <th><label class="help" for="ge_id">{t}Inventario emissioni{/t}:</label></th>
            <td>
                <select name="ge_id" id="ge_id" {if $lkp.ge_values|@count <= 1}disabled{/if}>
                    {html_options options=$lkp.ge_values selected=$vlu.ge_id}
                </select>
            </td>
            <th><label class="help" for="ge_id_2">{t}Inv. emiss. 2{/t}:</label></th>
            <td>
                <select name="ge_id_2" id="ge_id_2" {if $lkp.ge_values|@count <= 1}disabled{/if}>
                    {html_options options=$lkp.ge_values selected=$vlu.ge_id_2}
                </select>
            </td>
            <th><label class="help" for="gp_id">{t}Piano di azione{/t}:</label></th>
            <td>
                <select name="gp_id" id="gp_id" {*style="width:130px"*} {if $lkp.gp_values|@count <= 1}disabled{/if}>
                    {html_options options=$lkp.gp_values selected=$vlu.gp_id}
                </select>
            </td>
        </tr>
        <tr><td colspan="6">{include file="record_change.tpl"}</td></tr>
    </table>
    <br />
    {if $vars.view_mode <> 'T'}
        {if $vars.parent_act == 'show'}
            <input type="button" id="btnClose" name="btnClose"  value="{t}Chiudi{/t}" style="width:120px;height:25px;" />
        {else}
            {if $act != 'show'}
                <input type="button" id="btnSave" name="btnSave"  value="{t}Salva{/t}"    style="width:75px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" style="width:75px;height:25px;">
                {if $act <> 'add'}
                    &nbsp;&nbsp;&nbsp;&nbsp;<input type="button" id="btnExport" name="btnExport"  value="{t}Export PAES{/t}" data-alt-value="{t}Salva ed esporta PAES{/t}" style="width:150px;height:25px;" />
                    <input type="button" id="btnDownload" name="btnDownload"  value="{t}Scarica PAES{/t}" style="width:150px;height:25px;" />
                {/if}
            {else}
                {if $USER_CAN_MOD_GLOBAL_STRATEGY}
                    <input type="button" name="btnEdit" id="btnEdit" value="{t}Modifica{/t}" style="width:75px;height:25px;">&nbsp;&nbsp;&nbsp;&nbsp;{/if}
                    <input type="button" name="btnBack" id="btnBack"  value="{t}Indietro{/t}" style="width:75px;height:25px;">
                {/if}
            {/if}
        {/if}
    </form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}