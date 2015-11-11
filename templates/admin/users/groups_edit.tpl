{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

<script type="text/javascript" language="javascript">
    var ajax_select_privileges;
    var ajax_select_groups;

    // Ajax privileges handler
    window.onload = function() {ldelim}
        ajax_select_privileges = new AjaxSelect('privileges');
        ajax_select_groups = new AjaxSelect('groups');
    {rdelim}
    
    function showList() {ldelim}
    
        document.location = 'groups_list.php';
    {rdelim}
    
    function do_edit() {ldelim}
    
        document.location = 'groups_edit.php?act=mod&code=' + document.modForm.old_app_code.value + '&name=' + document.modForm.old_gr_name.value;
    {rdelim}
    
    function disableControls(status) {ldelim}
    
        document.modForm.btnSave.disabled = status;
        document.modForm.btnCancel.disabled = status;
    {rdelim}
    
    function xajaxCallFaild() {ldelim}
        
        //SS: rimettere questo alert! alert(js_html_entity_decode('SS: Timeout sel server. Riprovare!'));
        //alert("SS: Si e' verificato un errore di comunicazione col server. Riprovare a salvare i dati. Se il problema persiste contattare il supporto tecnico!");
        disableControls(false);
    {rdelim}
    
    function formCheckDone() {ldelim}

        showList();
    {rdelim}
    
    function formCheckError(text, element_name) {ldelim}

        //SS: rimettere questo alert! alert(js_html_entity_decode(text));
        alert(text);
        disableControls(false);
        if (element_name) {ldelim}
            e = document.getElementsByName(element_name);
            if (e && e[0] && !e[0].readOnly) {ldelim}
                e[0].focus();
                e[0].select();
            {rdelim}
        {rdelim}
    {rdelim}

    function submitForm() {ldelim}

        document.modForm.selectedPrivileges.value = getAllSelected(document.modForm.privileges);
        setTimeout("xajaxCallFaild()", 10000);
        disableControls(true);
        xajax_submitForm(getAllValues(), "formCheckDone", "formCheckError");
    {rdelim}
    
    function getAllSelected(theSelect) {ldelim}

        elems = new Array();
        selLength = theSelect.length;
        for (i = 0; i < selLength; i++) {ldelim}
            if (theSelect.options[i].selected)
                elems.push(theSelect.options[i].value);
        {rdelim}
        return elems;
    {rdelim}
    
    function applicationChange(showWarning) {ldelim}
      
        if (document.modForm.last_app_code.value != '') {ldelim}
            if (!confirm("{if !isset($txt.confirm)}{t}Sei sicuro, di voler cambiare l'applicativo?{/t}{else}{$txt.confirm}{/if}")) {ldelim}
                /* return the old value */
                for (i = document.modForm.app_code.length - 1; i >= 0; i--) {ldelim}
                    if (document.modForm.app_code.options[i].value == document.modForm.last_app_code.value) {ldelim}
                        document.modForm.app_code.selectedIndex = i;
                        break;
                    {rdelim}
                {rdelim}
                return false;
            {rdelim}
        {rdelim}
        document.modForm.last_app_code.value = document.modForm.app_code.value;

        
        var value = document.modForm.app_code.value;
	
       	// - load Privileges
        ajax_select_privileges.startLoading('privileges', value);
        ajax_select_groups.startLoading('groups', value);
    
    {rdelim}
    
    function doneLoadingGroups(tot) {ldelim}
      var imgCopy = new Image();
      var imgAppend = new Image();
      var groups_val = document.modForm.groups.value;
      
      if (tot > 1 && groups_val != '') {ldelim}
        imgCopy.src = '{$smarty.const.R3_APP_URL}images/copy_on.png';
        imgAppend.src = '{$smarty.const.R3_APP_URL}images/append_on.png';
        
        document.modForm.btnCopy.disabled = false;
        document.modForm.btnAppend.disabled = false;
      {rdelim} else {ldelim}
        imgCopy.src = '{$smarty.const.R3_APP_URL}images/copy_off.png';
        imgAppend.src = '{$smarty.const.R3_APP_URL}images/append_off.png';
        
        document.modForm.btnCopy.disabled = true;
        document.modForm.btnAppend.disabled = true;
        
        if (tot == 1)
          ajax_select_groups.disableInput();
      {rdelim}
      
      document.getElementById('imgCopy').src = imgCopy.src;
      document.getElementById('imgAppend').src = imgAppend.src;
    {rdelim}
    
    function do_copy_group() {ldelim}
      var app = document.modForm.app_code.value;
      var group1 = document.modForm.gr_name_org.value;
      var group2 = document.modForm.groups.value;
      var groups_text = document.modForm.groups.options[document.modForm.groups.selectedIndex].text;
      if (confirm("{if !isset($txt.confirm)}{t}Sei sicuro, di voler copiare i privilegi del gruppo{/t}{else}{$txt.confirm}{/if} "+groups_text+"?"))
        xajax.call('copy_group', [app, group1, group2]);
    {rdelim}
    
    function do_append_group() {ldelim}
      var app = document.modForm.app_code.value;
      var group1 = document.modForm.gr_name_org.value;
      var group2 = document.modForm.groups.value;
      var groups_text = document.modForm.groups.options[document.modForm.groups.selectedIndex].text;
      if (confirm("{if !isset($txt.confirm)}{t}Sei sicuro, di voler aggiungere i privilegi del gruppo{/t}{else}{$txt.confirm}{/if} "+groups_text+"?"))
        xajax.call('append_group', [app, group1, group2]);
    {rdelim}
    
    function clearPrivileges() {ldelim}
      for(var i=0; i<document.modForm.privileges.options.length; i++) {ldelim}
        document.modForm.privileges.options[i].selected = false;
      {rdelim}
    {rdelim}
    
    function addPrivileges(ac_verb, ac_name) {ldelim}
      for(var i=0; i<document.modForm.privileges.options.length; i++) {ldelim}
        if (document.modForm.privileges.options[i].value == ac_verb+'|'+ac_name)
          document.modForm.privileges.options[i].selected = true;
      {rdelim}
    {rdelim}

    
</script>

<h3>
  {if $act == 'add'}
    {if !isset($txt.add_group)}{t}Inserisci gruppo{/t}{else}{$txt.add_group}{/if}
  {elseif $act == 'shw'}
    {if !isset($txt.show_group)}{t}Visualizza gruppo{/t}{else}{$txt.show_group}{/if}
  {else}
    {if !isset($txt.mod_group)}{t}Modifica gruppo{/t}{else}{$txt.mod_group}{/if}
  {/if}
</h3>

<form name="modForm" method="post" action="groups_edit.php">
<input type="hidden" name="act" value="{$act}" />
<input type="hidden" name="old_app_code" value="{$vlu.app_code}" />
<input type="hidden" name="old_gr_name" value="{$vlu.gr_name}" />
<input type="hidden" name="last_app_code" value="{$vlu.app_code}" /> {* SS: Serve per ricordarmi l'ultimo valore del menù a tendina *}
<input type="hidden" name="selectedPrivileges" value="" />

<div style="background-color:#cccccc;">
{if !isset($hdr.action)}{t}Azione{/t}{else}{$hdr.action}{/if}: 
<select id="groups" name="groups" disabled onchange="doneLoadingGroups(this.options.length);">
  <option value="">{if !isset($txt.dd_select)}{t}-- selezionare --{/t}{else}{$txt.dd_select}{/if}</option>
</select>
<button type="button" name="btnCopy" disabled onclick="do_copy_group();">
  {* TODO AL: Hint Copia *}
  <img id="imgCopy" src="{$smarty.const.R3_APP_URL}images/copy_off.png" />
</button>
<button type="button" name="btnAppend" disabled onclick="do_append_group();">
  {* TODO AL: Hint Aggiungi *}
  <img id="imgAppend" src="{$smarty.const.R3_APP_URL}images/append_off.png" />
</button>
</div>

  <table class="form">
    <tr>
      <th>{if !isset($txt.Applicazione)}{t}Applicativo{/t}{else}{$txt.Applicazione}{/if}</th>
      <td>
	    <select name="app_code" id="app_code" {if $act == 'show'} disabled {/if} {$view_style} onChange="applicationChange()">
          {if $vlu.app_code == ''}<option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>{/if}
          {html_options options=$app_code_list selected=$vlu.app_code}
		</select>
	  </td>
	</tr>
	<tr>
	  <th>{if !isset($txt.Dominio)}{t}Dominio{/t}{else}{$txt.Dominio}{/if}</th>
	  <td>
        <select name="dn_name" {if $act == 'show'} disabled {/if} {$view_style}>
          <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
          {html_options options=$dn_name_list selected=$vlu.dn_name}
        </select>
	  </td>
	</tr>
	<tr>
      <th>{if !isset($txt.Nome)}{t}Nome{/t}{else}{$txt.Nome}{/if}</th>
      <td>
        <input type="text" name="gr_name" value="{$vlu.gr_name}" style="width:450px;" {$view_style} />
        <input type="hidden" name="gr_name_org" value="{$vlu.gr_name}" />
      </td>
	</tr>
	<tr>
      <th>{if !isset($txt.Descrizione)}{t}Descrizione{/t}{else}{$txt.Descrizione}{/if}</th>
      <td><textarea name="gr_descr" style="width:450px;height:100px;" {$view_style}>{$vlu.gr_descr}</textarea></td>
	</tr>
	<tr>
	  <th>{if !isset($txt.Privilegi)}{t}Privilegi{/t}{else}{$txt.Privilegi}{/if}</th>
	  <td>
        <select name="privileges" id="privileges" {if $act == 'show'} xdisabled {/if} multiple style="width:450px;height:200px;" {$view_style}>
          {html_options options=$privileges_list selected=$vlu.perm}
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
<script type="text/javascript" language="JavaScript">
  
    if (document.modForm.app_code && !document.modForm.app_code.disabled) {
        document.modForm.app_code.focus();
    } else if (document.modForm.dn_name && !document.modForm.dn_name.disabled) {
        document.modForm.dn_name.focus();
    } else if (document.modForm.gr_name && !document.modForm.gr_name.readOnly) {
        document.modForm.gr_name.focus();
        document.modForm.gr_name.select();
    }
  
</script>
{/literal}

</body>
</html>