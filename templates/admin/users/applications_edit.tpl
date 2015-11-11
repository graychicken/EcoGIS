{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

{literal}
<script type="text/javascript" language="javascript">
    
    function showList() {
    
        document.location = 'applications_list.php';
    }
    
    function do_edit() {
    
        document.location = 'applications_edit.php?act=mod&cod=' + document.modForm.old_app_code.value;
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

    function submitForm() {

        setTimeout("xajaxCallFaild()", 10000);
        disableControls(true);
        xajax_submitForm(getAllValues(), "formCheckDone", "formCheckError");
    }

    
</script>
{/literal}

<h3>
  {if $act == 'add'}
    {if !isset($txt.add_app)}{t}Inserisci applicativo{/t}{else}{$txt.add_app}{/if}
  {elseif $act == 'shw'}
    {if !isset($txt.show_app)}{t}Visualizza applicativo{/t}{else}{$txt.show_app}{/if}
  {else}
    {if !isset($txt.mod_app)}{t}Modifica applicativo{/t}{else}{$txt.mod_app}{/if}
  {/if}
</h3>

<form name="modForm" method="post" action="applications_edit.php">
<input type="hidden" name="act" value="{$act}" />
<input type="hidden" name="old_app_code" value="{$vlu.app_code}" />

  <table class="form">
    <tr>
      <th>{if !isset($txt.Codice)}{t}Codice{/t}{else}{$txt.Codice}{/if}</th>
      <td><input type="text" name="app_code" value="{$vlu.app_code}" style="width:150px;" {$view_style} /></td>
	</tr>
	<tr>
      <th>{if !isset($txt.Nome)}{t}Nome{/t}{else}{$txt.Nome}{/if}</th>
      <td><input type="text" name="app_name" value="{$vlu.app_name}" style="width:450px;" {$view_style} /></td>
	</tr>
    
    
    <tr>
      <th>IP (NOT IMPLEMENTED)</th>
      <td><textarea name="app_ip_addr" style="width:450px; height:150px;" {$view_style}>{$app_ip_addr}</textarea></td>
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
<script type="text/javascript" language="JavaScript">
  
    if (document.modForm.app_code && !document.modForm.app_code.readOnly) {
        document.modForm.app_code.focus();
        document.modForm.app_code.select();
    }    
  
</script>
{/literal}

</body>
</html>