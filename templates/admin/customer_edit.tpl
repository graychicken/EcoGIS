{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}
{literal}
    <style>
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
            $('#btnCancel').bind('click', function () {
                listObject()
            });
            $('#btnSave').bind('click', function () {
                submitFormDataCustomer();
            });
            $('#btnGenerateGrid').bind('click', function () {
                generateGrid()
            });

            $('#dn_name').bind('change', function () {
                validateDomain('F')
            });
            $('#dn_name_alias').bind('change', function () {
                validateDomain('T')
            });
            $('#cus_srid').bind('change', function () {
                changeSRID()
            });

            // Elenco comuni
            $('#pr_id').bind('change', function () {
                changeProvinceFilter()
            });
            $('#mu_name').bind('keyup', function () {
                changeProvinceFilterTimer(100)
            });
            $('#btnClearFilter').bind('click', function () {
                $('#pr_id').val('');
                $('#mu_name').val('');
                changeProvinceFilter()
            });
            $('#btnMoveAllToLeft').bind('click', function () {
                moveMunicipality('#mu_list', '#mu_selected', true)
            });
            $('#btnMoveToLeft').bind('click', function () {
                moveMunicipality('#mu_list', '#mu_selected')
            });
            $('#mu_list').bind('dblclick', function () {
                moveMunicipality('#mu_list', '#mu_selected')
            });
            $('#btnMoveAllToRight').bind('click', function () {
                moveMunicipality('#mu_selected', '#mu_list', true)
            });
            $('#btnMoveToRight').bind('click', function () {
                moveMunicipality('#mu_selected', '#mu_list')
            });
            $('#mu_selected').bind('dblclick', function () {
                moveMunicipality('#mu_selected', '#mu_list')
            });

            $('#openclose_upload').bind('click', function () {
                toggleTable('table_upload', 'img_close_upload', 'img_open_upload');
            });

            if ($('#act').val() == 'mod') {
                $('.download_image').bind('click', function () {
                    document.location = 'getfile.php?type=logo&domain=' + $('#dn_name').val() + '&file=' + this.id + '.png&disposition=attachment';
                });
                $('.download_reference').bind('click', function () {
                    document.location = 'getfile.php?type=reference&domain=' + $('#dn_name').val() + '&file=' + this.id + '.png&disposition=attachment';
                });
                $('.download_style').bind('click', function () {
                    document.location = 'getfile.php?type=style&domain=' + $('#dn_name').val() + '&file=' + this.id + '.png&disposition=attachment';
                });
            }
            setupReadOnly('#modform');
            setupInputFormat('#modform');
            $('#modform').toggle(true);  // Show the form
            $('#dn_name').focus();
        });
    </script>
{/literal}

{include file=inline_help.tpl}
<h3 id="page_title">{$page_title}</h3>

