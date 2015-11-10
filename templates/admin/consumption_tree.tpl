{if $vars.tab_mode=='ajax'}{include file="header_ajax.tpl"}{else}{include file="header_no_menu.tpl"}{/if}


{literal}
    <script language="JavaScript" type="text/javascript">
        function toggleConversionFactor() {
            $('.openclose_row').toggle();
        }
        $(document).ready(function () {
            $('.consumption_tree tr').bind('mouseenter', function () {
                $(this).addClass('tr_hover')
            });
            $('.consumption_tree tr').bind('mouseleave', function () {
                $(this).removeClass('tr_hover')
            });
            $('.openclose').bind('click', function () {
                toggleConversionFactor();
            });
            toggleConversionFactor();
        });

    </script>
{/literal}

<form action="">
    <input type="hidden" name="on" id="tab_on" value="{$object_name}" />
    <input type="hidden" name="act" id="tab_act" value="{$act}">
    <input type="hidden" name="tab_mode" id="tab_tab_mode" value="{$vars.tab_mode}">
    <input type="hidden" name="bu_id" id="tab_bu_id" value="{$vars.bu_id}">
    <input type="hidden" name="parent_act" id="tab_parent_act" value="{$vars.parent_act}">
    <input type="hidden" name="kind" id="tab_kind" value="{$vars.kind}">
    {foreach from=$vlu.data item=data}
        <ul class="consumption_tree">
            <li>
                <table>
                    <tr>
                        <th>{t}Contatore{/t}</th>
                        <th>{if $data.meter.is_producer == 'T'}{t}Fornitore{/t}{else}{t}Alimentazione{/t}{/if}</th>
                        <th>{t}Tipologia{/t}</th>
                        <th width="80">
                            {t}Azione{/t}
                            {if $vars.parent_act!='show' and $USER_CAN_ADD_METER}<a href="JavaScript:addMeter({$vars.bu_id}, '{$vars.kind}');" title="{t}Aggiungi contatore{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_add_small.gif">{/if}
                            </a>
                    </tr>
                    <tr id="COUNTER_{$data.meter.em_id}" class="{if $data.meter.im_id<>''}imported_row {/if}{if $data.meter.em_is_production == 'T'}production_row{else}consumption_row {/if}{if $vars.meter_last_id==$data.meter.em_id}selected_row{/if}"><td>{$data.meter.em_name}</td>
                        <td>{if $data.meter.is_producer == 'T'}{$data.meter.us_name} - {$data.meter.up_name} [{$data.meter.udm_name}]{else}{$data.meter.es_name} [{$data.meter.udm_name}]{/if}</td>
                        <td>{if $data.meter.em_is_production <> 'T'}{t}Consumo{/t}{else}{t}Produzione{/t}{/if}</td>
                        <td class="td_center">
                            {if $USER_CAN_SHOW_METER}<a href="JavaScript:showMeter({$data.meter.em_id}, '{$vars.kind}');" title="{t}Visualizza contatore{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_show_small.gif"></a>{/if}
                            {if $vars.parent_act!='show' and $USER_CAN_MOD_METER}<a href="JavaScript:modMeter({$data.meter.em_id}, '{$vars.kind}');" title="{t}Modifica contatore{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_mod_small.gif"></a>{/if}
                                {if $data.devices|@count == 0 && $data.consumptions|@count == 0}
                                    {if $vars.parent_act!='show' and $USER_CAN_DEL_METER}<a href="JavaScript:askDelMeter({$data.meter.em_id}, '{$vars.kind}');" title="{t}Cancella contatore{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_del_small.gif"></a>{/if}
                                {else}
                                    {if $vars.parent_act!='show' and $USER_CAN_DEL_METER}<a href="JavaScript:delMeterMessage({$data.meter.em_id}, '{$vars.kind}');" title="{t}Cancella contatore{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_del_small.gif"></a>{/if}
                                {/if}
                        </td></tr>
                </table>

                <ul class="consumption_tree_line">
                    <li>
                        <table>
                            <tr>
                                <th>{t}Impianto{/t}</th>
                                <th>{t}Potenza{/t} [kW]</th>
                                    {if $vars.kind=='HEATING'}
                                    <th>{t}Data installazione{/t}</th>
                                    <th>{t}Data fine esercizio{/t}</th>
                                    {/if}
                                <th width="80">
                                    {t}Azione{/t}
                                    {if $vars.parent_act!='show' and $USER_CAN_ADD_DEVICE}<a href="JavaScript:addDevice({$data.meter.em_id}, '{$vars.kind}');" title="{t}Aggiungi impianto{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_add_small.gif"></a>{/if}
                                </th>
                            </tr>
                            {foreach from=$data.devices item=devices}
                                <tr id="DEVICE_{$devices.dev_id}" class="{if $device.im_id<>''}imported_row {/if}{if $vars.device_last_id==$devices.dev_id}selected_row{/if}">
                                    <td>{$devices.dev_serial} - {$devices.dt_name}{if $devices.dt_extradata<>''} - {$devices.dt_extradata}{/if}</td>
                                    <td class="td_right">{$devices.dev_power}</td>
                                    {if $vars.kind=='HEATING'}
                                        <td class="td_center">{$devices.dev_install_date}</td>
                                        <td class="td_center">{$devices.dev_end_date}</td>
                                    {/if}
                                    <td class="td_center">
                                        {if $USER_CAN_SHOW_DEVICE}<a href="JavaScript:showDevice({$devices.dev_id}, '{$vars.kind}');" title="{t}Visualizza impianto{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_show_small.gif">{/if}</a>
                                        {if $vars.parent_act!='show' and $USER_CAN_MOD_DEVICE}<a href="JavaScript:modDevice({$devices.dev_id}, '{$vars.kind}');" title="{t}Modifica impianto{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_mod_small.gif">{/if}</a>
                                        {if $vars.parent_act!='show' and $USER_CAN_DEL_DEVICE}<a href="JavaScript:askDelDevice({$devices.dev_id}, '{$vars.kind}');" title="{t}Cancella impianto{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_del_small.gif">{/if}</a>
                                    </td></tr>
                                {/foreach}
                        </table>
                    </li>
                </ul>
                <ul>
                    <li class="consumption_tree_last_line" >
                        <table>
                            <tr>
                                <th>{if $data.meter.em_is_production <> 'T'}{t}Consumo{/t}{else}{t}Produzione{/t}{/if} [{$data.meter.udm_name}]</th>
                                {if $vars.kind<>'WATER'}<th>{if $data.meter.em_is_production <> 'T'}{t}Consumo{/t}{else}{t}Produzione{/t}{/if} [tep]</th>{/if}
                            {if $vars.kind<>'WATER'}{if $data.meter.udm_name|strtolower <> 'kwh'}<th>{if $data.meter.em_is_production <> 'T'}{t}Consumo{/t}{else}{t}Produzione{/t}{/if} [kWh]</th>{/if}{/if}
                            {if $vars.kind<>'WATER'}<th>{t escape=no}CO<sub>2</sub> emessa{/t} [kg]</th>{/if}
                            <th>{if $data.meter.em_is_production <> 'T'}{t}Spesa{/t}{else}{t}Ricavo{/t}{/if} [€]</th>
                            <th>{t}Prezzo unitario{/t} [€/{$data.meter.udm_name}]</th>
                            <th colspan="2">{t}Periodo{/t}</th>
                            <th width="80">
                                {t}Azione{/t}
                                {if $vars.parent_act!='show' and $USER_CAN_ADD_CONSUMPTION}<a href="JavaScript:addConsumptionFromTree({$data.meter.em_id}, '{$vars.kind}');" title="{if $data.meter.em_is_production <> 'T'}{t}Aggiungi consumo{/t}{else}{t}Aggiungi produzione{/t}{/if}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_add_small.gif"></a>{/if}
                            </th>
                        </tr>
                        {foreach from=$data.consumptions item=consumptions}
                            <tr id="CONSUMPTION_{$consumptions.co_id}" class="{if $consumptions.im_id<>''}imported_row {/if}{if $vars.consumption_last_id==$consumptions.co_id}selected_row{/if}">
                                <td class="td_right">{$consumptions.co_value}</td>
                                {if $vars.kind<>'WATER'}<td class="td_right">{$consumptions.co_value_tep}</td>{/if}
                            {if $vars.kind<>'WATER'}{if $data.meter.udm_name|strtolower <> 'kwh'}<td class="td_right">{$consumptions.co_value_kwh}</td>{/if}{/if}
                            {if $vars.kind<>'WATER'}<td class="td_right">{$consumptions.co_value_co2}</td>{/if}
                            <td class="td_right">{$consumptions.co_bill}</td>
                            <td class="td_right">{$consumptions.co_bill_specific}</td>
                            <td class="td_center">{$consumptions.co_start_date}</td>
                            <td class="td_center">{$consumptions.co_end_date}</td>
                            <td class="td_center">
                                {if $USER_CAN_SHOW_CONSUMPTION}<a href="JavaScript:showConsumptionFromTree({$consumptions.co_id}, '{$vars.kind}');" title="{if $data.meter.em_is_production <> 'T'}{t}Visualizza consumo{/t}{else}{t}Visualizza produzione{/t}{/if}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_show_small.gif"></a>{/if}
                                {if $vars.parent_act!='show' and $USER_CAN_MOD_CONSUMPTION}<a href="JavaScript:modConsumptionFromTree({$consumptions.co_id}, '{$vars.kind}');" title="{if $data.meter.em_is_production <> 'T'}{t}Modifica consumo{/t}{else}{t}Modifica produzione{/t}{/if}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_mod_small.gif"></a>{/if}
                                {if $vars.parent_act!='show' and $USER_CAN_DEL_CONSUMPTION}<a href="JavaScript:askDelConsumptionFromTree({$consumptions.co_id}, '{$vars.kind}');" title="{if $data.meter.em_is_production <> 'T'}{t}Cancella consumo{/t}{else}{t}Cancella produzione{/t}{/if}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_del_small.gif"></a>{/if}
                            </td></tr>
                        {/foreach}
                </table>
            </li>
        </ul>
    </li>
