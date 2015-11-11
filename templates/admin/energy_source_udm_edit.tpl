{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}
<h3 id="page_title">{$page_title}</h3>

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#es_id').bind('change', function () {
                updateEnergySourceFromESU()
            });

            $('#btnSave').bind('click', function () {
                submitFormDataEnergySourceUDM()
            });
            $('#btnCancel,#btnBack').bind('click', function () {
                listObject()
            });
            if ($('#act').val() == 'show') {
                setupShowMode();  // Setup the show mode
                setupInputFormat('#modform', false);
            } else {
                setupInputFormat('#modform');
                setupRequired('#modform');
            }
            setupReadOnly('#modform');
            autocomplete("#mu_name", {url: 'edit.php',
                on: 'building',
                method: 'fetch_municipality',
                pr_id: $('#pr_id').val(),
                limit: 20,
                minLength: 1});

            // Show element
            initChangeRecord();
            $('#modform').toggle(true);
            focusTo('#mu_id,#mu_name,#es_id');
        });

    </script>
{/literal}
{* Map settings *}
{assign var=preview_size value='x'|explode:$USER_CONFIG_APPLICATION_PHOTO_PREVIEW_SIZE}

{include file=inline_help.tpl}
<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" style="display: none">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="id" value="{$vlu.esu_id}">
    <input type="hidden" name="lang" id="lang" value="{$lang}">
    {foreach from=$vars key=key item=val}
        {if $key <> 'tabs'}<input type="hidden" name="{$key}" id="{$key}" value="{$val}" />{/if}
    {/foreach}
    <table class="table_form">
        <input type="hidden" name="mu_id" id="mu_id_dummy" value="{$vlu.mu_id}">
        {if $lkp.mu_values|@count > 1}
            <tr>
                <th><label class="help" for="mu_id">{t}Comune{/t}:</label></th>
                <td colspan="3">
                    {if $USER_CONFIG_APPLICATION_BUILDING_MUNICIPALITY_MODE <> 'COMBO'}
                        <input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}">
                        <input type="text" name="mu_name" id="mu_name" value="{$vlu.mu_name}" style="width:600px;">
                    {else}
                        <select name="mu_id" id="mu_id" style="width:600px" {if $act <> 'add'}class="readonly" disabled{/if}>
                            <option value="">{t}-- Selezionare --{/t}</option>
                            {html_options options=$lkp.mu_values selected=$vlu.mu_id}
                        </select>
                    {/if}
                </td>
            </tr>
        {/if}

        <tr>
            <th><label class="required help" for="es_id">{t}Tipo alimentazione{/t}:</label></th>
            <td>
                <input type="hidden" name="es_id" id="es_id_dummy" value="{$vlu.es_id}">
                <select name="es_id" id="es_id" style="width:300px;" {if $lkp.es_values|@count == 0}disabled{/if} {if $act=='mod'}disabled{/if}>
                    <option value="">{t}-- Selezionare --{/t}</option>
                    {html_options options=$lkp.es_values selected=$vlu.es_id}
                </select>
            </td>
            <th><label class="required help" for="udm_id">{t}Unità di misura{/t}:</label></th>
            <td><input type="hidden" name="udm_id" id="udm_id_selected" value="{$vlu.udm_id}" />
                <select name="udm_id" id="udm_id" style="width:100px;" {if $lkp.udm_values|@count == 0}disabled{/if} {if $act=='mod'}disabled{/if}>
                    {if $act == 'add'}<option value="">{t}-- Selezionare --{/t}</option>{/if}
                    {html_options options=$lkp.udm_values selected=$vlu.udm_id}
                </select>
            </td>
        </tr>
        <tr>
            <th><label class="required help" for="esu_kwh_factor">{t}Fattore conversione KWh{/t}:</label></th>
            <td><input type="text" name="esu_kwh_factor" id="esu_kwh_factor" value="{$vlu.esu_kwh_factor}" class="float" style="width:100px;" /></td>
            <th><label class="required help" for="esu_co2_factor">{t escape=no}Fattore conversione CO2{/t}:</label></th>
            <td><input type="text" name="esu_co2_factor" id="esu_co2_factor" value="{$vlu.esu_co2_factor}" class="float" style="width:100px;" /> [kg]</td>
        </tr>
        <tr>
            <th><label class="help" for="esu_tep_factor">{t}Fattore conversione TEP{/t}:</label></th>
            <td><input type="text" name="esu_tep_factor" id="esu_tep_factor" value="{$vlu.esu_tep_factor}" class="float" style="width:100px;" /></td>
            <td></th>
            <td></td>
        </tr>
        <tr>
            <th><label class="help" for="esu_is_consumption">{t}Fonte a consumo{/t}:</label></th>
            <td><input type="checkbox" name="esu_is_consumption" id="esu_is_consumption" value="T" {if $vlu.esu_is_consumption == 'T'}checked{/if} /></th><label for="esu_is_consumption">{t}Si{/t}</label></td>
            <th><label class="help" for="esu_is_production">{t}Fonte a produzione{/t}:</label></th>
            <td><input type="checkbox" name="esu_is_production" id="esu_is_production" value="T" {if $vlu.esu_is_production == 'T'}checked{/if} /></th><label for="esu_is_production">{t}Si{/t}</label></td>
        </tr>
        {if $vlu.ges_full_name<>''}
            <tr>
                <th><label class="required help" for="ges_full_name">{t}Alimentazione inventario{/t}:</label></th>
                <td colspan="3"><input type="text" name="ges_full_name" id="ges_full_name" value="{$vlu.ges_full_name}" style="width:300px;" class="readonly" /></td>
            </tr>
        {/if}
        {if $vlu.gc_full_name<>''}
            <tr>
                <th><label class="required help" for="gc_full_name">{t}Categoria inventario fissa{/t}:</label></th>
                <td colspan="3"><input type="text" name="gc_full_name" id="gc_full_name" value="{$vlu.gc_full_name}" style="width:300px;" class="readonly" /></td>
            </tr>
        {/if}
        <tr><td colspan="4">{include file="record_change.tpl"}</td></tr>
    </table>
    <br />

    {if $act != 'show'}
        <input type="button" id="btnSave" name="btnSave"  value="{t}Salva{/t}" style="width:75px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" style="width:75px;height:25px;">
    {else}
        {if $USER_CAN_MOD_ENERGYSOURCEUDM}
            <input type="button" name="btnEdit" id="btnEdit"  value="{t}Modifica{/t}" style="width:75px;height:25px;">&nbsp;&nbsp;&nbsp;&nbsp;
        {/if}
        <input type="button" name="btnBack" id="btnBack"  value="{t}Indietro{/t}" style="width:75px;height:25px;">
    {/if}
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}