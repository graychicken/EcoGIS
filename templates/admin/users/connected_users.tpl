{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

<script type="text/javascript" language="javascript">

    function askDisconnect(dn_name, us_login) {ldelim}
    
        if (confirm('{if !isset($txt.confirm)}{t}Sei sicuro, di voler disconnettere questo utente?{/t}{else}{$txt.confirm}{/if}')) {ldelim}
            setTimeout("xajaxCallFaild()", 10000);
            xajax.call('disconnectUser', [dn_name, us_login], 0);      
        {rdelim}
    {rdelim}
    
    function xajaxCallFaild() {ldelim}
        
        //SS: rimettere questo alert! alert(js_html_entity_decode('SS: Timeout sel server. Riprovare!'));
        alert("{if !isset($txt.timeout_server)}{t}Timeout del server. Riprovare!{/t}{else}{$txt.timeout_server}{/if}");
    {rdelim}
    
</script>

<h3>{if !isset($txt.connected_user_title)}{t}Utente connessi{/t}{else}{$txt.connected_user_title}{/if} - {if !isset($txt.Totale)}{t}Totale{/t}{else}{$txt.Totale}{/if}: {$tot}</h3>

<form name="simpleTable" method="post" action="connected_users.php">
{$table_html}
{$navigationBar_html}
</form>

</body>
</html>