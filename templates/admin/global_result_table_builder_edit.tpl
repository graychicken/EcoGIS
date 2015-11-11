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
                submitFormDataGlobalResultTableBuilder();
            });
            // Energy source
            $('#btnMoveAllLeft').bind('click', function () {
                moveSource('#gest_list', '#ges_list', true)
            });
            $('#btnMoveLeft').bind('click', function () {
                moveSource('#gest_list', '#ges_list')
            });
            $('#gest_list').bind('dblclick', function () {
                moveSource('#gest_list', '#ges_list')
            });
            $('#btnMoveAllRight').bind('click', function () {
                moveSource('#ges_list', '#gest_list', true)
            });
            $('#btnMoveRight').bind('click', function () {
                moveSource('#ges_list', '#gest_list')
            });
            $('#ges_list').bind('dblclick', function () {
                moveSource('#ges_list', '#gest_list')
            });
            $('#btnMoveUp').bind('click', function () {
                moveSourceUp('#gest_list')
            });
            $('#btnMoveDown').bind('click', function () {
                moveSourceDown('#gest_list')
            });

            // Categories
            $('#btnMoveAllCatLeft').bind('click', function () {
                moveSource('#gc_selected', '#gc_list', true)
            });
            $('#btnMoveCatLeft').bind('click', function () {
                moveSource('#gc_selected', '#gc_list')
            });
            $('#gc_selected').bind('dblclick', function () {
                moveSource('#gc_selected', '#gc_list')
            });
            $('#btnMoveAllCatRight').bind('click', function () {
                moveSource('#gc_list', '#gc_selected', true)
            });
            $('#btnMoveCatRight').bind('click', function () {
                moveSource('#gc_list', '#gc_selected')
            });
            $('#gc_list').bind('dblclick', function () {
                moveSource('#gc_list', '#gc_selected')
            });
            $('#btnMoveCatUp').bind('click', function () {
                moveSourceUp('#gc_selected')
            });
            $('#btnMoveCatDown').bind('click', function () {
                moveSourceDown('#gc_selected')
            });

            setupReadOnly('#modform');
            $('#modform').toggle(true);  // Show the form
            setupRequired('#modform');
            $('#gt_code').focus();
            initChangeRecord();

        });
    </script>
{/literal}

{include file=inline_help.tpl}

<h3 id="page_title">{$page_title}</h3>

