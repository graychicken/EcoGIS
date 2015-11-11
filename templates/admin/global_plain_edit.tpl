{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

<h3 id="page_title">{$page_title}<span id="page_subtitle" style="display: none"></span></h3>

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#btnSave').bind('click', function () {
                submitFormDataGlobalPlain()
            });
            $('#btnCancel,#btnBack').bind('click', function () {
                listObject()
            });
            $('#btnEdit').bind('click', function () {
                modObject()
            });
            if ($('#act').val() == 'show') {
                setupShowMode();  // Setup the show mode
                setupInputFormat('#modform', false);
            } else {
                setupInputFormat('#modform');
                setupRequired('#modform');
                $('#bu_survey_date').datepicker('option', {yearRange: '-20:+0'});
            }
            setupReadOnly('#modform');
            initChangeRecord();
            autocomplete("#mu_name", {url: 'edit.php',
                on: 'building',
                method: 'fetch_municipality',
                pr_id: $('#pr_id').val(),
                limit: 20,
                minLength: 1});
            // Calendar problem
            $('#ui-datepicker-div').css('display', 'none');

            if ($("#tabs").length > 0) {
                // Tabs not always enabled
                $("#tabs").tabs({cache: true,
                    ajaxOptions: {cache: true}});
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
                            $('#page_subtitle').html(' - ' + $('#gp_name_1').val()).toggle();
                        });
            }
            // Show element
            $('#modform').toggle(true);
            $('#tabs').toggle(true);
            focusTo('#mu_id,#mu_name,#gp_name_1');
        });

        $(window).resize(function () {
            resizeTabHeight();
        });
    </script>
{/literal}

{include file=inline_help.tpl}

<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" style="display: none">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="id" value="{$vlu.gp_id}">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" value="{$val}" />
    {/foreach}

    {if $lkp.mu_values|@count <= 1}<input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}" />{/if}
    <div id="form_controls_container">
        <table class="table_form">
            {if $lkp.mu_values|@count > 1}
                <tr>
                    <th><label class="help required" for="mu_id">{if $lkp.mu_values.tot.collection > 0}{t}Comune/raggruppamento{/t}{else}{t}Comune{/t}{/if}:</label></th>
                    <td colspan="3">
                        <input type="hidden" name="mu_id" id="mu_id" value="{$vlu.mu_id}">
                        {if $USER_CONFIG_APPLICATION_BUILDING_MUNICIPALITY_MODE <> 'COMBO'}
                            <input type="text" name="mu_name" id="mu_name" value="{$vlu.mu_name}" style="width:600px;">
                        {else}
                            <select name="mu_id" id="mu_id" style="width:600px" {if $act <> 'add'}class="readonly" disabled{/if}>
                                {if $lkp.mu_values.tot.municipality > 1}<option value="">{t}-- Selezionare --{/t}</option>{/if}
                                {html_options options=$lkp.mu_values.data selected=$vlu.mu_id}
                            </select>
                        {/if}
                    </td>
                </tr>
            {/if}
            <tr>
                <th><label class="required help" for="gp_name_1">{t}Titolo{/t} {$LANG_NAME_SHORT_FMT_1}:</label></th>
                <td><input type="text" name="gp_name_1" id="gp_name_1" value="{$vlu.gp_name_1}" style="width:400px;" /></td>
                <th><label class="help" for="gp_approval_date">{t}Data approvazione{/t}:</label></th>
                <td><input type="text" name="gp_approval_date" id="gp_approval_date" class="date" value="{$vlu.gp_approval_date}" style="width:100px;" /></td>
            </tr>
            {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
                <tr>
                    <th><label class="required help" for="gp_name_2">{t}Titolo{/t} {$LANG_NAME_SHORT_FMT_2}:</label></th>
                    <td colspan="3"><input type="text" name="gp_name_2" id="gp_name_2" value="{$vlu.gp_name_2}" style="width:600px;" /></td>
                </tr>
            {/if}
            <tr>
                <th><label class="help" for="gp_approving_authority_1">{t}Ente approvatore{/t} {$LANG_NAME_SHORT_FMT_1}:</label></th>
                <td colspan="3"><input type="text" name="gp_approving_authority_1" id="gp_approving_authority_1" value="{$vlu.gp_approving_authority_1}" style="width:600px;" /></td>
            </tr>
            {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
                <tr>
                    <th><label class="help" for="gp_approving_authority_2">{t}Ente approvatore{/t} {$LANG_NAME_SHORT_FMT_2}:</label></th>
                    <td colspan="3"><input type="text" name="gp_approving_authority_2" id="gp_approving_authority_2" value="{$vlu.gp_approving_authority_2}" style="width:600px;" /></td>
                </tr>
            {/if}
            <tr>
                <th><label class="help" for="gp_url_1">{t}Indirizzo sito pubblico{/t} {$LANG_NAME_SHORT_FMT_1}:</label></th>
                <td colspan="3"><input type="text" name="gp_url_1" id="gp_url_1" value="{$vlu.gp_url_1}" style="width:600px;" /></td>
            </tr>
            {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES > 1}
                <tr>
                    <th><label class="help" for="gp_url_2">{t}Indirizzo sito pubblico{/t} {$LANG_NAME_SHORT_FMT_2}:</label></th>
                    <td colspan="3"><input type="text" name="gp_url_2" id="gp_url_2" value="{$vlu.gp_url_2}" style="width:600px;" /></td>
                </tr>
            {/if}
            <tr><td colspan="4">{include file="record_change.tpl"}</td></tr>
        </table>
        <br />

        {if $act != 'show'}
            <input type="button" id="btnSave" name="btnSave"  value="{t}Salva{/t}" style="width:75px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" style="width:75px;height:25px;">
        {else}
            {if $USER_CAN_MOD_GLOBAL_PLAIN}
                <input type="button" name="btnEdit" id="btnEdit"  value="{t}Modifica{/t}" style="width:75px;height:25px;">&nbsp;&nbsp;&nbsp;&nbsp;
            {/if}
            <input type="button" name="btnBack" id="btnBack"  value="{t}Indietro{/t}" style="width:75px;height:25px;">
        {/if}
    </div>
</form>
{if $act != 'add'}
    <br />
    {r3tab id='tabs' items=$vars.tabs style="display: none; height: 300px" istyle="height: 250px; width: 100%" autoInit=false onLoad="resizeTabHeight()" mode=$vars.tab_mode}
{/if}

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}