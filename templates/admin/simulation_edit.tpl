{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}
<h3 id="page_title">{$page_title}<span id="page_subtitle" style="display: none"></span></h3>


<script language="JavaScript" type="text/javascript">
    var auto_selected_actions = {if $vars.auto_selected_actions=='T'}true{else}false{/if};
</script>

{literal}
    <script language="JavaScript" type="text/javascript">

        function toggleSimulationTable(tableRowClass, img1, img2) {
            $('.' + tableRowClass).toggle();
            $('#' + img1).toggle();
            $('#' + img2).toggle();
            resizeTabHeight();
        }

        $(document).ready(function () {
            $('#mu_id').bind('change', function () {
                refreshGlobalStrategy()
            });
            $('#ss_type,#ss_table,#ss_category').bind('change', function () {
                refreshSummary()
            });
            $('#btnSave').bind('click', function () {
                submitFormDataSimulation()
            });
            $('#btnCancel,#btnBack').bind('click', function () {
                listObject()
            });
            $('#btnSaveAndGenerate').bind('click', function () {
                submitFormDataSimulation(true)
            });
            $('#btnEdit').bind('click', function () {
                modObject()
            });
            $('#sw_efe_is_calculated').bind('click', function () {
                checkEfe();
            });
            $('#openclose-summary').bind('click', function () {
                toggleSimulationTable('simulation_non_important_row', 'img_close1', 'img_open1');
            });
            $('#openclose-calculation').bind('click', function () {
                toggleTable('simulation_log', 'img_close2', 'img_open2');
            });

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

            if ($("#tabs").length > 0) {
                $("#tabs").tabs({show: function (event, ui) {
                        if (ui.panel.id == 'tabs-summary') {
                            refreshSummary();
                        }
                    }});
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
                            $('#page_subtitle').html(' - ' + $('#sw_title_1').val()).toggle();
                        });
            }
            if ($('#act').val() == 'show') {
                $("#tabs-catalog").hide();
                $("#tabs>ul>li").first().hide();
                $("#tabs").tabs("select", 1);
            }

            $('#modform').toggle(true);
            focusTo('#mu_id,#mu_name,#ac_name_1');
            resizeTabHeight();
            initChangeRecord();

            $('#simulation_open_close').click(function () {
                $('#simulation_log').toggle();
            });

            $('#btnPrintSimulationLog').click(function () {
                $('#simulation_log').toggle(true);
                $('#simulation_window').printElement();
            });
        });
        $(window).resize(function () {
            resizeTabHeight();
        });
    </script>
{/literal}