</ul><br />
{/foreach}

{if $vlu.data|@count == 0}
    <ul class="consumption_tree">
        <li>
            <table>
                <tr>
                    <th>{t}Contatore{/t}</th>
                    <th>{t}Alimentazione{/t}</th>
                    <th>{t}Tipologia{/t}</th>
                    {if $vars.parent_act!='show' and $USER_CAN_ADD_METER}<th width="80">{t}Azione{/t} <a href="JavaScript:addMeter({$vars.bu_id}, '{$vars.kind}');" title="{t}Aggiungi contatore{/t}"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_add_small.gif"></a>{/if}
                </tr>
            </table>
        </li>
    </ul>
{/if}


{if $vars.kind<>'WATER' && $vlu.conversion_factor|@count>0}
    <table class="factor_table">
        <tr><th class="openclose" colspan="4" style="text-align: left"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_closed.gif" id="img_close" /> {t}Fattori di conversione{/t}</th></tr>
        <tr class="openclose_row"><th>{t}Alimentazione{/t}</th><th>{t}kWh{/t}</th><th>{t}tep{/t}</th><th>{t escape=no}CO<sub>2</sub>{/t}</th></tr>
                {foreach from=$vlu.conversion_factor key=key item=data}
            <tr class="openclose_row"><td style="text-align: left">{if !$data.standard_factor}<i>{/if} {* [{$key}] *}{$data.descr}{if !$data.standard_factor}</i>{/if}</td><td>{$data.kwh}</td><td>{$data.tep}</td><td>{$data.co2}</td></tr>

        {/foreach}
    </table>
{/if}

<table>
    <tr>
        <td>{t}Legenda{/t}:</td>
        {if $vars.kind<>'WATER'}<td class="production_row">{t}Contatore produzione{/t}</td>{/if}
        <td class="consumption_row">{t}Contatore consumo{/t}</td>
        {if $vlu.has_non_standard_factor}<td><i>{t}Fattore di conversione specifico fornitore di energia{/t}</i></td>{/if}
    </tr>
</table>

</form>
{if $vars.tab_mode=='ajax'}{include file="footer_ajax.tpl"}{else}{include file="footer_no_menu.tpl"}{/if}