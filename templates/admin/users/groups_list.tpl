{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

<script type="text/javascript" language="javascript">
    
    function askDel(code, name) {ldelim}
    
        if (confirm('{if !isset($txt.confirm)}{t}Sei sicuro, di voler cancellare questo gruppo?{/t}{else}{$txt.confirm}{/if}'))
            submitForm(code, name);
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

        document.location = 'groups_list.php';
    {rdelim}
    
    function formCheckError(text, element_name) {ldelim}

        //SS: rimettere questo alert! alert(js_html_entity_decode(text));
        alert(text);
        disableControls(false);
    {rdelim}

    function submitForm(code, name) {ldelim}

        setTimeout("xajaxCallFaild()", 10000);
        disableControls(true);
        xajax_submitForm(new Array('act|del', 'app_code|' + code, 'gr_name|' + name), "formCheckDone", "formCheckError");
    {rdelim}
    
    function applyFilter() {ldelim}
    
        document.frmFilter.submit();
        if (document.frmFilter.btnFilter)    document.frmFilter.btnFilter.disabled = true;
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
        
        var expgroup = document.getElementById('export_gr_name').value;
        e = document.getElementById('export_setup');
        e.style.display = 'none';
        url = 'export.php?what=GROUP&expgroup=' + expgroup;
        location.href = url;
    {rdelim}
    
    
    
</script>
<form name="frmFilter" method="post" action="groups_list.php">
<input type="hidden" name="pg" value="1">

<h3>{if !isset($txt.group_title)}{t}Gestione gruppi{/t}{else}{$txt.group_title}{/if} - {if !isset($txt.Totale)}{t}Totale{/t}{else}{$txt.Totale}{/if}: {$tot}</h3>

{if count($app_code_list) > 1}
<div style="text-align:left;">
<table class="filter">
<tr>
  <td>
  {if !isset($txt.Applicazione)}{t}Applicativo{/t}{else}{$txt.Applicazione}{/if}:
  <select name="fltapp_code" id="fltapp_code" style="width: 140px;">
    <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
    {html_options options=$app_code_list selected=$fltapp_code}
  </select>
  </td>
</tr>
<tr><td><input type="button" name="btnFilter" value="{if !isset($btn.filter)}{t}Filtra{/t}{else}{$btn.filter}{/if}" onclick="applyFilter();"></td></tr>
</table>
</div>
{/if}

<div class="function_list">
  <input type="button" name="btnAdd" value="{if !isset($btn.new)}{t}Nuovo{/t}{else}{$btn.new}{/if}" onClick="location.href='groups_edit.php?act=add&code={$app_code}';" style="height:25px;width:70px;" />
</div>

{if $USER_CAN_EXPORT_GROUP}
  <div class="function_list">
    <input type="button" name="btnExport" value="{if !isset($btn.esporta)}{t}Esporta{/t}{else}{$btn.esporta}{/if}" onClick="exportSetup();" style="height:25px;width:70px;" />
  </div>
  <div id="export_setup" style="display: none" class="function_list">
    <table class="table_list" border="1" bgcolor="white">
    <tr>
      <th colspan="2">
      <div>{if !isset($txt.export_settings)}{t}Impostazioni export{/t}{else}{$txt.export_settings}{/if}</div>
      <div style="position: right; right: 10px">[<a href="JavaScript:exportSetupClose()">X</a>]</div>
      </th>
    </tr><tr>  
      <td>{t}Gruppo:{/t}</td>
      <td>
        <select name="export_gr_name" id="export_gr_name" style="width: 140px;">
		  <option value="">{if !isset($txt.select)}{t}-- Tutti --{/t}{else}{$txt.select}{/if}</option>
          {html_options options=$export_gr_name_list selected=$gr_name}
        </select>
	  </td>
    </tr><tr>
      <td colspan="2" align="center"><input type="button" value="{t}Esporta{/t}" onClick="doExport()"></td>
    </tr>  
    </table>
  </div>
{/if}
</form>

<form name="simpleTable" method="post" action="groups_list.php">
{$table_html}
{$navigationBar_html}
</form>

</body>
</html>