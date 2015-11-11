{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

{literal}
    <script language="JavaScript" type="text/javascript">

        function showLookup(id) {
            ajaxWait(true);
            disableButton(true);
            document.location = 'lookup_edit.php?on=' + $('#on').val() + '&act=show&id=' + id + '&';
        }

        function addLookup() {
            ajaxWait(true);
            disableButton(true);
            document.location = 'lookup_edit.php?on=' + $('#on').val() + '&act=add&';
        }

        function modLookup(id) {
            ajaxWait(true);
            disableButton(true);
            document.location = 'lookup_edit.php?on=' + $('#on').val() + '&act=mod&id=' + id + '&';
        }

        function delLookup(id) {
            ajaxWait(true);
            $.getJSON('lookup_edit.php', {'on': $('#on').val(),
                'id': id,
                'act': 'del',
                'method': 'submitFormData'}, function (response) {
                isAjaxResponseOk(response);
                document.location = 'lookup_list.php?on=' + $('#on').val() + '&';
            });
        }

        function askDelLookup(id) {
            ajaxWait(true);
            ajaxConfirm('lookup_edit.php', {'on': $('#on').val(),
                'id': id,
                'method': 'confirmDeleteLookup'}, function () {
                delLookup(id);
            });
        }

        // Cancel the filter
        function cancelLookupFilter() {
            ajaxWait(true);
            disableButton(true);
            document.location = 'lookup_list.php?on=' + $('#on').val() + '&init&reset&';
        }

        $(document).ready(function () {
            $('#btnAdd').bind('click', function () {
                addLookup()
            });
            $('#btnFilter').bind('click', function () {
                applyFilter()
            });
            $('#btnCancel').bind('click', function () {
                cancelLookupFilter()
            });
        });
    </script>
{/literal}

<form name="filterform" id="filterform" method="get" action="lookup_list.php">
    <input type="hidden" name="is_filter" id="is_filter" value="1">
    <input type="hidden" name="on" id="on" value="{$object_name}">
    <input type="hidden" name="act" id="act" value="{$object_action}">
    <input type="hidden" name="pg" value="1">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}
    {if $USER_CAN_ADD_LOOKUP && $HAS_ADD_BUTTON}
        <div class="function_list"><input type="button" name="btnAdd" id="btnAdd" value="{t}Nuovo{/t}" style="height:25px; " /></div>
        {/if}

    <h3 id="page_title">{$page_title} - {t}Totale{/t}: {$tot_record}</h3>

    {if $filter.has_filter}
        <fieldset class="filter">
            {if $filter.title <> ''}<legend>{$filter.title}</legend>{/if}
            <div class="filter_fields">
                {foreach from=$filter.data item=item}
                    {if $item.type == 'select'}
                        {if $item.data|@count > 1}
                            <div>
                                <span>{$item.label}:</span>
                                <select name="{$item.name}" id="{$item.name}" {if $item.width>0}style="width:{$item.width}px;"{/if}>
                                    <option value="">{t}-- Selezionare --{/t}</option>
                                    {html_options options=$item.data selected=$flt[$item.name]}
                                </select>
                            </div>
                        {/if}
                    {elseif $item.type == 'text'}
                        <div>
                            <span>{$item.label}:</span>
                            <input type="text" name="{$item.name}" id="{$item.name}" value="{$flt[$item.name]}" style="width:180px;">
                        </div>
                    {else}
                        INVALID FILTER TYPE [{$item.type}]
                    {/if}
                {/foreach}
                <div>
                    <input type="submit" name="btnFilter" id="btnFilter" value="{t}Filtra{/t}" style="width:70px;" />
                    <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" style="width:70px;" />
                </div>
            </div>
        </fieldset>
    {/if}
</form>

<form name="tblform" id="tblform" method="post" action="lookup_list.php">
    <input type="hidden" name="on" id="on_table" value="{$object_name}">
    <input type="hidden" name="act" id="act_table" value="{$object_action}">
    {$html_table}
    {$html_table_legend}
    {$html_navigation}
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}
