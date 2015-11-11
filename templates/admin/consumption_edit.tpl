{include file="header_ajax.tpl"}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#popup_modform .help').bind('click', function () {
                showR3Help('consumption', this)
            });
            $('.calc_value').bind('change', function () {
                setTimeout('calcValue()', 100)
            });
            calcValue();

            $('#popup_btnSave, #popup_btnSaveContinue').bind('click', function () {
                submitFormDataConsumption(this.id == 'popup_btnSaveContinue');
            });
            $('#popup_btnCancel').bind('click', function () {
                closeR3Dialog()
            });

            if ($('#popup_act').val() == 'show') {
                setupShowMode('popup');  // Setup the show mode
                setupInputFormat('#popup_modform', false);
            } else {
                setupInputFormat('#popup_modform');
                setupRequired('#popup_modform');
                setupReadOnly('#popup_modform');
                $('#popup_modform .date').datepicker('option', {yearRange: '-10:+1'});
                if ($('#popup_act').val() == 'add') {
                    $('#popup_insert_type').bind('change', function () {
                        insertTypeChange()
                    });
                    insertTypeChange();
                    $('#popup_insert_year').bind('change', function () {
                        insertYearChange()
                    });
                    insertYearChange();
                }
            }
            $('#popup_modform').toggle(true);  // Show the form
            $('#co_start_date_free').focus();

        });
    </script>
{/literal}

