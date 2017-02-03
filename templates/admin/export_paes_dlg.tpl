{literal}
<script language="JavaScript" type="text/javascript">
$(document).ready(function() {
    $('#popupBtnExportPAES').bind('click', function() { exportPAES($('#paes_id').val(), $('#paes_format').val()) });
    $('#popupBtnCancel').bind('click', function() { closeR3Dialog() });
    $('#paes_format').focus();
    $("#progressbar").progressbar({value: 0});
});
</script>
{/literal}
<form name="popup_modform" id="popup_modform">
  <input type="hidden" name="paes_id" id="paes_id" value="{$vlu.id}" />

  <table class="form">
  <tr {if $lkp.formats|@count <=1}style="display:none"{/if}>
    <th><label class="help" for="paes_format">{t}Formato{/t}:</label></th>
    <td><select name="paes_format" id="paes_format" >
    {html_options options=$lkp.formats selected=$vlu.languageId}
    </select></td>
  </tr>
  <tr>
  <td colspan="2">{t escape=no}<b>NOTA</b>: La generazione del template potrà richiedere fino ad un minuto di calcolo{/t}</label></td>
  </tr>
  {if $vars.save == 'T'}
  <tr>
    <td colspan="2">{t escape=no}<b>NOTA</b>: Le eventuali modifiche effetuate sulla scheda saranno salvate{/t}</label></td>
  </tr>
  {/if}
  </table>
  
  <br />
  <div id="progressbar_container" style="height:40px; width: 280px; display: none" class="ui-widget-default">
    <div id="progressbar" style="height: 10px; width: 450px"></div>
    <div id="progress_status" style="width: 450px; margin: 5px"></div>
  </div>		
  <br />  
  <input type="button" id="popupBtnExportPAES" name="popupBtnExportPAES"  value="{if $vars.save == 'T'}{t}Salva ed esporta{/t}{else}{t}Esporta{/t}{/if}" style="width:120px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" id="popupBtnCancel" name="popupBtnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />
</form>