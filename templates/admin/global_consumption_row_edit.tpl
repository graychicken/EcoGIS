{include file="header_ajax.tpl"}
{literal}
    <script language="JavaScript" type="text/javascript">

        function submitFormDataEnergySourceRow() {
            submitData('#popup_modform');
        }

        function after_done_map_editing() {
            $('#geometryStatus').val('changed');
        }

        function afterGCDigitize(geometries) {
            ajaxWait(true);
            disableButton(true);
            $('#geometryStatus').val('changed');
            storeFeatureToTemporaryTable('building', geometries, function () {
                ajaxWait(false);
                disableButton(false);
            });
        }

        /**
         * Submit form data
         * param integer id     the meter id
         */
        function submitFormDataDoneEnergySourceRow(id, kind) {
            hideR3Help();
            if (kind == 'CONSUMPTION' ||
                    kind == 'EMISSION') {
                reloadTab('#tabs', 'consumption');
                reloadTab('#tabs', 'emission');
            } else {
                reloadTab();
            }
            ajaxWait(false);
            disableButton(false);
            closeR3Dialog();
        }

        $(document).ready(function () {
            $('#popup_modform .help').bind('click', function () {
                showR3Help('global_consumption_row', this)
            });
            $('#popup_btnSave').bind('click', function () {
                submitFormDataEnergySourceRow('#popup_modform');
            });
            $('#popup_btnCancel').bind('click', function () {
                closeR3Dialog()
            });

            $('#popup_btnMap').bind('click', function () {
                openGlobalConsumptionMap($("#gisclient").val());
            });

            if ($('#popup_act').val() == 'show') {
                setupShowMode('popup');  // Setup the show mode
                setupInputFormat('#popup_modform', false);
            } else {
                setupInputFormat('#popup_modform');
                setupRequired('#popup_modform');
            }
            setupReadOnly('#popup_modform');
            $('#popup_modform').toggle(true);  // Show the form
            $('#popup_gs_name_1').focus();

            initConsuptionSingleRows();

        });




        function initConsuptionSingleRows() {

            // Remove old events (prevent multiple data conversion)
            $('#consumption_table input[name^=ac_expected_energy_saving]').unbind('focus').unbind('blur');
            var jqTable = $('#consumption_table');
            jqTable.delegate('input[name^=ac_expected_energy_saving]', 'focus', function () {
                adjFloatField(this, true);
            }).delegate('input[name^=ac_expected_energy_saving]', 'blur', function () {
                adjFloatField(this, false);
            });

            $('#consumption_table').delegate('#popup_modform select[name^=ges_id]', 'change', function () {
                var kind = $('#popup_kind').val();
                if (kind == 'EMISSION') {
                    kind = 'CONSUMPTION';
                }
                updateEnergySourceForPAES('#popup_modform', this, kind);
            });
            $('#consumption_table').delegate('#popup_modform select[name^=es_id]', 'change', function () {
                var kind = $('#popup_kind').val();
                if (kind == 'EMISSION') {
                    kind = 'CONSUMPTION';
                }
                updateEnergyUDMForPAES('#popup_modform', this, kind);
            });
            $('#consumption_table').delegate('#popup_modform select[name^=udm_id],input[name^=ac_expected_energy_saving,input[name^=co_production_co2_factor]]', 'change', function () {
                setTimeout("performPAESEnergySourceCalc('#popup_modform')", 10);
            });  // fast-timer needed
            $('#consumption_table').delegate('#popup_modform img.btnRemoveConsumptionSingleRow', 'click', function () {
                if (confirm(askDeleteCurrentRow)) {
                    $(this).parent().parent().remove();
                    if ($('#consumption_table').find('.tplConsumpionSingleRow').length == 0) {
                        addExpectedEnergySavings();
                    }
                    performPAESEnergySourceCalc('#popup_modform');
                }

            });
            $('#popup_modform #btnAddConsumptionSingleRow').click(addExpectedEnergySavings);
        }

        function addExpectedEnergySavings() {
            $('#popup_modform #consumption_table').append($('#global_consumption_template_form .tplConsumpionSingleRow').parent().html());
        }

    </script>
{/literal}

{* Tamplates form *}
<form id="global_consumption_template_form" style="display: none">
    <table>
        {include file="global_consumption_row_single_row.tpl"}
    </table>
</form>

