{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

<h3 id="page_title">{$page_title}</h3>

{literal}
    <script language="JavaScript" type="text/javascript">

        $(document).ready(function () {
            $('#btnSave').bind('click', function () {
                submitFormDataStatGeneral()
            });
            $('#btnCancel').bind('click', function () {
                document.location = 'edit.php?on=stat_general&init'
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
            $('#modform').show();
            focusTo('#sg_title_1');
        });

    </script>
{/literal}

{include file=inline_help.tpl}

<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" style="display: none">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="mod">
    <input type="hidden" name="id" id="id" value="{$vlu.sg_id}">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}

    <table class="table_form">
        <tr>
            <th><label class="help" for="sg_title_1">{t}Titolo{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td><input type="text" name="sg_title_1" id="sg_title_1" value="{$vlu.sg_title_1}" style="width:600px;" /></td>
        </tr>
        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
            <tr>
                <th><label class="help" for="sg_title_2">{t}Titolo{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td><input type="text" name="sg_title_2" id="sg_title_2" value="{$vlu.sg_title_2}" style="width:600px;" /></td>
            </tr>
        {/if}

        <tr class="evidence"><td colspan="2"></td></tr>
        <tr>
            <th><label for="sg_upper_text_1" class="help">{t}Testo superiore{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td>
                {if $act!='show'}<textarea name="sg_upper_text_1" id="sg_upper_text_1" style="width:600px;height:100px;" >{$vlu.sg_upper_text_1}</textarea>{else}<div class="textarea_readonly">{$vlu.sg_upper_text_1}&nbsp;</div>{/if}
            </td>
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label for="sg_upper_text_2" class="help">{t}Testo superiore{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td>
                    {if $act!='show'}<textarea name="sg_upper_text_2" id="sg_upper_text_2" style="width:600px;height:100px;" >{$vlu.sg_upper_text_2}</textarea>{else}<div class="textarea_readonly">{$vlu.sg_upper_text_2}&nbsp;</div>{/if}
                </td>
            </tr>
        {/if}

        <tr class="evidence"><td colspan="2"></td></tr>
        <tr>
            <th><label for="sg_lower_text_1" class="help">{t}Testo inferiore{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td>
                {if $act!='show'}<textarea name="sg_lower_text_1" id="sg_lower_text_1" style="width:600px;height:100px;" >{$vlu.sg_lower_text_1}</textarea>{else}<div class="textarea_readonly">{$vlu.sg_lower_text_1}&nbsp;</div>{/if}
            </td>
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label for="sg_lower_text_2" class="help">{t}Testo inferiore{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td>
                    {if $act!='show'}<textarea name="sg_lower_text_2" id="sg_lower_text_2" style="width:600px;height:100px;" >{$vlu.sg_lower_text_2}</textarea>{else}<div class="textarea_readonly">{$vlu.sg_lower_text_2}&nbsp;</div>{/if}
                </td>
            </tr>
        {/if}
        <tr><td colspan="6">{include file="record_change.tpl"}</td></tr>
    </table>
    <br />
    {if $act != 'show'}
        <input type="button" id="btnSave" name="btnSave"  value="{t}Salva{/t}"    style="width:75px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" style="width:75px;height:25px;">
    {/if}
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}