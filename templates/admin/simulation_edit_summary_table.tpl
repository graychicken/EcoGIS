{literal}
    <style type="text/css">
        table[summary]:after {
            content: attr(summary);
            display: table-caption;
            caption-side: bottom;
            font-size: 10px;
            font-style: italic;
            margin-top: 2px;
            margin-bottom: 10px;
        }
    </style>
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#simulation_summary tr').bind('mouseenter', function () {
                $(this).addClass('tr_hover')
            });
            $('#simulation_summary tr').bind('mouseleave', function () {
                $(this).removeClass('tr_hover')
            });
        });
    </script>
{/literal}

<table id="simulation_summary_table" class="simulation_summary" width="1000" summary="{t}Tabella di sintesi di emissioni, obiettivi e simulazioni{/t}">
    <tr class="simulation_important_row">
        <th>&nbsp;</th>
        {if $vlu.ge_year<>''}<th><a href="javascript:showGlobalResult({$vlu.ge_id})"><div id="inventory_1_year">{$vlu.summary.inventory.1.year}</div></a></th>{/if}
        {if $vlu.ge_2_year<>''}<th><a href="javascript:showGlobalResult({$vlu.ge_id_2})"><div id="inventory_2_year">{$vlu.summary.inventory.2.year}</div></a></th>{/if}
        {if $vlu.gst_reduction_target>0}<th id="target_1_year">{$vlu.summary.target.1.year}</th>{/if}
        {if $vlu.gst_reduction_target_long_term>0}<th id="target_2_year">{$vlu.summary.target.2.year}</th>{/if}
    </tr>
    <tr class="simulation_non_important_row">
        <th>{t}Popolazione (abitanti){/t}</th>
    {if $vlu.ge_year<>''}<td id="inventory_1_population">{if $vlu.summary.inventory.1.population==''}-{else}{$vlu.summary.inventory.1.population}{/if}</td>{/if}
{if $vlu.ge_2_year<>''}<td id="inventory_2_population">{if $vlu.summary.inventory.2.population==''}-{else}{$vlu.summary.inventory.2.population}{/if}</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_population">{if $vlu.summary.simulation.1.population==''}-{else}{$vlu.summary.simulation.1.population}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_population">{if $vlu.summary.simulation.2.population==''}-{else}{$vlu.summary.simulation.2.population}{/if}</td>{/if}
</tr>
<tr class="simulation_non_important_row">
    <th>{t}Emissioni totali CO2 [t]{/t}</th>
{if $vlu.ge_year<>''}<td id="inventory_1_emission_total">{if $vlu.summary.inventory.1.emission.total==''}-{else}{$vlu.summary.inventory.1.emission.total}{/if}</td>{/if}
{if $vlu.ge_2_year<>''}<td id="inventory_2_emission_total">{if $vlu.summary.inventory.2.emission.total==''}-{else}{$vlu.summary.inventory.2.emission.total}{/if}</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_emission_total">{if $vlu.summary.simulation.1.emission.total==''}-{else}{$vlu.summary.simulation.1.emission.total}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_emission_total">{if $vlu.summary.simulation.2.emission.total==''}-{else}{$vlu.summary.simulation.2.emission.total}{/if}</td>{/if}
</tr>
<tr class="simulation_non_important_row">
    <th>{t}Emissioni pro capite CO2 [t/ab]{/t}</th>
{if $vlu.ge_year<>''}<td id="inventory_1_emission_per_capita">{if $vlu.summary.inventory.1.emission.per_capita==''}-{else}{$vlu.summary.inventory.1.emission.per_capita}{/if}</td>{/if}
{if $vlu.ge_2_year<>''}<td id="inventory_2_emission_per_capita">{if $vlu.summary.inventory.2.emission.per_capita==''}-{else}{$vlu.summary.inventory.2.emission.per_capita}{/if}</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_emission_per_capita">{if $vlu.summary.simulation.1.emission.per_capita==''}-{else}{$vlu.summary.simulation.1.emission.per_capita}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_emission_per_capita">{if $vlu.summary.simulation.2.emission.per_capita==''}-{else}{$vlu.summary.simulation.2.emission.per_capita}{/if}</td>{/if}
</tr>
<tr class="simulation_non_important_row">
    <th>{t}Target emissioni totali CO2 [t]{/t}</th>
    {if $vlu.ge_year<>''}<td>-</td>{/if}
    {if $vlu.ge_2_year<>''}<td>-</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_target_emission_total">{if $vlu.summary.simulation.1.target_emission.total==''}-{else}{$vlu.summary.simulation.1.target_emission.total}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_target_emission_total">{if $vlu.summary.simulation.2.target_emission.total==''}-{else}{$vlu.summary.simulation.2.target_emission.total}{/if}</td>{/if}
