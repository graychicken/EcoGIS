{include file="header_ajax.tpl"}

{literal}
    <script language="JavaScript" type="text/javascript">

        $(document).ready(function () {
            $('#popup_modform .help').bind('click', function () {
                showR3Help('global_plain_gauge', this)
            });
            $('#popup_btnSave').bind('click', function () {
                submitFormDataGlobalPlainGauge();
            });
            $('#popup_btnCancel').bind('click', function () {
                closeR3Dialog()
            });

            if ($('#popup_act').val() == 'show') {
                setupShowMode('popup');  // Setup the show mode
                setupInputFormat('#popup_modform', false);
            } else {
                setupInputFormat('#popup_modform');
                setupRequired('#popup_modform');
                setupReadOnly('#popup_modform');
            }
            $('#popup_modform').toggle(true);  // Show the form
            $('#popup_gpg_name_1').focus();

        });
    </script>
{/literal}
{include file=inline_help.tpl}
<form name="modform" id="popup_modform" action="edit.php?method=submitFormData" method="post" style="xdisplay:none">
    <input type="hidden" name="on" id="popup_on" value="{$object_name}" />
    <input type="hidden" name="act" id="popup_act" value="{$act}" />
    <input type="hidden" name="id" id="popup_gpg_id" value="{$vlu.gpg_id}" />
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="popup_{$key}" value="{$val}" />
    {/foreach}

    <table class="form">
        <tr>
            <th><label class="help required" for="popup_gpg_name_1">{t}Descrizione{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td><input type="text" id="popup_gpg_name_1" name="gpg_name_1" value="{$vlu.gpg_name_1}" style="width: 300px" /></td>
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label class="help required" for="popup_gpg_name_2">{t}Descrizione{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td><input type="text" id="popup_gpg_name_2" name="gpg_name_2" value="{$vlu.gpg_name_2}" style="width: 400px" /></td>
            </tr>
        {/if}
        <tr>
            <th><label class="help required" for="popup_gpg_value_1">{t}Valore unitario A{/t}:</label></th>
            <td><input type="text" name="gpg_value_1" id="popup_gpg_value_1" value="{$vlu.gpg_value_1}" maxlength="10" style="width: 80px" class="float" /></td>
        </tr>
        <tr>
            <th><label class="help required" for="popup_gpg_value_2">{t}Valore unitario B{/t}:</label></th>
            <td><input type="text" name="gpg_value_2" id="popup_gpg_value_2" value="{$vlu.gpg_value_2}" maxlength="10" style="width: 80px" class="float" /></td>
        </tr>
        <tr>
            <th><label class="help required" for="popup_gpg_value_3">{t}Fattore emissione{/t}:</label></th>
            <td><input type="text" name="gpg_value_3" id="popup_gpg_value_3" value="{$vlu.gpg_value_3}" maxlength="10" style="width: 80px" class="float" /></td>
        </tr>    
        <tr>    
            <th><label class="help required" for="popup_gpgu_id_1">{t}Unità di misura quantità{/t}:</label></th>
            <td>
                <select name="gpgu_id_1" id="popup_gpgu_id_1">
                    {html_options options=$lkp.gpgu_values selected=$vlu.gpgu_id_1}
                </select>
            </td>
        </tr>
        <tr>
            <th><label class="help required" for="popup_gpgu_id_2">{t}Unità di misura efficienza{/t}:</label></th>
            <td>
                <select name="gpgu_id_2" id="popup_gpgu_id_2">
                    {html_options options=$lkp.gpgu_values selected=$vlu.gpgu_id_2}
                </select>
            </td>
        </tr>
        {if $lkp.gpg_is_production_values|@count==1}
            <input type="hidden" name="gpg_is_production" id="popup_gpg_is_production" value="{$lkp.gpg_is_production_values|@key}" />
        {else}
            <tr>
                <th><label class="help required" for="popup_gpg_is_production">{t}Tipo indicatore{/t}:</label></th>
                <td colspan="3">
                    <select name="gpg_is_production" id="popup_gpg_is_production">
                        {html_options options=$lkp.gpg_is_production_values selected=$vlu.gpg_is_production}
                    </select>
                </td>

            </tr>
        {/if}

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