<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" style="xdisplay:none">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="do_id" value="{$vlu.do_id}">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}

    <table class="form">
        <tr><td>
                <fieldset class="filter">
                    <legend id="do_first_user" class="help">{t}Dati ente{/t}</legend>
                    <table class="form">
                        <tr>
                            <th><label class="help required" for="dn_name">{t}Dominio{/t}</label></th>
                            <td><input type="text" class="{if $act=='mod'}readonly{/if}" name="dn_name" id="dn_name" value="{$vlu.dn_name}" style="width: 200px;"></td>
                            <th><label class="help" for="dn_name_alias">{t}Alias{/t}</label></th>
                            <td><input type="text" name="dn_name_alias" id="dn_name_alias" value="{$vlu.dn_name_alias}" style="width: 200px;"></td>
                        </tr>
                        {if $act == 'add'}
                            <tr>
                                <th><label class="help" for="do_template">{t}Template{/t}</label></th>
                                <td colspan="3"><select name="do_template" id="do_template" style="width: 200px">
                                        {html_options options=$lkp.do_template_values selected=$vlu.do_template}
                                    </select>
                                </td>
                            </tr>
                        {/if}
                        <tr>
                            <th><label class="help required" for="cus_name_1">{t}Nome ente linguia 1{/t}:</label></th>
                            <td><input type="text" name="cus_name_1" id="cus_name_1" value="{$vlu.cus_name_1}" style="width: 200px;"></td>
                            <th><label class="help required" for="cus_name_2">{t}Nome ente lingua 2{/t}:</label></th>
                            <td><input type="text" name="cus_name_2" id="cus_name_2" value="{$vlu.cus_name_2}" style="width: 200px;"></td>
                        </tr>
                    </table>
                </fieldset>
            </td></tr>
            {if $act == 'add'}
            <tr><td>
                    <fieldset class="filter">
                        <legend id="do_first_user" class="">{t}Primo utente{/t}</legend>
                        <table class="form">
                            <tr>
                                <th><label class="required" for="us_name">{t}Nome utente{/t}</label></th>
                                <td><input type="text" name="us_name" id="us_name" style="width: 150px;"></td>
                                <th><label class="required" for="us_login">{t}Login{/t}</label></th>
                                <td><input type="text" name="us_login" id="us_login" style="width: 150px;">@<input type="text" class="readonly" tabindex="-1" name="us_login_domain" id="us_login_domain" style="width: 150px;"></td>
                            </tr>
                            <tr>
                                <th><label class="required" for="us_password">{t}Password{/t}</label></th>
                                <td><input type="text" name="us_password" id="us_password" style="width: 150px;"></td>
                            </tr>
                            <tr>
                                <th><label class="" for="us_group">{t}Gruppo{/t}</label></th>
                                <td><select name="us_group" id="us_group" style="width: 150px">
                                        {html_options options=$lkp.do_group_values selected=$vlu.gr_name}
                                    </select>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td></tr>
            {/if}
        <tr><td>
                <fieldset class="filter">
                    <legend id="do_config_settings" class="">{t}Parametri di configurazione{/t}</legend>
                    <table class="form">
                        <tr>
                            <th><label class="required" for="app_language">{t}Lingue applicativo{/t}</label></th>
                            <td><select name="app_language" id="app_language" style="width: 150px">
                                    {html_options options=$lkp.app_language_values selected=$vlu.app_language}
                                </select>
                            </td>
                            <th><label class="required" for="app_cat_type">{t}Tipologia catasto{/t}</label></th>
                            <td><select name="app_cat_type" id="app_cat_type" style="width: 150px">
                                    {html_options options=$lkp.app_cat_type_values selected=$vlu.app_cat_type}
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th><label class="required" for="do_build_year_type">{t}Tipologia anno edificio{/t}</label></th>
                            <td><select name="do_build_year_type" do_build_year_type="app_cat_type" style="width: 150px">
                                    {html_options options=$lkp.do_build_year_type_values selected=$vlu.do_build_year_type}
                                </select>
                            </td>
                            <th><label class="required" for="do_build_restructure_year_type">{t}Tipologia anno ristrutturazione edificio{/t}</label></th>
                            <td><select name="do_build_restructure_year_type" id="app_cat_type" style="width: 150px">
                                    {html_options options=$lkp.do_build_restructure_year_type_values selected=$vlu.do_build_restructure_year_type}
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th><label class="required" for="do_schema">{t}Schema geografico{/t}</label></th>
                            <td><input type="text" class="readonly" tabindex="-1" name="do_schema" id="do_schema" value="{$vlu.do_schema}" style="width: 150px;"></td>
                        </tr>
                        <tr>
                            <th><label class="required" for="cus_srid">{t}SRID{/t}</label></th>
                            <td><input type="text" name="cus_srid" id="cus_srid" value="{$vlu.cus_srid}" style="width: 200px;"></td>
                            <td colspan="2"><input type="text" name="cus_srid_text" id="cus_srid_text" class="readonly" tabindex="-1" value="{$vlu.cus_srid_text}" style="width: 250px;"></td>
                        </tr>

                        <tr>
                            <th><label class="required" for="do_building_show_id">{t}Visualizza ID interno edificio{/t}</label></th>
                            <td><select name="do_building_show_id" id="do_building_show_id" style="width: 200px">
                                    {html_options options=$lkp.true_false_values selected=$vlu.do_building_show_id}
                                </select>
                            </td>
                            <th><label class="required" for="do_building_code_type">{t}Codice edificio{/t}</label></th>
                            <td><select name="do_building_code_type" id="do_building_code_type" style="width: 200px">
                                    {html_options options=$lkp.do_building_code_type_values selected=$vlu.do_building_code_type}
                                </select>
                                <input type="hidden" name="do_building_code_required" value="F" />
                                <input type="checkbox" name="do_building_code_required" id="do_building_code_required" value="T" {if $vlu.do_building_code_required=='T'}checked{/if}/>
                                <label for="do_building_code_required">{t}Obblig.{/t}</label>

                                <input type="hidden" name="do_building_code_unique" value="F" />
                                <input type="checkbox" name="do_building_code_unique" id="do_building_code_unique" value="T" {if $vlu.do_building_code_unique=='T'}checked{/if}/>
                                <label for="do_building_code_unique">{t}Univoco{/t}</label>

                            </td>

                        </tr>
                        <tr>
                            <th><label class="required" for="do_municipality_mode">{t}Comuni{/t}</label></th>
                            <td><select name="do_municipality_mode" id="do_municipality_mode" style="width: 200px">
                                    {html_options options=$lkp.do_municipality_mode_values selected=$vlu.do_municipality_mode}
                                </select>
                            </td>
                            <th><label class="required" for="do_fraction_mode">{t}Frazioni{/t}</label></th>
                            <td><select name="do_fraction_mode" id="do_fraction_mode" style="width: 200px">
                                    {html_options options=$lkp.do_fraction_mode_values selected=$vlu.do_fraction_mode}
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th><label class="required" for="do_street_mode">{t}Strade{/t}</label></th>
                            <td><select name="do_street_mode" id="do_street_mode" style="width: 200px">
                                    {html_options options=$lkp.do_street_mode_values selected=$vlu.do_street_mode}
                                </select>
                            </td>
                            <th><label class="required" for="do_catastral_mode">{t}Comune catastale{/t}</label></th>
                            <td><select name="do_catastral_mode" id="do_catastral_mode" style="width: 200px">
                                    {html_options options=$lkp.do_catastral_mode_values selected=$vlu.do_catastral_mode}
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th colspan="4"><hr></th>
                        </tr>
                        <tr>
                            <th><label class="help" for="consumption_start_year">{t}Anno primo consumo{/t}</label></th>
                            <td><input type="text" class="year" name="consumption_start_year" value="{$vlu.consumption_start_year}" /></td>
                            <th><label class="help" for="consumption_end_year">{t}Anno ultimo consumo{/t}</label></th>
                            <td><input type="text" class="year" name="consumption_end_year" value="{$vlu.consumption_end_year}" /></td>
                        </tr>
                        <tr>
                            <th colspan="4"><hr></th>
                        </tr>
                        <tr> 
                            <th><label class="help" for="do_calculate_global_plain_totals">{t}Calcola somme piano azione (Consigliato){/t}</label></th>
                            <td><input type="hidden" name="do_calculate_global_plain_totals" value="F" />
                                <input type="checkbox" name="do_calculate_global_plain_totals" id="do_calculate_global_plain_totals" value="T" {if $vlu.do_calculate_global_plain_totals=='T'}checked{/if}/>
                                <label for="do_calculate_global_plain_totals">{t}Si{/t}</label>
                            </td>
                        </tr>

                    </table>
                </fieldset>
            </td></tr>


        <tr><td>
                <fieldset class="filter">
                    <legend id="do_gisclient" class="">{t}GisClient{/t}</legend>
                    <table class="form">
                        <tr>
                            <th><label class="required" for="do_gc_project">{t}Progetto{/t}</label></th>
                            <td><input type="text" name="do_gc_project" id="do_gc_project" value="{$vlu.do_gc_project}" style="width: 150px;"></td>
                            <th><label class="required" for="do_gc_mapset">{t}Mapset{/t}</label></th>
                            <td><input type="text" name="do_gc_mapset" id="do_gc_mapset" value="{$vlu.do_gc_mapset}" style="width: 150px;"></td>
                        </tr>
                        <tr>
                            <th><label class="required" for="do_gc_tools">{t}Strumenti{/t}</label></th>
                            <td>
                                <input type="hidden" name="do_gc_streeview" value="F" />
                                <input type="checkbox" name="do_gc_streeview" id="do_gc_streeview" value="T" {if $vlu.do_gc_streeview=='T'}checked{/if}/> <label for="do_gc_streeview">{t}Streeview{/t}</label>

                                <input type="hidden" name="do_gc_quick_search" value="F" />
                                <input type="checkbox" name="do_gc_quick_search" id="do_gc_quick_search" value="T" {if $vlu.do_gc_quick_search=='T'}checked{/if}/> <label for="do_gc_quick_search">{t}Ricerca veloce{/t}</label>
                            </td>
                        </tr>

                        <tr>
                            <th><label class="required" for="do_gc_tools">{t}Digitalizzazione su mappa{/t}</label></th>
                            <td>
                                <input type="hidden" name="do_gc_digitize_has_selection" value="F" />
                                <input type="checkbox" name="do_gc_digitize_has_selection" id="do_gc_digitize_has_selection" value="T" {if $vlu.do_gc_digitize_has_selection=='T'}checked{/if}/> <label for="do_gc_digitize_has_selection">{t}Seleziona oggetto{/t}</label>

                                <input type="hidden" name="do_gc_digitize_has_editing" value="F" />
                                <input type="checkbox" name="do_gc_digitize_has_editing" id="do_gc_digitize_has_editing" value="T" {if $vlu.do_gc_digitize_has_editing=='T'}checked{/if}/> <label for="do_gc_digitize_has_editing">{t}Disegna oggetto{/t}</label>
                            </td>
                        </tr>


                    </table>
                </fieldset>
            </td></tr>

        <tr><td>
                <fieldset class="filter">
                    <legend id="do_public_site_info" class="">{t}Sito pubblico{/t}</legend>
                    <table class="form">
                        <tr>
                            <th><label class="required" for="do_public_site">{t}Sito pubblico{/t}</label></th>
                            <td>
                                <input type="hidden" name="do_public_site" value="F" />
                                <input type="checkbox" name="do_public_site" id="do_public_site" value="T" {if $vlu.do_public_site=='T'}checked{/if}/>
                                <label for="do_public_site">{t}Attivo{/t}</label>
                            </td>
                            <th style="padding-left: 50px"><label for="do_grid_size">{t}Griglia statistica{/t}</label></th>
                            <td>
                                <input type="text" name="do_grid_size" id="do_grid_size" style="width: 50px; text-align: right" value="{$vlu.do_grid_size}" />
                                <input type="button" name="btnGenerateGrid" id="btnGenerateGrid" value="{t}Applica griglia{/t}" />
                            </td>
                        </tr>
                        <tr>
                            <th><label class="required" for="do_building_extra_descr">{t}Campo note aggiuntivo{/t}</label></th>
                            <td>
                                <input type="hidden" name="do_building_extra_descr" value="F" />
                                <input type="checkbox" name="do_building_extra_descr" id="do_building_extra_descr" value="T" {if $vlu.do_building_extra_descr=='T'}checked{/if}/>
                                <label for="do_building_extra_descr">{t}Si{/t}</label>
                            </td>

                        </tr>


                    </table>
                </fieldset>
            </td></tr>


        <tr>
            <td colspan="4">
                <fieldset class="filter">
                    <legend id="xdo_first_user" class="">{t}Comuni associati al cliente{/t}</legend>
                    <table style="border-collapse: collapse; border: 1px solid #777777"
                           summary="{t escape=no}Non saranno rimossi comuni presenti in: Frazioni, strade, edifici, catalogo azioni, fattori di conversione, parameri principali, inventari emissioni, simulazioni, piani d'azione, fornitori di energia{/t}">
                        <tr>
                            <td><label class="" for="pr_id">{t}Comuni associati{/t}</label></td>
                            <td></td>
                            <td><select name="pr_id" id="pr_id" style="width: 150px" >
                                    <option value="">{t}-- Filtro --{/t}</option>
                                    {html_options options=$lkp.pr_list}
                                </select> <input type="text" name="mu_name" id="mu_name" style="width: 200px">
                                <input type="button" id="btnClearFilter" name="btnClearFilter"  value="{t}X{/t}" style="width:30px;height:20px;" />
                            </td>
                        </tr>
                        <tr>

                            <td><select name="mu_selected" id="mu_selected" style="width: 300px; height: 200px" multiple>
                                    {html_options options=$lkp.mu_selected}
                                </select>
                                <input type="hidden" name="municipality" id="municipality"> {* Store the selected municipality *}
                            </td>
                            <td>
                                <input type="button" id="btnMoveAllToLeft" name="btnMoveAllToLeft"  value="&lt;&lt;" style="width:40px;height:20px;" /><br>
                                <input type="button" id="btnMoveToLeft" name="btnMoveToLeft"  value="&lt;" style="width:40px;height:20px;" /><br>
                                <input type="button" id="btnMoveToRight" name="btnMoveToRight"  value="&gt;" style="width:40px;height:20px;" /><br>
                                <input type="button" id="btnMoveAllToRight" name="btnMoveAllToRight"  value="&gt;&gt;" style="width:40px;height:20px;" /><br>


                            </td>
                            <td><select name="mu_list" id="mu_list" style="width: 400px; height: 200px" multiple>
                                    {html_options options=$lkp.mu_list}
                                </select>
                            </td>
                        </tr>
                    </table>

                </fieldset>
            </td></tr>


        <tr>
            <td colspan="4">
                <fieldset class="filter">
                    <legend id="openclose_upload">
                        <img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_closed.gif" id="img_close_upload" style="display:none" /><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_opened.gif" id="img_open_upload" />
                        {t}Loghi e stili{/t}</legend>
                    <table id="table_upload">
                        <tr>
                            <th><label class="" for="do_login_logo_sx">{t}Logo login (sinistro){/t}</label></th>
                            <td><input type="file" name="do_login_logo_sx[]" id="do_login_logo_sx" class="upload" maxlength="1" accept="png"></td>
                            <td>{if $vlu.images.do_login_logo_sx == true}<img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_doc_download.gif" id="login_sx" class="download_image"/>{/if}</td>
                            <td style="width: 10px"></td>
                            <th><label class="" for="do_login_logo_dx">{t}Logo login (destro){/t}</label></th>
                            <td><input type="file" name="do_login_logo_dx[]" id="do_login_logo_dx" class="upload" maxlength="1" accept="png"></td>
                            <td>{if $vlu.images.do_login_logo_dx == true}<img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_doc_download.gif" id="login_dx" class="download_image"/>{/if}</td>
                        </tr>
                        <tr>
                            <th><label class="" for="do_app_logo_sx">{t}Logo applicativo (sinistro){/t}</label></th>
                            <td><input type="file" name="do_app_logo_sx[]" id="do_app_logo_sx" class="upload" maxlength="1" accept="png"></td>
                            <td>{if $vlu.images.do_app_logo_sx == true}<img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_doc_download.gif" id="logo_sx" class="download_image"/>{/if}</td>
                            <td style="width: 10px"></td>
                            <th><label class="" for="do_app_logo_dx">{t}Logo applicativo (destro){/t}</label></th>
                            <td><input type="file" name="do_app_logo_dx[]" id="do_app_logo_dx" class="upload" maxlength="1" accept="png"></td>
                            <td>{if $vlu.images.do_app_logo_dx == true}<img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_doc_download.gif" id="logo_dx" class="download_image"/>{/if}</td>
                        </tr>
                        <tr>
                            <th><label class="" for="do_map_logo_sx">{t}Logo mappa (sinistro){/t}</label></th>
                            <td><input type="file" name="do_map_logo_sx[]" id="do_map_logo_sx" class="upload" maxlength="1" accept="png"></td>
                            <td>{if $vlu.images.do_map_logo_sx == true}<img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_doc_download.gif" id="map_sx" class="download_image"/>{/if}</td>
                            <td style="width: 10px"></td>
                            <th>{*<label class="" for="do_map_logo_dx">{t}Logo mappa (destro){/t}</label>*}</th>
                            <td>{*<input type="file" name="do_map_logo_dx[]" id="do_map_logo_dx" class="upload" maxlength="1" accept="png">*}</td>
                            <td>{if $vlu.images.do_map_logo_dx == true}<img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_doc_download.gif" id="map_dx" class="download_image"/>{/if}</td>
                        </tr>
                        <tr>
                            <th><label class="" for="do_app_css">{t}Stile applicativo{/t}</label></th>
                            <td><input type="file" name="do_app_css[]" id="do_app_css" class="upload" maxlength="1" accept="css"></td>
                            <td>{if $vlu.css.do_app_css == true}<img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_doc_download.gif" id="do_app_css" class="download_style"/>{/if}</td>
                            <td style="width: 10px"></td>
                            <th><label class="" for="do_map_css">{t}Stile mappa{/t}</label></th>
                            <td><input type="file" name="do_map_css[]" id="do_map_css" class="upload" maxlength="1" accept="css"></td>
                            <td>{if $vlu.css.do_map_css == true}<img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_doc_download.gif" id="do_map_css" class="download_style"/>{/if}</td>
                        </tr>
                        <tr>
                            <th><label class="" for="do_public_css">{t}Stile pubblico{/t}</label></th>
                            <td><input type="file" name="do_public_css[]" id="do_public_css" class="upload" maxlength="1" accept="css"></td>
                            <td>{if $vlu.css.do_public_css == true}<img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_doc_download.gif" id="do_public_css" class="download_style"/>{/if}</td>
                            <td style="width: 10px"></td>
                            <th><label class="" for="do_public_css_url">{t}Stile pubblico esterno{/t}</label></th>
                            <td><input type="text" name="do_public_css_url" id="do_public_css_url" value="{$vlu.do_public_css_url}"/></td>
                            <td></td>
                        </tr>
                    </table>
                </fieldset>
            </td></tr>
    </table>
    <br />
    {if $act == 'show'}
        <input type="button" id="btnCancel" name="btnCancel"  value="{t}Chiudi{/t}" style="width:120px;height:25px;" />
    {else}
        {if $smarty.const.R3_AUTO_POPULATE_GEOMETRY_COLUMNS}
            <input type="checkbox" name="skip_geometry_check" id="skip_geometry_check" value="T" /><label for="skip_geometry_check">{t}Non ripopolare le colonne spaziali (salvataggio più veloce){/t}</label>
            <br /><br />
        {/if}
        <input type="button" id="btnSave" name="btnSave"  value="{t}Salva{/t}" style="width:120px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="button" id="btnCancel" name="btnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />
        <br /><br />
    {/if}
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}