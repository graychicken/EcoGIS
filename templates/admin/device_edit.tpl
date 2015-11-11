{include file="header_ajax.tpl"}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#popup_modform .help').bind('click', function () {
                showR3Help('device', this)
            });
            $('#popup_btnSave').bind('click', function () {
                submitFormDataDevice('#popup_modform');
            });
            $('#popup_dt_id').bind('change', function () {
                updateForExtraData('#popup_dt_id', '#dt_extradata');
            });

            $('#popup_btnCancel').bind('click', function () {
                closeR3Dialog()
            });
            //setupExtraData('#popup_dt_id', 'popup');
            updateForExtraData('#popup_dt_id', '#dt_extradata');

            if ($('#popup_act').val() == 'show') {
                setupShowMode('popup');  // Setup the show mode
                setupInputFormat('#popup_modform', false);
            } else {
                setupInputFormat('#popup_modform');
                setupRequired('#popup_modform');
                setupReadOnly('#popup_modform');
                $('#popup_modform .date').datepicker('option', {yearRange: '-50:+0'});
            }
            $('#popup_modform').toggle(true);  // Show the form
            $('#popup_dt_id').focus();
        });
    </script>
{/literal}
<form name="modform" id="popup_modform" action="edit.php?method=submitFormData" method="post" style="display:none">
    <input type="hidden" name="on" id="popup_on" value="{$object_name}" />
    <input type="hidden" name="act" id="popup_act" value="{$act}" />
    <input type="hidden" name="id" id="popup_dev_id" value="{$vlu.dev_id}" />
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="popup_{$key}" value="{$val}" />
    {/foreach}

    <table class="form">
        <tr>
            <th><label class="help" for="popup_dev_em_name">{t}Contatore{/t}:</label></th>
            <td><input type="text" name="dev_em_dummy" id="popup_dev_em_name" class="readonly" value="{$vlu.em_data.em_name}" style="width: 200px" /></td>
                {if $vlu.em_data.is_producer!='T'}
                <th><label class="help" for="popup_dev_esu_name">{t}Alimentazione{/t}:</label></th>
                <td><input type="text" name="dev_esu_dummy" id="popup_dev_esu" class="readonly" value="{$vlu.em_data.es_name} [{$vlu.em_data.udm_name}]" style="width: 200px" /></td>
                {else}
                <td colspan="2"></td>
            {/if}
        </tr>
        <tr>
            <th><label class="help required" for="popup_dt_id">{if $vlu.em_data.et_code=='ELECTRICITY'}{t}Tipo utenza{/t}{else}{t}Tipo impianto{/t}{/if}:</label></th>
            <td colspan="3"><select name="dt_id" id="popup_dt_id" style="width: 200px" {if $lkp.dt_values|@count <= -1}disabled{/if}>
                    {if $act == 'add' && $lkp.dt_values|@count > 1}<option value="">{t}-- Selezionare --{/t}</option>{/if}
                    {foreach from=$lkp.dt_values key=key item=val}
                        <option label="{$val.dt_name}" {if $key==$vlu.dt_id}selected{/if} value="{$key}" has_extradata="{$val.dt_has_extradata}">{$val.dt_name}</option>
                    {/foreach}
                </select>
            </td>
        </tr>
        <tr id="dt_extradata">
            <th><label class="help" for="dt_extradata_1">{t}Altro{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td{if $NUM_LANGUAGES==1} colspan="3"{/if}><input type="text" id="dt_extradata_1" name="dt_extradata_1" style="width: {if $NUM_LANGUAGES>1}200px{else}500px{/if}" value="{$vlu.dt_extradata_1}" /></td>
                {if $NUM_LANGUAGES>1}
                <th><label class="help" for="dt_extradata_2" >{t}Altro{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td><input type="text" id="dt_extradata_2" name="dt_extradata_2" value="{$vlu.dt_extradata_2}" style="width: 200px" /></td>
                {/if}
        </tr>
        {if $vlu.em_data.et_code=='HEATING'}
            <tr>
                <th><label class="help" for="popup_dev_nr">{t}Matricola{/t}:</label></th>
                <td colspan="3"><input type="text" name="dev_serial" id="popup_dev_nr" value="{$vlu.dev_serial}" style="width: 200px" /></td>
            </tr>
            <tr>
                <th><label class="help" for="popup_dev_install_date">{t}Data installazione{/t}:</label></th>
                <td>{if 1==1}
                    <input type="text" name="dev_install_date" id="popup_dev_install_date" value="{$vlu.dev_install_date}" class="date" />
                {else}
                    <select name="dev_install_date" id="popup_dev_install_date" style="width: 80px" {if $lkp.dt_values|@count <= 1}disabled{/if}>
                        {if $act == 'add' && $lkp.dev_install_date_values|@count > 1}<option value=""></option>{/if}
                        {html_options options=$lkp.dev_install_date_values selected=$vlu.dev_install_date}
                    </select>
                {/if}
            </td>
            <th><label class="help" for="popup_dev_end_date">{t}Data fine esercizio{/t}:</label></th>
            <td>{if 1==1}
                <input type="text" name="dev_end_date" id="popup_dev_end_date" value="{$vlu.dev_end_date}" class="date" />
                {else}
                    <select name="dev_end_date" id="popup_dev_end_date" style="width: 80px" {if $lkp.dt_values|@count <= 1}disabled{/if}>
                        {if $act == 'add' && $lkp.dev_end_date_values|@count > 1}<option value=""></option>{/if}
                        {html_options options=$lkp.dev_end_date_values selected=$vlu.dev_end_date}
                    </select>
                    {/if}
                    </td>
                </tr>
                {/if}
                    <tr>
                        <th><label class="help" for="popup_dev_power">{t}Potenza{/t}:</label></th>
                        <td><input type="text" name="dev_power" id="popup_dev_power" value="{$vlu.dev_power}" maxlength="10" style="width: 80px" class="integer" /> {t}kW{/t}</td>
                            {if $vlu.em_data.et_code=='HEATING'}
                            <th><label class="help" for="popup_dev_energy_service">{t}Servizio energia{/t}:</label></th>
                            <td><input type="checkbox" name="dev_energy_service" id="popup_dev_energy_service" value="T" {if $vlu.dev_energy_service == 'T'}checked{/if} /><label for="popup_dev_energy_service">{t}Si{/t}</label></td>
                            {else}
                            <th><label class="help" for="popup_dev_connection">{t}Numero utenze{/t}:</label></th>
                            <td><input type="text" name="dev_connection" id="popup_dev_connection" value="{$vlu.dev_connection}" maxlength="10" style="width: 80px" class="integer" /></td>
                            {/if}
                    </tr>
                    {if $act<>'add'}<tr><td colspan="6">{include file="record_change.tpl"}</td></tr>{/if}
                    {if $vlu.im_id<>''}<tr><td colspan="6" style="padding-left: 20px"><i>{t}Questo impianto è stato importato automaticamente{/t}</i></td></tr>{/if}
                </table>
                <br />
                {if $act == 'show'}
                    <input type="button" id="popup_btnCancel" name="popupBtnCancel"  value="{t}Chiudi{/t}" style="width:120px;height:25px;" />
                {else}
                    <input type="button" id="popup_btnSave" name="popupBtnSave"  value="{t}Salva{/t}" style="width:120px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
                    <input type="button" id="popup_btnCancel" name="popupBtnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />
                {/if}
            </form>

            {include file="footer_ajax.tpl"}