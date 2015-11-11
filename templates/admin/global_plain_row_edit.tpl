{include file="header_ajax.tpl"}

{literal}
    <script language="JavaScript" type="text/javascript">

        function submitFormDataDoneGlobalPlainRow(id) {
            hideR3Help();
            reloadTab();
            closeR3Dialog();
            ajaxWait(false);
            disableButton(false);
        }

        function moveGauges() {
            $("#gpr_gauge_type_cel").html('');
            $(".gauge_data").appendTo("#gpr_gauge_type_cel");
            $("#hidden_form").remove();
        }

        $(document).ready(function () {
            $('#popup_modform .help').bind('click', function () {
                showR3Help('global_plain', this)
            });
            $('#popup_gc_id').bind('change', function () {
                updateGlobalAction('#popup_gpa_id', '#popup_gc_id');
                updateForExtraData('#popup_gc_id', '#popup_gc_extradata');
            });
            $('#popup_gpa_id').bind('change', function () {
                updateForExtraData('#popup_gpa_id', '#popup_gpa_extradata');
            });

            $('#popup_btnSave').bind('click', function () {
                submitFormDataGlobalPlainRow('#popup_modform');
            });
            $('#popup_btnCancel').bind('click', function () {
                closeR3Dialog()
            });

            moveGauges();
            if ($('#popup_act').val() == 'show') {
                setupShowMode('popup');  // Setup the show mode
                setupInputFormat('#popup_modform', false);
            } else {
                setupInputFormat('#popup_modform');
                setupRequired('#popup_modform');
            }
            setupReadOnly('#popup_modform');
            updateForExtraData('#popup_gc_id', '#popup_gc_extradata', true);
            updateForExtraData('#popup_gpa_id', '#popup_gpa_extradata', true);

            $('#popup_modform').delegate('input[name^=gpm_value]', 'change', function () {
                // Timeout needed by convert data to locale
                var $me = $(this);
                setTimeout(function () {
                    var tr = $me.parent().parent();
                    var value_1 = tr.find('input[name^=value_1]').val();
                    var value_2 = tr.find('input[name^=value_2]').val();
                    var value_3 = tr.find('input[name^=value_3]').val();
                    var quantity = locale2float(tr.find('input[name^=gpm_value_1]').val());
                    var efficiency = locale2float(tr.find('input[name^=gpm_value_2]').val());
                    var energyValue = '-';
                    var emissionValue = '-';
                    if (quantity != '' && efficiency != '') {
                        energyValue = value_1 * (value_2 - efficiency) * quantity;
                        emissionValue = float2locale(energyValue * value_3, 2);
                        energyValue = float2locale(energyValue, 2);
                    }
                    tr.find('input[name^=gpm_energy_value]').val(energyValue);
                    tr.find('input[name^=gpm_co2_value]').val(emissionValue);
                }, 50);
            });

            $('#popup_modform').delegate('.add_meter_row', 'click', function () {
                var tr = $(this).parent().parent();
                var table = tr.parent();
                table.append('<tr>' + tr.html() + '</tr>');
                table.find('tr:last').find('input[name^=gpm_value]').
                        bind('focus', function () {
                            adjFloatField(this, true)
                        }).
                        bind('blur', function () {
                            adjFloatField(this, false)
                        });

                // Restore datapicker
                var e = table.find('tr:last').find('input[name^=gpm_date]');
                e.removeAttr('id');
                e.parent().find('img').remove();
                e.removeClass('hasDatepicker').datepicker();
                // Remove add button
                $(this).remove();
            });
            $('#popup_modform').delegate('.mod_meter_row', 'click', function () {
                var tr = $(this).parent().parent();
                tr.find('input[name^=gpm_date]').removeClass('readonly').prop('readonly', false).datepicker();
                tr.find('input[name^=gpm_value]').removeClass('readonly').prop('readonly', false).focus().select();

                tr.find('input[name^=gpm_value]').
                        bind('focus', function () {
                            adjFloatField(this, true)
                        }).
                        bind('blur', function () {
                            adjFloatField(this, false)
                        });

            });
            $('#popup_modform').delegate('.del_meter_row', 'click', function () {
                if (confirm(txtAskDeleteMeterRow)) {
                    var tr = $(this).parent().parent().remove();
                }
            });

            $('#popup_modform').toggle(true);  // Show the form
        });

    </script>
{/literal}

