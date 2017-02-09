{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#btnSetupTableColumn').bind('click', function () {
                setupTableColumn()
            });
        });
    </script>
{/literal}

<form name="filterform" id="filterform" method="get" action="list.php">
    <input type="hidden" name="is_filter" id="is_filter" value="T" />
    <input type="hidden" name="on" id="on" value="{$object_name}">
    <input type="hidden" name="act" id="act" value="{$object_action}">
    <input type="hidden" name="pg" value="1">
    <input type="hidden" name="tab_tab_mode" id="tab_tab_mode" value="{$vars.tab_mode}" />

    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}

    {if $vars.bu_id==''}
        <div class="function_list">
            {if $USER_CAN_ADD_ACTION_CATALOG}
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
    {else}
        {if $vars.parent_act <> 'show'}
            <div class="function_list2">
                <a href="JavaScript:addActionCatalogFromBuilding({$vars.bu_id});" title="{t}Aggiungi azione{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_add_small.gif" border="0"></a>
            </div>
        {/if}
    {/if}
    {if $vars.bu_id==''}
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
                {if $flt.mu_values.tot.municipality > 1}
                    <div>
                        <span>{if $flt.mu_values.has_municipality_collection > 0}{t}Comune/raggruppamento{/t}{else}{t}Comune{/t}{/if}:</span>
                        {if $USER_CONFIG_APPLICATION_BUILDING_MUNICIPALITY_MODE <> 'COMBO'}
                            <input type="text" name="mu_name" id="mu_name" value="{$flt.mu_name}" style="width:180px;">
                        {else}
                            <select name="mu_id" style="width:180px;">
                                <option value="">{t}-- Selezionare --{/t}</option>
                                {html_options options=$flt.mu_values.data selected=$flt.mu_id}
                            </select>
                        {/if}
                    </div>
                {else}
                    <input type="hidden" id="mu_id" name="mu_id" value="{$flt.mu_values.data|@key}">
                {/if}
                <div>
                    <span>{t}Codice/Nome{/t}:</span>
                    <input type="text" name="ac_name" id="ac_name" value="{$flt.ac_name}" style="width:180px;">
                </div>
                {if $flt.gc_values|@count > 1}
                    <div>
                        <span>{t}Categoria PAES{/t}:</span>
                        <select name="gc_id" id="gc_id" style="width:180px;">
                            <option value="">{t}-- Selezionare --{/t}</option>
                            {foreach from= $flt.gc_values key=key item=val}
                                <option {if $val.level==1}style="font-style: italic"{/if}{if $key==$flt.gc_id}selected{/if} value="{$key}">{$val.name}</option>
                            {/foreach}
                        </select>
                    </div>
                {/if}
                {if $flt.gpa_values|@count > 1}
                    <div>
                        <span>{t}Azioni principali{/t}:</span>
                        <select name="gpa_name" id="gpa_name" style="width:180px;">
                            <option value="">{t}-- Selezionare --{/t}</option>
                            {html_options options=$flt.gpa_values selected=$flt.gpa_name}
                        </select>
                    </div>
                {/if}
                <div>
                    <input type="submit" name="btnFilter" id="btnFilter" value="{t}Filtra{/t}" onclick="applyFilter();" style="width:80px;" />
                    <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" onclick="cancelFilter('action_catalog', 'bu_id={$vars.bu_id}');" style="width:80px;" />
                </div>
            </div>
        </fieldset>
    </form>
{/if}

<form name="tblform" id="tblform" method="get" action="list.php">
    <input type="hidden" name="on" id="on_table" value="{$object_name}">
    <input type="hidden" name="act" id="act_table" value="{$object_action}">
    <input type="hidden" name="bu_id" value="{$vars.bu_id}">
    <input type="hidden" name="tab_mode" value="{$vars.tab_mode}">
    {$html_table}
    {$html_table_legend}
    {$html_navigation}
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}