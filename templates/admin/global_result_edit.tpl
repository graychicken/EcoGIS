{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

<h3 id="page_title">{$page_title}<span id="page_subtitle" style="display: none"></span></h3>

{literal}
    <script language="JavaScript" type="text/javascript">

        $(document).ready(function () {
            $('#btnSave').bind('click', function () {
                submitFormDataGlobalResult()
            });
            $('#btnCancel,#btnBack').bind('click', function () {
                listObject()
            });
            $('#btnClose').bind('click', function () {
                window.close()
            });
            $('#btnEdit').bind('click', function () {
                modObject()
            });
            if ($('#gisclient').val() == 1) {
                $('#btnMap').bind('click', function () {
                    var ge_id = $('#ge_id').val();
                    var mu_id = $('#mu_id').val();
                    openGisClient('gisclient.php?layer=global_entry&zoom_type=zoomextent&mapoper_zoom=global_entry&mu_id=' + mu_id + '&mapoper_id=' + ge_id + '&');
                });
            } else {
                $('#btnMap').bind('click', function () {
                    GenericOpenMap('generic&zoom_type=zoomextent&mapoper_zoom=global_result&mapoper_id=' + $('#id').val())
                });
            }
            $('#mu_id').change(function () {
                $('#mu_id_popup').val($(this).val());
            });

            $('#ge_national_efe,#ge_local_efe').bind('change', function () {
                if ($('#act').val() == 'mod') {
                    alert(txtSaveToCalculate);
                    $('#ge_national_efe,#ge_local_efe').unbind('change');
                }
            });

            if ($('#act').val() == 'show') {
                setupShowMode();  // Setup the show mode
                setupInputFormat('#modform', false);
            } else {
                setupInputFormat('#modform');
                setupRequired('#modform');
            }

            setupReadOnly('#modform');
            initChangeRecord();

            autocomplete("#mu_name", {url: 'edit.php',
                on: 'building',
                method: 'fetch_municipality',
                do_id: $('#do_id').val(),
                pr_id: $('#pr_id').val(),
                limit: 20,
                minLength: 2
            });

            if ($("#tabs").length > 0) {
                // Tabs not always enabled
                $("#tabs").tabs({cache: false, ajaxOptions: {cache: false}});
                resizeTabHeight();
                var activeTab = $('#active_tab').val();
                if (activeTab != '') {
                    $("#tabs").tabs("select", "#" + activeTab);
                }
                $("#tabs ul").css('padding-left', '35px');
                $("#tabs ul").parent().prepend('<img id="btnTabsResize" src="../images/tabresize.png">');
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
                            $('#page_subtitle').html(' - ' + $('#ge_name_1').val()).toggle();
                        });
            }

            $('#modform').toggle(true);  // Show the form
            $('#ge_name_1').focus();
        });

        $(window).resize(function () {
            resizeTabHeight();
        });

    </script>
{/literal}

{include file=inline_help.tpl}