<form name="modform" id="popup_modform" action="edit.php?method=submitFormData" method="post" style="display:none">
    <input type="hidden" name="on" id="popup_on" value="{$object_name}" />
    <input type="hidden" name="act" id="popup_act" value="{$act}">
    <input type="hidden" name="id" id="popup_gs_id" value="{$vlu.gs_id}">
    <input type="hidden" name="mu_id" id="mu_id_popup" value="{$vlu.mu_id}">
    <input type="hidden" name="gisclient" id="gisclient" value="{$smarty.const.GISCLIENT}">
    <input type="hidden" name="geometryStatus" id="geometryStatus" value="">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="popup_{$key}" value="{$val}" />
    {/foreach}
    <table class="form" >
        <tr>
            <th><label class="help required" for="popup_gc_name">{t}Categoria{/t}:</label></th>
            <td colspan="3"><input type="text" name="gc_name" id="popup_gc_name" value="{$vlu.gc_name}" style="width: 550px" class="readonly"></td>
        </tr>
        <tr>
            <th><label class="required help" for="popup_gs_name_1">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="3"><input type="text" name="gs_name_1" id="popup_gs_name_1" value="{$vlu.gs_name_1}" maxlength="80" style="width:550px;" /></td>
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label class="required help" for="popup_gs_name_2">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="3"><input type="text" name="gs_name_2" id="popup_gs_name_2" value="{$vlu.gs_name_2}" maxlength="80" style="width:550px;" />
            </tr>
        {/if}

        {if $lkp.global_method_list|@count > 0}
            <tr>
                <th><label class="help" for="popup_gm_id">{t}Fonte dei dati{/t}:</label></th>
                <td colspan="5"><select name="gm_id" id="popup_gm_id" style="width:550px">
                        <option value="">{t}-- Selezionare --{/t}</option>
                        {html_options options=$lkp.global_method_list selected=$vlu.gm_id}
                    </select></td>
            </tr>
        {/if}

        <tr>
            <th><label class="help" for="popup_gs_descr_1">{t}Descrizione{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="3"><textarea style="width:550px;height:50px;" name="gs_descr_1" id="popup_gs_descr_1">{$vlu.gs_descr_1}</textarea></td>
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label class="help" for="popup_gs_descr_1">{t}Descrizione{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="3"><textarea style="width:550px;height:50px;" name="gs_descr_2" id="popup_gs_descr_2">{$vlu.gs_descr_2}</textarea></td>
            </tr>
        {/if}
        {if $vars.kind=='EMISSION' && $vlu.gc_total_only == 'T'}
            <tr>
                <td><label class="help" for="popup_gs_tot_value">{t escape="no"}Totale CO2{/t}</label></td>
                <td><input type="text" name="gs_tot_value" id="popup_gs_tot_value" value="{$vlu.gs_tot_value}" class="float" data-dec="2" style="width:100px;" /><label class="help" for="popup_gs_tot_value"> [t]</label></td>
            </tr>
        {/if}
        {if $vars.kind=='ENERGY_PRODUCTION' || $vars.kind=='HEATH_PRODUCTION'}
            <tr>
                <td><label class="help" for="popup_gs_tot_production_value">{if $vars.kind=='ENERGY_PRODUCTION'}{t escape="no"}Elettricità prodotta localmente{/t}{else}{t}Calore/freddo prodotti localmente{/t}{/if}</label></td>
                <td><input type="text" name="gs_tot_production_value" id="popup_gs_tot_production_value" value="{$vlu.gs_tot_production_value}" class="float" data-dec="2" style="width:100px;" /><label for="popup_gs_tot_production_value">[MWh]</label></td>
                <td><label class="help" for="popup_gs_tot_emission_value">{t escape="no"}Emissioni di CO2{/t}</label></td>
                <td><input type="text" name="gs_tot_emission_value" id="popup_gs_tot_emission_value" value="{$vlu.gs_tot_emission_value}" class="float" data-dec="2" style="width:100px;" /><label for="popup_gs_tot_emission_value">[t]</label></td>
            </tr>
            <tr>
                <td><label class="help" for="popup_gs_tot_emission_factor">{t escape="no"}Fattori di emissione di CO2{/t}</label></td>
                <td colspan="3"><input type="text" name="gs_tot_emission_factor" id="popup_gs_tot_emission_factor" value="{$vlu.gs_tot_emission_factor}" class="float" data-dec="3" style="width:100px;" /><label for="popup_gs_tot_emission_factor">[t/MWh]</label></td>
            </tr>
        {/if}

    </table>
    <br />

    {if $vlu.gc_total_only == 'F'}
        <table class="consumption_table" id="consumption_table">
            <tr>
                <th>{t}Fonte energetica{/t}</th>
                <th width="80">Consumo</th>
                    {if $vars.kind=='ENERGY_PRODUCTION' || $vars.kind=='HEATH_PRODUCTION'}
                    <th width="80">Fatt.conv. tonnellate CO2</th>
                    {/if}
                <th width="80">MWh</th>
                <th width="80">CO<sub>2</sub> [t]</th>
                    {if $act<>'show'}
                    <th width="20"><img id="btnAddConsumptionSingleRow" src="../images/ico_add.gif" title="{t}Aggiungi{/t}" alt="{t}Aggiungi{/t}" /></th>
                    {/if}
            </tr>

            {if count($vlu.consumption) > 0}
                {foreach item=consumption key=consumption_key from=$vlu.consumption}
                    {assign var="ges_data" value="$lkp.energy_source_list[$consumption.ges_id]"}
                    {include file="global_consumption_row_single_row.tpl"}
                {/foreach}		
            {else}
                {include file="global_consumption_row_single_row.tpl"}
            {/if}

        {/if}

    </table>



    <br />

    {if $act == 'show'}
        <input type="button" id="popup_btnCancel" name="popupBtnCancel"  value="{t}Chiudi{/t}" style="width:120px;height:25px;" />
    {else}
        <input type="button" id="popup_btnSave" name="popupBtnSave"  value="{t}Salva{/t}" style="width:120px;height:25px;" />
        <input type="button" id="popup_btnCancel" name="popupBtnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />
    {/if}
    {if $act <> 'show'}
        &nbsp;&nbsp;&nbsp;&nbsp;
        <input type="button" name="btnMap" id="popup_btnMap" value="{t}Digitalizza su mappa{/t}" style="width:150px;height:25px;">
    {/if}

</form>

{include file="footer_ajax.tpl"}