{include file=inline_help.tpl}
{if $lkp.mu_values|@count == 1 && $vlu.gst_id == ''}
    <div class="info_container">
        {t}Attenzione: Per poter effettuare una simulazione è necessario verificare e salvare i parametri generali{/t}
    </div>{/if}
    {if $act<>'add' && $vlu.ge_year==''}
        <div class="info_container">
            {t}Attenzione: Per poter effettuare una simulazione è necessario avere inserito almeno un inventario emissioni e averlo associato nella scheda dei parametri principali{/t}
        </div>{/if}

        {if $USER_CONFIG_APPLICATION_ENABLE_SIMULATION_LOG == 'T'}
            <div id="simulation_window" class="calcSuggestionWindow" style="display:none;">
                <div id="simulation_title" class="calcSuggestionWindowTitle"><span id="simulation_open_close"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_closed.gif"><b>{t}Log simulazione{/t}</b></span> <img src="../images/ico_print.gif" id="btnPrintSimulationLog"></div>
                <div id="simulation_log" class="calcSuggestion"></div>
            </div>
        {/if}

        <div id="simulation_waiting" class="simulation_waiting" style="display: none">
            <span><img src="../images/ajax_loader.gif" /></span>
            <span>{t}Elaborazione simulazione in corso.{/t}</span> <span class="simulation_rebuild" style="display: none">[{t}RICALCOLO{/t}]</span><span> {t}Prego attendere...{/t}<span>
                    </div>

                    {* [<input type="button" name="reload" class="btnRefresh" value="reload">] *}

                    <form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" style="display: none">
                        <input type="hidden" name="on" id="on" value="{$object_name}" />
                        <input type="hidden" name="act" id="act" value="{$act}">
                        <input type="hidden" name="id" id="id" value="{$vlu.sw_id}">
                        <input type="hidden" name="ac_id_list" id="ac_id_list" value="{$vlu.actions.ac_id_list}" />
                        <input type="hidden" name="ac_perc_list" id="ac_perc_list" value="{$vlu.actions.ac_perc_list}" />
                        <input type="hidden" name="generate_paes" id="generate_paes" value="F" />

                        {if $lkp.mu_values|@count <= 1}<input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}" />{/if}
                        <div id="form_controls_container">
                            <table class="table_form" width="810">
                                {if $lkp.mu_values|@count > 1}
                                    <tr>
                                        <th style="width: 200px"><label class="help required" for="mu_id">{if $lkp.mu_values.tot.collection > 0}{t}Comune/raggruppamento{/t}{else}{t}Comune{/t}{/if}:</label></th>
                                        <td colspan="3">
                                            {if $USER_CONFIG_APPLICATION_BUILDING_MUNICIPALITY_MODE <> 'COMBO'}
                                                <input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}">
                                                <input type="text" name="mu_name" id="mu_name" value="{$vlu.mu_name}" style="width:500px;">
                                            {else}
                                                <input type="hidden" name="mu_id" id="mu_id_dummy" value="{$vlu.mu_id}" />
                                                <select name="mu_id" id="mu_id" style="width:500px" {if $act <> 'add'}class="readonly" disabled{/if}>
                                                    {if $lkp.mu_values.tot.municipality > 1}<option value="">{t}-- Selezionare --{/t}</option>{/if}
                                                    {html_options options=$lkp.mu_values.data selected=$vlu.mu_id}
                                                </select>
                                            {/if}
                                        </td>
                                    </tr>
                                {/if}
                                {* Non dovrebbe essere mai visibile, visto che i parametri principali sono bloccati a 1 *}
                                <tr id="gst_id_row" {if $lkp.global_strategy_list|@count <= 1}style="display:none"{/if}>
                                    <th style="width: 200px"><label for="gst_id" class="required help">{t}Parametri generali{/t}:</label></th>
                                    <td colspan="3">
                                        {if $act == 'show'}
                                            <input type="hidden" name="gst_id" id="gst_id" value="{$vlu.gst_id}">
                                        {else}
                                            <select name="gst_id" id="gst_id" style="width:500px">
                                                {html_options options=$lkp.global_strategy_list selected=$vlu.gst_id}
                                            </select>
                                        {/if}
                                    </td>
                                </tr>

                                <tr>
                                    <th><label for="sw_title_1" class="required help">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
                                    <td xcolspan="4"><input type="text" id="sw_title_1" name="sw_title_1" style="{if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}width: 300px{else}width: 500px{/if}" value="{$vlu.sw_title_1}"></td>
                                        {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
                                        <th><label for="sw_title_2" class="help">{t}Nome{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
                                        <td xcolspan="4"><input type="text" id="sw_title_2" name="sw_title_2" style="width: 300px" value="{$vlu.sw_title_2}"></td>
                                        {/if}
                                </tr>

                                {if $act<>'add'}
                                    <tr>
                                        <th><label for="sw_efe_1" class="help">{t}EFE{/t}<sub>({$vlu.gst_reduction_target_year})</sub>:</label></th>
                                        <td><input type="text" id="sw_efe_1" name="sw_efe_1" style="width: 100px" value="{$vlu.sw_efe_1}" class="float readonly"></td>
                                            {if $vlu.gst_reduction_target_year_long_term<>''}
                                            <th><label for="sw_efe_2" class="help">{t}EFE{/t}<sub>({$vlu.gst_reduction_target_year_long_term})</sub>:</label></th>
                                            <td colspan="3"><input type="text" id="sw_efe_2" name="sw_efe_2" style="width: 100px" value="{$vlu.sw_efe_2}" class="float readonly"></td>
                                            {else}
                                            <td colspan="3"></td>
                                        {/if}
                                    </tr>
                                    <tr class="general_parameters"><td colspan="4"><a href="javascript:showGlobalStrategy()" title="{t}Visualizza parametri generali utilizzati per la simulazione{/t}">{t}Visualizza parametri generali{/t}</a></td></tr>
                                {/if}

                                <tr class="last_change_data"><td colspan="4">{include file="record_change.tpl"}</td></tr>

                                {if $act<>'add' && $vlu.ge_year<>''}
                                    <tr class="openclose">
                                        <td colspan="4">
                                            <a href="javascript:;" id="openclose-summary">
                                                <img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_closed.gif" id="img_close1" style="display:none" /><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_opened.gif" id="img_open1" />
                                                {t}Riepilogo simulazione{/t}</a>&nbsp;
                                        </td>
                                    </tr>
                                {/if}

                            </table>


                            {if $vlu.ge_year<>''}
                                <div id="simulation_summary" style="xdisplay:none">
                                    {if $vlu.mu_id<>'' || $act != 'add'}
                                        {include file="simulation_edit_summary_table.tpl"}
                                    {/if}
                                </div>
                            {/if}

                            <br />
                            {if $act != 'show'}
                                {if $act == 'add'}
                                    <input type="button" id="btnSave" name="btnSave"  value="{t}Salva e continua{/t}" style="width:160px;height:25px;" {if $lkp.mu_values|@count == 1 && $vlu.gst_id == ''}disabled{/if} />&nbsp;&nbsp;&nbsp;&nbsp;
                                {else}
                                    <input type="button" id="btnSave" name="btnSave"  value="{t}Salva{/t}" style="width:75px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
                                {/if}
                                <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" style="width:75px;height:25px;">
                            {else}
                                {if $USER_CAN_MOD_SIMULATION}
                                    <input type="button" name="btnEdit" id="btnEdit" value="{t}Modifica{/t}" style="width:75px;height:25px;">&nbsp;&nbsp;&nbsp;&nbsp;
                                {/if}
                                <input type="button" name="btnBack" id="btnBack"  value="{t}Indietro{/t}" style="width:75px;height:25px;">
                            {/if}
                            {if $act == 'mod' && $vlu.ge_year<>''}
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" name="btnSaveAndGenerate" id="btnSaveAndGenerate"  value="{t}Salva e genera PAES{/t}" style="width:160px;height:25px;">
                            {/if}
                            <br />
                        </div>
                    </form>

                    {if $vlu.ge_year<>'' && ($vlu.mu_id<>'' || $act != 'add')}
                        <br />
                        <div id="catalog">
                            <div id="tabs" style="height:300px">
                                <ul>
                                    <li><a href="#tabs-catalog">{t}Azioni da selezionare{/t} <span id="catalog_tot"></span></a></li>
                                    <li><a href="#tabs-selected">{t}Azioni selezionate{/t} <span id="selected_tot"></span></a></li>
                                    <li><a href="#tabs-summary">{t}Riepilogo{/t}</a></li>
                                </ul>

                                <div id="tabs-catalog" class="tab-resize">
                                    {if $lkp.catalog_maincategory_list|@count > 1}
                                        <fieldset class="filter">
                                            <legend>{t}Filtro{/t}</legend>
                                            <div class="filter_fields">
                                                <div>
                                                    <span>{t}Categoria{/t}:</span>
                                                    <select name="gc_parent_id" id="gc_parent_id" style="width:180px;">
                                                        <option value="">{t}-- Selezionare --{/t}</option>
                                                        {html_options options=$lkp.catalog_maincategory_list selected=$flt.do_id}
                                                    </select>
                                                </div>
                                            </div>
                                        </fieldset>
                                    {/if}
                                    {$vars.catalog_html}
                                </div>

                                <div id="tabs-selected" class="tab-resize">
                                    {$vars.selected_html}
                                </div>

                                <div id="tabs-summary" class="tab-resize">
                                    <fieldset class="filter">
                                        <legend>{t}Filtro{/t}</legend>
                                        <div class="filter_fields">
                                            <div>
                                                <span>{t}Tipo{/t}:</span>
                                                <select name="ss_type" id="ss_type" style="width:180px;">
                                                    {html_options options=$lkp.summary_type_list}
                                                </select>
                                            </div>
                                            <div>
                                                <span>{t}Tabella{/t}:</span>
                                                <select name="ss_table" id="ss_table" style="width:180px;">
                                                    {html_options options=$lkp.summary_table_list}
                                                </select>
                                            </div>
                                            {if $lkp.catalog_maincategory_list|@count > 1}
                                                <div>
                                                    <span>{t}Categoria{/t}:</span>
                                                    <select name="ss_category" id="ss_category" style="width:180px;">
                                                        <option value="">{t}-- Selezionare --{/t}</option>
                                                        {html_options options=$lkp.catalog_maincategory_list selected=$flt.do_id}
                                                    </select>
                                                </div>
                                            {else}
                                                <input type="hidden" name="ss_category" id="ss_category">
                                            {/if}
                                        </div>
                                    </fieldset>
                                    <div id="summary-table"></div>
                                </div>
                            </div>
                        </div>
                    {/if}


            {if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}