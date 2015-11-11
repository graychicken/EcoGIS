{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

<script type="text/javascript" language="javascript">
    
    var xajaxTimer = null;
    
    function showList() {ldelim}
    
        document.location = 'config_list.php';
    {rdelim}
    
    function disableControls(status) {ldelim}
    
        document.modForm.btnSave.disabled = status;
        document.modForm.btnCancel.disabled = status;
    {rdelim}
    
    function xajaxCallFaild() {ldelim}
        
        alert(js_html_entity_decode('{if !isset($txt.timeout_server)}{t}Timeout del server. Riprovare!{/t}{else}{$txt.timeout_server}{/if}'));
        disableControls(false);
    {rdelim}
    
    function formCheckDone() {ldelim}

        clearTimeout(xajaxTimer);
        showList();        
    {rdelim}
    
    function formCheckError(text, element_name) {ldelim}

        clearTimeout(xajaxTimer);
        alert(js_html_entity_decode(text));
        disableControls(false);
        if (element_name) {ldelim}
            e = document.getElementsByName(element_name);
            if (e && e[0] && !e[0].readOnly) {ldelim}
                e[0].focus();
                e[0].select();
            {rdelim}
        {rdelim}
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

    function submitForm() {ldelim}

        if (document.modForm.se_private_dummy[0].checked)
            document.modForm.se_private.value = 'T';
        else
            document.modForm.se_private.value = 'F';
        xajaxTimer = setTimeout("xajaxCallFaild()", 10000);

        disableControls(true);
        xajax_submitForm(getAllValues(), "formCheckDone", "formCheckError");
    {rdelim}

    function applyType(e) {ldelim}
    
        /* extended data */
        document.getElementById('se_type_ext_STRING').style.display = 'none';
        document.getElementById('se_type_ext_ENUM').style.display = 'none';
        
        var elem = document.getElementById('se_type_ext_' + e);
        if (elem) {ldelim}
            elem.style.display = '';
        {rdelim}
        
        /* value field */
        if (e == 'TEXT' || e == 'ARRAY' || e == 'JSON') {ldelim}
            document.getElementById('se_value_normal').style.display = 'none';
            document.getElementById('se_value_TEXT').style.display = '';
        {rdelim} else {ldelim}
            document.getElementById('se_value_normal').style.display = '';
            document.getElementById('se_value_TEXT').style.display = 'none';
        {rdelim}
    {rdelim}
    
</script>

<h3>
  {if $act == 'add'}
    {if !isset($txt.add_config)}{t}Inserisci parametro di configurazione{/t}{else}{$txt.add_config}{/if}
  {elseif $act == 'shw'}
    {if !isset($txt.show_config)}{t}Visualizza parametro di configurazione{/t}{else}{$txt.show_config}{/if}
  {else}
    {if !isset($txt.mod_config)}{t}Modifica parametro di configurazione{/t}{else}{$txt.mod_config}{/if}
  {/if}
</h3>

<form name="modForm" method="post" action="domain_edit.php">
  <input type="hidden" name="act" value="{$act}" />
  <input type="hidden" name="old_dn_name" value="{$vlu.dn_name}" />
  <input type="hidden" name="old_app_code" value="{$vlu.app_code}" />
  <input type="hidden" name="old_us_login" value="{$vlu.us_login}" />
  <input type="hidden" name="old_se_section" value="{$vlu.se_section}" />
  <input type="hidden" name="old_se_param" value="{$vlu.se_param}" />
  <input type="hidden" name="se_private" value="{$vlu.se_private}" />
  
  <table class="form" border=1>
  
    {if $USER_CAN_SHOW_DOMAIN || $USER_CAN_SHOW_ALL_DOMAINS ||
        $USER_CAN_SHOW_APPLICATION || $USER_CAN_SHOW_ALL_APPLICATIONS ||
        $USER_CAN_SHOW_USER || $USER_CAN_SHOW_ALL_USERS}
    <tr>
      {if $USER_CAN_SHOW_DOMAIN || $USER_CAN_SHOW_ALL_DOMAINS}
      <th>{if !isset($txt.Dominio)}{t}Dominio{/t}{else}{$txt.Dominio}{/if}</th>
      <td>
      <select name="dn_name" id="dn_name" style="width: 140px;">
        {if $USER_CAN_SHOW_ALL_DOMAINS}
		<option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
        {/if}
        {html_options options=$dn_name_list selected=$vlu.dn_name}
      </select>
      </td>
      {/if}
	
      {if $USER_CAN_SHOW_APPLICATION || $USER_CAN_SHOW_ALL_APPLICATIONS}
      <th>{if !isset($txt.Applicazione)}{t}Applicativo{/t}{else}{$txt.Applicazione}{/if}</th>
      <td>
      <select name="app_code" id="app_code" style="width: 140px;">
        {if $USER_CAN_SHOW_ALL_APPLICATIONS}
        <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
        {/if}
        {html_options options=$app_code_list selected=$vlu.app_code}
      </select>
      </td>
      {/if}
	
      {if $USER_CAN_SHOW_USER || $USER_CAN_SHOW_ALL_USERS}
      <th>{if !isset($txt.Utente)}{t}Utente{/t}{else}{$txt.Utente}{/if}</th>
      <td>
      <select name="us_login" id="us_login" style="width: 140px;">
        {if $USER_CAN_SHOW_ALL_USERS}
		<option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
        {/if}
        {html_options options=$us_login_list selected=$vlu.us_login}
      </select>
      </td>
      {/if}
	</tr>
    {/if}
    
    <tr>
      <th>{if !isset($txt.Sezione)}{t}Sezione{/t}{else}{$txt.Sezione}{/if}</th>
      <td colspan=5><input type="text" name="se_section" value="{$vlu.se_section}" style="width:450px;" /></td>
	</tr>
    
    <tr>
      <th>{if !isset($txt.Parametro)}{t}Parametro{/t}{else}{$txt.Parametro}{/if}</th>
      <td colspan=5><input type="text" name="se_param" value="{$vlu.se_param}" style="width:450px;" /></td>
	</tr>
    
    <tr>
      <th  valign="top">{if !isset($txt.parameter_type)}{t}Tipo parametro{/t}{else}{$txt.parameter_type}{/if}</th>
      <td valign="top"><select name="se_type" id="se_type" style="width: 140px;" onChange="applyType(this.value)">
            {html_options options=$se_type_list selected=$vlu.se_type}
          </select>
      </td>
      <td colspan=4>
          <div id="se_type_ext_STRING" style="display: none">
          {if !isset($txt.max_length)}{t}Lunghezza massima{/t}{else}{$txt.max_length}{/if}: <input type="text" name="se_type_ext_STRING" value="{$vlu.se_type_ext_STRING}" style="width:45px;" />
          </div>
          <div id="se_type_ext_ENUM" style="display: none">
          {if !isset($txt.parameters)}{t}Parametri{/t}{else}{$txt.parameters}{/if}: <textarea name="se_type_ext_ENUM" style="width:300px; height: 100px">{$vlu.se_type_ext_ENUM}</textarea>
          (info: parametro1=valore1\nparametro2=valore2)
          </div>
      </td>
	</tr>
    
    
    
    <tr>
      <th>{if !isset($txt.Descrizione)}{t}Descrizione{/t}{else}{$txt.Descrizione}{/if}</th>
      <td colspan=5><textarea name="se_descr" style="width:450px; height: 100px">{$vlu.se_descr}</textarea></td>
	</tr>
    
    <tr>
      <th>{if !isset($txt.Privato)}{t}Privato{/t}{else}{$txt.Privato}{/if}</th>
      <td><input type="radio" name="se_private_dummy" value="T" {if $vlu.se_private == 'T'} checked {/if} />{if !isset($txt.YES)}{t}SI{/t}{else}{$txt.YES}{/if} <input type="radio" name="se_private_dummy" value="F" {if $vlu.se_private != 'T'} checked {/if} /> {if !isset($txt.NO)}{t}NO{/t}{else}{$txt.NO}{/if}</td>
	
      <th>{if !isset($txt.Posizione)}{t}Ordinamento{/t}{else}{$txt.Posizione}{/if}</th>
      <td  colspan=3><input type="text" name="se_order" value="{$vlu.se_order}" style="width:45px;" /></td>
	</tr>
    
  
    <tr>
      <th>{if !isset($txt.Valore)}{t}Valore{/t}{else}{$txt.Valore}{/if}</th>
      <td  colspan=5>
      <div id="se_value_normal" style="display: none">
        <input type="text" name="se_value_normal" value="{$vlu.se_value_normal}" style="width:450px;" />
      </div>
      <div id="se_value_TEXT" style="display: none">
          <textarea name="se_value_TEXT" style="width:600px; height: 400px; font-family: courier; font-size:10px" WRAP="off">{$vlu.se_value_TEXT}</textarea>
      </div>
          </td>
	</tr>
    
    
    
    
    
    
    
    
    
    
    
  </table>
  <br>
  
    <input type="button" name="btnSave"   value="{if !isset($btn.save)}{t}Salva{/t}{else}{$btn.save}{/if}" onclick="submitForm();" style="height:25px;width:70px;" />
    <input type="button" name="btnCancel"  value="{if !isset($btn.abort)}{t}Annulla{/t}{else}{$btn.abort}{/if}"  onClick="showList();" style="height:25px;width:70px;" />
    
</form>

{literal}
<script>

    applyType('{/literal}{$vlu.se_type}{literal}');
    
    if (document.modForm.dn_name && !document.modForm.dn_name.disabled && document.modForm.dn_name.value == '')
        document.modForm.dn_name.focus();
    else if (document.modForm.app_code && !document.modForm.app_code.disabled && document.modForm.app_code.value == '')
        document.modForm.app_code.focus();    
    else if (document.modForm.us_login && !document.modForm.us_login.disabled && document.modForm.us_login.value == '')
        document.modForm.us_login.focus();    
    else if (document.modForm.se_section && !document.modForm.se_section.disabled && document.modForm.se_section.value == '')
        document.modForm.se_section.focus();    
    else if (document.modForm.se_param && !document.modForm.se_param.disabled && document.modForm.se_param.value == '')
        document.modForm.se_param.focus();    
    else if (document.modForm.se_value && !document.modForm.se_value.disabled && document.modForm.se_value.visible && document.modForm.se_value.value == '')
        document.modForm.se_value.focus();    
    else if (document.modForm.se_value_TEXT && !document.modForm.se_value_TEXT.disabled && document.modForm.se_value_TEXT.visible && document.modForm.se_value_TEXT.value == '')
        document.modForm.se_value_TEXT.focus();    
    
    
  
</script>
{/literal}

</body>
</html>