<form {* name="modform" *} id="popup_modform" action="edit.php?method=submitFormData" method="post" style="xdisplay:none">
    <input type="hidden" name="on" id="popup_on" value="{$object_name}" />
    <input type="hidden" name="act" id="popup_act" value="{$act}">
    <input type="hidden" name="id" id="popup_id" value="{$vlu.gpr_id}">
    <input type="hidden" name="gp_id" id="popup_gp_id" value="{$vlu.gp_id}">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="popup_{$key}" value="{$val}" />
    {/foreach}
    <div>
        <input type="hidden" name="gpr_gauge_type" id="popup_gpr_gauge_type" value="{$vlu.gpr_gauge_type}" />
        <table class="form" >
            <tr>
                <th><label class="help" for="popup_gc_name">{t}Macro settore{/t}:</label></th>
                <td colspan="3"><input type="text" name="gc_name" id="popup_gc_name" value="{$vlu.gc_name}" style="width: 500px" class="readonly"></td>
            </tr>
            <tr>
                <th><label class="help required" for="popup_gc_id">{t}Settore{/t}:</label></th>
                <td colspan="3">
                    {if $vlu.gpr_imported_row}
                        <input type="text" name="gc_id" id="popup_gc_id" value="{$lkp.gc_values[$vlu.gc_id].gc_name}" style="width: 500px" class="readonly"></td>
                    {else}
                <select name="gc_id" id="popup_gc_id" style="width:500px">
                    <option value="">{t}-- Selezionare --{/t}</option>
                    {foreach from=$lkp.gc_values key=key item=val}
                        <option label="{$val.gc_name}" {if $key==$vlu.gc_id}selected{/if} value="{$key}" {if $val.gc_has_extradata=='T'}class="has_extradata"{/if} >{$val.gc_name}</option>
                    {/foreach}
                </select>
            {/if}
            </td>
            </tr>   
            <tr id="popup_gc_extradata">
                <th></th>
                <td {if $NUM_LANGUAGES==1}colspan="3"{/if}>
                    <label class="help" for="popup_gc_extradata_1">{t}Altro{/t}{$LANG_NAME_SHORT_FMT_1}:</label><br />
                    <input type="text" id="popup_gc_extradata_1" name="gc_extradata_1" style="width: {if $NUM_LANGUAGES>1}230px{else}500px{/if}" value="{$vlu.gc_extradata_1}">
                </td>
                {if $NUM_LANGUAGES>1}
                    <td colspan="3">
                        <label class="help" for="popup_gc_extradata_2">{t}Altro{/t}{$LANG_NAME_SHORT_FMT_2}:</label><br />
                        <input type="text" id="popup_gc_extradata_2" name="gc_extradata_2" value="{$vlu.gc_extradata_2}" style="width: 230px">
                    </td>
                {/if}
            </tr>
            {if !$vlu.gpr_imported_row || $vlu.gpr_descr_1<>''}
                <tr>
                    <th><label for="popup_gpr_descr_1">{t}Note{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                    <td colspan="3">
                        {if $act!='show'}
                            <textarea name="gpr_descr_1" id="popup_gpr_descr_1" style="width:500px;height:50px;" >{$vlu.gpr_descr_1}</textarea>
                        {else}
                            <div class="textarea_readonly">{$vlu.gpr_descr_1}&nbsp;</div>
                        {/if}
                    </td>
                </tr>
            {/if}
            {if $NUM_LANGUAGES>1}
                {if !$vlu.gpr_imported_row || $vlu.gpr_descr_2<>''}
                    <tr>
                        <th><label for="popup_gpr_descr_2">{t}Note{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                        <td colspan="3">
                            {if $act!='show'}
                                <textarea name="gpr_descr_2" id="popup_gpr_descr_2" style="width:500px;height:50px;" >{$vlu.gpr_descr_2}</textarea>
                            {else}
                                <div class="textarea_readonly">{$vlu.gpr_descr_2}&nbsp;</div>
                            {/if}
                        </td>
                    </tr>
                {/if}
            {/if}
            {if $vlu.gpr_imported_row}
                <tr>
                    <th><label for="popup_gpa_id" class="required help">{t}Azioni principali{/t}:</label></th>
                    <td colspan="3">
                        <input type="text" name="gc_id" id="popup_gc_id" value="{$lkp.gpa_values[$vlu.gpa_id].name}{if $lang==1 && $vlu.gpa_extradata_1<>''} - {$vlu.gpa_extradata_1}{/if}{if $lang==2 && $vlu.gpa_extradata_2<>''} - {$vlu.gpa_extradata_2}{/if}" style="width: 500px" class="readonly"></td>
                    </td>
                </tr>            
            {else}
                <tr>
                    <th><label for="popup_gpa_id" class="required help">{t}Azioni principali{/t}:</label></th>
                    <td colspan="3">
                        <select name="gpa_id" id="popup_gpa_id" style="width:500px;" {if $lkp.gpa_values|@count==0}disabled{/if}>
                            <option value="">{t}-- Selezionare --{/t}</option>
                            {foreach from=$lkp.gpa_values key=key item=val}
                                <option label="{$val.name}" {if $key==$vlu.gpa_id}selected{/if} value="{$key}" {if $val.has_extradata=='T'}class="has_extradata"{/if} >{$val.name}</option>
                            {/foreach}
                        </select>
                    </td>
                </tr>
                <tr id="popup_gpa_extradata">
                    <th></th>
                    <td {if $NUM_LANGUAGES==1}colspan="3"{/if}>
                        <label class="help" for="popup_gpa_extradata_1">{t}Altro{/t}{$LANG_NAME_SHORT_FMT_1}:</label><br />
                        <input type="text" id="popup_gpa_extradata_1" name="gpa_extradata_1" style="width: {if $NUM_LANGUAGES>1}230px{else}500px{/if}" value="{$vlu.gpa_extradata_1}">
                    </td>
                    {if $NUM_LANGUAGES>1}
                        <td colspan="2">
                            <label class="help" for="popup_gpa_extradata_2">{t}Altro{/t}{$LANG_NAME_SHORT_FMT_2}:</label><br />
                            <input type="text" id="popup_gpa_extradata_2" name="gpa_extradata_2" value="{$vlu.gpa_extradata_2}" style="width: 230px">
                        </td>
                    {/if}
                </tr>
            {/if}
            <tr>
                <th><label for="popup_gpr_responsible_department_1" class="help">{t}Responsabile{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                <td colspan="3"><input type="text" id="popup_gpr_responsible_department_1" name="gpr_responsible_department_1" style="width: 500px" value="{$vlu.gpr_responsible_department_1}" {if $vlu.gpr_imported_row}class="readonly"{/if} /></td>
            </tr>
            {if $NUM_LANGUAGES>1}
                <tr>
                    <th><label for="popup_gpr_responsible_department_2" class="help">{t}Responsabile{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                    <td colspan="3"><input type="text" id="popup_gpr_responsible_department_2" name="gpr_responsible_department_2" style="width: 500px" value="{$vlu.gpr_responsible_department_2}" {if $vlu.gpr_imported_row}class="readonly"{/if} /></td>
                </tr>
            {/if}
            <tr>
                <th><label for="popup_gpr_start_date" class="help">{t}Attuazione{/t}:</label></th>
                <td><label for="popup_gpr_start_date">{t}Dal{/t}:</label><input type="text" id="popup_gpr_start_date" name="gpr_start_date" value="{$vlu.gpr_start_date}" {if $vlu.gpr_imported_row}class="readonly" style="width: 80px"{else}class="date"{/if} /></td>
                <td style="text-align:right"><label for="popup_gpr_end_date">{t}al{/t}:</label></td>
                <td><input type="text" id="popup_gpr_end_date" name="gpr_end_date" value="{$vlu.gpr_end_date}" {if $vlu.gpr_imported_row}class="readonly" style="width: 80px"{else}class="date"{/if} /></td>
            </tr>
            <tr>
                <th><label class="help" for="popup_gpr_estimated_cost">{t}Costi stimati{/t}:</label></th>
                <td><input type="text" name="gpr_estimated_cost" id="popup_gpr_estimated_cost" value="{$vlu.gpr_estimated_cost}" maxlength="80" style="width:100px;" class="float {if $vlu.gpr_imported_row}readonly{/if}" data-dec="2"/>[€]</td>
                <th><label class="help" for="popup_gpr_expected_energy_saving">{t}Risparmio energetico previsto{/t}:</label></th>
                <td nowrap><input type="text" name="gpr_expected_energy_saving" id="popup_gpr_expected_energy_saving" value="{$vlu.gpr_expected_energy_saving}" class="float {if $vlu.gpr_imported_row}readonly{/if}" data-dec="2" maxlength="10" style="width:100px;" />[MWh/a]</td>
            </tr>
            <tr>
                <th><label class="help" for="popup_gpr_expected_renewable_energy_production">{t}Produzione di energia rinnovabile prevista{/t}:</label></th>
                <td nowrap><input type="text" name="gpr_expected_renewable_energy_production" id="popup_gpr_expected_renewable_energy_production" value="{$vlu.gpr_expected_renewable_energy_production}" maxlength="80" style="width:100px;" class="float {if $vlu.gpr_imported_row}readonly{/if}" data-dec="2" />[MWh/a]</td>
                <th><label class="help" for="popup_gpr_expected_co2_reduction">{t escape=no}Riduzione di CO<sub>2</sub> prevista{/t}:</label></th>
                <td><input type="text" name="gpr_expected_co2_reduction" id="popup_gpr_expected_co2_reduction" value="{$vlu.gpr_expected_co2_reduction}" maxlength="80" style="width:100px;" class="float {if $vlu.gpr_imported_row}readonly{/if}" data-dec="2" />[t/a]</td>
            </tr>
            <tr>
                <td colspan="4" id="gpr_gauge_type_cel">
                    {* Gauge data moved from hidden_form *}
                </td>
            </tr>
        </table>
    </div>
    <br />
    <br />
    <input type="button" id="popup_btnSave" name="popupBtnSave"  value="{t}Salva{/t}" style="width:120px;height:25px;" />
    <input type="button" id="popup_btnCancel" name="popupBtnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />

</form>
<form id="hidden_form" style="xdisplay: none">
    {foreach from=$vlu.data key=gpg_id item=gauge}
        <table border="0" width="100%" class="gauge_data ui-widget ui-widget-content" style="margin-top: 20px">
            <tr><td colspan="6" class="ui-widget-header ui-corner-all" style="height: 20px">{$gauge.header.title}</td></tr>

            <tr>
                <td colspan="6" style="padding-bottom: 5px">
                    {if $vlu.gpr_gauge_type <> 'G'}
                        {t escape=no}<b>NOTA</b>: Solo <b>l'ultimo valore inserito</b> in orine di data verrà considerato{/t}
                    {/if}
                </td>
            </tr>

            <tr>
                <td>{t}Data audit{/t}</td>
                {if $vlu.gpr_gauge_type == 'G'}
                    <td>{t}Quantità{/t}</td>
                    <td>{t}Param.efficienza{/t}</td>
                    <td>{t}Variazione Energia{/t}</td>
                    <td>{t}Variazione emissioni{/t}</td>
                {else}
                    <td>{t}% completamento{/t}</td>
                {/if}
                <td></td>
            </tr>
            {foreach from=$gauge.data key=gpm_id item=monitor}
                {if $monitor.date<>''}
                    <tr>
                        <td>
                            <input type="hidden" name="value_1[]" value="{$gauge.header.value_1}" />
                            <input type="hidden" name="value_2[]" value="{$gauge.header.value_2}" />
                            <input type="hidden" name="value_3[]" value="{$gauge.header.value_3}" />
                            <input type="hidden" name="gpg_id[]" value="{$monitor.gpg_id}" />
                            <input type="text" name="gpm_date[]" value="{$monitor.date_fmt}" class="readonly" style="width: 75px" />
                        </td>
                        <td>
                            <input type="text" name="gpm_value_1[]" value="{$monitor.value_1_fmt}" class="readonly" style="width: 70px; text-align: right" />{if $gauge.header.unit_1<>''} [{$gauge.header.unit_1}] {/if}
                        </td>
                        <td {if $vlu.gpr_gauge_type <> 'G'}style="display:none"{/if}>
                            <input type="text" name="gpm_value_2[]" value="{$monitor.value_2_fmt}" class="readonly" style="width: 70px; text-align: right" />{if $gauge.header.unit_2<>''}  [{$gauge.header.unit_2}] {/if}
                        </td>
                        <td {if $vlu.gpr_gauge_type <> 'G'}style="display:none"{/if}>
                            <input type="text" name="gpm_energy_value[]" value="{$monitor.energy_variation_fmt}" style="width:70px;" class="float readonly" data-dec="3" /> [MWh/a]
                        </td>
                        <td {if $vlu.gpr_gauge_type <> 'G'}style="display:none"{/if}>
                            <input type="text" name="gpm_co2_value[]" value="{$monitor.emission_variation_fmt}" style="width:70px;" class="float readonly" data-dec="3" /> [tCO2/a]
                        </td>
                        <td>
                            <a href="#" class="mod_meter_row"><img src="../images/ico_mod.gif" /></a>
                            <a href="#" class="del_meter_row"><img src="../images/ico_del.gif" /></a>
                        </td>
                    </tr>
                {/if}
            {/foreach}
            <tr>
                <td>
                    <input type="hidden" name="value_1[]" value="{$gauge.header.value_1}" />
                    <input type="hidden" name="value_2[]" value="{$gauge.header.value_2}" />
                    <input type="hidden" name="value_3[]" value="{$gauge.header.value_3}" />
                    <input type="hidden" name="gpg_id[]" value="{$monitor.gpg_id}" />
                    <input type="text" name="gpm_date[]" value="" class="date" style="width: 75px" />
                </td>
                <td>
                    <input type="text" name="gpm_value_1[]" value="" class="float" data-dec="2" style="width: 70px; text-align: right" />{if $gauge.header.unit_1<>''} [{$gauge.header.unit_1}] {/if}
                </td>
                <td {if $vlu.gpr_gauge_type <> 'G'}style="display:none"{/if}>
                    <input type="text" name="gpm_value_2[]" value="" class="float" data-dec="2" style="width: 70px; text-align: right" />{if $gauge.header.unit_2<>''}  [{$gauge.header.unit_2}] {/if}
                </td>
                <td {if $vlu.gpr_gauge_type <> 'G'}style="display:none"{/if}>
                    <input type="text" name="gpm_energy_value[]" value="" style="width:70px;" class="float readonly" data-dec="3" /> [MWh/a]
                </td>
                <td {if $vlu.gpr_gauge_type <> 'G'}style="display:none"{/if}>
                    <input type="text" name="gpm_co2_value[]" value="" style="width:70px;" class="float readonly" data-dec="3" /> [tCO2/a]
                </td>
                <td>
                    <a href="#" class="add_meter_row"><img src="../images/ico_add.gif" /></a>
                    <img width="16" src="../images/ico_spacer.gif" />
                </td>
            </tr>
        </table>
    {/foreach}
</form>

{include file="footer_ajax.tpl"}