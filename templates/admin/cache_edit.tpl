{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}
<h3>{$page_title}</h3>

{literal}
    <script language="JavaScript" type="text/javascript">
        function delCache() {
            ajaxWait(true);
            disableButton(true);
            $.getJSON('edit.php', {'on': $('#on').val(),
                'del_preview_map': $('#del_preview_map').attr('checked') ? 'T' : 'F',
                'del_preview_photo': $('#del_preview_photo').attr('checked') ? 'T' : 'F',
                'del_temp_files': $('#del_temp_files').attr('checked') ? 'T' : 'F',
                'method': 'delCache'}, function (response) {
                ajaxWait(false);
                disableButton(false)
            });
        }

        $(document).ready(function () {
            $('#btnGo').bind('click', function () {
                delCache()
            });
        });

    </script>
{/literal}

<form name="modform" id="modform" method="post">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    {foreach from=$vars key=key item=val}
        {if $key <> 'tabs'}<input type="hidden" name="{$key}" id="{$key}" value="{$val}" />{/if}
    {/foreach}

    <table class="table_form" id="table_form_part1">
        <tr>
            <td><input type="checkbox" name="del_preview_map" id="del_preview_map" value="T" checked></td>
            <td><label for="del_preview_map">{t}Elimina anteprima di mappa{/t}</label></td>
        </tr>
        <tr>
            <td><input type="checkbox" name="del_preview_photo" id="del_preview_photo" value="T" checked></td>
            <td><label for="del_preview_photo">{t}Elimina anteprima foto{/t}</label></td>
        </tr>
        <tr>
            <td><input type="checkbox" name="del_temp_files" id="del_temp_files" value="T" checked></td>
            <td><label for="del_preview_photo">{t}Elimina mappe e file temporanei{/t}</label></td>
        </tr>
    </table>
    <br />
    <input type="button" id="btnGo" name="btnGo"  value="{t}Procedi{/t}" style="width:120px;height:25px;" />
</form>


{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}