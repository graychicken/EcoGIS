{literal}
    <script language="JavaScript" type="text/javascript">
        function applySimulationSelection() {
            var selectedCategories = [];
            $('[name="ac_id[]"]').each(function (index) {
                var id = this.id.substr(6);
                if ($(this).prop("checked")) {
                    $('#selected_row_' + id).show();
                    selectedCategories.push($('#selected_row_' + id).attr('class').substr(13));
                } else {
                    $('#selected_row_' + id).hide();
                }
            });
            $('[class^="selected_row_summary-"]').hide();
            $.each(selectedCategories, function (dummy, id) {
                $('.selected_row_summary-' + id).show();
            });

        }
    </script>
{/literal}
<table class="selected actions" width="100%">
    {* TABLE HEADER *}
    <tr>
        <th>{t}Settori{/t}</th>
        <th>{t}Nome{/t}</th>
        <th>{t escape="no"}Azioni principali{/t}</th>
        <th colspan="2" width="150">{t}Attuazione{/t}</th>
        <th colspan="2" width="150">{t}Beneficio{/t}</th>
        <th width="100">{t escape="no"}Costi stimati [€]{/t}</th>
        <th width="100">{t escape="no"}Risparmio energetico [MWh/a]{/t}</th>
        <th width="100">{t escape="no"}Produzione di energia [MWh/a]{/t}</th>
            {*<th width="100">{t escape="no"}Riduzione di CO<sub>2</sub> prevista [t/a]{/t}</th>*}
        <th width="100">{t escape="no"}Acquisto energia verde [MWh/a]{/t}</th>
        <th width="80">{t escape="no"}Efficacia azione [%]{/t}</th>
    </tr>
    {foreach from=$vlu key=key item=data}
        <tr class="selected_row_summary-{$key}" >
            <td style="text-align:left;font-weight:bold;color:white;background-color: #330099" colspan="12">{$data.name}</td>
        </tr>
        {foreach from=$data.data key=cat_key item=cat}
            <tr class="selected_row-{$cat.gc_parent_id}" id="selected_row_{$cat.ac_id}">
                {if $cat.has_extradata=='T'}
                    <th style="text-align: left; font-weight: bold; vertical-align:text-top; font-style:italic;">{$cat.gc_name} {$cat.gc_extradata}</th>
                    {else}
                    <th style="text-align: left; font-weight: bold; vertical-align:text-top;">{$cat.gc_name} {$cat.gc_extradata}</th>
                    {/if}
                <td>{$cat.ac_name}</td>
                <td>{$cat.gpa_name} {$cat.gpa_extradata}</td>
                <td style="text-align:center">{$cat.ac_start_date|date_format:"%d/%m/%Y"}</td>
                <td style="text-align:center">{$cat.ac_end_date|date_format:"%d/%m/%Y"}</td>
                <td style="text-align:center">{$cat.ac_benefit_start_date|date_format:"%d/%m/%Y"}</td>
                <td style="text-align:center">{$cat.ac_benefit_end_date|date_format:"%d/%m/%Y"}</td>
                <td style="text-align:right"><div id="ac_estimated_auto_financing_calc_selected_{$cat.ac_id}"></div></td>
                <td style="text-align:right"><div id="ac_expected_energy_saving_calc_selected_{$cat.ac_id}"></div></td>
                <td style="text-align:right"><div id="ac_expected_renewable_energy_production_calc_selected_{$cat.ac_id}"></div></td>
                    {* <td style="text-align:right"><div id="ac_expected_co2_reduction_calc_selected_{$cat.ac_id}"></div></td> *}
                <td style="text-align:right"><div id="ac_green_electricity_purchase_calc_selected_{$cat.ac_id}"></div></td>
                <td style="text-align:right"><div id="ac_perc_selected_{$cat.ac_id}"></div></td>
            </tr>
        {/foreach}
    {/foreach}
</table>
