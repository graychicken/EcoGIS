{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

<script type="text/javascript" language="javascript">
    
    function askDel(app_code, ac_verb, ac_name) {ldelim}
    
        if (confirm('{if !isset($txt.confirm)}{t}Sei sicuro, di voler cancellare questo privilegio?{/t}{else}{$txt.confirm}{/if}'))
            submitForm(app_code, ac_verb, ac_name);
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

        document.location = 'acnames_list.php';
    {rdelim}
    
    function formCheckError(text, element_name) {ldelim}

        //SS: rimettere questo alert! alert(js_html_entity_decode(text));
        alert(text);
        disableControls(false);
    {rdelim}

    function submitForm(app_code, ac_verb, ac_name) {ldelim}

        setTimeout("xajaxCallFaild()", 10000);
        disableControls(true);
        xajax_submitForm(new Array('act|del', 
                                   'app_code|' + app_code,
                                   'ac_verb|' + ac_verb,
                                   'ac_name|' + ac_name), "formCheckDone", "formCheckError");
    {rdelim}
    
    function applyFilter() {ldelim}
    
        document.frmFilter.submit();
        if (document.frmFilter.btnFilter)    document.frmFilter.btnFilter.disabled = true;
       
    {rdelim}
    
    function doExport() {ldelim}
        
        location.href = 'export.php?what=ACNAME';
    {rdelim}
    
</script>

<form name="frmFilter" method="post" action="acnames_list.php">
<input type="hidden" name="pg" value="1">
<h3>{if !isset($txt.acnames_title)}{t}Gestione privilegi{/t}{else}{$txt.acnames_title}{/if} - {if !isset($txt.Totale)}{t}Totale{/t}{else}{$txt.Totale}{/if}: {$tot}</h3>

<div style="text-align:left;">
    <table class="filter">
      <tr>
        {if count($app_code_list) > 1}
	    <td>
          {if !isset($txt.Applicazione)}{t}Applicativo{/t}{else}{$txt.Applicazione}{/if}:
		  <select name="fltapp_code" id="fltapp_code" style="width: 140px;">
		    <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
            {html_options options=$app_code_list selected=$fltapp_code}
          </select>
	    </td>
        {/if}
        <td>
          {if !isset($txt.verbo)}{t}Verbo{/t}{else}{$txt.verbo}{/if}:
		  <select name="fltac_verb" id="fltac_verb" style="width: 140px;">
		    <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
            {html_options options=$ac_verb_list selected=$fltac_verb}
          </select>
	    </td>
        
        <td>
          {if !isset($txt.nome)}{t}Nome{/t}{else}{$txt.nome}{/if}:
		  <select name="fltac_name" id="fltac_name" style="width: 140px;">
		    <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
            {html_options options=$ac_name_list selected=$fltac_name}
          </select>
	    </td>
        
        <td>
          {t}Tipo{/t}:
		  <select name="fltac_type" id="fltac_type" style="width: 140px;">
		    <option value="">{t}-- selezionare --{/t}</option>
            {html_options options=$ac_type_list selected=$fltac_type}
          </select>
	    </td>
		
		</tr>
        

        
        <tr><td><input type="button" name="btnFilter" value="{if !isset($btn.filter)}{t}Filtra{/t}{else}{$btn.filter}{/if}" onclick="applyFilter();"></td></tr>
    </table>
  </div>
  
  <div class="function_list">
    <input type="button" name="btnExport" value="{if !isset($btn.esporta)}{t}Esporta{/t}{else}{$btn.esporta}{/if}" onClick="doExport();" style="height:25px;width:70px;" />
    <input type="button" name="btnAdd" value="{if !isset($btn.new)}{t}Nuovo{/t}{else}{$btn.new}{/if}" onClick="location.href='acnames_edit.php?act=add&app_code={$fltapp_code}';" style="height:25px;width:70px;" />
  </div>
</form>
  
<form name="simpleTable" method="post" action="acnames_list.php">
{$table_html}
{$navigationBar_html}
</form>

</body>
</html>