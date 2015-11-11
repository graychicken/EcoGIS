{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}
<h3 id="page_title">{$page_title}</h3>

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {

            // Elenco comuni
            $('#btnMoveAllToLeft').bind('click', function () {
                moveMunicipality('#mu_list', '#mu_selected', true)
            });
            $('#btnMoveToLeft').bind('click', function () {
                moveMunicipality('#mu_list', '#mu_selected')
            });
            $('#mu_list').bind('dblclick', function () {
                moveMunicipality('#mu_list', '#mu_selected')
            });
            $('#btnMoveAllToRight').bind('click', function () {
                moveMunicipality('#mu_selected', '#mu_list', true)
            });
            $('#btnMoveToRight').bind('click', function () {
                moveMunicipality('#mu_selected', '#mu_list')
            });
            $('#mu_selected').bind('dblclick', function () {
                moveMunicipality('#mu_selected', '#mu_list')
            });

            $('#btnSave').bind('click', function () {
                submitFormDataUtility()
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
            initChangeRecord();
            // Show element
            $('#modform').toggle(true);
            focusTo('#us_name_1');
        });

    </script>
{/literal}
{* Map settings *}

{include file=inline_help.tpl}
<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" style="xdisplay: none">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="id" value="{$vlu.us_id}">
    <input type="hidden" name="lang" id="lang" value="{$lang}">
    {foreach from=$vars key=key item=val}
        {if $key <> 'tabs'}<input type="hidden" name="{$key}" id="{$key}" value="{$val}" />{/if}
    {/foreach}


    <table class="form">
        <tr><td>
                <fieldset class="filter">
                    <legend id="do_first_user">{t}Dati fornitore{/t}</legend>
                    <table width="100%" class="form">
                        <tr>
                            <th><label class="help required" for="us_name_1">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_1 }</label></th>
                            <td><input type="text" name="us_name_1" id="us_name_1" value="{$vlu.us_name_1}" style="width: 500px;"></td>
                        </tr>
                        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
                            <tr>
                                <th><label class="required help" for="us_name_2">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                                <td colspan="5"><input type="text" name="us_name_2" id="us_name_2" value="{$vlu.us_name_2}" style="width:500px;" />
                            </tr>
                        {/if}
                        <input type="hidden" name="us_order" id="us_order" value="{$vlu.us_order}" class="integer" />
                        <tr><td>&nbsp;</td></tr>

                        <tr><td colspan="2">
                                <table border="0">
                                    <tr>
                                        <td><label class="help" for="mu_selected">{t}Comuni serviti{/t}</label></td>
                                        <td></td>
                                        <td><label class="help" for="municipality">{t}Comuni disponibili{/t}</label></td>
                                    </tr>
                                    <tr>
                                        <td><select name="mu_selected" id="mu_selected" style="width: 240px; height: 100px" multiple>
                                                {html_options options=$lkp.mu_selected}
                                            </select>
                                            <input type="hidden" name="municipality" id="municipality"> {* Store the selected municipality *}
                                        </td>
                                        <td>
                                            <input type="button" id="btnMoveAllToLeft" name="btnMoveAllToLeft"  value="&lt;&lt;" style="width:40px;height:20px;" /><br>
                                            <input type="button" id="btnMoveToLeft" name="btnMoveToLeft"  value="&lt;" style="width:40px;height:20px;" /><br>
                                            <input type="button" id="btnMoveToRight" name="btnMoveToRight"  value="&gt;" style="width:40px;height:20px;" /><br>
                                            <input type="button" id="btnMoveAllToRight" name="btnMoveAllToRight"  value="&gt;&gt;" style="width:40px;height:20px;" /><br>
                                        </td>
                                        <td><select name="mu_list" id="mu_list" style="width: 300px; height: 100px" multiple>
                                                {html_options options=$lkp.mu_list}
                                            </select>
                                        </td>
                                    </tr>

                                </table>
                            </td></tr>
                        <tr><td colspan="2">{include file="record_change.tpl"}</td></tr>
                    </table>
                </fieldset>
            </td></tr>


        {foreach from=$vlu.products key=key item=item name=loop}
            <tr><td>
                    <fieldset class="filter">
                        <legend>{t}Prodotto{/t} {counter}</legend>
                        <table class="form" width="100%">
                            <tr>
                                <th><label class="required" for="up_name_1_{$key}">{t}Nome prodotto{/t}{$LANG_NAME_SHORT_FMT_1}</label></th>
                                <td colspan="5"><input type="text" name="up_name_1_{$key}" id="up_name_1_{$key}" value="{$item.up_name_1}" style="width: 200px;"></td>
                            </tr>
                            {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
                                <tr>
                                    <th><label class="required" for="up_name_2_{$key}">{t}Nome prodotto{/t}{$LANG_NAME_SHORT_FMT_2}</label></th>
                                    <td colspan="5"><input type="text" name="up_name_2_{$key}" id="up_name_2_{$key}" value="{$item.up_name_2}" style="width:200px;" /></td>
                                </tr>
                            {/if}
                            <tr>
                                <th><label for="esu_co2_factor_{$key}">{t escape=no}Fattore di conversione CO2{/t}</label></th>
                                <td><input type="text" name="esu_co2_factor_{$key}" id="esu_co2_factor_{$key}" class="float" value="{$item.esu_co2_factor}" style="width: 100px;"></td>

                                <th><label class="required" for="et_code_{$key}">{t}Tipologia{/t}</label></th>
                                <td><input type="hidden" name="et_code_{$key}" id="et_code_{$key}_dummy" value="{$item.et_code}">
                                    <select name="et_code_{$key}" id="et_code_{$key}" style="width: 120px" {if $item.tot>0 || $item.up_name_1<>''}disabled{/if}>
                                        {html_options options=$lkp.kind_values selected=$item.et_code}
                                    </select>
                                </td>

                                <th><label for="ges_id_{$key}">{t}Alimentazione PAES{/t}</label></th>
                                <td><input type="hidden" name="ges_id_{$key}" id="ges_id_{$key}_dummy" value="{$item.ges_id}">
                                    <select name="ges_id_{$key}" id="ges_id_{$key}" style="width: 120px" {if $item.tot>0}disabled{/if}>
                                        <option value="">{t}-- Selezionare --{/t}</option>
                                        {html_options options=$lkp.ges_values selected=$item.ges_id}
                                    </select>
                                </td>

                            </tr>
                        </table>
                    </fieldset>
                </td></tr>
            {/foreach}
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