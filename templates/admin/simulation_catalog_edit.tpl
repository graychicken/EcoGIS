{literal}
    <script language="JavaScript" type="text/javascript">

        function setGoalReachedClass(response) {
            var duration = 'fast';

            if (response.goal1_reached_total) {
                $('#simulation_1_paes_target_total').switchClass('goal_not_reached', 'goal_reached', duration);
            } else {
                $('#simulation_1_paes_target_total').switchClass('goal_reached', 'goal_not_reached', duration);
            }
            if (response.goal2_reached_total) {
                $('#simulation_2_paes_target_total').switchClass('goal_not_reached', 'goal_reached', duration);
            } else {
                $('#simulation_2_paes_target_total').switchClass('goal_reached', 'goal_not_reached', duration);
            }
            if (response.goal1_reached_per_capita) {
                $('#simulation_1_paes_target_per_capita').switchClass('goal_not_reached', 'goal_reached', duration);
            } else {
                $('#simulation_1_paes_target_per_capita').switchClass('goal_reached', 'goal_not_reached', duration);
            }
            if (response.goal2_reached_per_capita) {
                $('#simulation_2_paes_target_per_capita').switchClass('goal_not_reached', 'goal_reached', duration);
            } else {
                $('#simulation_2_paes_target_per_capita').switchClass('goal_reached', 'goal_not_reached', duration);
            }
        }

        var simulationRequestCount = 0;
        var forceRecalcSimulation = false;
        function calculateTotals() {
            if (simulationRequestCount > 0) {
                forceRecalcSimulation = true;
                return false;  // Prevent more requests
            }

            $('#simulation_waiting').show();
            simulationRequestCount++;

            var id_list = '';
            var perc_list = '';
            $('[name="ac_id[]"]').each(function (index) {
                if ($(this).prop("checked")) {
                    var id = $(this).attr('id').substr(6);
                    id_list += $(this).val() + ',';
                    perc_list += $('#ac_perc_' + id).val() + ',';
                }
            });
            $.getJSON('edit.php', {
                on: $('#on').val(),
                id: $('#id').val(),
                ac_id_list: id_list,
                ac_perc_list: perc_list,
                efe_is_calculated: $('#sw_efe_is_calculated').prop('checked') ? 'T' : 'F',
                efe: $('#sw_efe').val(),
                method: 'calculateTotals'},
                    function (response) {
                        simulationRequestCount--;
                        if (!$('#simulation_window').is(":visible")) {
                            $('#simulation_window').show();
                            $('#simulation_log').toggle();
                        }
                        if (isAjaxResponseOk(response)) {
                            $('#sw_efe_1').val(response.efe1);
                            $('#sw_efe_2').val(response.efe2);
                            $.each(response.data, function (id, val) {
                                var e = $('#' + id);
                                if (e.is("input")) {
                                    e.val(val);
                                } else {
                                    e.html(val);
                                }
                            });
                            setGoalReachedClass(response);
                            $('#simulation_log').html(response.log);

                            $('#simulation_waiting').hide();
                            if (response.message != '') {
                                alert(response.message);
                            }
                            $('#simulation_waiting .simulation_rebuild').hide();
                            $('#simulation_waiting .simulation_rebuild').hide();
                            if (forceRecalcSimulation) {
                                $('#simulation_waiting .simulation_rebuild').show();
                                forceRecalcSimulation = false;
                                calculateTotals();
                            }
                            forceRecalcSimulation = false;
                        }
                    });
        }

        function toggleCatalogSelection(id, setFocus) {
            id = id.substr(6);
            var hasClass = $('#th_' + id).hasClass('paes_catalog_selected_row');
            $('#th_' + id).parent().toggleClass('paes_catalog_selected_row');
            $('#ac_perc_' + id).toggleClass('readonly').removeAttr('readonly');
            if ($('#ac_perc_' + id).val() == '') {
                $('#ac_perc_' + id).val('100');
            }
            calculateTotals();
            setSelecedTotal();
            applySimulationSelection();
        }

        // Applioca azioni propeeutiche e relative
        function doApplyRelated(id, type) {
            var checked = $('#' + id).prop("checked");
            var selector = '';
            var text = '';
            if (type == 'R') {
                selector = '#' + id + '_related_required';
                text = txtRelatedRequiredActionSelected;
            } else if (type == 'D') {
                selector = '#' + id + '_related';
                text = txtRelatedActionSelected;
            } else if (type == 'E') {
                selector = '#' + id + '_related_excluded';
                text = txtRelatedExcludedActionSelected;
            }
            var s = $(selector).val();
            if (s != '') {
                var requiredList = s.split(",");
                var requiredNameList = Array();
                $.each(requiredList, function (index, value) {
                    if (checked) {
                        if (type == 'R' && !$('#ac_id_' + value).prop("checked")) {
                            requiredNameList.push($('#name_' + value).html());
                            $('#ac_id_' + value).prop("checked", true);
                            toggleCatalogSelection('ac_id_' + value, false);
                        } else if (type == 'D' && !$('#ac_id_' + value).prop("checked")) {
                            requiredNameList.push($('#name_' + value).html());
                        } else if (type == 'E' && $('#ac_id_' + value).prop("checked")) {
                            requiredNameList.push($('#name_' + value).html());
                            $('#ac_id_' + value).prop("checked", false);
                            toggleCatalogSelection('ac_id_' + value, true);
                        }
                    }
                    if (type == 'R' || type == 'E') {
                        $('#ac_id_' + value).prop("disabled", checked);
                    }
                });
                if (requiredNameList.length > 0) {
                    if (type == 'R' || type == 'E') {
                        alert(text + '\n - ' + requiredNameList.join('\n - '));
                    } else {
                        if (confirm(text + '\n - ' + requiredNameList.join('\n - '))) {
                            $.each(requiredList, function (index, value) {
                                $('#ac_id_' + value).prop("checked", true);
                                toggleCatalogSelection('ac_id_' + value, false);
                            });
                        }
                    }
                }
            }
        }

        // Applioca azioni propeeutiche e relative
        function applyRelated(id) {
            doApplyRelated(id, 'R');
            doApplyRelated(id, 'D');
            doApplyRelated(id, 'E');
        }


        function applyCatalogFilter() {
            var val = $('#gc_parent_id').val();
            if (val == '') {
                $('[class^="row_summary"]').show();
                $('[class^="row-"]').show();
            } else {
                $('[class^="row-"]').hide();
                $('[class^="row_summary-"]').hide();
                $('.row-' + val).show();
            }
            setCatalogTotal();
        }

        function setCatalogTotal() {
            var tot = 0;
            $('[class^="row-"]').each(function (index) {
                if ($(this).is(":visible")) {
                    tot++;
                }
            });
            $('#catalog_tot').html('(' + tot + ')');
        }
        ;
        function setSelecedTotal() {
            $('#selected_tot').html('(' + $('.paes_catalog_selected_row').length + ')');

        }
        ;

        function applyEfficacy() {
            $('[name="ac_perc[]"]').each(function (index) {
                var id = this.id.substr(8);
                var perc = $(this).val();
                if (isNaN(parseInt(perc))) {
                    perc = 100;
                    $(this).val(perc);
                }
                var cost_perc = 100;

                var ac_estimated_auto_financing = $('#ac_estimated_auto_financing_' + id).val();
                var ac_expected_energy_saving = $('#ac_expected_energy_saving_' + id).val();
                var ac_expected_renewable_energy_production = $('#ac_expected_renewable_energy_production_' + id).val();
                var ac_expected_co2_reduction = $('#ac_expected_co2_reduction_' + id).val();
                var ac_green_electricity_purchase = $('#ac_green_electricity_purchase_' + id).val();
                $('#ac_estimated_auto_financing_calc_' + id + ',#ac_estimated_auto_financing_calc_selected_' + id).html(float2locale(ac_estimated_auto_financing / 100 * cost_perc, 2));
                $('#ac_expected_energy_saving_calc_' + id + ',#ac_expected_energy_saving_calc_selected_' + id).html(float2locale(ac_expected_energy_saving / 100 * perc, 2));
                $('#ac_expected_renewable_energy_production_calc_' + id + ',#ac_expected_renewable_energy_production_calc_selected_' + id).html(float2locale(ac_expected_renewable_energy_production / 100 * perc, 2));
                $('#ac_expected_co2_reduction_calc_' + id + ',#ac_expected_co2_reduction_calc_selected_' + id).html(float2locale(ac_expected_co2_reduction / 100 * perc, 2));
                $('#ac_green_electricity_purchase_calc_' + id + ',#ac_green_electricity_purchase_calc_selected_' + id).html(float2locale(ac_green_electricity_purchase / 100 * perc, 2));
                $('#ac_perc_selected_' + id).html(perc);
            });

        }

        function initializeCatalogSelection() {
            var acIdList = $('#ac_id_list').val().split(',');
            var acPercList = $('#ac_perc_list').val().split(',');
            $.each(acIdList, function (index, id) {
                $('#ac_id_' + id).prop("checked", true);
                $('#ac_perc_' + id).val(acPercList[index]);
                $('#th_' + id).parent().addClass('paes_catalog_selected_row');
                $('#ac_perc_' + id).removeClass('readonly').removeAttr('readonly');
            });
            setSelecedTotal();
            applySimulationSelection();
        }

        function showActionCatalog(id) {
            OpenWindowResizable('edit.php?on=action_catalog&act=show&parent_act=show&id=' + id, 'GLOBAL_RStrategy', 1024, 768);
        }

        $(document).ready(function () {
            $('#base_action_list tr').bind('mouseenter', function () {
                $(this).addClass('tr_hover')
            });
            $('#base_action_list tr').bind('mouseleave', function () {
                $(this).removeClass('tr_hover')
            });
            $('#base_action_list input[type=checkbox]').bind('click', function () {
                toggleCatalogSelection(this.id, false);
                applyRelated(this.id)
            });
            $('#gc_parent_id').bind('change', function () {
                applyCatalogFilter()
            });
            $('.efficacy').bind('change', function () {
                applyEfficacy();
                calculateTotals();
            });
            setCatalogTotal();
            setSelecedTotal();
            applySimulationSelection();

            initializeCatalogSelection();
            applyEfficacy();

            calculateTotals();

            if (auto_selected_actions == true) {
                calculateTotals();  // Recalculate
                alert(txtAutoSelectedActions);
            }

        });
    </script>
{/literal}
<table id="base_action_list" class="catalog actions" width="100%">
    {* TABLE HEADER *}
    <tr>
        <th>{t}Settori{/t}</th>
        <th colspan="2">{t}Codice{/t}</th>
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
        <tr class="row_summary-{$key}" >
            <td style="text-align:left;font-weight:bold;color:white;background-color: #330099" colspan="14">{$data.name}</td>
        </tr>
        {foreach from=$data.data key=cat_key item=cat}
            <tr class="row-{$cat.gc_parent_id}" >
                {if $cat.has_extradata=='T'}
                    <th id="th_{$cat.ac_id}" style="text-align: left; font-weight: bold; vertical-align:text-top; font-style:italic;">
                    {else}
                    <th id="th_{$cat.ac_id}" style="text-align: left; font-weight: bold; vertical-align:text-top;">                   
                    {/if}
                    {* $cat.ac_id *}
                    <input class="required_action_list" type="hidden" id="ac_id_{$cat.ac_id}_related_required" value="{$cat.ac_id_related_required}" rel="{$cat.ac_id}" />
                    <input class="related_action_list" type="hidden" id="ac_id_{$cat.ac_id}_related" value="{$cat.ac_id_related}" rel="{$cat.ac_id}" />
                    <input class="excluded_action_list" type="hidden" id="ac_id_{$cat.ac_id}_related_excluded" value="{$cat.ac_id_related_excluded}" rel="{$cat.ac_id}" />
                    <input type="checkbox" name="ac_id[]" id="ac_id_{$cat.ac_id}" value="{$cat.ac_id}" {if $cat.ac_benefit_ok!='T'}disabled{/if} class="{if $cat.ac_benefit_ok!='T'}invalid_benefit{/if}" /><label for="ac_id_{$cat.ac_id}">{$cat.gc_name} {$cat.gc_extradata}</label></th>
                <td align="right">{$cat.ac_code}</td>
                <td><a href="javascript:showActionCatalog({$cat.ac_id})"><img src="../images/ico_info_micro.gif" title="{t}Dettaglio azione{/t}"/></a></td>
                <td id="name_{$cat.ac_id}">{$cat.ac_name}</td>
                <td>{$cat.gpa_name} {$cat.gpa_extradata}</td>
                <td style="text-align:center">{$cat.ac_start_date|date_format:"%d/%m/%Y"}</td>
                <td style="text-align:center">{$cat.ac_end_date|date_format:"%d/%m/%Y"}</td>
                <td style="text-align:center">{$cat.ac_benefit_start_date|date_format:"%d/%m/%Y"}</td>
                <td style="text-align:center">{$cat.ac_benefit_end_date|date_format:"%d/%m/%Y"}</td>
                <td style="text-align:right">
                    <input type="hidden" id="ac_estimated_auto_financing_{$cat.ac_id}" value="{$cat.ac_estimated_auto_financing}" />
                    <div id="ac_estimated_auto_financing_calc_{$cat.ac_id}"></div>
                </td>
                <td style="text-align:right">
                    <input type="hidden" id="ac_expected_energy_saving_{$cat.ac_id}" value="{$cat.ac_expected_energy_saving_mwh}" />
                    <div id="ac_expected_energy_saving_calc_{$cat.ac_id}"></div>
                </td>
                <td style="text-align:right">
                    <input type="hidden" id="ac_expected_renewable_energy_production_{$cat.ac_id}" value="{$cat.ac_expected_renewable_energy_production_mwh}" />
                    <div id="ac_expected_renewable_energy_production_calc_{$cat.ac_id}"></div>
                </td>
                {*<td style="text-align:right">
                <input type="hidden" id="ac_expected_co2_reduction_{$cat.ac_id}" value="{$cat.ac_expected_co2_reduction_calc}" />
                <div id="ac_expected_co2_reduction_calc_{$cat.ac_id}"></div>
                </td>*}
                <td style="text-align:right">
                    <input type="hidden" id="ac_green_electricity_purchase_{$cat.ac_id}" value="{$cat.ac_green_electricity_purchase_mwh}" />
                    <div id="ac_green_electricity_purchase_calc_{$cat.ac_id}"></div>
                </td>
                <td style="text-align:center">
                    <input type="text" name="ac_perc[]" id="ac_perc_{$cat.ac_id}" value="" class="float readonly efficacy" style="width: 40px"/>
                </td>
            </tr>
        {/foreach}
    {/foreach}
</table>
