{include file="header_ajax.tpl"}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#popupBtnSave').bind('click', function () {
                submitData('#modform_fraction')
            });
            $('#popupBtnCancel').bind('click', function () {
                closeR3Dialog()
            });
            $('#popup_name_1').focus();
        });
    </script>
{/literal}

<form name="modform_fraction" id="modform_fraction" action="edit.php?method=submitFormData" method="post" onsubmit="return false;">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}

    <table class="form">
        <tr>
            <th><label class="help required" for="popup_name_1">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td><input type="text" name="popup_name_1" id="popup_name_1" style="width: 300px;"></td>
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label class="help required" for="popup_name_2">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td><input type="text" name="popup_name_2" id="popup_name_2" style="width: 300px;"></td>
            </tr>
        {/if}
    </table>
    <br />

    <input type="button" id="popupBtnSave" name="popupBtnSave"  value="{t}Salva{/t}" style="width:120px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
    <input type="button" id="popupBtnCancel" name="popupBtnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />
</form>

{include file="footer_ajax.tpl"}