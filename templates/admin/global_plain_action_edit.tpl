{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}
<h3 id="page_title">{$page_title}<span id="page_subtitle" style="display: none"></span></h3>

{literal}
    <style>
        .ui-state-disabled {
            display: none;
        }
    </style>
    <script language="JavaScript" type="text/javascript">

        function tabContentChanged() {
            $.getJSON('edit.php', {on: 'global_plain_action',
                'gpr_id': $('#id').val(),
                'method': 'countGaugeAndMonitor'}, function (response) {
                if (response.status == 'OK') {
                    $('#gpr_gauge_type').prop('disabled', response.data.tot > 0);
                }
            });
        }

        function submitFormDataDoneGlobalPlainRow(id) {
            if ($('#act').val() == 'add') {
                ajaxWait(true);
                modObject(id);
            } else {
                listObject($('#on').val());
            }
        }

        function moveGaugeType() {
            $("#gpr_gauge_type_cel").html('');
            $("#gpr_gauge_type").appendTo("#gpr_gauge_type_cel");
            $("#hidden_form").remove();
        }

        $(document).ready(function () {
            $('#btnCancel,#btnBack').bind('click', function () {
                listObject()
            });
            $('#btnEdit').bind('click', function () {
                modObject()
            });
            $('#modform .help').bind('click', function () {
                showR3Help('global_plain', this)
            });

            $('#gc_id_parent').bind('change', function () {
                $('#gc_extradata').hide();
                $('#gpa_extradata').hide();
                updateMainGlobalCategoryFromGlobalPlainAction();
            });

            $('#gc_id').bind('change', function () {
                $('#gpa_extradata').hide();
                updateGlobalAction('#gpa_id', '#gc_id');
                updateForExtraData('#gc_id', '#gc_extradata');
            });
            $('#gpa_id').bind('change', function () {
                updateForExtraData('#gpa_id', '#gpa_extradata');
            });

            $('#btnSave').bind('click', function () {
                submitFormDataGlobalPlainRow('#modform');
            });
            $('#btnCancel').bind('click', function () {
                listObject()
            });

            // Move block   gpr_gauge_type
            if ($('#act').val() == 'show') {
                moveGaugeType();
                setupShowMode();  // Setup the show mode
                setupInputFormat('#modform', false);
            } else {
                if ($('#gpr_imported_row').val() == '1') {
                    setupShowMode();  // Setup the show mode
                    setupInputFormat('#modform', false);
                } else {
                    setupInputFormat('#modform');
                    setupRequired('#modform');
                }
                moveGaugeType();
            }
            setupReadOnly('#modform');
            updateForExtraData('#gc_id', '#gc_extradata', true);
            updateForExtraData('#gpa_id', '#gpa_extradata', true);

            $('#modform').toggle(true);  // Show the form
            $('#gc_id_main').focus();

            if ($("#tabs").length > 0) {
                // Tabs not always enabled
                $("#tabs").tabs({cache: true, ajaxOptions: {cache: true}});
                $("#tabs ul").css('padding-left', '35px').parent().prepend('<img id="btnTabsResize" src="../images/tabresize.png">');
                $('#btnTabsResize')
                        .bind('mouseenter', function () {
                            $(this).addClass('tr_hover')
                        })
                        .bind('mouseleave', function () {
                            $(this).removeClass('tr_hover')
                        })
                        .bind('click', function () {
                            $('#form_controls_container').toggle();
                            resizeTabHeight();
                            $('#page_subtitle').html(' - ' + $('#gc_id_parent option:selected').text() + ' \\ ' + $('#gc_id option:selected').text() + ' - ' + $('#gpa_id option:selected').text()).toggle();
                        });
            }
            $('#gpr_gauge_type').change(function () {
                if ($(this).val() == 'P') {
                    $('#tabs').tabs('select', 1);
                    $('#tabs').tabs('disable', 0);
                    $("#btnAssignAction").hide();
                } else {
                    $('#tabs').tabs("enable", 0);
                    $('#tabs').tabs("select", 0);
                    $("#btnAssignAction").show();
                }
            }).change();

            $("#btnAssignAction").click(function () {
                openR3Dialog('edit.php?on=global_plain_action_predefined_actions&act=select&mode=dialog&gc_id=' + $('#gc_id').val(), txtPredefinedActionsDialogTitle, 500, 300);
            });

            $('#modform').toggle(true);
            $('#tabs').toggle(true);

            tabContentChanged();
            initChangeRecord();

        });



    </script>
{/literal}
{if $vlu.gpr_imported_row}
    <div id="info_container" class="info_container">{t}Attenzione! Per le azioni importate è possibile modificare solo gli indicatori{/t}</div>
{/if}
<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" >
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="id" value="{$vlu.gpr_id}">
    <input type="hidden" name="gp_id" id="gp_id" value="{$vlu.gp_id}">
    <input type="hidden" name="is_paes_action" value="T">
    <input type="hidden" name="gpr_imported_row" id="gpr_imported_row" value="{$vlu.gpr_imported_row}">
    <input type="hidden" name="gpr_gauge_type" id="gpr_gauge_type_dummy" value="{$vlu.gpr_gauge_type}" />
    {foreach from=$vars key=key item=val}
        {if $key <> 'tabs'}<input type="hidden" name="{$key}" id="{$key}" value="{$val}" />{/if}
    {/foreach}
    <div id="form_controls_container">
        <table class="form">
            {if $lkp.mu_values|@count > 1}
                <tr>
                    <th><label class="help required" for="mu_id">{if $lkp.mu_values.tot.collection > 0}{t}Comune/raggruppamento{/t}{else}{t}Comune{/t}{/if}:</label></th>
                    <td colspan="5">
                        {if $USER_CONFIG_APPLICATION_BUILDING_MUNICIPALITY_MODE <> 'COMBO'}
                            <input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}">
                            <input type="text" name="mu_name" id="mu_name" value="{$vlu.mu_name}" style="width:500px;" class="{if $act == 'mod'}readonly{/if}">
                        {else}
                            <input type="hidden" name="mu_id" id="mu_id_dummy" value="{$vlu.mu_id}" />
                            <select name="mu_id" id="mu_id" class="{if $act == 'mod'}readonly{/if}" style="width:500px" {if $act<>'add'}disabled{/if}>
                                {if $lkp.mu_values.tot.municipality > 1}<option value="">{t}-- Selezionare --{/t}</option>{/if}
                                {html_options options=$lkp.mu_values.data selected=$vlu.mu_id}
                            </select>
                        {/if}
                    </td>
                </tr>
            {/if}
            <tr>
                <th><label class="help required" for="gc_name">{t}Macro settore{/t}:</label></th>
                <td colspan="3">
                    <select name="gc_id_parent" id="gc_id_parent" style="width:500px">
                        <option value="">{t}-- Selezionare --{/t}</option>
                        {html_options options=$lkp.gc_parent_values selected=$vlu.gc_id_parent}
                    </select>
                </td>
            </tr>
            <tr>
                <th><label class="help required" for="gc_id">{t}Settore{/t}:</label></th>
                <td colspan="3">
                    <select name="gc_id" id="gc_id" style="width:500px" {if $lkp.gc_values|@count<=1}disabled{/if}>
                        <option value="">{t}-- Selezionare --{/t}</option>
                        {foreach from=$lkp.gc_values key=key item=val}
                            <option label="{$val.gc_name}" {if $key==$vlu.gc_id}selected{/if} value="{$key}" {if $val.gc_has_extradata=='T'}class="has_extradata"{/if} >{$val.gc_name}</option>
                        {/foreach}
                    </select>
                </td>
            </tr>
            <tr id="gc_extradata">
                <th></th>
                <td {if $NUM_LANGUAGES==1}colspan="3"{/if}>
                    <label class="help" for="gc_extradata_1">{t}Altro{/t}{$LANG_NAME_SHORT_FMT_1}:</label><br />
                    <input type="text" id="gc_extradata_1" name="gc_extradata_1" style="width: {if $NUM_LANGUAGES>1}230px{else}500px{/if}" value="{$vlu.gc_extradata_1}">
                </td>
                {if $NUM_LANGUAGES>1}
                    <td colspan="3">
                        <label class="help" for="gc_extradata_2">{t}Altro{/t}{$LANG_NAME_SHORT_FMT_2}:</label><br />
                        <input type="text" id="gc_extradata_2" name="gc_extradata_2" value="{$vlu.gc_extradata_2}" style="width: 230px">
                    </td>
                {/if}
            </tr>
            <tr {if $vlu.gpr_imported_row && $vlu.gpr_descr_1==''}style="display: none"{/if}>
                <th><label for="gpr_descr_1">{t}Note{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                <td colspan="3">
                    {if $act!='show'}
                        <textarea name="gpr_descr_1" id="gpr_descr_1" style="width:500px;height:50px;" >{$vlu.gpr_descr_1}</textarea>
                    {else}
                        <div class="textarea_readonly">{$vlu.gpr_descr_1}&nbsp;</div>
                    {/if}
                </td>
            </tr>
            {if $NUM_LANGUAGES>1}
                <tr {if $vlu.gpr_imported_row && $vlu.gpr_descr_2==''}style="display: none"{/if}>
                    <th><label for="gpr_descr_2">{t}Note{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                    <td colspan="3">
                        {if $act!='show'}
                            <textarea name="gpr_descr_2" id="gpr_descr_2" style="width:500px;height:50px;" >{$vlu.gpr_descr_2}</textarea>
                        {else}
                            <div class="textarea_readonly">{$vlu.gpr_descr_2}&nbsp;</div>
                        {/if}
                    </td>
                </tr>
            {/if}
            <tr>
                <th><label for="gpa_id" class="required help">{t}Azioni principali{/t}:</label></th>
                <td colspan="3">
                    <select name="gpa_id" id="gpa_id" style="width:500px;" {if $lkp.gpa_values|@count==0}disabled{/if}>
                        <option value="">{t}-- Selezionare --{/t}</option>
                        {foreach from=$lkp.gpa_values key=key item=val}
                            <option label="{$val.name}" {if $key==$vlu.gpa_id}selected{/if} value="{$key}" {if $val.has_extradata=='T'}class="has_extradata"{/if} >{$val.name}</option>
                        {/foreach}
                    </select>
                </td>
            </tr>
            <tr id="gpa_extradata">
                <th></th>
                <td {if $NUM_LANGUAGES==1}colspan="3"{/if}>
                    <label class="help" for="gpa_extradata_1">{t}Altro{/t}{$LANG_NAME_SHORT_FMT_1}:</label><br />
                    <input type="text" id="gpa_extradata_1" name="gpa_extradata_1" style="width: {if $NUM_LANGUAGES>1}230px{else}500px{/if}" value="{$vlu.gpa_extradata_1}">
                </td>
                {if $NUM_LANGUAGES>1}
                    <td colspan="2">
                        <label class="help" for="gpa_extradata_2">{t}Altro{/t}{$LANG_NAME_SHORT_FMT_2}:</label><br />
                        <input type="text" id="gpa_extradata_2" name="gpa_extradata_2" value="{$vlu.gpa_extradata_2}" style="width: 230px">
                    </td>
                {/if}
            </tr>
            <tr>
                <th><label for="gpr_responsible_department_1" class="help">{t}Responsabile{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                <td colspan="3"><input type="text" id="gpr_responsible_department_1" name="gpr_responsible_department_1" style="width: 500px" value="{$vlu.gpr_responsible_department_1}">
            </tr>
            {if $NUM_LANGUAGES>1}
                <tr>
                    <th><label for="gpr_responsible_department_2" class="help">{t}Responsabile{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                    <td colspan="3"><input type="text" id="gpr_responsible_department_2" name="gpr_responsible_department_2" style="width: 500px" value="{$vlu.gpr_responsible_department_2}">
                </tr>
            {/if}
            <tr>
                <th><label for="gpr_start_date" class="help">{t}Attuazione{/t}:</label></th>
                <td><label for="gpr_start_date">{t}Dal{/t}:</label><input type="text" id="gpr_start_date" name="gpr_start_date" value="{$vlu.gpr_start_date}" class="date"></td>
                <td style="text-align:right"><label for="gpr_end_date">{t}al{/t}:</label></td>
                <td><input type="text" id="gpr_end_date" name="gpr_end_date" value="{$vlu.gpr_end_date}" class="date"></td>
            </tr>
            <tr>
                <th><label class="help" for="gpr_estimated_cost">{t}Costi stimati{/t}:</label></th>
                <td><input type="text" name="gpr_estimated_cost" id="gpr_estimated_cost" value="{$vlu.gpr_estimated_cost}" maxlength="80" style="width:100px;" class="float" data-dec="2"/>[€]</td>
                <th><label class="help" for="gpr_expected_energy_saving">{t}Risparmio energetico previsto{/t}:</label></th>
                <td nowrap><input type="text" name="gpr_expected_energy_saving" id="gpr_expected_energy_saving" value="{$vlu.gpr_expected_energy_saving}" class="float" data-dec="2" maxlength="10" style="width:100px;" />[MWh/a]</td>
            </tr>
            <tr>
                <th><label class="help" for="gpr_expected_renewable_energy_production">{t}Produzione di energia rinnovabile prevista{/t}:</label></th>
                <td nowrap><input type="text" name="gpr_expected_renewable_energy_production" id="gpr_expected_renewable_energy_production" value="{$vlu.gpr_expected_renewable_energy_production}" maxlength="80" style="width:100px;" class="float" data-dec="2" />[MWh/a]</td>
                <th><label class="help" for="gpr_expected_co2_reduction">{t escape=no}Riduzione di CO<sub>2</sub> prevista{/t}:</label></th>
                <td><input type="text" name="gpr_expected_co2_reduction" id="gpr_expected_co2_reduction" value="{$vlu.gpr_expected_co2_reduction}" maxlength="80" style="width:100px;" class="float" data-dec="2" />[t/a]</td>
            </tr>
            <tr>
                <th><label class="help required" for="gpr_gauge_type">{t}Tipo monitoraggio{/t}:</label></th>
                <td colspan="3" id="gpr_gauge_type_cel">

                    {* [select -> See hiddenform] *}
                </td>
            </tr>
            <tr><td colspan="4">{include file="record_change.tpl"}</td></tr>
        </table>
        <br />
        {if $act != 'show'}
            <input type="button" id="btnSave" name="btnSave"  value="{t}Salva{/t}" style="width:120px;height:25px;" />
            <input type="button" id="btnCancel" name="btnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />
        {else}
            {if $USER_CAN_MOD_GLOBAL_PLAIN}
                <input type="button" name="btnEdit" id="btnEdit"  value="{t}Modifica{/t}" style="width:75px;height:25px;">&nbsp;&nbsp;&nbsp;&nbsp;
            {/if}
            <input type="button" name="btnBack" id="btnBack"  value="{t}Indietro{/t}" style="width:75px;height:25px;">
        {/if}
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        {* <input type="button" id="btnAssignAction" name="btnAssignAction"  value="{t}Azioni predefinite{/t}" style="width:120px;height:25px;" /> *}
    </div>
</form>
<form id="hidden_form" style="display: none">
    <select name="gpr_gauge_type" id="gpr_gauge_type" style="width:500px">
        {html_options options=$lkp.gpa_gauge_values selected=$vlu.gpr_gauge_type}
    </select>
</form>



{if $act != 'add'}
    <br />
    {r3tab id='tabs' items=$vars.tabs style="display: none; height: 300px" istyle="height: 250px; width: 100%" autoInit=false onLoad="resizeTabHeight()" mode=$vars.tab_mode}
{/if}

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}