{if $vars.tab_mode=='ajax'}{include file="header_ajax.tpl"}{else}{include file="header_no_menu.tpl"}{/if}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('.actions tr').bind('mouseenter', function () {
                $(this).addClass('tr_hover')
            });
            $('.actions tr').bind('mouseleave', function () {
                $(this).removeClass('tr_hover')
            });

            $('#merge_municipality_data').click(function () {
                ajaxWait(true);
                document.location = 'edit.php?on=global_plain_table&gp_id=' + $('#tab_gp_id').val() +
                        '&merge_municipality_data=' + ($('#merge_municipality_data').prop('checked') ? 'T' : 'F') +
                        '&tab_mode=' + $('#tab_mode').val() +
                        '&parent_act=' + $('#tab_parent_act').val();

            });

            $('#btnRefresh').bind('click', function () {
                $(this).prop('disabled', true);
                ajaxWait(true);
                location.reload();
            });

        });
    </script>
{/literal}

<form name="modform" id="modform" method="get" action="edit.php" >
    <input type="hidden" name="on" id="tab_on" value="{$object_name}" />
    <input type="hidden" name="xact" id="tab_act" value="{$act}">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="tab_{$key}" value="{$val}" />
    {/foreach}

    <table class="actions">
        {* TABLE HEADER *}
        <tr>
            <th width="200">{t}Settori{/t}
                <button name="btnRefresh" id="btnRefresh" type="button" style="float:left; height:25px;" title="{t}Refresh{/t}">
                    <img src="../images/ico_refresh.png">
                </button>
                {if $vlu.mu_type == 'C'} {* Municipality collection *}
                        <br><input type="checkbox" name="merge_municipality_data" id="merge_municipality_data" value="T" {if $vlu.merge_municipality_data}checked{/if}/><label for="merge_municipality_data">{t}Mostra dettaglio comuni{/t}</label>
                    {/if}
                </th>
                <th xwidth="200">{t escape="no"}Azioni principali{/t}</th>
                <th xwidth="150">{t escape="no"}Responsabile{/t}</th>
                <th colspan="2" width="160">{t escape="no"}Attuazione{/t}</th>
                <th width="100">{t escape="no"}Costi stimati [€]{/t}</th>
                <th width="100">{t escape="no"}Risparmio energetico previsto [MWh/a]{/t}</th>
                <th width="100">{t escape="no"}Produzione di energia rinnovabile prevista [MWh/a]{/t}</th>
                <th width="100">{t escape="no"}Riduzione di CO<sub>2</sub> prevista [t/a]{/t}</th>
                    {if !$vars.short_format}
                    <th width="100">{t escape="no"}Obiettivo di risparmio energetico [MWh] nel 2020{/t}</th>
                    <th width="100">{t escape="no"}Obiettivo di produzione locale di energia rinnovabile [MWh] nel 2020{/t}</th>
                    <th width="100">{t escape="no"}Obiettivo di riduzione di CO<sub>2</sub> [t] nel 2020{/t}</th>
                    {/if}
                    {if $vlu.can_monitoring}
                    <th width="100">{t}% Completamento energia{/t}</th>
                    <th width="100">{t}% Completamento emissioni{/t}</th>
                    {/if}

                {if $vars.parent_act<>'show'}
                    <th width="70">{t}Azione{/t}</th>
                    {/if}
            </tr>

            {foreach from=$vlu.data.data item=data}
                <tr>
                    {if $vars.short_format}
                        <td style="text-align:left;font-weight:bold;color:white;background-color:#330099" colspan="6">{$data.name}</td>
                        <td style="text-align:right;font-weight:bold;color:white;background-color:#330099">{$data.sum.expected_energy_saving|r3number_format:2:',':'.'}</td>
                        <td style="text-align:right;font-weight:bold;color:white;background-color:#330099">{$data.sum.expected_renewable_energy_production|r3number_format:2:',':'.'}</td>
                        <td style="text-align:right;font-weight:bold;color:white;background-color:#330099">{$data.sum.expected_co2_reduction|r3number_format:2:',':'.'}</td>
                    {else}
                        <td style="text-align:left;font-weight:bold;color:white;background-color: #330099" colspan="9">{$data.name}</td>
                        <td style="text-align:right;">{$data.sum.expected_energy_saving|r3number_format:2:',':'.'}</td>
                        <td style="text-align:right;">{$data.sum.expected_renewable_energy_production|r3number_format:2:',':'.'}</td>
                        <td style="text-align:right;">{$data.sum.expected_co2_reduction|r3number_format:2:',':'.'}</td>
                    {/if}
                    {if $vlu.can_monitoring}
                        <td style="text-align:right;font-weight:bold;color:white;background-color:#330099">{if $data.sum.progress_energy<>''}{$data.sum.progress_energy|r3number_format:1:',':'.'}%{/if}</td>
                        <td style="text-align:right;font-weight:bold;color:white;background-color:#330099">{if $data.sum.progress_emission<>''}{$data.sum.progress_emission|r3number_format:1:',':'.'}%{/if}</td>
                    {/if}

                    {if $vars.parent_act<>'show'}
                        <td style="background-color: #330099">
                            {if $USER_CONFIG_APPLICATION_CALCULATE_GLOBAL_PLAIN_TOTALS<>'T'}
                                <img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_spacer.gif" width="16">
                                {if $USER_CAN_MOD_GLOBAL_PLAIN_TABLE}<a href="javascript:modGlobalPlainSum({$data.gc_parent_id}, {$vars.gp_id})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_mod_small.gif" border="0"></a>{/if}
                                    {if $USER_CAN_DEL_GLOBAL_PLAIN_TABLE && ($data.sum.expected_energy_saving <> '' ||
                                    $data.sum.expected_renewable_energy_production <> '' ||
                                    $data.sum.expected_co2_reduction <> '')}<a href="javascript:askDelGlobalPlainSum({$data.gc_parent_id}, {$vars.gp_id})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_del_small.gif" border="0"></a>{/if}
                                {/if}
                        </td>
                        {/if}
                        </tr>
                        {foreach from=$data.categories key=cat_key item=cat name=foo}
                            <tr>
                                {foreach from=$cat.data item=cat_data key=gpr_id name=foo2}
                                    {if $smarty.foreach.foo2.first}
                                        {if $cat.has_extradata=='T'}
                                            <th style="text-align: left; font-weight: bold; vertical-align:text-top; font-style:italic;">{$cat_data.fullname}</th>
                                            {else}
                                            <th rowspan="{$cat.data|@count}" style="text-align: left; font-weight: bold; vertical-align:text-top;">{$cat.name}</th>
                                            {/if}
                                        {/if}

                                    {if !$smarty.foreach.foo2.first}
                                        {if $vlu.can_monitoring}
                                            <td style="width:70px; text-align: right">{if $last_progress_energy<>''}{$last_progress_energy|r3number_format:1:',':'.'}%{/if}</td>
                                            <td style="width:70px; text-align: right">{if $last_progress_emission<>''}{$last_progress_emission|r3number_format:1:',':'.'}%{/if}</td>
                                        {/if}
                                        {if $vars.parent_act<>'show'}
                                            <td>
                                            {if $USER_CAN_ADD_GLOBAL_PLAIN_TABLE}{if $smarty.foreach.foo2.iteration<=2}<a href="javascript:addGlobalPlainRow({$cat_key}, {$vars.gp_id})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_add_small.gif" border="0"></a>{else}<img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_spacer.gif" width="16" border="0">{/if}{/if}
                                            {if $USER_CAN_MOD_GLOBAL_PLAIN_TABLE && $last_can_mod !== false}<a href="javascript:modGlobalPlainRow({$cat_key}, {$vars.gp_id}, {if $last_gpr_id>0}{$last_gpr_id}{else}0{/if})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/{if $last_gauge_type==''}ico_mod_small.gif{else}ico_mod_monitor.gif{/if}" border="0"></a>{/if}
                                            {if $USER_CAN_DEL_GLOBAL_PLAIN_TABLE && !$last_imported_row && $last_can_del !== false}<a href="javascript:askDelGlobalPlainRow({$last_gpr_id})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_del_small.gif" border="0"></a>{/if}
                                        </td>
                                    {/if}
                                </tr><tr>
                                    {if $cat.has_extradata=='T'}
                                        <th style="text-align: left; font-weight: bold; vertical-align:text-top; font-style:italic;">{$cat_data.fullname}</th>
                                        {/if}
                                    {/if}
                                    {assign var='last_gpr_id' value=$gpr_id}
                                    {assign var='last_imported_row' value=$cat_data.imported_row}
                                    {assign var='last_gauge_type' value=$cat_data.gauge_type}
                                    {assign var='last_progress_energy' value=$cat_data.progress_energy}
                                    {assign var='last_progress_emission' value=$cat_data.progress_emission}
                                    {assign var='last_can_mod' value=$cat_data.can_mod}
                                    {assign var='last_can_del' value=$cat_data.can_del}

                                <td {if $cat_data.descr<>''}title="{$cat_data.descr|escape:'htmlall':'utf-8'}"{/if}>{$cat_data.name}</td>
                                <td>{$cat_data.responsible_department}</td>
                                <td align="center" width="78">{$cat_data.start_date|date_format:"%d/%m/%Y"}</td>
                                <td align="center">{$cat_data.end_date|date_format:"%d/%m/%Y"}</td>
                                <td align="right">{$cat_data.estimated_cost|r3number_format:2:',':'.'}</td>
                                <td align="right">{$cat_data.expected_energy_saving|r3number_format:2:',':'.'}</td>
                                <td align="right">{$cat_data.expected_renewable_energy_production|r3number_format:2:',':'.'}</td>
                                <td align="right">{$cat_data.expected_co2_reduction|r3number_format:2:',':'.'}</td>
                                {if !$vars.short_format}<td class="no_border" colspan="3"></td>{/if}
                            {/foreach}
                            {if $vlu.can_monitoring}
                                <td style="width:70px; text-align: right">{if $last_progress_energy<>''}{$last_progress_energy|r3number_format:1:',':'.'}%{/if}</td>
                                <td style="width:70px; text-align: right">{if $last_progress_emission<>''}{$last_progress_emission|r3number_format:1:',':'.'}%{/if}</td>
                            {/if}
                            {if $vars.parent_act<>'show'}
                                <td nowrap>
                                    {if $smarty.foreach.foo2.first}
                                        {if $USER_CAN_ADD_GLOBAL_PLAIN_TABLE}<a href="javascript:addGlobalPlainRow({$cat_key}, {$vars.gp_id})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_add_small.gif" border="0"></a>{/if}
                                        {else}
                                        <img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_spacer.gif" width="16">
                                    {/if}
                                    {if $USER_CAN_MOD_GLOBAL_PLAIN_TABLE && $last_gpr_id>0 && $last_can_mod !== false}<a href="javascript:modGlobalPlainRow({$cat_key}, {$vars.gp_id}, {if $last_gpr_id>0}{$last_gpr_id}{else}0{/if})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/{if $last_gauge_type==''}ico_mod_small.gif{else}ico_mod_monitor.gif{/if}" border="0"></a>{/if}
                                    {if $USER_CAN_DEL_GLOBAL_PLAIN_TABLE && $last_gpr_id>0 && !$last_imported_row && $last_can_del !== false}<a href="javascript:askDelGlobalPlainRow({$last_gpr_id})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_del_small.gif" border="0"></a>{/if}
                                </td>
                            {/if}
                        </tr>
                    {/foreach}
                    {/foreach}
                        <tr>
                            <td style="background-color: #e6e6e6" colspan="{if $vars.short_format}5{else}8{/if}"></td>
                            <th style="text-align:right;font-weight:bold;">{t}Totale{/t}</th>
                            <td style="text-align:right;background-color: #e6e6e6;">{$vlu.data.sum.expected_energy_saving|r3number_format:2:',':'.'}</td>
                            <td style="text-align:right;background-color: #e6e6e6;">{$vlu.data.sum.expected_renewable_energy_production|r3number_format:2:',':'.'}</td>
                            <td style="text-align:right;background-color: #e6e6e6;">{$vlu.data.sum.expected_co2_reduction|r3number_format:2:',':'.'}</td>
                            {if $vlu.can_monitoring}
                                <td style="text-align:right;background-color: #e6e6e6;">{$vlu.data.sum.progress_energy|r3number_format:1:',':'.'}%</td>
                                <td style="text-align:right;background-color: #e6e6e6;">{$vlu.data.sum.progress_emission|r3number_format:1:',':'.'}%</td>
                                <td style="background-color: #e6e6e6"></td>
                            {else}
                                <td style="background-color: #e6e6e6"></td>
                            {/if}
                        </tr>



                        {* END OF TABLE HEADER *}

                        {foreach from=$vlu.data item=data}
                            {* Macro categoria *}
                            {if $data.show_label == 'T'}
                                <tr>
                                    <th width="300" style="text-align:left;font-weight:bold;color:white;background-color: #330099" colspan="{math equation="x + 2" x=$vlu.header.parameter_count}">{$data.name}</th>
                                    <th style="background-color: #330099"></th>
                                </tr>
                            {/if}
                            {foreach from=$data.categories key=cat_key item=cat}
                                {* Categoria principale *}
                                <tr style="background-color:#f5f5f5">
                                    <td style="font-weight:bold;" title="{$cat.header.name}">
                                        {if $cat.sub_categories|@count > 0}<img class="toggler sub_cat_{$cat_key}_closed" sub_cat_id="{$cat_key}" src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_closed.gif" style="display:none" /><img class="toggler sub_cat_{$cat_key}_opened" sub_cat_id="{$cat_key}" src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_opened.gif" />
                                        {else}<img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_open_close_off.gif" />{/if}
                                        {$cat.header.name}
                                    </td>
                                    {foreach from=$cat.sum item=sum}
                                        {* somme di categoria *}
                                        <td style="font-weight:bold; text-align:right; {if $cat.header.total_only=='T'}background-color: #cccccc;{/if}" title="{$sum}">{$sum}</td>
                                    {/foreach}
                                    <td style="font-weight:bold; text-align:right" title="{$cat.header.sum}">{$cat.header.sum}</td>
                                    <td>
                                        {if $vars.parent_act!='show' and $USER_CAN_ADD_GLOBAL_CONSUMPTION_ROW}
                                            <a href="javascript:addGlobalConsumptionRow({$cat_key}, {$vlu.header.parameter_count}, '{$cat.header.total_only}')"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_add_small.gif" border="0"></a>
                                            {/if}
                                    </td>
                                </tr>
                                {foreach from=$cat.sub_categories key=sub_cat_key item=sub_cat}
                                    <tr class="sub_cat_{$cat_key}">
                                        <td style="padding-left:30px; {if $sub_cat.header.kind!='GLOBAL'}font-style: italic;{/if}" title="{$sub_cat.header.name}">
                                            {if $sub_cat.header.kind!='GLOBAL'}
                                                <a href="javascript:{if $sub_cat.header.kind=='BUILDING'}showBuilding{else if $sub_cat.header.kind=='STREET_LIGHTING'}showStreetLighting{/if}({$sub_cat.header.id})">{$sub_cat.header.name}</a>
                                            {else}
                                                {$sub_cat.header.name}
                                            {/if}
                                        </td>
                                        {foreach from=$sub_cat.data item=sub_data}
                                            {* valori *}
                                            <td style="text-align:right; {if $sub_cat.header.kind!='GLOBAL'}font-style: italic;{/if} {if $cat.header.total_only=='T'}background-color: #cccccc;{/if}" title="{$sub_data}">{$sub_data}</td>
                                        {/foreach}
                                        <td style="text-align:right" title="{$sub_cat.header.sum}">{$sub_cat.header.sum}</td>
                                        <td>
                                            {if $sub_cat.header.kind=='GLOBAL'}
                                                <a href="javascript:showObjectOnMap({$sub_cat.header.id}, 'global_consumption')"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_map_small.gif" border="0"></a>
                                                {if $USER_CAN_SHOW_GLOBAL_CONSUMPTION_ROW}<a href="javascript:showGlobalConsumptionRow({$sub_cat.header.id}, {$vlu.header.parameter_count}, '{$cat.header.total_only}')"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_show_small.gif" border="0"></a>{/if}
                                                {if $vars.parent_act!='show' and $USER_CAN_MOD_GLOBAL_CONSUMPTION_ROW}<a href="javascript:modGlobalConsumptionRow({$sub_cat.header.id}, {$vlu.header.parameter_count}, '{$cat.header.total_only}')"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_mod_small.gif" border="0"></a>{/if}
                                                {if $vars.parent_act!='show' and $USER_CAN_DEL_GLOBAL_CONSUMPTION_ROW}<a href="javascript:askDelGlobalConsumptionRow({$sub_cat.header.id})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_del_small.gif" border="0"></a>{/if}
                                                {else}
                                                <a href="javascript:showObjectOnMap({$sub_cat.header.id}, '{$sub_cat.header.kind|strtolower}')"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_map_small.gif" border="0"></a>
                                                <a href="javascript:cantEditMessage({$sub_cat.header.id})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_info_small.gif" border="0"></a>
                                                {/if}
                                        </td>
                                    </tr>
                                {/foreach}
                            {/foreach}
                        {/foreach}
                    </table>
                </form>
        {if $vars.tab_mode=='ajax'}{include file="footer_ajax.tpl"}{else}{include file="footer_no_menu.tpl"}{/if}