{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

<script type="text/javascript" language="javascript">

    function askDel(dn_name, us_login) {ldelim}
        if (confirm('{if !isset($txt.confirm)}{t}Sei sicuro, di voler cancellare questo utente?{/t}{else}{$txt.confirm}{/if}'))
            submitForm(dn_name, us_login);
    {rdelim}
    
    function disableControls(status) {ldelim}
    
        if (document.frmFilter.btnAdd)  document.frmFilter.btnAdd.disabled = status;
        
    {rdelim}
    
    function xajaxCallFaild() {ldelim}
        
        //SS: rimettere questo alert! alert(js_html_entity_decode('SS: Timeout sel server. Riprovare!'));
        //alert("SS: Si e' verificato un errore di comunicazione col server. Riprovare a salvare i dati. Se il problema persiste contattare il supporto tecnico!");
        disableControls(false);
    {rdelim}
    
    function formCheckDone() {ldelim}

        document.location = 'users_list.php';
    {rdelim}
    
    function formCheckError(text, element_name) {ldelim}

        //SS: rimettere questo alert! alert(js_html_entity_decode(text));
        alert(text);
        disableControls(false);
    {rdelim}

    function submitForm(dn_name, us_login) {ldelim}

        setTimeout("xajaxCallFaild()", 10000);
        disableControls(true);
        xajax_submitForm(new Array('act|del', 'dn_name|' + dn_name, 'us_login|' + us_login), "formCheckDone", "formCheckError");
    {rdelim}
    
    function applyFilter() {ldelim}
    
        document.frmFilter.submit();
        if (document.frmFilter.btnFilter)    document.frmFilter.btnFilter.disabled = true;
       
    {rdelim}
    
    function cancelFilter() {ldelim}
    
        document.location = 'users_list.php?reset';
       
    {rdelim}
    
</script>

<form name="frmFilter" method="post" action="users_list.php">
  <input type="hidden" name="pg" value="1" />
  {if $USER_CAN_ADD_USER || $USER_CAN_ADD_ALL_USERS || $USER_CAN_ADD_LOCAL_USER}
  <div class="function_list">
    <input type="button" name="btnNew" value="{if !isset($btn.new)}{t}Nuovo{/t}{else}{$btn.new}{/if}" onclick="location.href='users_edit.php?act=add&app_code={$fltapp_code}&dn_name={$fltdn_name}&gr_name={$gr_name}';" style="height:25px;width:70px;" />
  </div>
  {/if}
  <h3>{if !isset($txt.users_title)}{t}Gestione utenti{/t}{else}{$txt.users_title}{/if} - {if !isset($txt.Totale)}{t}Totale{/t}{else}{$txt.Totale}{/if}: {$tot}</h3>
  
  {* filter *}
  <fieldset class="um_filter app_filter">
    <legend>{t}Filtro{/t}</legend>
    <div class="um_filter_fields app_filter_fields">
      {if count($dn_name_list) > 2}
      <div>
        <span>{if !isset($txt.Dominio)}{t}Dominio{/t}{else}{$txt.Dominio}{/if}:</span>
        <select name="fltdn_name" id="fltdn_name">
  		    <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
          {html_options options=$dn_name_list selected=$fltdn_name}
        </select>
      </div>
      {/if}
      {if count($app_code_list) > 1}
      <div>
        <span>{if !isset($txt.Applicazione)}{t}Applicativo{/t}{else}{$txt.Applicazione}{/if}:</span>
        <select name="fltapp_code" id="fltapp_code">
          <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
          {html_options options=$app_code_list selected=$fltapp_code}
        </select>
      </div>
      {/if}
      {if count($gr_name_list) > 1}
      <div>
        <span>{if !isset($txt.Gruppo)}{t}Gruppo{/t}{else}{$txt.Gruppo}{/if}:</span>
        <select name="gr_name" id="gr_name" style="width: 140px;">
          <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
          {html_options options=$gr_name_list selected=$gr_name}
        </select>
      </div>
      {/if}
      <div>
        <span>{if !isset($txt.Nome)}{t}Nome{/t}{else}{$txt.Nome}{/if}/{if !isset($txt.Login)}{t}Login{/t}{else}{$txt.Login}{/if}:</span>
        <input type="text" name="login_name" id="login_name" value="{$login_name}" style="width:200px;" />
      </div>
      <div>
        <span>{t}Stato{/t}:</span>
        <select name="us_status" id="us_status" style="width: 140px;">
          <option value="">{t}-- selezionare --{/t}</option>
          <option value="E" {if $us_status == 'E'}selected{/if}>{t}Attivo{/t}</option>
          <option value="D" {if $us_status == 'D'}selected{/if}>{t}Non attivo{/t}</option>
        </select>
      </div>
      <div>
        <input type="submit" name="btnFilter" id="btnFilter" value="{if !isset($btn.filter)}{t}Filtra{/t}{else}{$btn.filter}{/if}" onclick="applyFilter();" style="width:70px;" />
        <input type="button" name="btnCancel" id="btnCancel" value="{if !isset($btn.abort)}{t}Annulla{/t}{else}{$btn.abort}{/if}" onclick="cancelFilter();" style="width:70px;" />
      </div>
    </div>
  </fieldset>
</form>
  
<form name="simpleTable" method="post" action="users_list.php">
{$table_html}
{$navigationBar_html}
</form>
  
</body>
</html>