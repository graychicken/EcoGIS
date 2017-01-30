{if $vars.tab_mode=='ajax'}{include file="header_ajax.tpl"}{else}{include file="header_no_menu.tpl"}{/if}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('.consumption_tree tr').bind('mouseenter', function () {
                $(this).addClass('tr_hover')
            });
            $('.consumption_tree tr').bind('mouseleave', function () {
                $(this).removeClass('tr_hover')
            });
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
        
    <ul class="consumption_tree">
        <li>
            <table>
                <tr>
                    <th>{t}Anno{/t}</th>
                    <th>{t}Riscaldamento{/t} ({t}kWh/anno{/t})</th>
                    <th>{t}Riscaldamento{/t} ({t}kWh/anno{/t}) <div style="font-size: 10px">({t}Con gradi giorno{/t})</div></th>
                    {if $vlu.data.has_heating_degree_day}
                    <th>{$vlu.data.heating2_label} ({t}kWh/anno{/t})</th>
                    <th>{$vlu.data.heating2_label} ({t}kWh/anno{/t}) <div style="font-size: 10px">({t}Con gradi giorno{/t})</div></th>
                    {/if}
                    <th>{t}Energia elettrica{/t} ({t}kWh/anno{/t})</th>
                    <th>{t escape=no}CO<sub>2</sub> (kg CO<sub>2</sub>/anno){/t}</th>
                    <th>{t escape=no}CO<sub>2</sub> (kg CO<sub>2</sub>/anno){/t} <div style="font-size: 10px">({t}Con gradi giorno{/t})</div></th>
                </tr>
                {foreach from=$vlu.data.rows item=row}
                <tr>
                    <td class="td_right">{$row.co_year}</td>
                    <td class="td_right">{$row.heating_fmt}</td>
                    <td class="td_right">{$row.heating_gg_fmt}</td>
                    {if $vlu.data.has_heating_degree_day}
                    <td class="td_right">{$row.heating_utility_fmt}</td>
                    <td class="td_right">{$row.heating_utility_gg_fmt}</td>
                    {/if}
                    <td class="td_right">{$row.electricity_fmt}</td>
                    <td class="td_right">{$row.co2_fmt}</td>
                    <td class="td_right">{$row.co2_gg_fmt}</td>
                </tr>
                {/foreach}
            </table>
        </li>
    </ul>
</form>
{if $vars.tab_mode=='ajax'}{include file="footer_ajax.tpl"}{else}{include file="footer_no_menu.tpl"}{/if}