{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

{literal}
<script type="text/javascript" language="javascript">

function disableControls(status) {
    
    if (document.frmFilter.btnAdd)  document.frmFilter.btnAdd.disabled = status;
        
}
    
function applyFilter() {
    
    document.frmFilter.submit();
    if (document.frmFilter.btnFilter)    document.frmFilter.btnFilter.disabled = true;
       
}

function checkControls() {

}
    
</script>
{/literal}

<h3>
  {if !isset($lbl.logs_title)}{t}Logs{/t}{else}{$lbl.logs_title}{/if} -
  {if !isset($lbl.logs_title)}{t}Totale{/t}{else}{$lbl.logs_total}{/if}: {$tot}
</h3>

<form name="frmFilter" method="post" action="logs.php">
  <input type="hidden" name="pg" value="1">
  <input type="hidden" name="apply_filter" value="T">
<fieldset class="um_filter app_filter">
    <legend>{t}Filtro{/t}</legend>
  <div class="um_filter_fields app_filter_fields">
    {if count($dn_name_list) > 2} {* 1 dominio è sempre SYSTEM *}
    <div>
      <span>{if !isset($lbl.domain)}{t}Dominio{/t}{else}{$lbl.domain}{/if}</span>
      <select name="fltdn_name" id="fltdn_name" style="width:100px;">
        <option value="">{if !isset($lbl.select)}{t}-- selezionare --{/t}{else}{$lbl.select}{/if}</option>
        {html_options options=$dn_name_list selected=$fltdn_name}
      </select>
    </div>
    {/if}
    {if count($app_code_list) > 1}
    <div>
      <span>{if !isset($lbl.logs_application)}{t}Applicativo{/t}{else}{$lbl.logs_application}{/if}</span>
      <select name="fltapp_code" id="fltapp_code" style="width:150px;">
        <option value="">{if !isset($lbl.select)}{t}-- selezionare --{/t}{else}{$lbl.select}{/if}</option>
        {html_options options=$app_code_list selected=$fltapp_code}
      </select>
    </div>
    {/if}
    <div>
      <span>{if !isset($lbl.logs_name_login)}{t}Nome{/t}/{t}Login{/t}{else}{$lbl.logs_name_login}{/if}</span>
      <input type="text" name="fltlogin_name" value="{$fltlogin_name}" style="width: 200px;">
    </div>
    <div>
      <span>{if !isset($lbl.logs_date_from)}{t}Dal{/t}{else}{$lbl.logs_date_from}{/if}</span>
      {if !defined('R3_UM_JQUERY') || !$smarty.const.R3_UM_JQUERY}
      {$fltdate_from}
      {else}
      {r3datepicker name='fltdate_from' value=$fltdate_from}
      {/if}
      <span>{if !isset($lbl.logs_date_to)}{t}Al{/t}{else}{$lbl.logs_date_to}{/if}</span>
      {if !defined('R3_UM_JQUERY') || !$smarty.const.R3_UM_JQUERY}
      {$fltdate_to}
      {else}
      {r3datepicker name='fltdate_to' value=$fltdate_to}
      {/if}
    </div>
    <div>
      <span>{if !isset($lbl.logs_ip)}{t}IP{/t}{else}{$lbl.logs_ip}{/if}</span>
      <input type="text" name="fltip" value="{$fltip}" style="width:100px;" />
    </div>
    <div>
      <span>{if !isset($lbl.logs_type_message)}{t}Tipo messaggio{/t}{else}{$lbl.logs_type_message}{/if}</span>
      <input type="checkbox" name="flterror" id="flterror" value="T" {if $flterror == 'T'}checked{/if} onClick="checkControls()"><label for="flterror">{if !isset($lbl.logs_type_errors)}{t}Errori{/t}{else}{$lbl.logs_type_errors}{/if}</label>
      <input type="checkbox" name="fltwarn"  id="fltwarn" value="T" {if $fltwarn == 'T'}checked{/if} onClick="checkControls()"><label for="fltwarn">{if !isset($lbl.logs_type_warning)}{t}Avvisi{/t}{else}{$lbl.logs_type_warning}{/if}</label>
      <input type="checkbox" name="fltinfo"  id="fltinfo" value="T" {if $fltinfo == 'T'}checked{/if} onClick="checkControls()"><label for="fltinfo">{if !isset($lbl.logs_type_info)}{t}Info{/t}{else}{$lbl.logs_type_info}{/if}</label>
      <input type="checkbox" name="fltdebug" id="fltdebug" value="T" {if $fltdebug == 'T'}checked{/if} onClick="checkControls()"><label for="fltdebug">{if !isset($lbl.logs_type_debug)}{t}Debug{/t}{else}{$lbl.logs_type_debug}{/if}</label>
    </div>
    <div>
      <span>{if !isset($lbl.logs_topic_message)}{t}Argomento messaggio{/t}{else}{$lbl.logs_topic_message}{/if}</span>
      <input type="checkbox" name="fltauth"  id="fltauth" value="T" {if $fltauth == 'T'}checked{/if}><label for="fltauth">{if !isset($lbl.logs_topic_auth)}{t}Autenticazione{/t}{else}{$lbl.logs_topic_auth}{/if}</label>
      <input type="checkbox" name="fltnavigation" id="fltnavigation" value="T" {if $fltnavigation == 'T'}checked{/if}><label for="fltnavigation">{if !isset($lbl.logs_topic_nav)}{t}Navigazione{/t}{else}{$lbl.logs_topic_nav}{/if}</label>
    </div>
    <div>
      <span>{if !isset($lbl.logs_rows)}{t}Nr. righe{/t}{else}{$lbl.logs_rows}{/if}</span>
      <select name="fltlimit">
        {html_options options=$limit_list selected=$fltlimit}
      </select>
    </div>
    <div>
      <input type="button" name="btnFilter" value="{if !isset($btn.filter)}{t}Filtra{/t}{else}{$btn.filter}{/if}" onclick="applyFilter();" style="width:75px;" />
      <input type="button" name="btnAbort" value="{if !isset($btn.abort)}{t}Annulla{/t}{else}{$btn.abort}{/if}" onclick="location.href='logs.php?reset';" style="width:75px;" />
    </div>
  </div>
  </div>
  </fieldset>
</form>
  
<br style="clear:both;" />

<form name="simpleTable" method="post" action="logs.php">
{$table_html}
{$navigationBar_html}
</form>

</body>
</html>