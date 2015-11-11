{if $vars.tab_mode=='ajax'}{include file="header_ajax.tpl"}{else}{include file="header_no_menu.tpl"}{/if}

{if $vars.has_show_on_map_column}
    <script type="text/javascript" src="{$gisclient_folder}external/OpenLayers.js"></script>
    <script type="text/javascript" language="javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/gisclient_part1.all.js" ></script>
    <script type="text/javascript" language="javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/gisclient_part1.all.i18n.{$lang_code}.js" ></script>
    <script type="text/javascript" language="javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/gisclient_part2.all.js" ></script>
    {literal}
        <script type="text/javascript">
            var langId = '{/literal}{$lang}{literal}';
            if (typeof OpenLayers != 'undefined') {
                OpenLayers.Lang.setCode('{/literal}{$lang_code}{literal}');
            }
            if (typeof Proj4js != 'undefined') {
                Proj4js.defs["EPSG:{/literal}{$proj4js.srid}{literal}"] = "{/literal}{$proj4js.proj4text}{literal}";
            }
        </script>
    {/literal}
{/if}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('.toggler').bind('click', function () {
                toggleSubcategory(this, undefined, true);
            });
            $('#open_all').bind('click', function () {
                toggleAllSubcategory(true, true);
            });
            $('#close_all').bind('click', function () {
                toggleAllSubcategory(false, true);
            });

            $('#udm_divider').bind('change', function () {
                applyUdmDivider();
                parent.reloadAllGlobalResultTabs($('#tab_kind').val().toLowerCase());
            });

            $('.emissions tr').bind('mouseenter', function () {
                $(this).addClass('tr_hover')
            });
            $('.emissions tr').bind('mouseleave', function () {
                $(this).removeClass('tr_hover')
            });

            $('#btnRefresh').bind('click', function () {
                $(this).prop('disabled', true);
                ajaxWait(true);
                location.reload();
            });

            if ($('#tab_toggle_subcategory').val() == 'F' || $('#last_openclose_status').val() == 'CLOSE') {
                toggleAllSubcategory(false);
            } else {
                toggleAllSubcategory(true);
            }
            $.each($('#last_open_categories').val().split(','), function (dummy, id) {
                console.log(id);
                $('.sub_cat_' + id).toggle(true);
                $('.sub_cat_' + id + '_closed').toggle(false);
                $('.sub_cat_' + id + '_opened').toggle(true);
            });

            $('#merge_municipality_data').click(function () {
                applyUdmDivider();
                parent.reloadAllGlobalResultTabs($('#tab_kind').val().toLowerCase());
            });
            $('#modform').toggle(true);

            $('.cantEditMessage').attr('title', txtCantEditManagedObject);

            if ($('#tab_open_category').val() != '') {
                // Forza apertura se arrivo da interogazione mappa
                toggleSubcategory($('#tab_open_category').val(), true);
                $('#tab_dummy_input').focus();
                $('#tab_dummy_input').remove();
            }
        });

    </script>
{/literal}

