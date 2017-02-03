{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#btnAdd').bind('click', function () {
                addObject()
            });
            $('#btnExport').bind('click', function () {
                showExportDlg();
            });
            $('#btnSetupTableColumn').bind('click', function () {
                setupTableColumn()
            });

            autocomplete("#mu_name", {url: 'edit.php',
                on: 'building',
                method: 'fetch_municipality',
                pr_id: $('#pr_id').val(),
                limit: 20,
                minLength: 1
            });
            autocomplete("#fr_name", {url: 'edit.php',
                on: 'building',
                method: 'fetch_fraction',
                mu_id: $('#mu_id').val(),
                used_by: 'building',
                limit: 40,
                minLength: 1
            });
            autocomplete("#st_name", {url: 'edit.php',
                on: 'building',
                method: 'getStreetList',
                mu_id: $('#mu_id').val(),
                used_by: 'building',
                limit: 40,
                minLength: 1
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
        {if $USER_CAN_ADD_BUILDING}
            <input type="button" name="btnAdd" id="btnAdd" value="{t}Nuovo{/t}" style="height:25px;width:70px;" />
        {/if}
        {if $USER_CAN_EXPORT_BUILDING}
            <input type="button" name="btnExport" id="btnExport" value="{t}Export{/t}" style="height:25px;width:70px;" />
        {/if}
    </div>
    {if $USER_CAN_MOD_SETUP_TABLE_COLUMN}
        {* non spostare *}
        <div class="function_list">
            <button name="btnSetupTableColumn" id="btnSetupTableColumn" type="button" style="height:25px;width:25px;padding:0px;" title="{t}Configura elenco{/t}">
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
                    <span>{t}Provincia{/t}:</span>  {* Mostrare solo se ho più di un record *}
                    <select name="pr_id" style="width:180px;">
                        <option value="">{t}-- Selezionare --{/t}</option>
                        {html_options options=$flt.pr_values selected=$flt.pr_id}
                    </select>
                </div>
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
            {else}
                <input type="hidden" id="mu_id" name="mu_id" value="{$flt.mu_values|@key}">
            {/if}

            {if $flt.mu_values|@count == 1 && $flt.fr_values|@count > 1} {* per ora mostro il filtro frazione solo se ho un comune *}
                    <div>
                        <span>{t}Frazione{/t}:</span>
                        {if $USER_CONFIG_APPLICATION_BUILDING_FRACTION_MODE <> 'COMBO'}
                            <input type="text" name="fr_name" id="fr_name" value="{$flt.fr_name}" style="width:180px;">
                        {else}
                            <select name="fr_id" style="width:180px;">
                                <option value="">{t}-- Selezionare --{/t}</option>
                                {html_options options=$flt.fr_values selected=$flt.fr_id}
                            </select>
                        {/if}
                    </div>
                {/if}

                {if $flt.mu_values|@count == 1 && $flt.st_values|@count > 1} {* per ora mostro il filtro strade solo se ho un comune *}
                        <div>
                            <span>{t}Indirizzo{/t}:</span>  {* Mostrare solo se ho più di un record. *}
                            {if $USER_CONFIG_APPLICATION_BUILDING_STREET_MODE <> 'COMBO'}
                                <input type="text" name="st_name" id="st_name" value="{$flt.st_name}" style="width:180px;" title="{t}Via/piazza{/t}">
                            {else}
                                <select name="st_id" style="width:180px;" title="{t}Via/piazza{/t}">
                                    <option value="">{t}-- Selezionare --{/t}</option>
                                    {html_options options=$flt.st_values selected=$flt.st_id}
                                </select>
                            {/if}
                            <input type="text" name="bu_civic" id="bu_civic" value="{$flt.bu_civic}" style="width:50px;" title="{t}Civico{/t}">
                        </div>
                    {/if}

                    {if $USER_CONFIG_APPLICATION_BUILDING_SHOW_ID == 'T' || $USER_CONFIG_APPLICATION_BUILDING_CODE_TYPE <> 'NONE'}
                        <div>
                            <span>{if $USER_CONFIG_APPLICATION_BUILDING_SHOW_ID == 'T'}{t}ID/Codice edificio{/t}{else}{t}Codice edificio{/t}{/if}:</span>
                            <input type="text" name="bu_code" id="bu_code" value="{$flt.bu_code}" style="width:80px;">
                        </div>
                    {/if}
                    <div>
                        <span>{t}Nome edificio{/t}:</span>
                        <input type="text" name="bu_name" id="bu_name" value="{$flt.bu_name}" style="width:180px;">
                    </div>
                    {if $flt.bpu_values|@count > 1}
                        <div>
                            <span>{t}Destinazione d'uso{/t}:</span>
                            <select name="bpu_id" id="bpu_id" style="width:180px;">
                                <option value="">{t}-- Selezionare --{/t}</option>
                                {foreach from=$flt.bpu_values key=key item=val}
                                    <option label="{$val.bpu_name}" {if $key==$flt.bpu_id}selected{/if} value="{$key}">{$val.bpu_name}</option>
                                {/foreach}
                            </select>
                        </div>
                    {/if}
                    {if $flt.bt_values|@count > 1}
                        <div>
                            <span>{t}Tipologia costruttiva{/t}:</span>
                            <select name="bt_id" id="bt_id" style="width:180px;">
                                <option value="">{t}-- Selezionare --{/t}</option>
                                {foreach from=$flt.bt_values key=key item=val}
                                    <option label="{$val.bt_name}" {if $key==$flt.bt_id}selected{/if} value="{$key}">{$val.bt_name}</option>
                                {/foreach}
                            </select>
                        </div>
                    {/if}
                    {if $flt.bby_values|@count > 1}
                        <div>
                            <span>{t}Anno costruzione{/t}:</span>
                            <select name="bby_id" id="bby_id" style="width:180px;">
                                <option value="">{t}-- Selezionare --{/t}</option>
                                {html_options options=$flt.bby_values selected=$flt.bby_id}
                            </select>
                        </div>
                    {/if}
                    {if $flt.bry_values|@count > 1}
                        <div>
                            <span>{t}Anno ristrutturazione{/t}:</span>
                            <select name="bry_id" id="bry_id" style="width:180px;">
                                <option value="">{t}-- Selezionare --{/t}</option>
                                {html_options options=$flt.bry_values selected=$flt.bry_id}
                            </select>
                        </div>
                    {/if}
                    <div>
                        <input type="hidden" name="bu_to_check" id="bu_to_check_dummy" value="F" />
                        <input type="checkbox" name="bu_to_check" id="bu_to_check" value="T" {if $flt.bu_to_check == 'T'}checked{/if}/>
                        <span>{t}Solo da controllare{/t}</span>
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