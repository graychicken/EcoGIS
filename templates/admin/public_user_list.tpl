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
    <input type="hidden" name="on" id="on" value="{$object_name}">
    <input type="hidden" name="act" id="act" value="{$object_action}">
    <input type="hidden" name="pg" value="1">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}

    <h3 id="page_title">{$page_title} - {t}Totale{/t}: {$tot_record}</h3>

    <fieldset class="filter">
        <legend>{t}Filtro{/t}</legend>
        <div class="filter_fields">
            <div>
                <span>{t}Nome/email{/t}:</span>
                <input type="text" name="us_name_email" id="us_name_email" value="{$flt.us_name_email}" style="width:250px;" />
            </div>
            <div>
                <span>{t}Stato{/t}:</span>
                <select name="us_status" style="width:180px;">
                    <option value="">{t}-- Selezionare --{/t}</option>
                    {html_options options=$flt.us_status_list selected=$flt.us_status}
                </select>
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