</tr>
<tr class="simulation_non_important_row">
    <th>{t}Target emissioni pro capite CO2 [t/ab]{/t}</th>
    {if $vlu.ge_year<>''}<td>-</td>{/if}
    {if $vlu.ge_2_year<>''}<td>-</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_target_emission_per_capita">{if $vlu.summary.simulation.1.target_emission.per_capita==''}-{else}{$vlu.summary.simulation.1.target_emission.per_capita}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_target_emission_per_capita">{if $vlu.summary.simulation.2.target_emission.per_capita==''}-{else}{$vlu.summary.simulation.2.target_emission.per_capita}{/if}</td>{/if}
</tr>
<tr class="simulation_non_important_row">
    <th>{t}Obiettivo di riduzione [t]{/t}</th>
    {if $vlu.ge_year<>''}<td>-</td>{/if}
    {if $vlu.ge_2_year<>''}<td>-</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_target_total">{if $vlu.summary.simulation.1.target.total==''}-{else}{$vlu.summary.simulation.1.target.total}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_target_total">{if $vlu.summary.simulation.2.target.total==''}-{else}{$vlu.summary.simulation.2.target.total}{/if}</td>{/if}
</tr>
<tr class="simulation_non_important_row">
    <th>{t}Totale riduzione CO2 da azioni [t]{/t}</th>
    {if $vlu.ge_year<>''}<td>-</td>{/if}
    {if $vlu.ge_2_year<>''}<td>-</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_simulation_reduction_total">{if $vlu.summary.simulation.1.simulation_reduction.total==''}-{else}{$vlu.summary.simulation.1.simulation_reduction.total}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_simulation_reduction_total">{if $vlu.summary.simulation.2.simulation_reduction.total==''}-{else}{$vlu.summary.simulation.2.simulation_reduction.total}{/if}</td>{/if}
</tr>
<tr class="simulation_non_important_row">
    <th>{t}Emissione totale CO2 da simulazione [t]{/t}</th>
    {if $vlu.ge_year<>''}<td>-</td>{/if}
    {if $vlu.ge_2_year<>''}<td>-</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_simulation_emission_total">{if $vlu.summary.simulation.1.simulation_emission.total==''}-{else}{$vlu.summary.simulation.1.simulation_emission.total}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_simulation_emission_total">{if $vlu.summary.simulation.2.simulation_emission.total==''}-{else}{$vlu.summary.simulation.2.simulation_emission.total}{/if}</td>{/if}
</tr>
<tr class="simulation_non_important_row">
    <th>{t}Emissione pro capite CO2 da simulazione [t/ab]{/t}</th>
    {if $vlu.ge_year<>''}<td>-</td>{/if}
    {if $vlu.ge_2_year<>''}<td>-</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_simulation_emission_per_capita">{if $vlu.summary.simulation.1.simulation_emission.per_capita==''}-{else}{$vlu.summary.simulation.1.simulation_emission.per_capita}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_simulation_emission_per_capita">{if $vlu.summary.simulation.2.simulation_emission.per_capita==''}-{else}{$vlu.summary.simulation.2.simulation_emission.per_capita}{/if}</td>{/if}
</tr>
<tr class="simulation_important_row">
    <th>{t}Obiettivo PAES assoluto raggiunto[%]{/t}</th>
    {if $vlu.ge_year<>''}<td>-</td>{/if}
    {if $vlu.ge_2_year<>''}<td>-</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_paes_target_total" class="{if $vlu.summary.simulation.1.goal_reached.total}goal_reached{else}goal_not_reached{/if}">{if $vlu.summary.simulation.1.paes_target.total==''}-{else}{$vlu.summary.simulation.1.paes_target.total}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_paes_target_total" class="{if $vlu.summary.simulation.2.goal_reached.total}goal_reached{else}goal_not_reached{/if}">{if $vlu.summary.simulation.2.paes_target.total==''}-{else}{$vlu.summary.simulation.2.paes_target.total}{/if}</td>{/if}