<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" style="xdisplay:none">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="gt_id" value="{$vlu.gt_id}">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}

    <table class="form">
        <tr>
            <th><label class="required" for="gt_code">{t}Codice{/t}</label></th>
            <td colspan="5"><input type="text" class="{if $act=='mod'}readonly{/if}" name="gt_code" id="gt_code" value="{$vlu.gt_code}" style="width: 200px;"></td>
        </tr>
        <tr>
            <th><label class="required" for="gt_name_1">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_1}</label></th>
            <td><input type="text" name="gt_name_1" id="gt_name_1" value="{$vlu.gt_name_1}" style="width: 200px;"></td>
                {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
                <th><label class="required" for="gt_name_2">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_2}</label></th>
                <td><input type="text" name="gt_name_2" id="gt_name_2" value="{$vlu.gt_name_2}" style="width: 200px;"></td>
                {/if}
            <th><label class="required" for="gt_name_3">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_3}</label></th>
            <td><input type="text" name="gt_name_3" id="gt_name_2" value="{$vlu.gt_name_3}" style="width: 200px;"></td>
        </tr>

        <tr>
            <td colspan="6">
                <fieldset class="filter">
                    <legend id="xdo_first_user" class="">{t}Fonti{/t}</legend>
                    <table class="form">
                        <tr>
                            <td><label class="" for="ges_list">{t}Fonti disponibili{/t}</label></td>
                            <td></td>
                            <td><label class="" for="gest_list">{t}Fonti selezionate{/t}</label></td>
                            <td></td>
                        </tr>
                        <tr>

                            <td><select name="ges_list" id="ges_list" style="width: 400px; height: 300px" multiple>
                                    {html_options options=$lkp.ges_list}
                                </select>
                            </td>
                            <td>
                                <input type="button" id="btnMoveAllLeft" name="btnMoveAllLeft"  value="&lt;&lt;" style="width:50px;height:20px;" /><br>
                                <input type="button" id="btnMoveLeft" name="btnMoveLeft"  value="&lt;" style="width:50px;height:20px;" /><br>
                                <input type="button" id="btnMoveRight" name="btnMoveRight"  value="&gt;" style="width:50px;height:20px;" /><br>
                                <input type="button" id="btnMoveAllRight" name="btnMoveAllRight"  value="&gt;&gt;" style="width:50px;height:20px;" /><br>
                            </td>
                            <td><select name="gest_list" id="gest_list" style="width: 400px; height: 300px" multiple>
                                    {html_options options=$lkp.gest_list}
                                </select>
                                <input type="hidden" name="global_energy_source_type" id="global_energy_source_type"> {* Store csv data *}
                            </td>
                            <td>
                                <input type="button" id="btnMoveUp" name="btnMoveUp"  value="UP" style="width:50px;height:20px;" /><br>
                                <input type="button" id="btnMoveDown" name="btnMoveDown"  value="DOWN" style="width:50px;height:20px;" /><br>
                            </td>
                        </tr>

                    </table>
                </fieldset>
        </tr>

        <tr>
            <td colspan="6">
                <fieldset class="filter">
                    <legend id="xxdo_first_user" class="">{t}Categorie{/t}</legend>
                    <table class="form">
                        <tr>
                            <td><label class="" for="pr_id">{t}Categorie disponibili{/t}</label></td>
                            <td></td>
                            <td><label class="" for="pr_id">{t}Categorie selezionate{/t}</label></td>
                            <td></td>
                        </tr>
                        <tr>

                            <td><select name="gc_list" id="gc_list" style="width: 400px; height: 300px" multiple>
                                    {html_options options=$lkp.gc_list}
                                </select>
                                <input type="hidden" name="global_category" id="global_category"> {* Store the selected municipality *}
                            </td>
                            <td>
                                <input type="button" id="btnMoveAllCatLeft" name="btnMoveAllCatLeft"  value="&lt;&lt;" style="width:50px;height:20px;" /><br>
                                <input type="button" id="btnMoveCatLeft" name="btnMoveCatLeft"  value="&lt;" style="width:50px;height:20px;" /><br>
                                <input type="button" id="btnMoveCatRight" name="btnMoveCatRight"  value="&gt;" style="width:50px;height:20px;" /><br>
                                <input type="button" id="btnMoveAllCatRight" name="btnMoveAllCatRight"  value="&gt;&gt;" style="width:50px;height:20px;" /><br>
                            </td>
                            <td><select name="gc_selected" id="gc_selected" style="width: 400px; height: 300px" multiple>
                                    {html_options options=$lkp.gc_selected}
                                </select>
                            </td>
                            <td>
                                <input type="button" id="btnMoveCatUp" name="btnMoveCatUp"  value="UP" style="width:50px;height:20px;" /><br>
                                <input type="button" id="btnMoveCatDown" name="btnMoveCatDown"  value="DOWN" style="width:50px;height:20px;" /><br>
                            </td>
                        </tr>

                    </table>
                </fieldset>
        </tr>
        <tr><td colspan="6">{include file="record_change.tpl"}</td></tr>


    </table>
    <br />
    {if $act == 'show'}
        <input type="button" id="btnCancel" name="btnCancel"  value="{t}Chiudi{/t}" style="width:120px;height:25px;" />
    {else}
        <input type="button" id="btnSave" name="btnSave"  value="{t}Salva{/t}" style="width:120px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="button" id="btnCancel" name="btnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />
    {/if}
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}