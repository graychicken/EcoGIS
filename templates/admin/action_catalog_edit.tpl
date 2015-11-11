{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}
{if $vlu.bu_id == ''}<h3 id="page_title">{$page_title}</h3>{/if}
{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#btnSave').bind('click', function () {
                submitFormDataActionCatalog()
            });
            $('#btnCancel,#btnBack').bind('click', function () {
                listObject()
            });
            $('#btnEdit').bind('click', function () {
                modObject()
            });
            $('#btnClose').bind('click', function () {
                window.close()
            });

            $('#btnSaveDialog').bind('click', function () {
                submitFormDataActionCatalogFromBuilding()
            });
            $('#btnCancelDialog,#btnCloseDialog').bind('click', function () {
                parent.closeR3Dialog()
            });
            $('#btnMap').bind('click', function () {
                openActionCatalogMap();
            });
            $('#enable_benefit_year').bind('click', function () {
                toggleBenefitYear();
            });
            $('#gc_id_parent').bind('change', function () {
                updateMainGlobalCategory();
            });
            $('#ac_object_id').bind('change', function () {
                checkSubActionMapLink();
            });

            $('#ft_id').bind('change', function () {
                updateForExtraData('#ft_id', '#ft_extradata');
            });

            $('#mu_id').bind('change', function () {
                updateSubCategory();
                updateRelatedActionsList();
            });
            $('#gc_id').bind('change', function () {
                updateForExtraData('#gc_id', '#gc_extradata');
                updateSubCategory();
                updateGlobalAction('#gpa_id', '#gc_id');
            });
            $('#gpa_id').bind('change', function () {
                updateForExtraData('#gpa_id', '#gpa_extradata');
                updateActionName();
                $('#gpa_id_dummy').val($('#gpa_id').val())
            });
            $('#gpa_extradata_1,#gpa_extradata_2').bind('change', function () {
                updateActionName();
            });
            $('#ges_id_production').bind('change', function () {
                updateEnergySourceForActionCatalog('#modform', this, 'ENERGY_PRODUCTION');
            });
            $('#es_id_production').bind('change', function () {
                updateEnergyUDMForPAES('#modform', this, 'ENERGY_PRODUCTION');
            });
            $('#ac_end_date').bind('change', function () {
                setValueForBenefitStartDate()
            });

            $('#ac_estimated_cost,#ac_estimated_public_financing,#ac_estimated_other_financing,#ac_effective_cost,#ac_effective_public_financing,#ac_effective_other_financing').bind('change', function () {
                setTimeout('calculateAutoFinancing()', 10)
            });

            $('#mu_id,#udm_id_production,#ac_expected_renewable_energy_production').bind('change', function () {
                setTimeout("performPAESEnergySourceCalc('#modform')", 10)
            });  // fast-timer needed

            if ($('#act').val() == 'show') {
                setupShowMode();  // Setup the show mode
                setupInputFormat('#modform', false);
            } else {
                setupInputFormat('#modform');
                setupRequired('#modform');
            }
            setupReadOnly('#modform');
            autocomplete("#mu_name", {url: 'edit.php',
                on: 'building',
                method: 'fetch_municipality',
                pr_id: $('#pr_id').val(),
                limit: 20,
                minLength: 1});


            updateForExtraData('#gc_id', '#gc_extradata');
            updateForExtraData('#gpa_id', '#gpa_extradata');

            var hasGeometry = $("#has_geometry").val() == '1';
            $("#map_container").show(hasGeometry);
            if (hasGeometry) {
                $('#map_preview').bind('click', function () {
                    ZoomToMap('generic', 'action_catalog', $('#id').val());
                });
            }

            initChangeRecord();
            updateForExtraData('#ft_id', '#ft_extradata');
            setRelatedSelectStatus();
            initExpectedEnergySavings();
            initRelatedActions();
            initRelatedRequiredActions();
            initRelatedExcludedActions();
            initBenefitYear();

            calculateAutoFinancing();
            updateMenu();
            checkSubActionMapLink();
            toggleBenefitYear();

            // Show element
            $('#action_on_map_link').hide();
            $('#modform').toggle(true);
            updateMapButtonStatus();
            focusTo('#mu_id,#mu_name,#ac_code');
        });

    </script>
{/literal}
{* Map settings *}
{assign var=preview_size value='x'|explode:$USER_CONFIG_APPLICATION_PHOTO_PREVIEW_SIZE}

