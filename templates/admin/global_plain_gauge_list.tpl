{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

<form name="filterform" id="filterform" method="get" action="list.php">
    <input type="hidden" name="on" id="tab_on" value="{$object_name}">
    <input type="hidden" name="act" id="tab_act" value="{$act}">
    <input type="hidden" name="pg" value="1">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="tab_{$key}" value="{$val}" />
    {/foreach}


    {if $vars.parent_act!='show' and $USER_CAN_ADD_GLOBAL_PLAIN_GAUGE}
        <div class="function_list2">
            {if $vars.hasReductionOrPruduction}
                <a href="Javascript:addGlobalPlainGauge({$vars.gpr_id});" title="{t}Nuovo{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_add_small.gif" border="0"></a>
                {else}
                <a href="Javascript:alert(txtCantAdd);" title="{t}Nuovo{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_add_small.gif" border="0"></a>
                {/if}
        </div>
    {/if}
</form>

<form name="tblform" id="tblform" method="get" action="list.php">
    <input type="hidden" name="on" id="on_table" value="{$object_name}" />
    <input type="hidden" name="act" id="act_table" value="{$object_action}" />
    {$html_table}
    {$html_table_legend}
    {$html_navigation}
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}