<tr class="tplConsumpionSingleRow">
    <td>
        <select class="ges_name" name="ges_id_consumption[]" id="popup_ges_id_{$consumption_key}">
            <option value="">{t}--Selezionare--{/t}</option>
            {foreach item=ges_data key=ges_id from=$lkp.energy_source_list}
                <option value="{$ges_id}" label="{$ges_data.name}" {if isset($consumption) && $consumption.ges_id == $ges_id}selected{/if}>{$ges_data.name}</option>
            {/foreach}
        </select>
        <input type="hidden" name="es_id_consumption[]" value="{$consumption.es_id}">
        <select class="energy_source" name="es_id_consumption_helper[]" style="width:120px">
            <option value="">{t}--Selezionare--{/t}</option>
            {if isset($consumption)}
                {foreach from=$lkp.energy_source_list[$consumption.ges_id].source key=es_id item=es_data}
                    <option value="{$es_id}" label="{$es_data.name}" {if $es_id==$consumption.es_id}selected{/if}>{$es_data.name}</option>
                {/foreach}
            {/if}
        </select>
        <input type="hidden" name="udm_id_consumption[]" value="{$consumption.udm_id}">
        <select class="energy_udm" name="udm_id_consumption_helper[]" style="width:100px">
            <option value="">{t}--Selezionare--{/t}</option>
            {if isset($consumption)}
                {foreach from=$lkp.energy_source_list[$consumption.ges_id].source[$consumption.es_id].udm key=udm_id item=udm_data}
                    <option value="{$udm_id}" label="{$udm_data.name}" {if $udm_id==$consumption.udm_id}selected{/if}>{$udm_data.name}</option>
                {/foreach}
            {/if}
        </select>
    </td>
    <td style="text-align:center"><input type="text" name="ac_expected_energy_saving[]" class="co_value float" data-dec="2" style="width:75px" {if isset($consumption)}value="{$consumption.co_value}"{/if} id="popup_co_value_{$consumption_key}"></td>
        {if $vars.kind=='ENERGY_PRODUCTION' || $vars.kind=='HEATH_PRODUCTION'}
        <td style="text-align:center"><input type="text" name="co_production_co2_factor[]" class="co_value float" data-dec="2" style="width:75px" {if isset($consumption)}value="{$consumption.co_production_co2_factor}"{/if} id="popup_co_production_co2_factor_{$consumption_key}"></td>
        {/if}
    <td style="text-align:center"><input type="text" name="ac_expected_energy_saving_mwh[]" class="readonly float" data-dec="2" style="width:75px" tabindex="-1" {if isset($consumption)}value="{$consumption.co_value_kwh}"{/if}></td>
    <td style="text-align:center"><input type="text" name="ac_expected_co2_reduction" class="readonly float" data-dec="2" style="width:75px" tabindex="-1" {if isset($consumption)}value="{$consumption.co_value_co2}"{/if}></td>
        {if $act<>'show'}
        <td><img src="../images/ico_del_small.gif" class="btnRemoveConsumptionSingleRow"></td>
        {/if}
</tr>