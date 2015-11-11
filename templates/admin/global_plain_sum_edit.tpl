{include file="header_ajax.tpl"}
{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#popup_modform .help').bind('click', function () {
                showR3Help('global_plain', this)
            });
            $('#popup_btnSave').bind('click', function () {
                submitData('#popup_modform');
            });
            $('#popup_btnCancel').bind('click', function () {
                hideR3Help();
                closeR3Dialog()
            });
            setupInputFormat('#popup_modform');
            setupRequired('#popup_modform');
            setupReadOnly('#popup_modform');
            $('#popup_modform').toggle(true);  // Show the form
            $('#popup_gps_expected_energy_saving').focus();
        });
    </script>
{/literal}
<form name="modform" id="popup_modform" action="edit.php?method=submitFormData" method="post" style="display:none">
    <input type="hidden" name="on" id="popup_on" value="{$object_name}" />
    <input type="hidden" name="act" id="popup_act" value="{$act}">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="popup_{$key}" value="{$val}" />
    {/foreach}
    <table class="form">
        <tr>
            <th><label class="help" for="popup_gc_name">{t}Macro settore{/t}:</label></th>
            <td><input type="text" name="gc_name" id="popup_gc_name" value="{$vlu.gc_name}" style="width: 300px" class="readonly"></td>
        </tr>
        <tr>
            <th><label class="help" for="popup_gps_expected_energy_saving">{t}Obiettivo di risparmio energetico previsto{/t}:</label></th>
            <td><input type="text" class="float" data-dec="2" name="gps_expected_energy_saving" id="popup_gps_expected_energy_saving" value="{$vlu.gps_expected_energy_saving}" maxlength="20" style="width:100px;" /> MWh nel 2020</td>
        </tr>
        <tr>
            <th><label class="help" for="popup_gps_expected_renewable_energy_production">{t}Obiettivo di produzione locale di energia rinnovabile{/t}:</label></th>
            <td><input type="text" class="float" data-dec="2" name="gps_expected_renewable_energy_production" id="popup_gps_expected_renewable_energy_production" value="{$vlu.gps_expected_renewable_energy_production}" maxlength="20" style="width:100px;" /> MWh nel 2020</td>
        </tr>
        <tr>
            <th><label class="help" for="popup_gps_expected_co2_reduction">{t escape=no}Obiettivo di riduzione di CO<sub>2</sub>{/t}:</label></th>
            <td><input type="text" class="float" data-dec="2" name="gps_expected_co2_reduction" id="popup_gps_expected_co2_reduction" value="{$vlu.gps_expected_co2_reduction}" maxlength="20" style="width:100px;" /> MWh nel 2020</td>
        </tr>
    </table>
    <br />
    <br />
    <input type="button" id="popup_btnSave" name="popupBtnSave"  value="{t}Salva{/t}" style="width:120px;height:25px;" />
    <input type="button" id="popup_btnCancel" name="popupBtnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />
</form>
{include file="footer_ajax.tpl"}