<form name="modform" id="modform" method="get" action="edit.php">
    <input type="hidden" name="on" id="tab_on" value="{$object_name}" />
    <input type="hidden" name="xact" id="tab_act" value="{$act}">
    <input type="hidden" name="on" id="on" value="{$object_name}" />

    <input type="hidden" name="last_openclose_status" id="last_openclose_status" value="{$vars.last_openclose_status}" />
    <input type="hidden" name="last_open_categories" id="last_open_categories" value="{$vars.last_open_categories}" />
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="tab_{$key}" value="{$val}" />
    {/foreach}
    {* [kind={$vars.kind}] *}
    <table class="emissions">
        {* TABLE HEADER *}
        <tr>
            <th rowspan="{$vlu.header.line0[0].rowspan}" colspan="{$vlu.header.line0[0].colspan}">
                <button name="btnRefresh" id="btnRefresh" type="button" style="float:left; height:25px;" title="{t}Refresh{/t}">
                    <img src="../images/ico_refresh.png">
                </button>
                {$vlu.header.line0[0].label}<br />
                <a href="javascript:;" id="open_all">{t}Apri tutte{/t} <img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_closed.gif" /></a>
                <a href="javascript:;" id="close_all">{t}Chiudi tutte{/t} <img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_opened.gif" /></a>
                    {if $vlu.mu_type == 'C'} {* Municipality collection *}
                        <br><input type="checkbox" name="merge_municipality_data" id="merge_municipality_data" value="T" {if $vlu.merge_municipality_data}checked{/if}/><label for="merge_municipality_data">{t}Mostra dettaglio comuni{/t}</label>
                    {/if}
                </th>
                {if $vars.kind=='ENERGY_PRODUCTION'||$vars.kind=='HEATH_PRODUCTION'}
                    <th rowspan="{$vlu.header.first_fixed_column.line0.rowspan}" colspan="{$vlu.header.first_fixed_column.line0.colspan}">{$vlu.header.first_fixed_column.line0.label} [{$lkp.udm_divider_values[$vlu.udm_divider]}]</th>
                    {/if}
                <th rowspan="{$vlu.header.line0[1].rowspan}" colspan="{$vlu.header.line0[1].colspan}">{$vlu.header.line0[1].label} [
                    {if $vars.can_change_udm && $lkp.udm_divider_values|@count > 1}
                        <select name="udm_divider" id="udm_divider">
                            {html_options options=$lkp.udm_divider_values selected=$vlu.udm_divider}
                        </select>
                    {else}
                        {$lkp.udm_divider_values[$vlu.udm_divider]}
                    {/if}
                    ]</th>
                {if $vlu.header.line0[2].label<>''}<th rowspan="{$vlu.header.line0[2].rowspan}" colspan="{$vlu.header.line0[2].colspan}">{$vlu.header.line0[2].label}</th>{/if}
                {if $vlu.header.line0[3].label<>''}<th rowspan="{$vlu.header.line0[3].rowspan}" colspan="{$vlu.header.line0[3].colspan}">{$vlu.header.line0[3].label}</th>{/if}
                {if $vars.has_action_column}<th rowspan="3">{t}Azione{/t}</th>{/if}
                {if $vars.has_show_on_map_column}<th rowspan="3">{t}Azione{/t}</th>{/if}
            </tr>
            <tr>
                {foreach from=$vlu.header.line1 item=data}
                    <th colspan="{$data.colspan}" rowspan="{$data.rowspan}">{$data.label}{* ({$data.id})*}</th>
                    {/foreach}
            </tr>
            <tr>
                {foreach from=$vlu.header.line2 item=data}
                    <th>{$data.label}{* ({$data.id}) *}</th>
                    {/foreach}
            </tr>
            {* END OF TABLE HEADER *}

            {foreach from=$vlu.data.data item=data}

                {* Macro categoria *}
                {if $data.show_label == 'T'}
                    <tr>
                        {if $vars.has_action_column}
                            <th style="text-align:left;font-weight:bold;color:white;background-color: #330099" colspan="{math equation="x + 2" x=$vlu.header.parameter_count}">{$data.name}</th>
                            {else}
                                {* Elenco completo in popup global_result_object-list *}
                            <th style="text-align:left;font-weight:bold;color:white;background-color: #330099" colspan="{math equation="x + 1" x=$vlu.header.parameter_count}">{$data.name}</th>
                            {/if}
                        <th style="background-color: #330099"></th>
                    </tr>
                {/if}

                {* Categoria principale *}
                {foreach from=$data.categories key=cat_key item=cat}
                    <tr style="background-color:#f5f5f5" data-type="category" data-cat_id="{$cat_key}">
                        <td style="font-weight:bold;" title="{$cat.header.name}">
                            {if $cat.sub_categories|@count > 0 || $vlu.data.production_data[$cat_key]|@count > 0}
                                <img class="toggler sub_cat_{$cat_key}_closed" sub_cat_id="{$cat_key}" src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_closed.gif" style="display:none" />
                                <img class="toggler sub_cat_{$cat_key}_opened" sub_cat_id="{$cat_key}" src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_opened.gif" />
                                <label class="toggler" sub_cat_id="{$cat_key}">{$cat.header.name} {* ({$cat.header.id}) *}</label>
                            {else}
                                <img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_open_close_off.gif" />
                                {$cat.header.name} {* ({$cat.header.id}) *}
                            {/if}
                        </td>
                        {if $vars.kind=='ENERGY_PRODUCTION' || $vars.kind=='HEATH_PRODUCTION'}
                            {assign var='type' value='category'}
                            <td style="text-align:right;">{if $vlu.data.production_sum[$type][$cat_key] <> ''}<b>{$vlu.data.production_sum[$type][$cat_key]}</b>{/if}</td>
                                {/if}

                        {foreach from=$cat.sum item=sum}
                            {* somme di categoria *}
                            <td style="font-weight:bold; text-align:right; {if $cat.header.total_only=='T'}background-color: #cccccc;{/if}" title="{$sum}">{$sum}</td>
                        {/foreach}
                        {if $vars.kind=='CONSUMPTION' || $vars.kind=='EMISSION'}
                            <td style="font-weight:bold; text-align:right" title="{$cat.header.sum}">{$cat.header.sum}</td>
                        {/if}
                        {if $vars.kind=='ENERGY_PRODUCTION' || $vars.kind=='HEATH_PRODUCTION'}
                            {assign var='type' value='category'}
                            <td style="font-weight:bold; text-align:right">{if $vlu.data.production_emission_sum[$type][$cat_key] <> ''}<b>{$vlu.data.production_emission_sum[$type][$cat_key]}</b>{/if}</td>
                            <td style="font-weight:bold; text-align:right">{if $vlu.data.production_emission_sum_factor[$type][$cat_key] <> ''}<b>{$vlu.data.production_emission_sum_factor[$type][$cat_key]}</b>{/if}</td>
                                {/if}
                                {if $vars.has_action_column}
                            <td>
                                {if $vars.parent_act!='show' and $USER_CAN_ADD_GLOBAL_CONSUMPTION_ROW}
                                    <a href="javascript:addGlobalConsumptionRow({$cat_key}, {$vlu.header.parameter_count}, '{$cat.header.total_only}')"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_add_small.gif" border="0"></a>
                                    {/if}
                            </td>
                        {/if}
                    </tr>

                    {assign var="row_count" value=0}
                    {assign var="tick" value=1}

                    {foreach from=$cat.sub_categories key=sub_cat_key item=sub_cat}
                        {if $sub_cat.header.kind!='GLOBAL'}
                            {assign var="row_count" value=$row_count+$tick}
                        {/if}
                        {if $vars.max_inventory_row == '' || $row_count <= $vars.max_inventory_row}
                            <tr class="sub_cat_{$cat_key} {if $vars.gs_id==$sub_cat.header.id}selected_row{/if}">
                                <td style="padding-left:30px; {if $sub_cat.header.kind!='GLOBAL'}font-style: italic;{/if}" title="{$sub_cat.header.name}">
                                    {if $vars.gs_id==$sub_cat.header.id}<input type="text" id="tab_dummy_input" style="width: 0px">{/if}
                                    {if $sub_cat.header.kind!='GLOBAL'}
                                        <a href="javascript:{if $sub_cat.header.kind=='BUILDING'}showBuilding({$sub_cat.header.id-10000000}){else if $sub_cat.header.kind=='STREET_LIGHTING'}showStreetLighting({$sub_cat.header.id-11000000}){/if}">{$sub_cat.header.name}</a>
                                    {else}
                                        {$sub_cat.header.name}
                                    {/if}
                                </td>
                                {if $vars.kind=='ENERGY_PRODUCTION' || $vars.kind=='HEATH_PRODUCTION'}
                                    {assign var='type' value='production'}
                                    <td style="text-align:right;">{$vlu.data.production_data[$cat_key][$sub_cat_key][$type]}</td>
                                {/if}

                                {foreach from=$sub_cat.data item=sub_data}
                                    {* valori *}
                                    <td style="text-align:right; {if $sub_cat.header.kind!='GLOBAL'}font-style: italic;{/if} {if $cat.header.total_only=='T'}background-color: #cccccc;{/if}" title="{$sub_data}">{$sub_data}</td>
                                {/foreach}
                                {if $vars.kind=='CONSUMPTION' || $vars.kind=='EMISSION'}
                                    <td style="text-align:right" title="{$sub_cat.header.sum}">{$sub_cat.header.sum}</td>
                                {/if}
                                {if $vars.kind=='ENERGY_PRODUCTION' || $vars.kind=='HEATH_PRODUCTION'}
                                    {assign var='type' value='production_emission'}
                                    <td style="text-align:right" title="{$sub_cat.header.co2_sum}">{$vlu.data.production_data[$cat_key][$sub_cat_key][$type]}</td>
                                    {assign var='type' value='production_emission_factor'}
                                    <td style="text-align:right" title="{$sub_cat.header.co2_sum}">{$vlu.data.production_data[$cat_key][$sub_cat_key][$type]}</td>
                                {/if}

                                {if $vars.has_action_column}
                                    <td nowrap>
                                        {if $sub_cat.header.kind=='GLOBAL'}
                                            {if $sub_cat.header.has_geometry}
                                                {if $smarty.const.GISCLIENT} 
                                                    <a href="javascript:parent.$.fn.zoomToMap({ldelim}obj_t: 'global_subcategory', obj_key: 'gs_id', obj_id: {$sub_cat.header.id}, highlight: true, windowMode: false, featureType: 'g_inventory.global_subcategory'{rdelim})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_map_small.gif" border="0"></a>
                                                    {else}
                                                    <a href="javascript:showObjectOnMap({$sub_cat.header.id}, 'global_subcategory')"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_map_small.gif" border="0"></a>
                                                    {/if}
                                                {else}
                                                <img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/spacer.gif" width="18">
                                            {/if}
                                            {if $USER_CAN_SHOW_GLOBAL_CONSUMPTION_ROW}<a href="javascript:showGlobalConsumptionRow({$sub_cat.header.id}, {$vlu.header.parameter_count}, '{$cat.header.total_only}')"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_show_small.gif" border="0"></a>{/if}
                                            {if $vars.parent_act!='show' and $USER_CAN_MOD_GLOBAL_CONSUMPTION_ROW and $sub_cat.header.can_mod !== false}<a href="javascript:modGlobalConsumptionRow({$sub_cat.header.id}, {$vlu.header.parameter_count}, '{$cat.header.total_only}')"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_mod_small.gif" border="0"></a>{/if}
                                            {if $vars.parent_act!='show' and $USER_CAN_DEL_GLOBAL_CONSUMPTION_ROW and $sub_cat.header.can_del !== false}<a href="javascript:askDelGlobalConsumptionRow({$sub_cat.header.id})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_del_small.gif" border="0"></a>{/if}
                                            {else}
                                                {if $sub_cat.header.has_geometry}		
                                                    {if $smarty.const.GISCLIENT} 
                                                        {if $sub_cat.header.kind|strtolower == 'building'} 
                                                        <a href="javascript:parent.$.fn.zoomToMap({ldelim}obj_t: 'building', obj_key: 'bu_id', obj_id: {$sub_cat.header.id-10000000}, highlight: true, windowMode: false, featureType: 'g_building.building'{rdelim})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_map_small.gif" border="0"></a>
                                                        {elseif $sub_cat.header.kind|strtolower == 'street_lighting'}
                                                        <a href="javascript:parent.$.fn.zoomToMap({ldelim}obj_t: 'street_lighting', obj_key: 'sl_id', obj_id: {$sub_cat.header.id-11000000}, highlight: true, windowMode: false, featureType: 'g_street_lighting.street_lighting'{rdelim})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_map_small.gif" border="0"></a>
                                                        {/if}
                                                    {else} 
                                                    <a href="javascript:showObjectOnMap({$sub_cat.header.id}, '{$sub_cat.header.kind|strtolower}')"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_map_small.gif" border="0"></a>
                                                    {/if}
                                                {else}
                                                <img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/spacer.gif" width="18">
                                            {/if}
                                            <a href="javascript:cantEditMessage({$sub_cat.header.id})"><img class="cantEditMessage" src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_info_small.gif" border="0"></a>
                                            {/if}
                                    </td>
                                {/if}
                                {if $vars.has_show_on_map_column}
                                    <td nowrap>
                                        {if $sub_cat.header.has_geometry}
                                            {if $sub_cat.header.kind|strtolower == 'building'} 
                                                <a href="javascript:$.fn.zoomToMap({ldelim}obj_t: 'building', obj_key: 'bu_id', obj_id: {$sub_cat.header.id-10000000}, highlight: true, windowMode: false, featureType: 'g_building.building'{rdelim})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_map_small.gif" border="0"></a>
                                                {elseif $sub_cat.header.kind|strtolower == 'street_lighting'}
                                                <a href="javascript:$.fn.zoomToMap({ldelim}obj_t: 'street_lighting', obj_key: 'sl_id', obj_id: {$sub_cat.header.id-11000000}, highlight: true, windowMode: false, featureType: 'g_street_lighting.street_lighting'{rdelim})"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_map_small.gif" border="0"></a>
                                                {/if}
                                            {/if}
                                    </td>
                                {/if}
                            </tr>
                        {elseif $row_count == $vars.max_inventory_row+1}
                            {assign var="row_count" value=$row_count+$tick}
                            {* Superato numero massimo di edifici / tratti di strada digitalizzati *}
                            <tr class="sub_cat_{$cat_key}"><td style="padding-left:40px; font-style: italic;"><a href="javascript:showInventoryObjectList({$vars.ge_id}, {$cat_key}, '{$vars.kind}')" style="color: black;">{t}E' stato superato il numero massimo di elementi digitalizzati visualizzabili{/t}</a></td>
                                {foreach from=$sub_cat.data item=sub_data}
                                    <td></td>
                                {/foreach}
                                {if $vars.kind=='CONSUMPTION' || $vars.kind=='EMISSION'}
                                    <td></td>
                                {/if}
                                {if $vars.kind=='ENERGY_PRODUCTION' || $vars.kind=='HEATH_PRODUCTION'}
                                    <td></td>
                                    <td></td>
                                {/if}
                                {if $vars.has_action_column}
                                    <td></td>
                                {/if}
                            </tr>
                        {/if}
                    {/foreach}
                {/foreach}
                {if $vars.has_partial_total_row}
                    {if $data.sum.source|@count>0 && $data.show_label == 'T'}
                            <tr style="background-color: #66FF66"><td><i>{$data.sub_total_label}</i></td>
                                        {foreach from=$data.sum.source item=tot}
                                    <td style="text-align:right;">{if $tot<>''}<b>{$tot}</b>{/if}</td>
                                        {/foreach}
                                <td style="text-align:right;">{if $data.sum.total<>''}<b>{$data.sum.total}</b>{/if}</td>
                                <td></td>
                            </tr>
                        {/if}
                    {/if}
                    {/foreach}
                        {if $vlu.data.production_sum.tot<>'0' || 
            $vlu.data.sum.source|@count>0 || 
            (int)$vlu.data.sum.total <> '0' ||
            (int)$vlu.data.tot_emission <> '0'}  {* Totale di tabella (Solo se ho dati) *}
                        <tr style="background-color: #339933">
                            <td><b>{$vlu.data.sum.label}</b></td>
                            {if $vars.kind=='ENERGY_PRODUCTION' || $vars.kind=='HEATH_PRODUCTION'}
                                {assign var='type' value='tot'}
                                <td style="text-align:right;">{if $vlu.data.production_sum[$type]<>''}<b>{$vlu.data.production_sum[$type]}</b>{/if}</td>
                                    {/if}
                                    {foreach from=$vlu.data.sum.source item=tot}
                                <td style="text-align:right;">{if $tot<>''}<b>{$tot}</b>{/if}</td>
                                    {/foreach}
                                    {if $vars.kind=='CONSUMPTION' || $vars.kind=='EMISSION'}
                                <td style="text-align:right;">{if $vlu.data.sum.total<>''}<b>{$vlu.data.sum.total}</b>{/if}</td>
                                    {else}
                                        {assign var='type' value='tot'}
                                <td style="text-align:right;">{if $vlu.data.production_emission_sum[$type]<>''}<b>{$vlu.data.production_emission_sum[$type]}</b>{/if}</td>
                                    {/if}
                                    {if $vars.has_action_column}
                                <td></td>
                            {/if}
                        </tr>
                        {/if}
                        </table>
                    </form>

            {if $vars.tab_mode=='ajax'}{include file="footer_ajax.tpl"}{else}{include file="footer_no_menu.tpl"}{/if}