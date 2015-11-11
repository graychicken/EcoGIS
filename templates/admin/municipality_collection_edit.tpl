{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}
{literal}
    <style>
        table[summary]:after {
            content: attr(summary);
            display: table-caption;
            caption-side: bottom;
            font-size: 10px;
            font-style: italic;
            margin-top: 2px;
            margin-bottom: 10px;
        }
    </style>
    <script language="JavaScript" type="text/javascript">

        $(document).ready(function () {
            $('#btnCancel').bind('click', function () {
                listObject()
            });
            $('#btnSave').bind('click', function () {
                submitFormDataMunicipalityCollection();
            });

            $('#do_id_collection').bind('change', function () {
                loadAvailableMunicipalityForCollection();
                $('#mu_selected').emptySelect();
            });

            $('#mu_name').bind('keyup', function () {
                loadAvailableMunicipalityForCollection();
            });

            $('#btnClearFilter').bind('click', function () {
                $('#mu_name').val('');
                loadAvailableMunicipalityForCollection();
            });


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
            setupReadOnly('#modform');
            setupInputFormat('#modform');
            $('#mu_name_1').focus();
        });
    </script>
{/literal}

{include file=inline_help.tpl}
<h3 id="page_title">{$page_title}</h3>

<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="mu_id" value="{$vlu.mu_id}">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}

    <table border=1 xclass="form">
        {if $lkp.do_values|@count>1}
            <tr>
                <th><label class="help" for="do_template">{t}Ente{/t}</label></th>
                <td>
                    {if $act == 'add'}
                        <select name="do_id_collection" id="do_id_collection" style="width: 200px">
                            <option value="">{t}-- Selezionare --{/t}</option>
                            {html_options options=$lkp.do_values}
                        </select>
                    {else}
                        DOMINIO IN TEXT
                    {/if}
                </td>
            </tr>
        {else}
            <input type="hidden" id="do_id_collection" name="do_id_collection" value="{$lkp.do_values|@key}" />
        {/if}
        <tr>
            <th><label class="required" for="mu_name_1">{t}Nome raggruppamento{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td>
                <input type="text" name="mu_name_1" id="mu_name_1" value="{$vlu.mu_name_1}" style="width:550px;" />
            </td>
        </tr>
        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
            <tr>
                <th><label class="required" for="mu_name_1">{t}Nome raggruppamento{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td><input type="text" name="mu_name_1" id="mu_name_1" value="{$vlu.mu_name_1}" maxlength="80" style="width:550px;" />
            </tr>
        {/if}
        <tr>
            <td colspan="2">
                <table border="1" xstyle="border-collapse: collapse; border: 1px solid #777777">
                    <tr>
                        <td><label class="" for="mu_name">{t}Comuni associati{/t}</label></td>
                        <td></td>
                        <td><input type="text" name="mu_name" id="mu_name" style="width: 360px">
                            <input type="button" id="btnClearFilter" name="btnClearFilter"  value="{t}X{/t}" style="width:30px;height:20px;" />
                        </td>
                    </tr>
                    <tr>
                        <td><select name="mu_selected" id="mu_selected" style="width: 300px; height: 200px" multiple>
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
                        <td><select name="mu_list" id="mu_list" style="width: 400px; height: 200px" multiple>
                                {html_options options=$lkp.mu_list}
                            </select>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <br />
    {if $act == 'show'}
        <input type="button" id="btnCancel" name="btnCancel"  value="{t}Chiudi{/t}" style="width:120px;height:25px;" />
    {else}
        {if $smarty.const.R3_AUTO_POPULATE_GEOMETRY_COLUMNS}
            <input type="checkbox" name="skip_geometry_check" id="skip_geometry_check" value="T" /><label for="skip_geometry_check">{t}Non ripopolare le colonne spaziali (salvataggio più veloce){/t}</label>
            <br /><br />
        {/if}
        <input type="button" id="btnSave" name="btnSave"  value="{t}Salva{/t}" style="width:120px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="button" id="btnCancel" name="btnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />
        <br /><br />
    {/if}
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}