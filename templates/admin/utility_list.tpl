{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            autocomplete("#mu_name", {url: 'edit.php',
                on: 'building',
                method: 'fetch_municipality',
                pr_id: $('#pr_id').val(),
                limit: 20,
                minLength: 1
            });
        });
    </script>
{/literal}

<form name="filterform" id="filterform" method="get" action="list.php">
    <input type="hidden" name="on" id="on" value="{$object_name}">
    <input type="hidden" name="act" id="act" value="{$object_action}">
    <input type="hidden" name="pg" value="1">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}

    <div class="function_list">
        {if $USER_CAN_ADD_UTILITY}
            <input type="button" name="btnAdd" id="btnAdd" value="{t}Nuovo{/t}" onClick="addObject();" style="height:25px;width:70px;" />
        {/if}
        {if $USER_CAN_EXPORT_ENERGYSOURCE}
            <input type="button" name="btnExport" id="btnExport" value="{t}Export{/t}" onClick="exportObject();" style="height:25px;width:70px;" />
        {/if}
    </div>

    <h3 id="page_title">{$page_title} - {t}Totale{/t}: {$tot_record}</h3>

    {if $flt.mu_values|@count > 1}
        <fieldset class="filter">
            <legend>{t}Filtro{/t}</legend>
            <div class="filter_fields">
                <div>
                    <span>{t}Comune{/t}:</span>
                    <input type="hidden" id="mu_id" name="mu_id" value="{$flt.mu_values|@key}">
                    {if $USER_CONFIG_APPLICATION_BUILDING_MUNICIPALITY_MODE <> 'COMBO'}
                        <input type="text" name="mu_name" id="mu_name" value="{$flt.mu_name}" style="width:180px;">
                    {else}
                        <select name="mu_id" id="mu_id" style="width:180px;">
                            <option value="">{t}-- Selezionare --{/t}</option>
                            {html_options options=$flt.mu_values selected=$flt.mu_id}
                        </select>
                    {/if}
                </div>
                <div>
                    <input type="submit" name="btnFilter" id="btnFilter" value="{t}Filtra{/t}" onclick="applyFilter();" style="width:70px;" />
                    <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" onclick="cancelFilter();" style="width:70px;" />
                </div>
            </div>
        </fieldset>
    </form>
{/if}

<form name="tblform" id="tblform" method="get" action="list.php">
    <input type="hidden" name="on" id="on_table" value="{$object_name}">
    <input type="hidden" name="act" id="act_table" value="{$object_action}">
    {$html_table}
    {$html_table_legend}
    {$html_navigation}
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}