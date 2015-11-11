{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

{literal}
<script type="text/javascript" language="javascript">
    
    function showList() {
    
        document.location = 'acnames_list.php';
    }
    
    function do_edit() {
    
        document.location = 'acnames_edit.php?act=mod&app_code=' + document.modForm.old_app_code.value + 
                            '&ac_verb=' + document.modForm.old_ac_verb.value + 
                            '&ac_name=' + document.modForm.old_ac_name.value;
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
    {if !isset($txt.add_acl)}{t}Inserisci privilegio{/t}{else}{$txt.add_acl}{/if}
  {elseif $act == 'show'}
    {if !isset($txt.show_acl)}{t}Visualizza privilegio{/t}{else}{$txt.show_acl}{/if}
  {else}
    {if !isset($txt.mod_acl)}{t}Modifica privilegio{/t}{else}{$txt.mod_acl}{/if}
  {/if}
</h3>

<form name="modForm" method="post" action="acnames_edit.php">
<input type="hidden" name="act" value="{$act}" />
<input type="hidden" name="old_app_code" value="{$vlu.app_code}" />
{if $app_code_list == 0}<input type="hidden" name="app_code" value="{$vlu.app_code}" />{/if}
<input type="hidden" name="old_ac_verb" value="{$vlu.ac_verb}" />
<input type="hidden" name="old_ac_name" value="{$vlu.ac_name}" />

  <table class="form">
  
  
  
        {if $app_code_list > 1}
        <tr>
	    <th>{if !isset($txt.Applicazione)}{t}Applicativo{/t}{else}{$txt.Applicazione}{/if}</th>
        
        <td>  
		  <select name="app_code" id="app_code" style="width: 140px;" {if $act == 'show'}disabled {/if} {$view_style}>
            <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option> 
            {html_options options=$app_code_list selected=$vlu.app_code}
          </select>
	    </td>
        </tr>    
        {/if}
    <tr>
        <th>{t}Tipo{/t}</th>
        <td><select name="ac_type" id="ac_type" style="width: 140px;" {if $act == 'show'}disabled {/if} {$view_style}>
            {html_options options=$ac_type_list selected=$vlu.ac_type}
        </select></td>
    </tr>
    <tr>
      <th>{if !isset($txt.Verbo)}{t}Verbo{/t}{else}{$txt.Verbo}{/if}</th>
      <td><input type="text" name="ac_verb" value="{$vlu.ac_verb}" style="width:450px;" {$view_style} /></td>
	</tr>
	<tr>
      <th>{if !isset($txt.Oggetto)}{t}Oggetto{/t}{else}{$txt.Oggetto}{/if}</th>
      <td><input type="text" name="ac_name" value="{$vlu.ac_name}" style="width:450px;" {$view_style} /></td>
	</tr>
	<tr>
      <th>{if !isset($txt.Descrizione)}{t}Descrizione{/t}{else}{$txt.Descrizione}{/if}</th>
      <td><textarea name="ac_descr" style="width:450px;height:150px;" {$view_style}>{$vlu.ac_descr}</textarea></td>
	</tr>
	<tr>
      <th>{if !isset($txt.Ordinamento)}{t}Ordinamento{/t}{else}{$txt.Ordinamento}{/if}</th>
      <td><input type="text" name="ac_order" value="{$vlu.ac_order}" style="width:250px;" {$view_style} /></td>
	</tr>
    <tr>
	  {if $act != 'show'}
      <th><input type="checkbox" name="ac_active" id="ac_active" value="T" {if $vlu.ac_active == 'T'} checked {/if} /></th>
	  {else}
      <th><input type="checkbox" name="ac_active" id="ac_active" disabled value="T" {if $vlu.ac_active == 'T'} checked {/if} /></th>
	  {/if}
      <td><label for="ac_active">{if !isset($txt.Attivo)}{t}Attivo{/t}{else}{$txt.Attivo}{/if}</label></td>
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
    if (document.modForm.app_code && !document.modForm.app_code.disabled && document.modForm.app_code.value == '') {
        document.modForm.app_code.focus();
    } else if (document.modForm.ac_verb && !document.modForm.ac_verb.readOnly) {
        document.modForm.ac_verb.focus();
        document.modForm.ac_verb.select();
    }
  
</script>
{/literal}

</body>
</html>