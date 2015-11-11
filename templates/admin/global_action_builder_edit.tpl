{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}
{literal}
    <script language="JavaScript" type="text/javascript">

        function moveSource(src, dest, all) {
            if (all) {
                $(src + ' option').remove().appendTo(dest);
            } else {
                $(src + ' option:selected').remove().appendTo(dest);
            }
        }

        function moveSourceUp(selector) {
            $(selector + ' option:selected').each(function () {
                $(this).insertBefore($(this).prev());
            });
        }

        function moveSourceDown(selector) {
            $(selector + ' option:selected').each(function () {
                $(this).insertAfter($(this).next());
            });
        }

        $(document).ready(function () {
            $('#btnCancel').bind('click', function () {
                listObject()
            });
            $('#btnSave').bind('click', function () {
                submitFormDataGlobalActionBuilder();
            });
            // Energy source
            $('#btnMoveAllLeft').bind('click', function () {
                moveSource('#gpa_id_selected', '#gpa_id_available', true)
            });
            $('#btnMoveLeft').bind('click', function () {
                moveSource('#gpa_id_selected', '#gpa_id_available')
            });
            $('#gpa_id_selected').bind('dblclick', function () {
                moveSource('#gpa_id_selected', '#gpa_id_available')
            });
            $('#btnMoveAllRight').bind('click', function () {
                moveSource('#gpa_id_available', '#gpa_id_selected', true)
            });
            $('#btnMoveRight').bind('click', function () {
                moveSource('#gpa_id_available', '#gpa_id_selected')
            });
            $('#gpa_id_available').bind('dblclick', function () {
                moveSource('#gpa_id_available', '#gpa_id_selected')
            });
            $('#btnMoveUp').bind('click', function () {
                moveSourceUp('#gpa_id_selected')
            });
            $('#btnMoveDown').bind('click', function () {
                moveSourceDown('#gpa_id_selected')
            });

            setupReadOnly('#modform');
            $('#modform').toggle(true);  // Show the form
            setupRequired('#modform');
            initChangeRecord();
        });
    </script>
{/literal}

{include file=inline_help.tpl}

<h3 id="page_title">{$page_title}</h3>

<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" style="xdisplay:none">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="gc_id" value="{$vlu.gc_id}">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}

    <table class="form">
        <tr>
            <th><label class="required" for="gc_name_main">{t}Macro-categoria{/t}</label></th>
            <td><input type="text" class="readonly" name="gc_name_main" id="gc_name_main" value="{$vlu.gc_name_main}" style="width: 200px;"></td>
        </tr>
        <tr>
            <th><label class="required" for="gc_name">{t}Categoria{/t}</label></th>
            <td><input type="text" class="readonly" name="gc_name" id="gc_name" value="{$vlu.gc_name}" style="width: 200px;"></td>
        </tr>

        <tr>
            <td colspan="2">
                <fieldset class="filter">
                    <legend id="xdo_first_user" class="">{t}Azioni princiapli{/t}</legend>
                    <table class="form">
                        <tr>
                            <td><label class="" for="gpa_id_available">{t}Azioni princiapli disponibili{/t}</label></td>
                            <td></td>
                            <td><label class="" for="gpa_id_selected">{t}Azioni princiapli selezionate{/t}</label></td>
                            <td></td>
                        </tr>
                        <tr>

                            <td><select name="gpa_id_available" id="gpa_id_available" style="width: 400px; height: 300px" multiple>
                                    {html_options options=$lkp.gpa_id_available}
                                </select>
                            </td>
                            <td>
                                <input type="button" id="btnMoveAllLeft" name="btnMoveAllLeft"  value="&lt;&lt;" style="width:40px;height:20px;" /><br>
                                <input type="button" id="btnMoveLeft" name="btnMoveLeft"  value="&lt;" style="width:40px;height:20px;" /><br>
                                <input type="button" id="btnMoveRight" name="btnMoveRight"  value="&gt;" style="width:40px;height:20px;" /><br>
                                <input type="button" id="btnMoveAllRight" name="btnMoveAllRight"  value="&gt;&gt;" style="width:40px;height:20px;" /><br>
                            </td>
                            <td><select name="gpa_id_selected" id="gpa_id_selected" style="width: 400px; height: 300px" multiple>
                                    {html_options options=$lkp.gpa_id_selected}
                                </select>
                                <input type="hidden" name="gpa_id_list" id="gpa_id_list"> {* Store csv data *}
                            </td>
                            <td>
                            </td>
                        </tr>
                    </table>
                </fieldset>
        </tr>
        <tr><td colspan="2">{include file="record_change.tpl"}</td></tr>
    </table>
    <br />
    <input type="button" id="btnSave" name="btnSave"  value="{t}Salva{/t}" style="width:120px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
    <input type="button" id="btnCancel" name="btnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}