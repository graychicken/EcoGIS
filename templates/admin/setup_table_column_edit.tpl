{include file="header_ajax.tpl"}

{literal}
    <script language="JavaScript" type="text/javascript">
        var {/literal}popup_on = '{$object_name}'{literal};

        $(document).ready(function () {
            $("#popup_modform input[name='btnSave']").bind('click', function () {
                submitFormDataSetupTableColumn($("#popup_modform input[name='module']").val())
            });
            $("#popup_modform input[name='btnCancel']").bind('click', function () {
                closeR3Dialog()
            });
            $("#popup_modform input[name='btnReset']").bind('click', function () {
                resetSetupTableColumnEdit()
            });

            $('.movedown').bind('click', function () {
                moveSetupTableRowToDown(this);
            });
            $('.moveup').bind('click', function () {
                moveSetupTableRowToUp(this);
            });

            setupReadOnly('#popup_modform');
            updateMoveSetupTableArrowsVisibility();

            // Show element
            setupHelp('#popup_modform', 'setup_table_column');
            $("#r3_dialog").dialog("option", "title", page_title);
            $('#popup_modform').toggle(true);
        });

    </script>
{/literal}
{include file=inline_help.tpl}
<form name="popup_modform" id="popup_modform" action="edit.php?method=submitFormData&on={$object_name}" method="post" style="display: none">
    <input type="hidden" name="fields_position" id="fields_position" value="">
    {foreach from=$vars key=key item=val}
        {if $key <> 'tabs'}<input type="hidden" name="{$key}" id="{$key}" value="{$val}" />{/if}
    {/foreach}

    <div style="border-width: 1px 1px 0px 1px; border-style: solid; border-color: #CCCCCC; font-weight: bold; width: 458px">
        <span style="display: inline-block; width: 295px"><label class="help" for="column_name">{t}Colonna{/t}</label></span>
        <span style="display: inline-block; width: 70px"><label class="help" for="column_visible">{t}Visibile{/t}</label></span>
        <span style="display: inline-block; width: 45px"><label class="help" for="column_dimension">{t}Dim.{/t}</label></span>
        <span><label class="help" for="column_position">{t}Pos.{/t}</label></span>
    </div>
    <div style="height: 210px; overflow: auto">
        <table class="table_form" id="table_form" style="width: 460px;">
            {foreach from=$vlu key=key item=data name=row}
                <tr id="row_{$key}">
                    <td>{*[row_{$data.position}]*}<input type="text" name="{$key}_label" id="{$key}_label" value="{$data.label}" style="width: 290px" class="readonly" /></td>
                    <td style="width: 40px;" align="middle">
                        <input name="{$key}_visible" type="checkbox" id="{$key}_visible" value="T" {if $data.visible}checked{/if} />

                        {*<select name="{$key}_visible" id="{$key}_visible">
                        {html_options options=$lkp.yesno selected=$data.visible}</select>*}</td>
                    <td style="width: 75px;" align="middle"> {* simulate a editable select. SS: TODO: Select/Create a jquery plugin *}
                        <select name="{$key}_width_dummy" id="{$key}_width_dummy" style="width: 60px;" onchange="$('input#{$key}_width').val($(this).val());">
                            {foreach from=$data.width_list item=val}
                                <option {if $data.width==$val}selected{/if}>{if $val == ''}{t}Auto{/t}{else}{$val}{/if}</option>
                            {/foreach}
                        </select>
                        <input name="{$key}_width" id="{$key}_width" value="{if $data.width == ''}{t}Auto{/t}{else}{$data.width}{/if}" style="margin-left: -60px; width: 38px; height: 1.2em; border: 0;" />
                    </td>
                    <td style="width: 40px;" align="middle"><img id="arror_up_{$data.position}" src="../images/arrow_up.png" class="moveup" /><img id="arror_down_{$data.position}"src="../images/arrow_down.png" class="movedown" /></td>
                </tr>
            {/foreach}
        </table>
    </div>
    <br />
    <input type="button" name="btnSave"  value="{t}Salva{/t}" style="width:75px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
    <input type="button" name="btnCancel" value="{t}Annulla{/t}" style="width:75px;height:25px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type="button" name="btnReset" value="{t}Ripristina default{/t}" style="width:150px;height:25px;">
</form>

{include file="footer_ajax.tpl"}