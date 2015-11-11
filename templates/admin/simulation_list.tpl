{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

{literal}
    <script language="JavaScript" type="text/javascript">

        function recalculateSimulations() {
            // Ricalcola le statistiche se necessario
            $('span.invalid_simulation:first').each(function (dummy, e) {
                $(e).html('<b>' + $(e).text() + '</b>');
                $.getJSON('edit.php', {
                    'method': 'recalculateSimulation',
                    'on': $('#on').val(),
                    'sw_id': $(e).attr('data-role')
                },
                        function (response) {
                            $(e).removeClass('invalid_simulation');
                            if (typeof response != 'object' || response.status != 'OK') {
                                $(e).html('<b>Error</b>');
                            } else {
                                $(e).html('OK');
                                $.each(response.response, function (paramName, paramValue) {
                                    $('span.simulation_td[data-role=' + $(e).attr('data-role') + '_' + paramName + ']').text(paramValue);
                                });
                            }
                            recalculateSimulations();
                        });
            });
        }

        $(document).ready(function () {
            $('#btnSetupTableColumn').bind('click', function () {
                setupTableColumn()
            });

            $('#btnCompare').bind('click', function () {
                compareSimulation()
            });
            $('#btnAdd').bind('click', function () {
                addObject()
            });
            $('#btnExport').bind('click', function () {
                exportObject()
            });
            autocomplete("#mu_name", {url: 'edit.php',
                on: 'simulation_work',
                method: 'fetch_municipality',
                do_id: $('#do_id').val(),
                pr_id: $('#pr_id').val(),
                limit: 20,
                minLength: 2
            });
            recalculateSimulations();

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
        {if $USER_CAN_ADD_SIMULATION}
            <input type="button" name="btnAdd" id="btnAdd" value="{t}Nuovo{/t}" style="height:25px;width:70px;" />
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
                    <select id="pr_id" name="pr_id" style="width:180px;">
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
                        <select name="mu_id" id="mu_id" style="width:180px;">
                            <option value="">{t}-- Selezionare --{/t}</option>
                            {html_options options=$flt.mu_values.data selected=$flt.mu_id}
                        </select>
                    {/if}
                </div>
            {/if}
            <div>
                <span>{t}Titolo{/t}:</span>
                <input type="text" name="sw_title" id="sw_title" value="{$flt.sw_title}" style="width:250px;" />
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