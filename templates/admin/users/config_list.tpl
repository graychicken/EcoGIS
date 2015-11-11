{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

<script type="text/javascript" language="javascript">

    function askDel(dn_name, app_code, us_login, se_section, se_param) {ldelim}
    
        if (confirm('{if !isset($txt.confirm)}{t}Sei sicuro, di voler cancellare questa configurazione?{/t}{else}{$txt.confirm}{/if}'))
            submitForm(dn_name, app_code, us_login, se_section, se_param);
    {rdelim}
    
    function disableControls(status) {ldelim}
    
        if (document.frmFilter.dn_name)         document.frmFilter.dn_name.disabled = true;
        if (document.frmFilter.app_code)        document.frmFilter.app_code.disabled = true;
        if (document.frmFilter.us_login)        document.frmFilter.us_login.disabled = true;
        if (document.frmFilter.show_private)    document.frmFilter.show_private.disabled = true;
        if (document.frmFilter.btnAdd)          document.frmFilter.btnAdd.disabled = status;
        
    {rdelim}
    
    function xajaxCallFaild() {ldelim}
        
        alert(js_html_entity_decode('{if !isset($txt.timeout_server)}{t}Timeout del server. Riprovare!{/t}{else}{$txt.timeout_server}{/if}'));
        disableControls(false);
    {rdelim}
    
     function formCheckDone() {ldelim}

        document.location = 'config_list.php';
    {rdelim}
    
    function formCheckError(text, element_name) {ldelim}

        alert(js_html_entity_decode(text));
        disableControls(false);
    {rdelim}

    function submitForm(dn_name, app_code, us_login, se_section, se_param) {ldelim}

        setTimeout("xajaxCallFaild()", 10000);
        disableControls(true);
        xajax_submitForm(new Array('act|del',
                                   'dn_name|' + dn_name, 
                                   'app_code|' + app_code, 
                                   'us_login|' + us_login, 
                                   'se_section|' + se_section, 
                                   'se_param|' + se_param), "formCheckDone", "formCheckError");
    {rdelim}
    
    function applyFilter() {ldelim}
    
        document.frmFilter.submit();
        disableControls(true);
    {rdelim}
    
    function showList() {ldelim}
    
        if (document.modForm.btnSave)          document.modForm.btnSave.disabled = true;
        if (document.modForm.btnCancel)        document.modForm.btnCancel.disabled = true;
        document.location='config_list.php';
    {rdelim}
    
    function saveAll() {ldelim}
        if (document.modForm.btnSave)          document.modForm.btnSave.disabled = true;
        if (document.modForm.btnCancel)        document.modForm.btnCancel.disabled = true;
        document.modForm.submit();
    {rdelim}
    
    function exportSetup() {ldelim}
        
        e = document.getElementById('export_setup');
        e.style.display = '';
        
    {rdelim}
    function exportSetupClose() {ldelim}
        
        e = document.getElementById('export_setup');
        e.style.display = 'none';
        
    {rdelim}
    
    function doExport() {ldelim}
        
        var section = '{$fltsection}';
        
        e = document.getElementById('export_setup');
        e.style.display = 'none';
        if (document.frmFilter.set[0].checked) {ldelim}
            mode = 'add';
        {rdelim} else {ldelim}
            mode = 'set';
        {rdelim}

        url = 'export.php?what=CONFIG&mode=' + mode;
        if (document.frmFilter.all[0].checked) {ldelim}
            url = url + '&expsection=' + section;
        {rdelim}
        location.href = url;
    {rdelim}
    
    
</script>
<form name="frmFilter" method="post" action="config_list.php">

{if $USER_CAN_SHOW_USER || $USER_CAN_SHOW_ALL_USERS || $USER_CAN_SHOW_LOCAL_USER || 
    $USER_CAN_SHOW_DOMAIN || $USER_CAN_SHOW_ALL_DOMAINS ||
    $USER_CAN_SHOW_APPLICATION || $USER_CAN_SHOW_ALL_APPLICATIONS}
<div style="text-align:left;">
    <table class="filter">
    
      <tr>
        {if $USER_CAN_SHOW_DOMAIN || $USER_CAN_SHOW_ALL_DOMAINS}
        <th>{if !isset($txt.Dominio)}{t}Dominio{/t}{else}{$txt.Dominio}{/if}</th> 
        <td>
          <select name="fltdn_name" id="fltdn_name" style="width: 140px;" onChange="applyFilter()">
		  <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
          {html_options options=$dn_name_list selected=$dn_name}
          </select>
	    </td>
		{/if}
        
        {if $USER_CAN_SHOW_ALL_APPLICATIONS || $USER_CAN_SHOW_APPLICATION}
        <th>{if !isset($txt.Applicazione)}{t}Applicativo{/t}{else}{$txt.Applicazione}{/if}</th>
	    <td>
          <select name="fltapp_code" id="fltapp_code" style="width: 140px;" onChange="applyFilter()">
          {if $USER_CAN_SHOW_ALL_APPLICATIONS}
		  <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
          {/if}
          {html_options options=$app_code_list selected=$app_code}
        </select>
	    </td>
        {/if}
        
        {if $USER_CAN_SHOW_ALL_USERS || $USER_CAN_SHOW_USER || $USER_CAN_SHOW_LOCAL_USER}
        <td>
          {if !isset($txt.Utente)}{t}Utente{/t}{else}{$txt.Utente}{/if}: 
		  <select name="fltus_login" id="fltus_login" style="width: 140px;" onChange="applyFilter()" {if count($us_login_list) == 0}disabled{/if}>
		    <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
            {html_options options=$us_login_list selected=$us_login}
          </select>
	    </td>
        {/if}
		</tr>
    </table>
  </div>
  
  {/if} {* fine filtro *}  
  {if $USER_CAN_EDIT_CONFIG || $USER_CAN_EXPORT_CONFIG}
  <div class="function_list">
    {if $USER_CAN_EXPORT_CONFIG}
    <input type="button" name="btnExport" value="{if !isset($btn.esporta)}{t}Esporta{/t}{else}{$btn.esporta}{/if}" onClick="exportSetup();" style="height:25px;width:70px;" />
    {/if}  
    {if $USER_CAN_EDIT_CONFIG}
    <input type="button" name="btnNew" value="{if !isset($btn.new)}{t}Nuovo{/t}{else}{$btn.new}{/if}" onClick="location.href='config_edit.php?act=add';" style="height:25px;width:70px;" />
    {/if}
  </div>
  {/if}

  <div id="export_setup" style="display: none" class="function_list">
    <table class="table_list" border="1" bgcolor="white">
    <tr>
      <th colspan="5">
      <span>{if !isset($txt.export_settings)}{t}Impostazioni export{/t}{else}{$txt.export_settings}{/if}</span>
      <span>[<a href="JavaScript:exportSetupClose()">X</a>]</span>
      </th>
    </tr><tr>  
      <td>{if !isset($txt.Tipo)}{t}Tipo{/t}{else}{$txt.Tipo}{/if}</td><td><input type="radio" name="all" value="F" checked="checked"></td>
      <td>{if !isset($txt.current_section)}{t}Solo sezione corrente{/t}{else}{$txt.current_section}{/if}</td><td><input type="radio" name="all" value="T">
      </td><td>{if !isset($txt.Tutto)}{t}Tutto{/t}{else}{$txt.Tutto}{/if}</td>
    </tr><tr>  
      <td>{if !isset($txt.modality)}{t}Modalità{/t}{else}{$txt.modality}{/if}</td><td><input type="radio" name="set" value="F" checked="checked"></td>
      <td>{if !isset($txt.only_new_values)}{t}Aggiungi solo i valori nuovi{/t}{else}{$txt.only_new_values}{/if}</td><td><input type="radio" name="set" value="T"></td>
      <td>{if !isset($txt.set_all_values)}{t}Imposta tutti i valori{/t}{else}{$txt.set_all_values}{/if}</td>
    </tr><tr>
      <td colspan="5" align="center"><input type="button" value="Esporta" onClick="doExport()"></td>
    </tr>  
    </table>
  </div>
  
  
 </form>
  
<table class="form">
  <tr>
    <td>
	  <div class="tab_menu">
{foreach from=$sections item=value}
  {if $value == $fltsection}
    [<a href="config_list.php?fltsection={$value}"><b>{$value}</b></a>]
  {else}
    [<a href="config_list.php?fltsection={$value}">{$value}</a>]
  {/if}  
{/foreach}
      </div>
	</td>
  </tr>	
</table>
<br />

{if count($attribs) > 0}  
<form name="modForm" method="post" action="config_list.php">  
<input type="hidden" name="save" value="T">
  
  <table class="form">
  <tr>
    <th>{if !isset($txt.Parameter)}{t}Parametero{/t}{else}{$txt.Parameter}{/if}</th>
    <th>{if !isset($txt.Value)}{t}Valore{/t}{else}{$txt.Value}{/if}</th>
    {if $USER_CAN_EDIT_CONFIG}
    <th>{if !isset($txt.Action)}{t}Azione{/t}{else}{$txt.Action}{/if}</th>
    {/if}
  </tr>
  {foreach from=$attribs key=key1 item=value1}
    {foreach from=$value1 key=key2 item=value2}
      <tr>
      <td>{$value2.se_param}</td>
      <td>
      {if $value2.se_type == 'STRING'}
        <input type="text" name="{$value2.se_section}|{$value2.se_param}" value="{$value2.se_value}" style="width: 500px" maxlength="{$value2.se_type_ext}" class="input">
      {elseif $value2.se_type == 'PASSWORD'}
        <input type="text" name="{$value2.se_section}|{$value2.se_param}" style="width: 500px" maxlength="{$value2.se_type_ext}" class="input">
      {elseif $value2.se_type == 'TEXT'}
        <textarea name="{$value2.se_section}|{$value2.se_param}" style="width: 500px; height: 100px" class="inputwrap" wrap="off">{$value2.se_value}</textarea>
      {elseif $value2.se_type == 'NUMBER'}
        <input type="text" name="{$value2.se_section}|{$value2.se_param}" value="{$value2.se_value}" style="width: 80px" maxlength="10" class="input">
      {elseif $value2.se_type == 'ENUM'}
        {foreach from=$value2.se_enum_data key=key3 item=value3}
        <input type="radio" id="enum_{$value2.se_section}|{$value2.se_param}|{$key3}" name="{$value2.se_section}|{$value2.se_param}" value="{$key3}" {if $value2.se_value==$key3}checked{/if} class="input"><label for="enum_{$value2.se_section}|{$value2.se_param}|{$key3}">{$value3}</label>&nbsp;&nbsp;
        {/foreach}
        <!--<input type="text" name="{$value2.se_section}|{$value2.se_param}dummy" value="{$value2.se_value}" style="width: 80px" maxlength="10" class="input">-->
      {elseif $value2.se_type == 'ARRAY' || $value2.se_type == 'JSON'}
        <textarea style="width: 500px; height: 100px" class="inputwrap" wrap="off" readonly>{$value2.se_value}</textarea>
      {else}
        {$value2.se_value} {* unknown type *}      
      {/if}
      </td>      
      <td>
      {if $value2.se_descr != ''}
        <img src="{if $smarty.const.R3_ICONS_URL != ''}{$smarty.const.R3_ICONS_URL}{else}{$R3_ICONS_URL}{/if}info.gif" style="cursor: help" title="{$value2.se_descr}" width="18" onClick="alert(js_html_entity_decode('{$value2.se_descr}'))">
      {else}    
        <img src="{if $smarty.const.R3_ICONS_URL != ''}{$smarty.const.R3_ICONS_URL}{else}{$R3_ICONS_URL}{/if}spacer.gif" width="18">
      {/if}

      {if $USER_CAN_EDIT_CONFIG}
       <a href="config_edit.php?act=mod&dn_name={$dn_name}&app_code={$app_code}&us_login={$us_login}&se_section={$value2.se_section}&se_param={$value2.se_param}"><img src="{if $smarty.const.R3_ICONS_URL != ''}{$smarty.const.R3_ICONS_URL}{else}{$R3_ICONS_URL}{/if}ico_edit.gif" border="0" width="18"></a>
       <a href="JavaScript:askDel('{$dn_name}', '{$app_code}', '{$us_login}', '{$value2.se_section}', '{$value2.se_param}')"><img src="{if $smarty.const.R3_ICONS_URL != ''}{$smarty.const.R3_ICONS_URL}{else}{$R3_ICONS_URL}{/if}ico_del.gif" border="0" width="18"></a>
      {/if}
      </td>
      </tr>
    {/foreach}
  {/foreach}
  </table>
  <br />
  
  {if $USER_CAN_EDIT_CONFIG}
    <input type="button" name="btnSave"  value="{if !isset($btn.save)}{t}Salva{/t}{else}{$btn.save}{/if}" onClick="saveAll();" style="height:25px;width:70px;" />
    <input type="button" name="btnCancel"  value="{if !isset($btn.abort)}{t}Annulla{/t}{else}{$btn.abort}{/if}" onClick="showList();" style="height:25px;width:70px;" />
  {/if}
</form>    
{/if}

</body>
</html>