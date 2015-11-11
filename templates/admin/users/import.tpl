{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{literal}
<script type="text/javascript" language="javascript">

var errMissingDomain = "{/literal}{t}Immettere un dominio{/t}{literal}";
var errMissingApplication = "{/literal}{t}Immettere un'applicazione{/t}{literal}";
var errMissingFile = "{/literal}{t}Immettere un file in formato xml da caricare{/t}{literal}";

function disableControls(status) {
    
    document.modForm.fltdn_name.disabled = status;
    document.modForm.fltapp_code.disabled = status;
    document.modForm.file.disabled = status;
    document.modForm.btnImport.disabled = status;
}
    
function submitForm() {

    if (document.modForm.fltdn_name.value == '') {
        alert(errMissingDomain);
        document.modForm.fltdn_name.focus();
    } else if (document.modForm.fltapp_code.value == '') {
        alert(errMissingApplication);
        document.modForm.fltapp_code.focus();
    } else if (document.modForm.file.value == '') {
        alert(errMissingFile);
        document.modForm.file.focus();    
    } else {
        document.modForm.submit();
        disableControls(true);
    }
}

</script>
{/literal}

<h3>{if !isset($txt.Import)}{t}Import{/t}{else}{$txt.Import}{/if}</h3>

<form name="modForm" method="post" enctype="multipart/form-data" action="import.php">
<input type="hidden" name="act" value="import">

  <table class="form" border=1>
  <tr>
  <th>{if !isset($txt.Dominio)}{t}Dominio{/t}{else}{$txt.Dominio}{/if}</th>
      <td>
      <select name="fltdn_name" id="fltdn_name" style="width: 140px;" {if !$USER_CAN_SHOW_DOMAIN && !$USER_CAN_SHOW_ALL_DOMAINS}disabled{/if}>
        {if $USER_CAN_SHOW_ALL_DOMAINS}
		<option value="">{if !isset($txt.select)}{t}-- Selezionare --{/t}{else}{$txt.select}{/if}</option>
        {/if}
        {html_options options=$dn_name_list selected=$vlu.fltdn_name}
      </select>
      </td>
	
      <th>{if !isset($txt.Applicazione)}{t}Applicativo{/t}{else}{$txt.Applicazione}{/if}</th>
      <td>
      <select name="fltapp_code" id="fltapp_code" style="width: 140px;" {if !$USER_CAN_SHOW_APPLICATION && !$USER_CAN_SHOW_ALL_APPLICATIONS}disabled{/if}>
        {if $USER_CAN_SHOW_ALL_APPLICATIONS}
		<option value="">{if !isset($txt.select)}{t}-- Selezionare --{/t}{else}{$txt.select}{/if}</option>
        {/if}
        {html_options options=$app_code_list selected=$vlu.fltapp_code}
      </select>
      </td>
    </tr>  
    
    <tr>
      <th>{if !isset($txt.Config)}{t}File{/t}{else}{$txt.Config}{/if}</th>
      <td colspan="3"><input type="file" name="file" style="width: 350px;"></td>
	</tr>
    {if $import_result.acnames.tot > 0 || $import_result.acnames.skip > 0 ||
        $import_result.groups.tot > 0 || $import_result.groups.skip || 
        $import_result.configs.tot > 0 || $import_result.configs.skip > 0}
    <tr>
      <th>{if !isset($txt.Config)}{t}Esito import{/t}{else}{$txt.Config}{/if}</th>
      <td colspan="3">
      {if $import_result.acnames.tot > 0 || $import_result.acnames.skip > 0}
      {t}Access control list importati: {/t}{$import_result.acnames.tot}, {t}ignorati{/t}: {$import_result.acnames.skip}<br />
      {/if}
      
      {if $import_result.groups.tot > 0 || $import_result.groups.skip > 0}
      {t}Access control list importati: {/t}{$import_result.groups.tot}, {t}ignorati{/t}: {$import_result.groups.skip}<br />
      {/if}
      
      {if $import_result.configs.tot > 0 || $import_result.configs.skip > 0}
      {t}Configurazioni importate: {/t}{$import_result.configs.tot}, {t}ignorate{/t}: {$import_result.configs.skip}<br />
      {/if}
      </td>
	</tr>
    {/if}
  </table>
  <br>
  <input type="button" name="btnImport"   value="{if !isset($btn.save)}{t}Importa{/t}{else}{$btn.save}{/if}" onclick="submitForm();" style="height:25px;width:70px;" />
</form>

{* if $FooterName != ''}
  {include file="$FooterName.tpl"}
{else}
  {include_php file="footer.php"}
{/if *}