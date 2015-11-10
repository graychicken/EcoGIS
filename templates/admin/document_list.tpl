{if $vars.tab_mode=='ajax'}{include file="header_ajax.tpl"}{else}{include file="header_no_menu.tpl"}{/if}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#doc_form').toggle(true);  // Show the form
        });

    </script>
{/literal}

{if $vars.parent_act!='show' and $USER_CAN_ADD_DOCUMENT}
    <div class="function_list2">
        <a href="JavaScript:addDocument('{$vars.type}', {$vars.doc_object_id});" title="{t}Aggiungi documento{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_add_small.gif" border="0"></a>
    </div>
{/if}

<form name="modform" id="doc_form" method="get" action="list.php" style="display:none">
    <input type="hidden" name="on" id="tab_on" value="{$object_name}" />
    <input type="hidden" name="act" id="tab_act" value="{$act}">
    <input type="hidden" name="tab_mode" id="tab_tab_mode" value="{$vars.tab_mode}">
    <input type="hidden" name="type" id="tab_type" value="{$vars.type}">
    <input type="hidden" name="doc_object_id" id="tab_doc_object_id" value="{$vars.doc_object_id}">
    <input type="hidden" name="parent_act" id="tab_parent_act" value="{$vars.parent_act}">
    {$html_table}
    {$html_table_legend}
</form>

{if $vars.tab_mode=='ajax'}{include file="footer_ajax.tpl"}{else}{include file="footer_no_menu.tpl"}{/if}