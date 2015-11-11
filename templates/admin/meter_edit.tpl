{include file="header_ajax.tpl"}
{literal}
<script language="JavaScript" type="text/javascript">
$(document).ready(function() {
    //$('#meter_form .required').append('<em>*</em>');
    $('#popup_modform .help').bind('click', function() { showR3Help('meter', this) });
    $('#popup_btnSave').bind('click', function() {
        submitFormDataMeter();
    });
    $('#popup_em_is_production').bind('change', function() { updateMeterType() });
    $('#popup_us_id').bind('change', function() { updateUtilitySupplier() });


    $('#popup_btnCancel').bind('click', function() { closeR3Dialog() });
    $('#popup_es_id').bind('change', function() { updateEnergySourceFromMeter() });
    if ($('#popup_act').val() == 'show') {
        setupShowMode('popup');  // Setup the show mode
        setupInputFormat('#popup_modform', false);
    } else {
        setupInputFormat('#popup_modform');
        setupRequired('#popup_modform');
        setupReadOnly('#popup_modform');
    }

    updateMeterType(true);
    setUtilityProduct();
    if ($('#popup_act').val() != 'add' && 
        $('#popup_em_is_production').val() == 'F' &&
        ($('#popup_consumptions').val() > 0 ||
        $('#popup_devices').val() > 0)) { 
        var hasUtilitySupplier = $('#popup_us_id').val() > 0;
        $('#popup_utility_supplier_row').toggle(hasUtilitySupplier);
        $('#popup_energy_source_row').toggle(!hasUtilitySupplier);
    }
    
    $('#popup_modform').toggle(true);  // Show the form
    $('#popup_em_serial').focus();

});
</script>
{/literal}

