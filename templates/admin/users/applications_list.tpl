{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

<script type="text/javascript" language="javascript">
    
    function askDel(cod) {ldelim}
    
        if (confirm('{if !isset($txt.confirm)}{t}Sei sicuro, di voler cancellare questo applicativo?{/t}{else}{$txt.confirm}{/if}'))
            submitForm(cod);
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

        document.location = 'applications_list.php';
    {rdelim}
    
    function formCheckError(text, element_name) {ldelim}

        //SS: rimettere questo alert! alert(js_html_entity_decode(text));
        alert(text);
        disableControls(false);
    {rdelim}

    function submitForm(cod) {ldelim}

        setTimeout("xajaxCallFaild()", 10000);
        disableControls(true);
        xajax_submitForm(new Array('act|del', 'app_code|' + cod), "formCheckDone", "formCheckError");
    {rdelim}
    
</script>

<form name="frmFilter" method="post" action="user_list.php">
<input type="hidden" name="pg" value="1">

  <div class="function_list">
    <input type="button" name="btnAdd" value="{if !isset($btn.new)}{t}Nuovo{/t}{else}{$btn.new}{/if}" onClick="location.href='applications_edit.php?act=add';" style="height:25px;width:70px;" />
  </div>
  
</form>
 
<h3>{if !isset($txt.application_title)}{t}Gestione applicativi{/t}{else}{$txt.application_title}{/if} - {if !isset($txt.Totale)}{t}Totale{/t}{else}{$txt.Totale}{/if}: {$tot}</h3>
  
<form name="simpleTable" method="post" action="applications_list.php">
{$table_html}
{$navigationBar_html}
</form>

</body>
</html>