{* Tamplates form *}
<form action="" id="action_catalog_template_form" style="display: none">
    <table>
        {include file="action_catalog_consumption_row.tpl"}
    </table>
</form>
<form action="" id="related_action_template_form" style="display: none">
    <table>
        {include file="action_catalog_related_actions.tpl"}
    </table>
</form>
<form action="" id="related_required_action_template_form" style="display: none">
    <table>
        {include file="action_catalog_related_required_actions.tpl"}
    </table>
</form>
<form action="" id="related_excluded_action_template_form" style="display: none">
    <table>
        {include file="action_catalog_related_excluded_actions.tpl"}
    </table>
</form>
<form action="" id="benefit_year_template_form" style="display: none">
    <table>
        {include file="action_catalog_benefit_year.tpl"}
    </table>
</form>

{include file=inline_help.tpl}
<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" style="display: none">
    {* <input type="button" name="aaa" value="test" onclick="__updateSubCategoryTESTONLY()"> *}
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="id" value="{$vlu.ac_id}">
    <input type="hidden" name="has_geometry" id="has_geometry" value="{$vlu.has_geometry}">
    <input type="hidden" name="map_on" id="map_on" value="" />
    <input type="hidden" name="lang" id="lang" value="{$lang}">
    <input type="hidden" name="bu_id" id="bu_id" value="{$vlu.bu_id}">
    {* Already defined <input type="hidden" name="session_id" id="session_id" value="{$vars.session_id}"> *}
    <input type="hidden" name="geometryStatus" id="geometryStatus" value="">
    {foreach from=$vars key=key item=val}
        {if $key <> 'tabs'}<input type="hidden" name="{$key}" id="{$key}" value="{$val}" />{/if}
    {/foreach}

    {if $vlu.wo_id<>''}
        <div class="form_msg">{t}Attenzione! Salvando questa azione verrà perso il legame con il relativo intervento sull'edificio.{/t}</div>
    {/if}

    {if $lkp.mu_values|@count <= 1 || $vlu.bu_id<>''}<input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}" />{/if}
    {if $vlu.bu_id<>''}<input type="hidden" name="gc_id" id="gc_id" value="{$vlu.gc_id}" />{/if}
    {if $vlu.bu_id<>''}<input type="hidden" name="gc_id_parent" id="gc_id_parent" value="{$vlu.gc_parent_id}" />{/if}
    {if $vlu.bu_id<>''}<input type="hidden" name="ac_object_id" id="ac_object_id" value="{$vlu.bu_id}" />{/if}
    <table class="table_form">
        {if $vlu.bu_id <> ''}
            <tr>
                <th><label>{t}Settore{/t}:</label></th>
                <td colspan="3">
                    <input type="text" name="sector" id="sector" value="{$vars.sector}" style="width:600px;" class="readonly" disabled>
                </td>
            </tr>
        {/if}

        {if $vlu.bu_id == ''}
            {if $lkp.mu_values|@count > 1}
                <tr>
                    <th><label class="help required" for="mu_id">{if $lkp.mu_values.tot.collection > 0}{t}Comune/raggruppamento{/t}{else}{t}Comune{/t}{/if}:</label></th>
                    <td colspan="3">
                        {if $USER_CONFIG_APPLICATION_BUILDING_MUNICIPALITY_MODE <> 'COMBO'}
                            <input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}">
                            <input type="text" name="mu_name" id="mu_name" value="{$vlu.mu_name}" style="width:600px;">
                        {else}
                            <input type="hidden" name="mu_id" id="mu_id_dummy" value="{$vlu.mu_id}" />
                            <select name="mu_id" id="mu_id" style="width:600px" {if $act <> 'add'}class="readonly" disabled{/if}>
                                {if $lkp.mu_values.tot.municipality > 1}<option value="">{t}-- Selezionare --{/t}</option>{/if}
                                {html_options options=$lkp.mu_values.data selected=$vlu.mu_id}
                            </select>
                        {/if}
                    </td>
                </tr>
            {/if}
        {/if}
        <tr>
            <th><label class="help" for="ac_code">{t}Codice azione{/t}:</label></th>
            <td colspan="3">
                <input type="text" name="ac_code" id="ac_code" value="{$vlu.ac_code}" maxlength="10" style="width: 80px" />
            </td>
        </tr>
        {if $vlu.bu_id == ''}
            <tr>
                <th><label class="help required" for="gc_id_parent">{t}Settore{/t}:</label></th>
                <td colspan="3">
                    <select name="gc_id_parent" id="gc_id_parent" style="width:600px">
                        <option value="">{t}-- Selezionare --{/t}</option>
                        {foreach from=$lkp.gc_parent_values key=key item=val}
                            <option label="{$val.name}" {if $key==$vlu.gc_parent_id}selected{/if} value="{$key}" {if $val.has_extradata=='T'}class="has_extradata"{/if} >{$val.name}</option>
                        {/foreach}
                    </select>
                </td>
            </tr>
            <tr>
                <th><label class="help required" for="gc_id">{t}Campo d'azione{/t}:</label></th>
                <td colspan="3">
                    <select name="gc_id" id="gc_id" style="width:600px" {if $lkp.gc_values|@count<=1}disabled{/if}>
                        <option value="">{t}-- Selezionare --{/t}</option>
                        {foreach from=$lkp.gc_values key=key item=val}
                            <option label="{$val.name}" {if $key==$vlu.gc_id}selected{/if} value="{$key}" {if $val.has_extradata=='T'}class="has_extradata"{/if} >{$val.name}</option>
                        {/foreach}
                    </select>
                </td>
            </tr>

            <tr id="gc_extradata">
                <th></th>
                <td {if $NUM_LANGUAGES==1}colspan="3"{/if}>
                    <label>{t}Altro{/t}{$LANG_NAME_SHORT_FMT_1}:</label>
                    <input type="text" id="gc_extradata_1" name="gc_extradata_1" style="width: {if $NUM_LANGUAGES>1}230px{else}540px{/if}" value="{$vlu.gc_extradata_1}">
                </td>
                {if $NUM_LANGUAGES>1}
                    <td colspan="3">
                        <label>{t}Altro{/t}{$LANG_NAME_SHORT_FMT_2}:</label>
                        <input type="text" id="gc_extradata_2" name="gc_extradata_2" value="{$vlu.gc_extradata_2}" style="width: 200px">
                    </td>
                {/if}
            </tr>

            <tr>
                <th><label class="help" for="ac_object_id">{t}Entità geometrica{/t}:</label></th>
                <td colspan="3">
                    <select name="ac_object_id" id="ac_object_id" style="width:600px" {if $lkp.ac_object_values|@count==0}disabled{/if}>
                        <option value="">{t}-- Selezionare --{/t}</option>
                        {html_options options=$lkp.ac_object_values selected=$vlu.ac_object_id}
                    </select>

                    {* <a id="action_on_map_link" href="JavaScript:showActionOnMap();" type="display: none"><img src="../images/ico_map.gif" title="{t}Mostra su mappa{/t}" border="0"></a> *}

                </td>
            </tr>
            <tr class="separator"><td colspan="4"></td></tr>
            {/if}
        <tr>
            <th><label for="gpa_id" class="required help">{t}Azione principali{/t}:</label></th>
            <td colspan="3">
                <input type="hidden" name="gpa_id" id="gpa_id_dummy" value="{$vlu.gpa_id}" />
                <select name="gpa_id" id="gpa_id" style="width:600px;" {if $lkp.gpa_values|@count<=1}disabled{/if}>
                    <option value="">{t}-- Selezionare --{/t}</option>
                    {foreach from=$lkp.gpa_values key=key item=val}
                        <option label="{$val.name}" {if $key==$vlu.gpa_id}selected{/if} value="{$key}" {if $val.has_extradata=='T'}class="has_extradata"{/if} >{$val.name}</option>
                    {/foreach}
                </select>
                {if $act<>'show'}
                    <a href="JavaScript:updateActionName(true);"><img src="../images/ico_copy_text.gif" title="{t}Copia in nome azione{/t}" border="0"></a>
                    {/if}
            </td>
        </tr>
        <tr id="gpa_extradata">
            <th></th>
            <td {if $NUM_LANGUAGES==1}colspan="3"{/if}>
                <label>{t}Altro{/t}{$LANG_NAME_SHORT_FMT_1}:</label>
                <input type="text" id="gpa_extradata_1" name="gpa_extradata_1" style="width: {if $NUM_LANGUAGES>1}230px{else}540px{/if}" value="{$vlu.gpa_extradata_1}">
            </td>
            {if $NUM_LANGUAGES>1}
                <td colspan="3">
                    <label>{t}Altro{/t}{$LANG_NAME_SHORT_FMT_2}:</label>
                    <input type="text" id="gpa_extradata_2" name="gpa_extradata_2" value="{$vlu.gpa_extradata_2}" style="width: 200px">
                </td>
            {/if}
        </tr>
        <tr>
            <th><label for="ac_name_1" class="required help">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="3"><input type="text" id="ac_name_1" name="ac_name_1" style="width: 600px" value="{$vlu.ac_name_1}">
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label for="ac_name_2" class="help">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="3"><input type="text" id="ac_name_2" name="ac_name_2" style="width: 600px" value="{$vlu.ac_name_2}">
            </tr>
        {/if}
        <tr>
            <th><label for="ac_action_descr_1" class="help">{t}Descrizione azione{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="3">
                {if $act!='show'}
                    <textarea name="ac_action_descr_1" id="ac_action_descr_1" style="width:600px;height:50px;" >{$vlu.ac_action_descr_1}</textarea>
                {else}
                    <div class="textarea_readonly">{$vlu.ac_action_descr_1}&nbsp;</div>
                {/if}
            </td>
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label for="ac_action_descr_2" class="help">{t}Descrizione azione{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="3">
                    {if $act!='show'}
                        <textarea name="ac_action_descr_2" id="ac_action_descr_2" style="width:600px;height:50px;" >{$vlu.ac_action_descr_2}</textarea>
                    {else}
                        <div class="textarea_readonly">{$vlu.ac_action_descr_2}&nbsp;</div>
                    {/if}
                </td>
            </tr>
        {/if}

        <tr>
            <th><label for="ac_responsible_department_1" class="help">{t}Responsabile{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="3"><input type="text" id="ac_responsible_department_1" name="ac_responsible_department_1" style="width: 600px" value="{$vlu.ac_responsible_department_1}">
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label for="ac_responsible_department_2" class="help">{t}Responsabile{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="3"><input type="text" id="ac_responsible_department_2" name="ac_responsible_department_2" style="width: 600px" value="{$vlu.ac_responsible_department_2}">
            </tr>
        {/if}
        <tr>
            <th><label for="ac_start_date" class="required help">{t}Attuazione{/t}:</label></th>
            <td><label for="ac_start_date">{t}Dal{/t}:</label><input type="text" id="ac_start_date" name="ac_start_date" value="{$vlu.ac_start_date}" class="date"></td>
            <td style="text-align:right"><label for="ac_end_date">{t}al{/t}:</label></td>
            <td><input type="text" id="ac_end_date" name="ac_end_date" value="{$vlu.ac_end_date}" class="date"></td>
        </tr>
        <tr>
            <th><label for="ac_benefit_start_date" class="help required">{t}Beneficio{/t}:</label></th>
            <td><label for="ac_benefit_start_date">{t}Dal{/t}:</label><input type="text" id="ac_benefit_start_date" name="ac_benefit_start_date" value="{$vlu.ac_benefit_start_date}" class="date"></td>
            <td style="text-align:right"><label for="ac_benefit_end_date">{t}al{/t}:</label></td>
            <td><input type="text" id="ac_benefit_end_date" name="ac_benefit_end_date" value="{$vlu.ac_benefit_end_date}" class="date"></td>
        </tr>

        <tr>
            <th></th>
            <td colspan="3"><input type="checkbox" id="enable_benefit_year" name="enable_benefit_year" value="T" {if $vlu.enable_benefit_year=='T'}checked{/if}><label for="enable_benefit_year" class="help">{t}Beneficio distribuito{/t}</label></td>
        </tr>

        <tr class="separator enable_benefit_year_row"><td colspan="4"></td></tr>
        <tr class="enable_benefit_year_row"><td colspan="4" style="padding:0px;">
                <table id="tblBenefitYear" width="100%">
                    <tr class="evidence">
                        <td colspan="4"><label class="help" for="benefit_year">{t}Beneficio/anno{/t}</label></td>
                        {if $act <> 'show'}
                            <td align="right"><img id="btnAddBenefitYear" src="../images/ico_add.gif" title="{t}Aggiungi{/t}" alt="{t}Aggiungi{/t}" /></td>
                            {/if}
                    </tr>
                    <!-- inizio sezione da ripetere -->
                    {if !empty($vlu.ac_benefit_year)}
                        {foreach from=$vlu.ac_benefit_year key=n item=vlu2}
                            {include file="action_catalog_benefit_year.tpl"}
                        {/foreach}
                    {else}
                        {assign var="n" value="0"}
                        {include file="action_catalog_benefit_year.tpl"}
                    {/if}
                    <!-- fine sezione da ripetere -->
                </table>
            </td></tr>

        <tr class="separator"><td colspan="4"></td></tr>
        <tr><td colspan="4" style="padding:0px;">
                <table id="tblExpectedEnergySavings">
                    <tr class="evidence">
                        <td colspan="3"><label class="help" for="ges_id_consumption">{t}Risparmio energetico previsto all'anno{/t}</label></td>
                        <td><label class="help" for="ac_expected_co2_reduction">{t escape=no}Riduzione di CO2/a{/t}</label></td>
                        {if $act <> 'show'}
                            <td><img id="btnAddExpectedEnergySavings" src="../images/ico_add.gif" title="{t}Aggiungi{/t}" alt="{t}Aggiungi{/t}" /></td>
                            {/if}
                    </tr>
                    {if count($vlu.ac_expected_energy_savings) > 0}
                        {foreach from=$vlu.ac_expected_energy_savings item=vlu2}
                            {include file="action_catalog_consumption_row.tpl"}
                        {/foreach}
                    {else}
                        {include file="action_catalog_consumption_row.tpl"}
                    {/if}
                </table>
            </td></tr>

        <tr class="separator"><td colspan="4"></td></tr>
        <tr class="evidence">
            <td colspan="4"><label class="help" for="ges_id_production">{t}Produzione di energia rinnovabile prevista all'anno{/t}</label></td>
        </tr>
        <tr>
            <td colspan="4">
                <select name="ges_id_production_helper" id="ges_id_production" style="width:150px;" {if $lkp.production_energy_source_list|@count<1}disabled{/if}>
                    <option value="">{t}-- Selezionare --{/t}</option>
                    {foreach from=$lkp.production_energy_source_list key=key item=ges_data}
                        <option label="{$ges_data.name}" {if $key==$vlu.ges_id_production}selected{/if} value="{$key}">{$ges_data.name}</option>
                    {/foreach}
                </select>
                <input type="hidden" name="es_id_production" id="es_id_production_default" value="">
                <select name="es_id_production_helper" id="es_id_production" style="width:150px;" {if $lkp.es_id_production_values|@count<=1}disabled{/if}>
                    <option value="">{t}-- Selezionare --{/t}</option>
                    {html_options options=$lkp.es_id_production_values selected=$vlu.es_id_production}
                </select>
                <input type="hidden" name="udm_id_production" id="udm_id_production_default" value="">
                <select name="udm_id_production_helper" id="udm_id_production" style="width:100px;" {if $lkp.udm_id_production_values|@count<=1}disabled{/if}>
                    {html_options options=$lkp.udm_id_production_values selected=$vlu.udm_id_production}
                </select>
                <input type="text" name="ac_expected_renewable_energy_production" id="ac_expected_renewable_energy_production" value="{$vlu.ac_expected_renewable_energy_production}" class="float" maxlength="10" style="width:80px;" />
                =
                <input type="text" name="ac_expected_renewable_energy_production_mwh" id="ac_expected_renewable_energy_production_mwh" value="{$vlu.ac_expected_renewable_energy_production_mwh}" class="float readonly" maxlength="10" style="width:80px;" /> MWh/a
            </td>
        </tr>

        <tr class="evidence">
            <td colspan="4"><label class="help" for="estimated_co2_reduction">{t}Riduzione di CO2 stimata{/t}</label></td>
        </tr>
        <tr>
            <th><label for="ac_co2_reduction_tco2">{t}Riduzione aggiuntiva di CO2{/t}:</label></th>
            <td><input type="text" id="ac_co2_reduction_tco2" name="ac_co2_reduction_tco2" value="{$vlu.ac_co2_reduction_tco2}" class="float" style="width:80px;"> t/a</td>
            <td></td>
            <td></td>
        </tr>

        <tr class="separator"><td colspan="4"></td></tr>
        <tr class="evidence">
            <td colspan="4"><label class="help" for="ac_green_electricity_purchase_mwh">{t}Acquisto energia verde{/t}</label></td>
        </tr>
        <tr>
            <th><label for="ac_green_electricity_purchase_mwh">{t}Acquisto energia{/t}:</label></th>
            <td><input type="text" id="ac_green_electricity_purchase_mwh" name="ac_green_electricity_purchase_mwh" value="{$vlu.ac_green_electricity_purchase_mwh}" class="float" style="width:80px;"> MWh/a</td>
            <td style="text-align:right"><label for="ac_green_electricity_co2_factor">{t}Fattore conversione in t CO2{/t}:</label></td>
            <td><input type="text" id="ac_end_daac_green_electricity_co2_factorte" name="ac_green_electricity_co2_factor" value="{$vlu.ac_green_electricity_co2_factor}" class="float" style="width:80px;"> t/MWh</td>
        </tr>

        <tr class="separator"><td colspan="4"></td></tr>
        <tr><td colspan="4" style="padding:0px;">
                <table id="tblRelatedRequiredActions" width="100%">
                    <tr class="evidence">
                        <td colspan="4"><label class="help" for="related_required_actions">{t}Azioni propedeutiche{/t}</label></td>
                        {if $act <> 'show'}
                            <td><img id="btnAddRelatedRequiredActions" src="../images/ico_add.gif" title="{t}Aggiungi{/t}" alt="{t}Aggiungi{/t}" /></td>
                            {/if}
                    </tr>
                    <!-- inizio sezione da ripetere -->
                    {if !empty($vlu.ac_related_required_actions)}
                        {foreach from=$vlu.ac_related_required_actions key=n item=vlu_required}
                            {include file="action_catalog_related_required_actions.tpl"}
                        {/foreach}
                    {else}
                        {assign var="n" value="0"}
                        {include file="action_catalog_related_required_actions.tpl"}
                    {/if}
                    <!-- fine sezione da ripetere -->
                </table>
            </td></tr>

        <tr class="separator"><td colspan="4"></td></tr>
        <tr><td colspan="4" style="padding:0px;">
                <table id="tblRelatedActions" width="100%">
                    <tr class="evidence">
                        <td colspan="4"><label class="help" for="related_actions">{t}Azioni interdipendenti{/t}</label></td>
                        {if $act <> 'show'}
                            <td><img id="btnAddRelatedActions" src="../images/ico_add.gif" title="{t}Aggiungi{/t}" alt="{t}Aggiungi{/t}" /></td>
                            {/if}
                    </tr>
                    <!-- inizio sezione da ripetere -->
                    {if !empty($vlu.ac_related_actions)}
                        {foreach from=$vlu.ac_related_actions key=n item=vlu_dependent}
                            {include file="action_catalog_related_actions.tpl"}
                        {/foreach}
                    {else}
                        {assign var="n" value="0"}
                        {assign var="vlu2" value=""}
                        {include file="action_catalog_related_actions.tpl"}
                    {/if}
                    <!-- fine sezione da ripetere -->
                </table>
            </td></tr>

        <tr class="separator"><td colspan="4"></td></tr>
        <tr><td colspan="4" style="padding:0px;">
                <table id="tblRelatedExcludedActions" width="100%">
                    <tr class="evidence">
                        <td colspan="4"><label class="help" for="related_excluded_actions">{t}Azioni esclusive{/t}</label></td>
                        {if $act <> 'show'}
                            <td><img id="btnAddRelatedExcludedActions" src="../images/ico_add.gif" title="{t}Aggiungi{/t}" alt="{t}Aggiungi{/t}" /></td>
                            {/if}
                    </tr>
                    <!-- inizio sezione da ripetere -->
                    {if !empty($vlu.ac_related_excluded_actions)}
                        {foreach from=$vlu.ac_related_excluded_actions key=n item=vlu_excluded}
                            {include file="action_catalog_related_excluded_actions.tpl"}
                        {/foreach}
                    {else}
                        {assign var="n" value="0"}
                        {include file="action_catalog_related_excluded_actions.tpl"}
                    {/if}
                    <!-- fine sezione da ripetere -->
                </table>
            </td></tr>

        <tr class="separator"><td colspan="4"></td></tr>
        <tr class="evidence">
            <td><label class="help" for="ac_estimated_cost">{t}Costi stimati{/t}:</label></td>
            <td><label class="help" for="ac_estimated_public_financing">{t}Finanziamento pubblico{/t}:</label></td>
            <td><label class="help" for="ac_estimated_other_financing">{t}Finanziamento terzi{/t}:</label></td>
            <td><label class="help" for="ac_estimated_auto_financing">{t}Autofinanziamento{/t}:</label></td>
        </tr>
        <tr>
            <td><input type="text" name="ac_estimated_cost" id="ac_estimated_cost" value="{$vlu.ac_estimated_cost}" maxlength="80" style="width:100px;" class="float" data-dec="2" /> €</td>
            <td><input type="text" name="ac_estimated_public_financing" id="ac_estimated_public_financing" value="{$vlu.ac_estimated_public_financing}" maxlength="80" style="width:100px;" class="float" data-dec="2" /> €</td>
            <td><input type="text" name="ac_estimated_other_financing" id="ac_estimated_other_financing" value="{$vlu.ac_estimated_other_financing}" maxlength="80" style="width:100px;" class="float" data-dec="2" /> €</td>
            <td><input type="text" name="ac_estimated_auto_financing" id="ac_estimated_auto_financing" maxlength="80" style="width:100px;" class="float readonly" disabled data-dec="2" /> €</td>
        </tr>

        <tr class="evidence">
            <td><label class="help" for="ac_effective_cost">{t}Costi effettivi{/t}:</label></td>
            <td><label class="help" for="ac_effective_public_financing">{t}Finanziamento pubblico{/t}:</label></td>
            <td><label class="help" for="ac_effective_other_financing">{t}Finanziamento terzi{/t}:</label></td>
            <td><label class="help" for="ac_effective_auto_financing">{t}Autofinanziamento{/t}:</label></td>
        </tr>
        <tr>
            <td><input type="text" name="ac_effective_cost" id="ac_effective_cost" value="{$vlu.ac_effective_cost}" maxlength="80" style="width:100px;" class="float" data-dec="2" /> €</td>
            <td><input type="text" name="ac_effective_public_financing" id="ac_effective_public_financing" value="{$vlu.ac_effective_public_financing}" maxlength="80" style="width:100px;" class="float" data-dec="2" /> €</td>
            <td><input type="text" name="ac_effective_other_financing" id="ac_effective_other_financing" value="{$vlu.ac_effective_other_financing}" maxlength="80" style="width:100px;" class="float" data-dec="2" /> €</td>
            <td><input type="text" name="ac_effective_auto_financing" id="ac_effective_auto_financing" maxlength="80" style="width:100px;" class="float readonly" disabled data-dec="2" /> €</td>
        </tr>


        <tr>
            <th><label class="help" for="ft_id">{t}Finanziamento{/t}:</label></th>
            <td colspan="3">
                <select name="ft_id" id="ft_id" style="width:600px">
                    <option value="">{t}-- selezionare --{/t}</option>
                    {foreach from=$lkp.ft_id_values key=key item=item}
                        <option label="{$item.name}" {if $key==$vlu.ft_id}selected{/if} value="{$key}" has_extradata="{$item.has_extradata}" {if $item.class<>''}class="{$item.class}"{/if}>{$item.name}</option>
                    {/foreach}
                </select>
            </td>
        </tr>
        <tr id="ft_extradata">
            <td></td><td><label class="help" for="ft_extradata_1" >{t}Altro{/t}{$LANG_NAME_SHORT_FMT_1}:</label>
                <input type="text" id="ft_extradata_1" name="ft_extradata_1" value="{$vlu.ft_extradata_1}" style="width: {if $NUM_LANGUAGES>1}220px{else}600px{/if}"></td>
                {if $NUM_LANGUAGES>1}
                <td colspan="2"><label class="help" for="ft_extradata_2" >{t}Altro{/t}{$LANG_NAME_SHORT_FMT_2}:</label>
                    <input type="text" id="ft_extradata_2" name="ft_extradata_2" value="{$vlu.ft_extradata_2}" style="width: 220px"></td>
                {/if}
            </td>
        </tr>


        <tr class="separator"><td colspan="4"></td></tr>
        <tr>
            <th><label for="ac_monitoring_descr_1" class="help">{t}Monitoraggio azione{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="3">
                {if $act!='show'}
                    <textarea name="ac_monitoring_descr_1" id="ac_monitoring_descr_1" style="width:600px;height:50px;" >{$vlu.ac_monitoring_descr_1}</textarea>
                {else}
                    <div class="textarea_readonly">{$vlu.ac_monitoring_descr_1}&nbsp;</div>
                {/if}
            </td>
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label for="ac_monitoring_descr_2" class="help">{t}Monitoraggio azione{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="3">
                    {if $act!='show'}
                        <textarea name="ac_monitoring_descr_2" id="ac_monitoring_descr_2" style="width:600px;height:50px;" >{$vlu.ac_monitoring_descr_2}</textarea>
                    {else}
                        <div class="textarea_readonly">{$vlu.ac_monitoring_descr_2}&nbsp;</div>
                    {/if}
                </td>
            </tr>
        {/if}

        <tr class="separator"><td colspan="4"></td></tr>
        <tr>
            <th><label for="ac_descr_1" class="help">{t}Note{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td colspan="3">
                {if $act!='show'}
                    <textarea name="ac_descr_1" id="ac_descr_1" style="width:600px;height:50px;" >{$vlu.ac_descr_1}</textarea>
                {else}
                    <div class="textarea_readonly">{$vlu.ac_descr_1}&nbsp;</div>
                {/if}
            </td>
        </tr>
        {if $NUM_LANGUAGES>1}
            <tr>
                <th><label for="ac_descr_2" class="help">{t}Note{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                <td colspan="3">
                    {if $act!='show'}
                        <textarea name="ac_descr_2" id="ac_descr_2" style="width:600px;height:50px;" >{$vlu.ac_descr_2}</textarea>
                    {else}
                        <div class="textarea_readonly">{$vlu.ac_descr_2}&nbsp;</div>
                    {/if}
                </td>
            </tr>
        {/if}
        <tr><td colspan="4">{include file="record_change.tpl"}</td></tr>
    </table>
    <br />
    {if $vlu.bu_id<>''}
        {if $act == 'show'}
            <input type="button" id="btnCloseDialog" name="btnCloseDialog"  value="{t}Chiudi{/t}" style="width:120px;height:25px;" />
        {else}
            {if $act != 'show'}
                <input type="button" id="btnSaveDialog" name="btnSaveDialog"  value="{t}Salva{/t}" style="width:75px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="button" name="btnCancelDialog" id="btnCancelDialog" value="{t}Annulla{/t}" style="width:75px;height:25px;">
            {/if}
        {/if}
    {else}
        {if $vars.parent_act == 'show'}
            <input type="button" id="btnClose" name="btnClose"  value="{t}Chiudi{/t}" style="width:120px;height:25px;" />
        {else}
            {if $act != 'show'}
                <input type="button" id="btnSave" name="btnSave"  value="{t}Salva{/t}" style="width:75px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" style="width:75px;height:25px;">
            {else}
                {if $USER_CAN_MOD_ACTION_CATALOG}
                    <input type="button" name="btnEdit" id="btnEdit" value="{t}Modifica{/t}" style="width:75px;height:25px;">&nbsp;&nbsp;&nbsp;&nbsp;
                {/if}
                <input type="button" name="btnBack" id="btnBack"  value="{t}Indietro{/t}" style="width:75px;height:25px;">
            {/if}
        {/if}
    {/if}
</form>


{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}