<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" >
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="id" value="{$vlu.ge_id}">
    <input type="hidden" name="ge_id" id="ge_id" value="{$vlu.ge_id}">
    <input type="hidden" name="gisclient" id="gisclient" value="{$smarty.const.GISCLIENT}">
    {foreach from=$vars key=key item=val}
        {if $key <> 'tabs'}<input type="hidden" name="{$key}" id="{$key}" value="{$val}" />{/if}
    {/foreach}

    {if $lkp.mu_values|@count <= 1}<input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}" />{/if}
    <div id="form_controls_container">
        <table class="table_form">
            {if $lkp.mu_values|@count > 1}
                <tr>
                    <th><label class="help required" for="mu_id">{if $lkp.mu_values.tot.collection > 0}{t}Comune/raggruppamento{/t}{else}{t}Comune{/t}{/if}:</label></th>
                    <td colspan="5">
                        {if $USER_CONFIG_APPLICATION_BUILDING_MUNICIPALITY_MODE <> 'COMBO'}
                            <input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}">
                            <input type="text" name="mu_name" id="mu_name" value="{$vlu.mu_name}" style="width:600px;" class="{if $act == 'mod'}readonly{/if}">
                        {else}
                            <input type="hidden" name="mu_id" id="mu_id_dummy" value="{$vlu.mu_id}" />
                            <select name="mu_id" id="mu_id" class="{if $act == 'mod'}readonly{/if}" style="width:600px" {if $act<>'add'}disabled{/if}>
                                {if $lkp.mu_values.tot.municipality > 1}<option value="">{t}-- Selezionare --{/t}</option>{/if}
                                {html_options options=$lkp.mu_values.data selected=$vlu.mu_id}
                            </select>
                        {/if}
                    </td>
                </tr>
            {/if}

            <tr>
                <th><label class="required help" for="ge_name_1">{t}Titolo{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                <td colspan="5"><input type="text" name="ge_name_1" id="ge_name_1" value="{$vlu.ge_name_1}" maxlength="80" style="width:600px;" /></td>
            </tr>
            {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
                <tr>
                    <th><label class="required help" for="ge_name_2">{t}Titolo{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                    <td colspan="5"><input type="text" name="ge_name_2" id="ge_name_2" value="{$vlu.ge_name_2}" maxlength="80" style="width:600px;" /></td>
                </tr>
            {/if}
            <tr>
                <th><label class="required help" for="ge_year">{t}Anno di riferimento{/t}:</label></th>
                <td><input type="text" name="ge_year" id="ge_year" value="{$vlu.ge_year_as_string}" class="year {if $act == 'mod'}readonly{/if}" style="width:100px;" /></td>
                <th><label class="required help" for="ge_reference_citizen">{t}Abitanti{/t}</label> <sub>({if $vlu.ge_year_as_string<>''}{$vlu.ge_year_as_string}{else}{t}anno di riferimento{/t}{/if})</sub></th>
                <td><input type="text" name="ge_citizen" id="ge_citizen" value="{$vlu.ge_citizen}" class="integer" style="width:100px;" /></td>
            </tr>

            <tr>
                <th><label class="help" for="ge_national_efe">{t}EFE nazionale{/t}</label> <sub>({if $vlu.ge_year_as_string<>''}{$vlu.ge_year_as_string}{else}{t}anno di riferimento{/t}{/if})</sub></th>
                <td><input type="text" name="ge_national_efe" id="ge_national_efe" value="{$vlu.ge_national_efe}" maxlength="10" class="float" style="width:100px;" /></td>
                <th><label class="help" for="ge_local_efe">{t}EFE locale{/t}</label> <sub>({if $vlu.ge_year_as_string<>''}{$vlu.ge_year_as_string}{else}{t}anno di riferimento{/t}{/if})</sub></th>
                <td colspan="3"><input type="text" name="ge_local_efe" id="ge_local_efe" value="{$vlu.ge_local_efe}" class="float" maxlength="10" style="width:100px;" /></td>
            </tr>


            <tr>
                <th><label class="help" for="ge_green_electricity_purchase">{t}Acquisto di elettricità verde certificata{/t}:</label></th>
                <td><input type="text" name="ge_green_electricity_purchase" id="ge_green_electricity_purchase" value="{$vlu.ge_green_electricity_purchase}" maxlength="10" class="float" style="width:100px;" />[MWh]</td>
                <th><label class="help" for="ge_green_electricity_co2_factor">{t}Fattore di emissione di CO2 elettricità verde certificata{/t}:</label></th>
                <td colspan="3"><input type="text" name="ge_green_electricity_co2_factor" id="ge_green_electricity_co2_factor" value="{$vlu.ge_green_electricity_co2_factor}" class="float" maxlength="10" style="width:100px;" /></td>
            </tr>
            <tr>
                <th colspan="2"></th>
                <th><label class="" for="ge_non_produced_co2_factor">{t}Fattore di emissione di CO2 elettricità non prodotta localmente{/t}:</label></th>
                <td colspan="3"><input type="text" name="ge_non_produced_co2_factor" id="ge_non_produced_co2_factor" value="{$vlu.ge_non_produced_co2_factor}" maxlength="10" class="float" style="width:100px;" />[t/MWh]</td>
            </tr>

            <tr><td colspan="6">{include file="record_change.tpl"}</td></tr>

        </table>

        <br />

        {if $vars.parent_act == 'show'}
            <input type="button" id="btnClose" name="btnClose"  value="{t}Chiudi{/t}" style="width:120px;height:25px;" />
        {else}
            {if $act != 'show'}
                {if $act == 'add'}
                    <input type="button" id="btnSave" name="btnSave"  value="{t}Salva e continua{/t}" style="width:160px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
                {else}
                    <input type="button" id="btnSave" name="btnSave"  value="{t}Salva{/t}" style="width:75px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
                {/if}
                <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" style="width:75px;height:25px;">
            {else}
                {if $USER_CAN_MOD_BUILDING}
                    <input type="button" name="btnEdit" id="btnEdit"  value="{t}Modifica{/t}" style="width:75px;height:25px;">&nbsp;&nbsp;&nbsp;&nbsp;
                {/if}
                <input type="button" name="btnBack" id="btnBack"  value="{t}Indietro{/t}" style="width:75px;height:25px;">
            {/if}
        {/if}
        <br /><br />
    </div>
    {if $act != 'add'}
        {r3tab id='tabs' items=$vars.tabs style="height: 400px;" istyle="height: 350px; width: 100%" autoInit=false mode=$vars.tab_mode}
    {/if}

</form>


{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}