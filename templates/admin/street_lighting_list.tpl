{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

{literal}
    <script language="JavaScript" type="text/javascript">

        $(document).ready(function () {
            $('#btnSetupTableColumn').bind('click', function () {
                setupTableColumn()
            });

            autocomplete("#mu_name", {url: 'edit.php',
                on: 'street_lighting',
                method: 'getMunicipalityList',
                do_id: $('#do_id').val(),
                pr_id: $('#pr_id').val(),
                limit: 20,
                minLength: 2
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
        {if $USER_CAN_ADD_SIMULATION}
            <input type="button" name="btnAdd" id="btnAdd" value="{t}Nuovo{/t}" onClick="addObject();" style="height:25px;width:70px;" />
        {/if}
    </div>
    {if $USER_CAN_MOD_SETUP_TABLE_COLUMN}
        {* non spostare *}
        <div class="function_list">
            <button name="btnSetupTableColumn" id="btnSetupTableColumn" type="button" style="height:25px;width:25px;" title="{t}Configura elenco{/t}">
                <span class="ui-icon ui-icon-gear"></span>
            </button>
        </div>
    {/if}

    <h3 id="page_title">{$page_title} - {t}Totale{/t}: {$tot_record}</h3>

    <fieldset class="filter">
        <legend>{t}Filtro{/t}</legend>
        <div class="filter_fields">
            {if $flt.pr_values|@count > 1}
                <div>
                    <span>{t}Provincia{/t}:</span>
                    <select name="pr_id" style="width:180px;">
                        <option value="">{t}-- Selezionare --{/t}</option>
                        {html_options options=$flt.pr_values selected=$flt.pr_id}
                    </select>
                </div>
            {else}
                <input type="hidden" name="pr_id" id="pr_id" value="" />
            {/if}
            {if $flt.mu_values|@count > 1}
                <div>
                    <span>{t}Comune{/t}:</span>
                    {if $USER_CONFIG_APPLICATION_BUILDING_MUNICIPALITY_MODE <> 'COMBO'}
                        <input type="text" name="mu_name" id="mu_name" value="{$flt.mu_name}" style="width:180px;">
                    {else}
                        <select name="mu_id" style="width:180px;">
                            <option value="">{t}-- Selezionare --{/t}</option>
                            {html_options options=$flt.mu_values selected=$flt.mu_id}
                        </select>
                    {/if}
                </div>
            {/if}
            {if $flt.mu_values|@count == 1 && $flt.st_values|@count > 1}
                    <div>
                        <span>{t}Strada{/t}:</span>
                        {if $USER_CONFIG_APPLICATION_BUILDING_STREET_MODE <> 'COMBO'}
                            <input type="text" name="st_name" id="st_name" value="{$flt.st_name}" style="width:180px;">
                        {else}
                            <select name="st_id" style="width:180px;">
                                <option value="">{t}-- Selezionare --{/t}</option>
                                {html_options options=$flt.st_values selected=$flt.st_id}
                            </select>
                        {/if}
                    </div>
                {/if}
                <div>
                    <span>{t}Tratto{/t}:</span>
                    <input type="text" name="sl_full_name" id="sl_full_name" value="{$flt.sl_full_name}" style="width:250px;" />
                </div>
                <div>
                    <input type="hidden" name="sl_to_check" id="sl_to_check_dummy" value="F" />
                    <input type="checkbox" name="sl_to_check" id="sl_to_check" value="T" {if $flt.sl_to_check == 'T'}checked{/if}/>
                    <span>{t}Solo da controllare{/t}</span>
                </div>
                <div>
                    <input type="submit" name="btnFilter" id="btnFilter" value="{t}Filtra{/t}" onclick="applyFilter();" style="width:70px;" />
                    <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" onclick="cancelFilter();" style="width:70px;" />
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