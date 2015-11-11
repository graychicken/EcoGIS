{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

<h3>{$page_title}</h3>

{include file=inline_help.tpl}

<form name="modform" method="post" action="javascript:after_submit();">
    <input type="hidden" name="act" value="{$act}">
    <input type="hidden" name="co_id" value="{$vlu.co_id}">
    <input type="hidden" name="ro_id" value="{$vlu.ro_id}">

    <table class="form">
        <tr>
            <th>{$lbl.con_list_year}</th>
            <td><select name="ref_year">
                    {html_options options=$referenceYearArr selected=$vlu.ref_year}
                </select></td>
        </tr>
        <tr>
            <th>{$lbl.ro_con_value}</th>
            <td><input type="text" name="co_value" value="{$vlu.co_value}" style="width:100px;text-align:right;" {$view_style} /> {$lbl.kwh}</td>
            <th>{$lbl.ro_con_cost}</th>
            <td><input type="text" name="co_bill" value="{$vlu.co_bill}" style="width:100px;text-align:right;" {$view_style} /> {$lbl.euro}</td>
            <th>{$lbl.ro_con_days}</th>
            <td><input type="text" name="co_days_amount" value="{$vlu.co_days_amount}" style="width:50px;text-align:right;" {$view_style} /></td>
        </tr>
        <tr>
            <th>{$lbl.ro_con_value_average}</th>
            <td><input type="text" name="co_value_avg" value="{$vlu.co_value_avg}" style="width:100px;text-align:right;" {$view_style} /> {$lbl.kwh}</td>
            <th>{$lbl.ro_con_power}</th>
            <td colspan="3"><input type="text" name="co_delivery_rate" value="{$vlu.co_delivery_rate}" style="width:100px;text-align:right;" {$view_style} /> {$lbl.kw}</td>
        </tr>
        {if $act != 'add'}
            <tr><td colspan="6" class="separator"></td></tr>
            <tr class="view_info">
                <th>{$lbl.info_modify_title}</th>
                <th>{$lbl.info_date}</th>
                <td>{$vlu.co_mod_date}</td>
                <th>{$lbl.info_user}</th>
                <td colspan="2">{$vlu.co_mod_user}</td>
            </tr>      
        {/if}
    </table>
    <br />

    {if $act != 'show'}
        <input type="button" name="btnSave"  value="{$btn.save}"  onClick="do_submit();" style="width:75px;height:25px;">&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="button" name="btnAbort" value="{$btn.abort}" onClick="do_abort();" style="width:75px;height:25px;">
    {else}
        {if $HANDLE_EDIT}
            <input type="button" name="btnEdit"  value="{$btn.edit}"  onClick="do_mod();" style="width:75px;height:25px;">&nbsp;&nbsp;&nbsp;&nbsp;
        {/if}
        <input type="button" name="btnBack"  value="{$btn.close}"  onClick="do_abort();" style="width:75px;height:25px;">
    {/if}
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}