<form name="modform" id="popup_modform" action="edit.php?method=submitFormData" method="post" style="display:none">
  <input type="hidden" name="on" id="popup_on" value="{$object_name}" />
  <input type="hidden" name="act" id="popup_act" value="{$act}" />
  <input type="hidden" name="id" id="popup_em_id" value="{$vlu.em_id}" />
  {* <input type="hidden" name="bu_id" id="popup_bu_id" value="{$vlu.bu_id}" /> *}
  <input type="hidden" name="consumptions" id="popup_consumptions" value="{$vlu.consumptions}" />
  <input type="hidden" name="devices" id="popup_devices" value="{$vlu.devices}" />
  {foreach from=$vars key=key item=val}
  <input type="hidden" name="{$key}" id="popup_{$key}" value="{$val}" />
  {/foreach}

  <table class="form">
  <tr>
    <th><label class="help required" for="popup_em_serial">{if $vars.kind=='ELECTRICITY'}{t}POD{/t}{else}{t}Matricola{/t}{/if}:</label></th>
    <td colspan="3"><input type="text" name="em_serial" id="popup_em_serial" value="{$vlu.em_serial}" style="width: 365px;" /></td>
  </tr>

  <tr>
    <th><label class="help" for="popup_em_descr_1">{t}Descrizione{/t}{if $NUM_LANGUAGES>1}{$LANG_NAME_SHORT_FMT_1}{/if}:</label></th>
    <td colspan="3"><input type="text" name="em_descr_1" id="popup_em_descr_1" value="{$vlu.em_descr_1}" style="width: 365px;" /></td>
  </tr>
  {if $NUM_LANGUAGES>1}
  <tr>
    <th><label class="help" for="popup_em_descr_2">{t}Descrizione{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
    <td colspan="3"><input type="text" name="em_descr_2" id="popup_em_descr_2" value="{$vlu.em_descr_2}" style="width: 365px;" /></td>
  </tr>
  {/if}
  <tr {if $vars.kind=='WATER'}style="display: none"{/if}>
    <th><label class="help required" for="popup_em_is_production">{t}Tipo contatore{/t}:</label></th>
    <input type="hidden" name="em_is_production" id="popup_em_is_production_dummy" value="{$vlu.em_is_production}" />
    <td colspan="3"><select name="em_is_production" id="popup_em_is_production" style="width: 150px" {if $vlu.consumptions<>0 || $vlu.devices<>0}disabled{/if} {* if $act<>'add'}disabled{/if *}>
        {html_options options=$lkp.em_production_values selected=$vlu.em_is_production}
        </select>
    </td>
  </tr>
  {if $lkp.us_values|@count > 0}
  <tr id="popup_utility_supplier_row">
    <th><label class="help" for="popup_us_id">{t}Fornitore{/t}:</label></th>
    <td><select name="us_id" id="popup_us_id" style="width: 150px" {if $vlu.consumptions<>0 || $vlu.devices<>0 || $vlu.es_id<>''}disabled{/if} {* if $act<>'add'}disabled{/if *}>
        <option value="">{t}-- Standard --{/t}</option>
        {html_options options=$lkp.us_values selected=$vlu.us_id}
        </select>
    </td>
    <th id="popup_up_id_label_lbl"><label class="help" id="popup_up_id_label" for="popup_up_id">{t}Contratto{/t}:</label></th>
    <td id="popup_up_id_label_cbx">
        <input type="hidden" name="up_id" id="up_id_default" value="{$vlu.udm_id}" />
        <select name="up_id_dummy" id="popup_up_id" style="width: 150px" {if $vlu.consumptions<>0 || $vlu.devices<>0 || $vlu.es_id<>'' || $lkp.up_values|@count<=1}disabled{/if} {* if $act<>'add'}disabled{/if *}>
        {if $lkp.up_values|@count > 1}<option value="">{t}-- Selezionare --{/t}</option>{/if}
        {html_options options=$lkp.up_values selected=$vlu.up_id}
        </select>
    </td>
  </tr>
  {/if}

  {if $lkp.es_values|@count > 0}
  <tr id="popup_energy_source_row">
    <th><label class="help required" for="popup_es_id">{t}Alimentazione{/t}:</label></th>
    <td colspan="3"><input type="hidden" name="es_id" id="es_id_default" value="{$vlu.es_id}" />
        <select name="es_id" id="popup_es_id" style="width: 150px" {if $vlu.consumptions<>0 || $vlu.us_id<>''}disabled{/if} {* if $act<>'add'}disabled{/if *}>
        {if $lkp.es_values|@count > 1 || $vlu.us_id <> ''}<option value="">{t}-- Selezionare --{/t}</option>{/if}
        {html_options options=$lkp.es_values selected=$vlu.es_id}
        </select>
        <input type="hidden" name="udm_id" id="udm_id_default" value="{$vlu.udm_id}" />
        <select name="udm_id" id="popup_udm_id" style="width: 150px" {if $vlu.consumptions<>0 || $vlu.us_id<>'' || $lkp.udm_values|@count < 1}disabled{/if}>
        {if $lkp.udm_values|@count <> 1}<option value="">{t}-- Selezionare --{/t}</option>{/if}
        {html_options options=$lkp.udm_values selected=$vlu.udm_id}
      </select></td>
  </tr>
  {/if}
  {if $act<>'add'}<tr><td colspan="6">{include file="record_change.tpl"}</td></tr>{/if}
  {if $vlu.im_id<>''}<tr><td colspan="6" style="padding-left: 20px"><i>{t}Questo contatore è stato importato automaticamente{/t}</i></td></tr>{/if}
  
  </table>
  <br />
  {if $act == 'show'}
  <input type="button" id="popup_btnCancel" name="popupBtnCancel"  value="{t}Chiudi{/t}" style="width:120px;height:25px;" />
  {else}
  <input type="button" id="popup_btnSave" name="popupBtnSave"  value="{t}Salva{/t}" style="width:120px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" id="popup_btnCancel" name="popupBtnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />
  {/if}
</form>
{include file="footer_ajax.tpl"}