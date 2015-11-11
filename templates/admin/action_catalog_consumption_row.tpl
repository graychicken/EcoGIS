<tr class="tplExpectedEnergySavings">
    <td colspan="3" nowrap>
        <select name="ges_id_consumption[]" style="width:150px;" {if $lkp.consumption_energy_source_list|@count<=1}disabled{/if}>
            <option value="">{t}-- Selezionare --{/t}</option>
            {foreach from=$lkp.consumption_energy_source_list key=key item=ges_data}
                <option label="{$ges_data.name}" {if $key==$vlu2.ges_id}selected{/if} value="{$key}">{$ges_data.name}</option>
            {/foreach}
        </select>
        <input type="hidden" name="es_id_consumption[]" value="">
        <select name="es_id_consumption_helper[]" style="width:150px;" {if $vlu2.es_id_consumption_values|@count<=1}disabled{/if}>
            <option value="">{t}-- Selezionare --{/t}</option>
            {html_options options=$vlu2.es_id_consumption_values selected=$vlu2.es_id}
        </select>
        <input type="hidden" name="udm_id_consumption[]" value="">
        <select name="udm_id_consumption_helper[]" style="width:100px;" {if $vlu2.udm_id_consumption_values|@count<=1}disabled{/if}>
            <option value="">{t}-- Selezionare --{/t}</option>
            {html_options options=$vlu2.udm_id_consumption_values selected=$vlu2.udm_id}
        </select>
        <input type="text" name="ac_expected_energy_saving[]" value="{$vlu2.ac_expected_energy_saving}" class="float" maxlength="10" style="width:80px;" />
        =
        <input type="text" name="ac_expected_energy_saving_mwh[]" value="{$vlu2.ac_expected_energy_saving_mwh}" class="float readonly" maxlength="10" data-dec="2" style="width:80px;" /> MWh/a
    </td>
    <td>
        <input type="text" name="ac_expected_co2_reduction[]" value="{$vlu2.ac_expected_co2_reduction}" maxlength="80" class="float readonly" data-dec="2" style="width:80px;" /> t/a
    </td>
    {if $act <> 'show'}
        <td>
            <img src="../images/ico_del_small.gif" title="{t}Elimina{/t}" alt="{t}Elimina{/t}" class="btnRemoveExpectedEnergySavings" />
        </td>
    {/if}
</tr>