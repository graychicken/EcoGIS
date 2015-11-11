{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#btnAdd').bind('click', function () {
                addObject()
            });
        });
    </script>
{/literal}

<form name="filterform" id="filterform" method="get" action="list.php">
    <input type="hidden" name="is_filter" id="is_filter" value="T" />
    <input type="hidden" name="on" id="on" value="{$object_name}">
    <input type="hidden" name="act" id="act" value="{$object_action}">
    <input type="hidden" name="pg" value="1">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}

    <div class="function_list">
        {if $USER_CAN_ADD_MUNICIPALITY_COLLECTION}
            <input type="button" name="btnAdd" id="btnAdd" value="{t}Nuovo{/t}" style="height:25px;width:70px;" />
        {/if}
    </div>

    <h3 id="page_title">{$page_title} - {t}Totale{/t}: {$tot_record}</h3>

    <fieldset class="filter">
        <legend>{t}Filtro{/t}</legend>
        <div class="filter_fields">
            {if $flt.do_values|@count > 1}
                <div>
                    <span>{t}Ente{/t}:</span>
                    <select name="do_id_filter" style="width:180px;">
                        <option value="">{t}-- Selezionare --{/t}</option>
                        {html_options options=$flt.do_values selected=$flt.do_id_filter}
                    </select>
                </div>
            {/if}
            <div>
                <span>{t}Nome raggruppamento{/t}:</span>
                <input type="text" name="mu_name_collection" id="mu_name_collection" value="{$flt.mu_name_collection}" style="width:180px;">
            </div>
            <div>
                <span>{t}Comune{/t}:</span>
                <input type="text" name="mu_name" id="mu_name" value="{$flt.mu_name}" style="width:180px;">
            </div>
            <div>
                <input type="submit" name="btnFilter" id="btnFilter" value="{t}Filtra{/t}" onclick="applyFilter();" style="width:80px;" />
                <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" onclick="cancelFilter();" style="width:80px;" />
            </div>
        </div>
    </fieldset>
</form>

<form name="tblform" id="tblform" method="get" action="list.php">
    <input type="hidden" name="on" id="on_table" value="{$object_name}">
    <input type="hidden" name="act" id="act_table" value="{$object_action}">
    {$html_table}
    {$html_table_legend}
    {$html_navigation}
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}