<form name="modform" id="popup_modform" action="edit.php?method=submitFormData" method="post" style="display:none">
    <input type="hidden" name="on" id="popup_on" value="{$object_name}" />
    <input type="hidden" name="act" id="popup_act" value="{$act}">
    <input type="hidden" name="id" id="popup_co_id" value="{$vlu.co_id}">
    <input type="hidden" name="reinsert" id="popup_reinsert" value="">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="popup_{$key}" value="{$val}" />
    {/foreach}

    <table class="form">
        {if $act == 'add'}
            {if $vars.kind == 'street_lighting'}
                <input type="hidden" name="insert_type" id="popup_insert_type" value="free">
            {else}
                <tr>
                    <th><label class="required help" for="popup_insert_type">{t}Tipo inserimento{/t}:</label></th>
                    <td><select name="insert_type" id="popup_insert_type" style="width: 200px">
                            {html_options options=$lkp.insert_type_values}
                        </select></td>
                    <th><label class="required help year_data" for="popup_insert_year">{t}Anno{/t}:</label></th>
                    <td><select class="year_data" name="insert_year" id="popup_insert_year" style="width: 200px">
                            {html_options options=$lkp.insert_year_values}
                        </select></td>
                </tr>
            {/if}
        {/if}
        {if $vars.kind != 'street_lighting'}
            <tr>
                <th><label class="help" for="popup_dev_em_name">{t}Contatore{/t}:</label></th>
                <td><input type="text" name="dev_esu_dummy" id="popup_dev_em_name" class="readonly" value="{$vlu.em_data.em_name}" style="width: 200px"></td>
                    {if $vlu.em_data.is_producer!='T'}
                    <th><label class="help" for="popup_dev_esu_name">{t}Alimentazione{/t}:</label></th>
                    <td><input type="text" name="dev_esu_dummy" id="popup_dev_esu_name" class="readonly" value="{$vlu.em_data.es_name} [{$vlu.em_data.udm_name}]" style="width: 200px"></td>
                    {else}
                    <td colspan="2"></td>
                {/if}
            </tr>
        {/if}
    </table>
    <div id="kind_free">
        <table width="100%" class="form">
            <tr>
                <th><label class="required help" for="popup_co_start_date_free">{t}Inizio{/t}</th>
                <td><input type="text" name="co_start_date_free" id="popup_co_start_date_free" value="{$vlu.co_start_date}" class="date" /></td>
                <th><label class="required help" for="popup_co_end_date_free">{t}Fine{/t}</th>
                <td><input type="text" name="co_end_date_free" id="popup_co_end_date_free" value="{$vlu.co_end_date}" class="date" /></td>
                <th><label class="required help" for="popup_co_value_free">{if $vlu.em_data.em_is_production == 'T'}{t}Produzione{/t}{else}{t}Consumo{/t}{/if}</th>
                <td><input type="text" name="co_value_free" id="popup_co_value_free" value="{$vlu.co_value}" class="calc_value float" style="width: 60px" /> {$vlu.em_data.udm_name}</td>
                <th><label class="help" for="popup_co_bill_free">{if $vlu.em_data.em_is_production == 'T'}{t}Ricavo{/t}{else}{t}Spesa{/t}{/if}</th>
                <td><input type="text" name="co_bill_free" id="popup_co_bill_free" value="{$vlu.co_bill}" class="calc_value float" data-dec="2" style="width: 60px" /> €</td>
                <th><label class="help" for="popup_co_energy_costs_free">{t}Costo unitario{/t}</th>
                <td><input type="text" name="co_energy_costs_free" id="popup_co_energy_costs_free" value="{$vlu.co_energy_costs}" class="float readonly" data-dec="2" style="width: 60px" /> €/{$vlu.em_data.udm_name}</td>
            </tr>    
        </table>
    </div>
    {if $act == 'add'}
        <div id="kind_month">
            <table width="100%" class="form">
                {foreach from=$vars.months item=mm}
                    <tr>
                        <th><label class="required" for="popup_co_start_date_month_{$mm}">{t}Inizio{/t}</th>
                        <td><input type="text" name="co_start_date_month[]" id="popup_co_start_date_month_{$mm}" class="readonly" style="width: 75px" /></td>
                        <th><label class="required" for="popup_co_end_date_month_{$mm}">{t}Fine{/t}</th>
                        <td><input type="text" name="co_end_date_month[]" id="popup_co_end_date_month_{$mm}" class="readonly" style="width: 75px" /></td>
                        <th><label class="required" for="popup_co_value_month_{$mm}">{if $vlu.em_data.em_is_production == 'T'}{t}Produzione{/t}{else}{t}Consumo{/t}{/if}</th>
                        <td><input type="text" name="co_value_month[]" id="popup_co_value_month_{$mm}" class="float calc_value" style="width: 60px" /> {$vlu.em_data.udm_name}</td>
                        <th><label class="required" for="popup_co_bill_month_{$mm}">{if $vlu.em_data.em_is_production == 'T'}{t}Ricavo{/t}{else}{t}Spesa{/t}{/if}</th>
                        <td><input type="text" name="co_bill_month[]" id="popup_co_bill_month_{$mm}" class="float calc_value" data-dec="2" style="width: 60px" /> €</td>
                        <th><label for="popup_co_energy_costs_month_{$mm}">{t}Costo unitario{/t}</th>
                        <td><input type="text" name="co_energy_costs_month[]" id="popup_co_energy_costs_month_{$mm}" class="float readonly" data-dec="2" style="width: 60px" /> €/{$vlu.em_data.udm_name}</td>
                    </tr>   
                {/foreach}    
            </table>
        </div>

        <div id="kind_year">
            <table width="100%" class="form">
                <tr>
                    <th><label class="required" for="popup_co_start_date_year">{t}Inizio{/t}</th>
                    <td><input type="text" name="co_start_date_year" id="popup_co_start_date_year" class="readonly" style="width: 75px" /></td>
                    <th><label class="required" for="popup_co_end_date_year">{t}Fine{/t}</th>
                    <td><input type="text" name="co_end_date_year" id="popup_co_end_date_year" class="readonly" style="width: 75px" /></td>
                    <th><label class="required" for="popup_co_value_year">{if $vlu.em_data.em_is_production == 'T'}{t}Produzione{/t}{else}{t}Consumo{/t}{/if}</th>
                    <td><input type="text" name="co_value_year" id="popup_co_value_year" class="float calc_value" style="width: 60px" /> {$vlu.em_data.udm_name}</td>
                    <th><label class="required" for="popup_co_bill_year">{if $vlu.em_data.em_is_production == 'T'}{t}Ricavo{/t}{else}{t}Spesa{/t}{/if}</th>
                    <td><input type="text" name="co_bill_year" id="popup_co_bill_year" class="float calc_value" data-dec="2" style="width: 60px" /> €</td>
                    <th><label for="popup_co_energy_costs_year">{t}Costo unitario{/t}</th>
                    <td><input type="text" name="co_energy_costs_year" id="popup_co_energy_costs_year" class="float readonly" data-dec="2" style="width: 60px" /> €/{$vlu.em_data.udm_name}</td>
                </tr>    
            </table>
        </div>
    {/if}
    {if $act<>'add'}<div>{include file="record_change.tpl"}</div>{/if}
    {if $vlu.im_id<>''}<div style="padding-left: 20px"><i>{t}Questo consumo è stato importato automaticamente{/t}</i></div>{/if}

    {if $act == 'show'}
        <input type="button" id="popup_btnCancel" name="popupBtnCancel"  value="{t}Chiudi{/t}" style="width:120px;height:25px;" />
    {else}
        <input type="button" id="popup_btnSave" name="popupBtnSave"  value="{t}Salva{/t}" style="width:120px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="button" id="popup_btnCancel" name="popupBtnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />
    {/if}
</form>


{include file="footer_ajax.tpl"}