{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

{literal}
<script type="text/javascript" language="javascript">
    
    function showList() {
    
        document.location = 'domains_list.php';
    }
    
    function do_edit() {
    
        document.location = 'domains_edit.php?act=mod&name=' + document.modForm.old_do_name.value;
    }
    
    function disableControls(status) {
    
        document.modForm.btnSave.disabled = status;
        document.modForm.btnCancel.disabled = status;
    }
    
    function xajaxCallFaild() {
        
        //SS: rimettere questo alert! alert(js_html_entity_decode('SS: Timeout sel server. Riprovare!'));
        //alert("SS: Si e' verificato un errore di comunicazione col server. Riprovare a salvare i dati. Se il problema persiste contattare il supporto tecnico!");
        disableControls(false);
    }
    
    function formCheckDone() {

        showList();        
    }
    
    function formCheckError(text, element_name) {

        //SS: rimettere questo alert! alert(js_html_entity_decode(text));
        alert(text);
        disableControls(false);
        if (element_name) {
            e = document.getElementsByName(element_name);
            if (e && e[0] && !e[0].readOnly) {
                e[0].focus();
                e[0].select();
            }  
        }
    }

    function getAllSelected(theSelect) {

        elems = new Array();
        selLength = theSelect.length;
        for (i = 0; i < selLength; i++)
        {
            if (theSelect.options[i].selected)
                elems.push(theSelect.options[i].value);
        }
        return elems;
    }

    function submitForm() {

        document.modForm.selectedApplications.value = getAllSelected(document.modForm.applications);
        setTimeout("xajaxCallFaild()", 10000);
        disableControls(true);
        xajax_submitForm(getAllValues(), "formCheckDone", "formCheckError");
    }

    
</script>
{/literal}

<h3>
  {if $act == 'add'}
    {if !isset($txt.add_domain)}{t}Inserisci dominio{/t}{else}{$txt.add_domain}{/if}
  {elseif $act == 'shw'}
    {if !isset($txt.show_domain)}{t}Visualizza dominio{/t}{else}{$txt.show_domain}{/if}
  {else}
    {if !isset($txt.mod_domain)}{t}Modifica dominio{/t}{else}{$txt.mod_domain}{/if}
  {/if}
</h3>

<form name="modForm" method="post" action="domains_edit.php">
<input type="hidden" name="act" value="{$act}" />
<input type="hidden" name="old_do_name" value="{$vlu.do_name}" />
<input type="hidden" name="selectedApplications" value="" />

  <table class="form">
	<tr>
      <th>{if !isset($txt.Nome)}{t}Nome{/t}{else}{$txt.Nome}{/if}</th>
      <td><input type="text" name="do_name" value="{$vlu.do_name}" style="width:450px;" {$view_style} /></td>
	</tr>
	<tr>
      <th>{if !isset($txt.Alias)}{t}Alias{/t}{else}{$txt.Alias}{/if}</th>
      <td><textarea name="do_alias" style="width:450px; height:50px;" {$view_style}>{$vlu.do_alias}</textarea></td>
	</tr>
	{*USING table auth.auth_settings
        <tr>
	  <th>{if !isset($txt.Kind)}{t}Tipo autenticazione{/t}{else}{$txt.Kind}{/if}</th>
	  <td>
        <select name="do_auth_type" {if $act == 'show'} disabled {$view_style} {/if} >
          {html_options options=$do_auth_type_list selected=$vlu.do_auth_type}
        </select>
	  </td>
	  
	</tr>
	<tr>
      <th>{if !isset($txt.auth_data)}{t}Dati autenticazione{/t}{else}{$txt.auth_data}{/if}</th>
      <td><textarea name="do_auth_data" style="width:450px; height:150px;" {$view_style}>{$vlu.do_auth_data}</textarea></td>
	</tr>*}
        <input type="hidden" name="do_auth_type" value="DB" />
        <input type="hidden" name="do_auth_data" value="" />        
	<tr>
	  <th>{if !isset($txt.Applicativi)}{t}Applicativi{/t}{else}{$txt.Applicativi}{/if}</th>
	  <td>
        <select name="applications" multiple style="width:350px;height:150px;" {$view_style}>
          {html_options options=$applications_list selected=$vlu.applications}
        </select>
	  </td>
	</tr>
  </table>
  <br>
  {if $act != 'show'}
    <input type="button" name="btnSave"   value="{if !isset($btn.save)}{t}Salva{/t}{else}{$btn.save}{/if}" onclick="submitForm();" style="height:25px;width:70px;" />
    <input type="button" name="btnCancel"  value="{if !isset($btn.abort)}{t}Annulla{/t}{else}{$btn.abort}{/if}"  onClick="showList();" style="height:25px;width:70px;" />
    
  {else}
    <input type="button" name="btnBack"  value="{if !isset($btn.back)}{t}Indietro{/t}{else}{$btn.back}{/if}" onClick="showList();" style="height:25px;width:70px;" />
    <input type="button" name="btnEdit"  value="{if !isset($btn.edit)}{t}Modifica{/t}{else}{$btn.edit}{/if}" onClick="do_edit();" style="height:25px;width:70px;" />
    
    
  {/if}
  
</form>

{literal}
<script>
  
    if (document.modForm.app_code && !document.modForm.app_code.readOnly) {
        document.modForm.app_code.focus();
        document.modForm.app_code.select();
    }    
  
</script>
{/literal}

</body>
</html>