</tr>
<tr class="simulation_important_row">
    <th>{t}Obiettivo PAES pro capite raggiunto [%]{/t}</th>
    {if $vlu.ge_year<>''}<td>-</td>{/if}
    {if $vlu.ge_2_year<>''}<td>-</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_paes_target_per_capita" class="{if $vlu.summary.simulation.1.goal_reached.per_capita}goal_reached{else}goal_not_reached{/if}">{if $vlu.summary.simulation.1.paes_target.per_capita==''}-{else}{$vlu.summary.simulation.1.paes_target.per_capita}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_paes_target_per_capita" class="{if $vlu.summary.simulation.2.goal_reached.per_capita}goal_reached{else}goal_not_reached{/if}">{if $vlu.summary.simulation.2.paes_target.per_capita==''}-{else}{$vlu.summary.simulation.2.paes_target.per_capita}{/if}</td>{/if}
</tr>
<tr class="simulation_non_important_row">
    <th>{t}Energia da fonti rinnovabili [MWh]{/t}</th>
    {if $vlu.ge_year<>''}<td>-</td>{/if}
    {if $vlu.ge_2_year<>''}<td>-</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_renewal_production_total">{if $vlu.summary.simulation.1.renewal_production.total==''}-{else}{$vlu.summary.simulation.1.renewal_production.total}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_renewal_production_total">{if $vlu.summary.simulation.2.renewal_production.total==''}-{else}{$vlu.summary.simulation.2.renewal_production.total}{/if}</td>{/if}
</tr>
<tr class="simulation_non_important_row">
    <th>{t}Energia da fonti rinnovabili [%]{/t}</th>
    {if $vlu.ge_year<>''}<td>-</td>{/if}
    {if $vlu.ge_2_year<>''}<td>-</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_renewal_production_total_perc">{if $vlu.summary.simulation.1.renewal_production.total_perc==''}-{else}{$vlu.summary.simulation.1.renewal_production.total_perc}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_renewal_production_total_perc">{if $vlu.summary.simulation.2.renewal_production.total_perc==''}-{else}{$vlu.summary.simulation.2.renewal_production.total_perc}{/if}</td>{/if}
</tr>
<tr class="simulation_non_important_row">
    <th>{t}Risparmio energetico [%]{/t}</th>
    {if $vlu.ge_year<>''}<td>-</td>{/if}
    {if $vlu.ge_2_year<>''}<td>-</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_energy_saving_total_perc">{if $vlu.summary.simulation.1.energy_saving.total_perc==''}-{else}{$vlu.summary.simulation.1.energy_saving.total_perc}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_energy_saving_total_perc">{if $vlu.summary.simulation.2.energy_saving.total_perc==''}-{else}{$vlu.summary.simulation.2.energy_saving.total_perc}{/if}</td>{/if}
</tr>
<tr>
    <th>{t}Costo totale [€]{/t}</th>
    {if $vlu.ge_year<>''}<td>-</td>{/if}
    {if $vlu.ge_2_year<>''}<td>-</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_cost_total">{if $vlu.summary.simulation.1.cost.total==''}-{else}{$vlu.summary.simulation.1.cost.total}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_cost_total">{if $vlu.summary.simulation.2.cost.total==''}-{else}{$vlu.summary.simulation.2.cost.total}{/if}</td>{/if}
</tr>
<tr>
    <th>{t}Costo pro capite [€]{/t}</th>
    {if $vlu.ge_year<>''}<td>-</td>{/if}
    {if $vlu.ge_2_year<>''}<td>-</td>{/if}
{if $vlu.gst_reduction_target>0}<td id="simulation_1_cost_per_capita">{if $vlu.summary.simulation.1.cost.per_capita==''}-{else}{$vlu.summary.simulation.1.cost.per_capita}{/if}</td>{/if}
{if $vlu.gst_reduction_target_long_term>0}<td id="simulation_2_cost_per_capita">{if $vlu.summary.simulation.2.cost.per_capita==''}-{else}{$vlu.summary.simulation.2.cost.per_capita}{/if}</td>{/if}
</tr>

</table>


