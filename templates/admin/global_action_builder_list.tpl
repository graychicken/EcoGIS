{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

<h3 id="page_title">{$page_title} - {t}Totale{/t}: {$tot_record}</h3>

<form name="filterform" id="filterform" method="get" action="list.php">
    <input type="hidden" name="on" id="on" value="{$object_name}">
    <input type="hidden" name="act" id="act" value="{$object_action}">
    <input type="hidden" name="pg" value="1">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}
</form>
<form name="tblform" id="tblform" method="get" action="list.php">
    <input type="hidden" name="on" id="on_table" value="{$object_name}">
    <input type="hidden" name="act" id="act_table" value="{$object_action}">
    {$html_table}
    {$html_table_legend}
    {$html_navigation}
</form>
{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}