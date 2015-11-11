{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

{literal}
    <style>

        .tab_on {
            padding: 3px;
            xfont-weight: bold;
            background-color: #cccccc;
        }

        .tab_off {
            padding: 3px;
            xfont-weight: none;
            background-color: #ffffff;
        }

    </style>

<script type="text/javascript" language="javascript">
    $(document).ready(function() { 
        if($('#as_code').length > 0){
            $('#as_code').change(function(){
				if ($(this).val() == '') {
					$('#change_password').show();
				} else {
				    $('#change_password').hide();
				}	
            });
            $('#as_code').trigger('change');
        }
    }); 

{/literal}

    var xajaxTimer = null;
    
    function showList() {ldelim}
    
    document.location = 'users_list.php';
    {rdelim}
    
        function do_edit() {ldelim}
    
        document.location = 'users_edit.php?act=mod&dn_name=' + document.modForm.old_dn_name.value + '&us_login=' + document.modForm.old_us_login.value;
    {rdelim}
    
        function disableControls(status) {ldelim}
    
        document.modForm.btnSave.disabled = status;
        document.modForm.btnCancel.disabled = status;
    {rdelim}
    
        function xajaxCallFaild() {ldelim}
        
        //SS: rimettere questo alert! alert(js_html_entity_decode('SS: Timeout sel server. Riprovare!'));
        alert("{if !isset($txt.server_connection_error)}{t}Si è verificato un errore di comunicazione col server. Riprovare a salvare i dati. Se il problema persiste contattare il supporto tecnico!{/t}{else}{$txt.server_connection_error}{/if}");
        disableControls(false);
    {rdelim}
    
        function formCheckDone() {ldelim}

        showList();        
    {rdelim}
    
        function formCheckError(text, element_name) {ldelim}

        if (xajaxTimer) {ldelim}
        clearTimeout(xajaxTimer);
    {rdelim}
        //alert(js_html_entity_decode(text));
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
    {foreach from=$grp_perm key=k1 item=v1}
        {if $v1.max_groups != '0'}
            document.modForm.selectedGroups_{$k1}.value = getAllSelected(document.modForm.groups_{$k1});
        {/if}  
        {if $v1.has_user_perm != 'F'}
            document.modForm.selectedPerms_{$k1}.value = getAllSelected(document.modForm.perms_{$k1});
        {/if}
        {if $v1.has_user_perm_negate != 'F'}
            document.modForm.selectedPerms_n_{$k1}.value = getAllSelected(document.modForm.perms_n_{$k1});
        {/if}
    {/foreach}
        
        xajaxTimer = setTimeout("xajaxCallFaild()", 10000);
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
    
        function domainChange() {ldelim}
      
        document.modForm.dn_name.disabled = true;
        document.modForm.btnCancel.disabled = true;
            
        document.location = 'users_edit.php?act=' + document.modForm.act.value +
            '&dn_name=' + document.modForm.dn_name.value;
    {rdelim}
    
        function checkField(e, type) {ldelim}
      
        
    {rdelim}

    {if $act != 'show'}    
        function enableTab(name) {ldelim}
        {foreach from=$grp_perm key=k1 item=v1 name=sw}
            tab = document.getElementById('tab_{$k1}');
            if (tab) {ldelim}
            if (name == '{$k1}')  tab.className = 'tab_text tab_text_select';
            else                  tab.className = 'tab_text';
            {rdelim}
                app = document.getElementById('application_{$k1}');
                if (name == '{$k1}')  app.style.display = '';
                else                  app.style.display = 'none';
        {/foreach}
        {rdelim}
    {/if}    
</script>


<h3>
    {if $act == 'add'}
{if !isset($txt.add_user)}{t}Inserisci utente{/t}{else}{$txt.add_user}{/if}
{elseif $act == 'show'}
{if !isset($txt.show_user)}{t}Visualizza utente{/t}{else}{$txt.show_user}{/if}
{else}
{if !isset($txt.mod_user)}{t}Modifica utente{/t}{else}{$txt.mod_user}{/if}
{/if}
</h3>

<form name="modForm" method="post" action="product_edit_do.php" enctype="multipart/form-data" autocomplete="off">
    <input type="hidden" name="act" value="{$act}">
    <input type="hidden" name="old_dn_name" value="{$vlu.dn_name}">
    <input type="hidden" name="old_us_login" value="{$vlu.us_login}">

    {if $vlu.dn_name == ''}
        <table class="um_table_form app_table_form">
            <tr>
                <th><label for="dn_name">{if !isset($txt.Dominio)}{t}Dominio{/t}{else}{$txt.Dominio}{/if}:</label></th>
                <td>
                    <select name="dn_name" id="dn_name" onChange="domainChange()">
                        <option value="">{if !isset($txt.select)}{t}-- selezionare --{/t}{else}{$txt.select}{/if}</option>
                        {html_options options=$dn_name_list}
                    </select>
                </td>
            </tr>
        </table>
        <br />
        <input type="button" name="btnCancel"  value="{if !isset($btn.abort)}{t}Annulla{/t}{else}{$btn.abort}{/if}"  onClick="showList();" style="height:25px;width:70px;" />
        <script>
            document.modForm.dn_name.focus();
        </script>

    {else}
        <table class="um_table_form app_table_form" style="width:610px;">
            {* Questi compi vengono presi dalla configurazione *}
            {assign var='position_for_extra_fields' value='TOP'}
            {include file='users/users_edit_extra_fields.tpl'}
            {*
            {foreach from=$extra_fields key=k1 item=v1 name=foo}
            {if strToUpper($v1.position) == 'TOP'}
            {if $smarty.foreach.foo.first || $wrap != 'no'}
            <tr>
            {/if}
          
            { * label * }
            <th><label for="{$k1}">{$v1.label}</label></th>
            { * campo * }
            <td {if $v1.wrap != 'no'}colspan="3"{/if}>
                {if $v1.type == 'string' || $v1.type == 'email' || $v1.type == 'integer'}
                    <input type="text" name="{$k1}" id="{$k1}" value="{$v1.value}" {if $v1.size}style="width:{$v1.size}px;"{/if} {if $v1.maxlength}maxlength="{$v1.maxlength}"{/if} onBlur="checkField(this, '{$v1.type}')" {if $act == 'show'}class="input_readonly" readOnly {/if}>
                {elseif $v1.type == 'text'}
                    <textarea name="{$k1}" id="{$k1}" {if $v1.size}style="width:{$v1.size[0]}px; height:{$v1.size[1]}px;"{/if} onBlur="checkField(this, '{$v1.type}')" {if $act == 'show'}class="input_readonly" readOnly {/if}>{$v1.value}</textarea>
                {elseif $v1.type == 'select'}
                    {if $act != 'show'}
                        <select name="{$k1}" id="{$k1}">
                            {html_options options=$v1.values selected=$v1.value}
                        </select>
                    {else}
                        <input type="text" name="{$k1}" id="{$k1}" value="{$v1.values[$v1.value]}" {if $v1.size}style="width:{$v1.size}px;"{/if} class="input_readonly" readOnly>
                    {/if}
                {/if}
            </td>

            {if $smarty.foreach.foo.last || $wrap}
                </tr> 
            {/if}

            { * Imposto una variabile snarty per indicare se devo andare a capo (genero </tr><tr>) * }
                {if $v1.wrap == 'no'}
                    {assign var='wrap' value='no'}
                {else}
                    {assign var='wrap' value=''}
                {/if}
            {/if}      
            {/foreach}
                *}

                {if $vlu.dn_name != $USER_CONFIG_USER_MANAGER_DEFAULT_DOMAIN}
                <tr>
                    <th><label for="dn_name">{if !isset($txt.Dominio)}{t}Dominio{/t}{else}{$txt.Dominio}{/if}:</label></th> {* SS: sempre disabilitato *}
                    <td><input type="text" name="dn_name" id="dn_name" readonly value="{$vlu.dn_name}" {$view_style}></td>
                </tr>
            {else}
                <input type="hidden" name="dn_name" id="dn_name" value="{$vlu.dn_name}">
            {/if}

            <tr>
                <th style="width:22.4%"><label for="us_name">{if !isset($lbl.um_name)}{t}Nome utente{/t}{else}{$lbl.um_name}{/if}:</label></th>
                <td colspan="5">
                {if !$canChangeUserName}<input type="hidden" name="us_name" value="{$vlu.us_name}">{/if}
                <input type="text" id="us_name" name="us_name" value="{$vlu.us_name}" style="width:100%;" {if !$canChangeUserName}readonly{/if}{$view_style} />
            </td>
        </tr>
        <tr>
            <th style="width:22.4%"><label for="us_login">{if !isset($lbl.um_login)}{t}Login{/t}{else}{$lbl.um_login}{/if}:</label></th>
            <td colspan="5">
            {if $act != 'add' && !$canChangeLogin}<input type="hidden" name="us_login" value="{$vlu.us_login}">{/if}
            <input type="text" id="us_login" name="us_login" value="{$vlu.us_login}" style="width:100%;" {if $act != 'add' && !$canChangeLogin}readonly class="input_readonly"{/if} {$view_style} />
        </td>
    </tr>
    {if $auth_types|@count>0}
        <tr>
            <th>{t}Tipo autenticazione{/t}</th>
            <td> 
				{if $act != 'show'}
                <select id="as_code" name="as_code">
				<option value="">Standard</option>
				{html_options options=$auth_types selected=$vlu.as_code}
				</select>
				{else}
				<input type="text" id="as_code" name="as_code" value="{$auth_types[$vlu.as_code]}" style="width:100%;" {$view_style} />
				{/if}
            </td>
        </tr>
    {else}
        <input type="hidden" name="as_code" value=""/>
    {/if}

    {if count($grp_perm) <= 1}
        {foreach from=$grp_perm key=k1 item=v1}
            {if $v1.max_groups != '0'}
                <tr><th style="width:22.4%">{if $v1.has_user_perm == 'F' && $v1.has_user_perm_negate == 'F'}{t}Gruppo{/t}{else}{t}Permessi{/t}{/if}:</th><td colspan="5">
                        <div style="float:left;">
                        {if $v1.has_user_perm != 'F' || $v1.has_user_perm_negate != 'F'}{t}Gruppo{/t}<br />{/if}
                        <input type="hidden" name="selectedGroups_{$k1}" value="">
                        {if $act != 'show'}
                            <select name="groups_{$k1}" {if $v1.max_groups != '1'} multiple style="height:50px;width:150px;" {else} style="width:150px;" {/if} > 
                                {if $v1.max_groups == '1' && $v1.group_mandatory != 'T'}
                                    <option value=""></option>
                                {/if}      
                                {foreach from=$v1.groups key=k2 item=v2}
                                    {* SS: salvato in campo hidden selectedGroups_<nome_applicazione>*}
                                    <option value="{$v2.gr_name}" {if $v2.status == 'ON'}selected{/if}>{$v2.gr_name}</option>
                                {/foreach}
                            </select>
                        {else}
                            {foreach from=$v1.groups key=k2 item=v2}
                                {* SS: salvato in campo hidden selectedGroups_<nome_applicazione>*}
                                {if $v2.status == 'ON'}
                                    <input type="text" name="groups_{$k1}" value="{$v2.gr_name}" style="width:150px;" class="input_readonly" readOnly />
                                {/if}
                            {/foreach}
                        {/if}
                    </div>
                    {if $v1.has_user_perm != 'F'}
                        <div style="float:left;">
                            {t}Permessi{/t}<br />
                            <input type="hidden" name="selectedPerms_{$k1}" value="">
                            <select name="perms_{$k1}" multiple style="height:50px;width:200px;"> 
                                {foreach from=$v1.perms key=k2 item=v2}
                                    {* SS: salvato in campo hidden selectedPerms_<nome_applicazione>*}
                                    <option value="{$v2.ac_verb}|{$v2.ac_name}" {if $v2.ua_status == 'ALLOW'}selected{/if}>{$v2.ac_verb} {$v2.ac_name}</option>
                                {/foreach}
                            </select>
                        </div>
                    {/if}
                    {if $v1.has_user_perm_negate != 'F'}
                        <div style="float:left;">
                    {if !isset($lbl.permission_denied)}{t}Permessi negati{/t}{else}{$lbl.permission_denied}{/if}<br />
                    <input type="hidden" name="selectedPerms_n_{$k1}" value="">
                    <select name="perms_n_{$k1}" multiple style="height:50px;width:200px;"> 
                        {foreach from=$v1.perms_n key=k2 item=v2}
                            {* SS: salvato in campo hidden selectedPerms_n_<nome_applicazione>*}
                            <option value="{$v2.ac_verb}|{$v2.ac_name}" {if $v2.ua_status == 'ALLOW'}selected{/if}>{$v2.ac_verb} {$v2.ac_name}</option>
                        {/foreach}
                    </select>
                </div>
            {/if}
        </td>
    </tr>
{/if}
{/foreach}
{/if}




{if $canChangePassword}
    {* Password su server esterni potrebbero essere fisse *}
    </table>
    <table class="um_table_form app_table_form" id="change_password" style="width:610px;">
    <tr>
        <th><label for="us_password">{if !isset($lbl.um_password)}{t}Password{/t}{else}{$lbl.um_password}{/if}:</label></th>
        <td><input type="password" name="us_password" id="us_password" style="width:150px;" {$view_style} /></td>
        <th><label for="us_password2">{if !isset($lbl.um_password_repeat)}{t}Ripeti password{/t}{else}{$lbl.um_password_repeat}{/if}:</label></th>
        <td><input type="password" name="us_password2" id="us_password2" style="width:150px;" {$view_style} /></td>
    </tr>
    <tr>
        <th><label for="us_pw_expire">{if !isset($lbl.um_password_expire)}{t}Scadenza password{/t}{else}{$lbl.um_password_expire}{/if}:</label></th>
        <td><input type="text" name="us_pw_expire" id="us_pw_expire" style="width:80px;" value="{$vlu.us_pw_expire}" {if $act == 'show'}class="input_readonly" readOnly {/if} /> {if !isset($lbl.um_password_day)}{t}giorni{/t}{else}{$lbl.um_password_day}{/if}</td>
        <th><label for="us_pw_expire_alert">{if !isset($lbl.um_password_expire_alert)}{t}Preavviso scadenza{/t}{else}{$lbl.um_password_expire_alert}{/if}:</label></th>
        <td><input type="text" name="us_pw_expire_alert" id="us_pw_expire_alert" style="width:80px;" value="{$vlu.us_pw_expire_alert}" {if $act == 'show'}class="input_readonly" readOnly {/if} /> {if !isset($lbl.um_password_day)}{t}giorni{/t}{else}{$lbl.um_password_day}{/if}</td>
    </tr>
    {if $USER_CONFIG_USER_MANAGER_FIRST_LOGIN_CHANGE_PASSWORD <> ''}
        <tr>
            <th><input type="checkbox" name="us_force_password_change" id="us_force_password_change"  value="T" {if $vlu.us_pw_last_change == '' && $USER_CONFIG_USER_MANAGER_FIRST_LOGIN_CHANGE_PASSWORD == 'T'} checked {/if} {if $act == 'show'}disabled {/if}/></th>
            <td colspan="3"><label for="us_force_password_change">{if !isset($lbl.um_password_chg_on_login)}{t}cambio password obbligatorio al primo collegamento{/t}{else}{$lbl.um_password_chg_on_login}{/if}</label></td>
        </tr>
    {/if}
    <tr class="separator"><td colspan="4"></td></tr>
    </table>
    <table class="um_table_form app_table_form">
{/if}




{if $USER_CONFIG_USER_MANAGER_HAS_START_DATE != 'F' || $USER_CONFIG_USER_MANAGER_HAS_EXPIRE_DATE != 'F'}
    <tr>
        <th>{if !isset($lbl.um_validate_start)}{t}Inizio validità{/t}{else}{$lbl.um_validate_start}{/if}:</th>
        {if !defined('R3_UM_JQUERY') || !$smarty.const.R3_UM_JQUERY}
            <td>{$startDate}</td>
        {else}
            <td>{r3datepicker name='us_start_date' value=$vlu.us_start_date}</td>
        {/if}
        <th>{if !isset($lbl.um_validate_end)}{t}Fine validità{/t}{else}{$lbl.um_validate_end}{/if}:</th>
        {if !defined('R3_UM_JQUERY') || !$smarty.const.R3_UM_JQUERY}
            <td>{$expireDate}</td>
        {else}
            <td>{r3datepicker name='us_expire_date' value=$vlu.us_expire_date}</td>
        {/if}
    </tr>
{/if}
<tr>
    <th>{if !isset($lbl.um_status)}{t}Stato{/t}{else}{$lbl.um_status}{/if}:</th>
    <td colspan="5">
        {if $act != 'show'}
            <select name="us_status">
                <option {if $vlu.us_status == 'E'} selected {/if} value="E">{if !isset($lbl.um_enabled)}{t}Attivo{/t}{else}{$lbl.um_enabled}{/if}</option>
                <option {if $vlu.us_status != 'E'} selected {/if}value="D">{if !isset($lbl.um_disabled)}{t}Non attivo{/t}{else}{$lbl.um_disabled}{/if}</option>
            </select>
        {else}
            <input type="text" name="us_status" value="{if $vlu.us_status == 'E'}{t}Attivo{/t}{else}{t}Non attivo{/t}{/if}" class="input_readonly" readOnly />
        {/if}
    </td>
</tr>

{* Questi compi vengono presi dalla configurazione *}
{assign var='position_for_extra_fields' value=''}
{include file='users/users_edit_extra_fields.tpl'}
{*
{foreach from=$extra_fields key=k1 item=v1 name=foo}
{if strToUpper($v1.position) != 'TOP'}
{if $smarty.foreach.foo.first || $wrap != 'no'}
<tr>
{/if}

{ * label * }
<th><label for="{$k1}">{$v1.label}</label></th>
{ * campo * }
<td {if $v1.wrap != 'no'}colspan="3"{/if}>
    {if $v1.type == 'string' || $v1.type == 'email' || $v1.type == 'integer'}
        <input type="text" name="{$k1}" id="{$k1}" value="{$v1.value}" {if $v1.size}style="width:{$v1.size}px;"{/if} {if $v1.maxlength}maxlength="{$v1.maxlength}"{/if} onBlur="checkField(this, '{$v1.type}')" {if $act == 'show'}class="input_readonly" readOnly {/if}>
    {elseif $v1.type == 'text'}
        <textarea name="{$k1}" id="{$k1}" {if $v1.size}style="width:{$v1.size[0]}px; height:{$v1.size[1]}px;"{/if} onBlur="checkField(this, '{$v1.type}')" {if $act == 'show'}class="input_readonly" readOnly {/if}>{$v1.value}</textarea>
    {elseif $v1.type == 'select'}
        {if $act != 'show'}
            <select name="{$k1}" id="{$k1}" {if $v1.size}style="width:{$v1.size}px;"{/if}>
                {html_options options=$v1.values selected=$v1.value}
            </select>
        {else}
            <input type="text" name="{$k1}" id="{$k1}" value="{$v1.values[$v1.value]}" {if $v1.size}style="width:{$v1.size}px;"{/if} class="input_readonly" readOnly>
        {/if}
    {/if}
</td>

{if $smarty.foreach.foo.last || $wrap}
    </tr> 
{/if}

{ * Imposto una variabile snarty per indicare se devo andare a capo (genero </tr><tr>) * }
    {if $v1.wrap == 'no'}
        {assign var='wrap' value='no'}
    {else}
        {assign var='wrap' value=''}
    {/if}
    {/if}      
        {/foreach}
            *}

            {if $USER_CONFIG_USER_MANAGER_HAS_IP_LIST != 'F'}
            <tr>
                <th>{if !isset($lbl.um_ip_address)}{t}Indirizzi IP per l'accesso{/t}{else}{$lbl.um_ip_address}{/if}:</th>
                <td colspan="3"><textarea name="us_ip" style="width:450px;height:50px;">{$ip_list}</textarea></td>
            </tr>
        {/if}
        <tr>
            <td colspan="4" class="separator"></td>
        </tr>
        <tr>
            <td colspan="4" {if $act != 'show'}style="padding:0px;"{/if}>

                {if count($grp_perm) > 1}
                    {literal}
                        <style>
                            .tab_text {
                                background-color:#b1b1b1;
                                border:1px solid #999999;
                                padding:5px;
                                height:25px;
                                text-decoration:none;
                            }
                            .tab_text:hover {
                                background-color:#FFFFFF;
                            }
                            .tab_text_select {
                                background-color:#e5e5e5;
                            }
                        </style>
                    {/literal}
                    {foreach from=$grp_perm key=k1 item=v1 name=sw}
                        {if $act != 'show'}
                            {if $v1.max_groups != '0' || $v1.has_user_perm != 'F' || $v1.has_user_perm_negate != 'F'}
                                <a id="tab_{$k1}" href="JavaScript:enableTab('{$k1}')">{$v1.name}</a>
                                {* if !$smarty.foreach.sw.last} | {/if *}
                            {/if}
                        {else}
                            {foreach from=$v1.groups key=k2 item=v2}
                                {if $v2.status == 'ON'}
                                    <span id="tab_{$k1}"><strong>{$v1.name}:</strong>&nbsp;{$v2.gr_name};</span>
                                {/if}
                            {/foreach}
                        {/if}
                    {/foreach}
                    <br>




                    {foreach from=$grp_perm key=k1 item=v1}
                        {if $act == 'show'}
                            {* Do nothing *}
                        {else}
                            <div id="application_{$k1}" style="display: none">
                                {if count($grp_perm) <= 1}
                                    <div style="background-color:#e5e5e5; padding:3px; font-weight:bold;">{$v1.name}</div>
                                {/if}
                                <table style="margin:2px; ">
                                    <tr>
                                        {if $v1.max_groups != '0'}
                                            <th style="text-align:left;">{if !isset($lbl.um_group)}{t}Gruppo{/t}{else}{$lbl.um_group}{/if}</th>
                                        {/if}
                                        {if $v1.has_user_perm != 'F'}
                                            <th style="text-align:left;">{if !isset($lbl.um_privileges)}{t}Privilegi{/t}{else}{$lbl.um_privileges}{/if}</th>
                                        {/if}
                                        {if $v1.has_user_perm_negate != 'F'}
                                            <th style="text-align:left;">{if !isset($lbl.um_invalid_privileges)}{t}Privilegi negati{/t}{else}{$lbl.um_invalid_privileges}{/if}</th>
                                        {/if}
                                    </tr>
                                    <tr>
                                        {if $v1.max_groups != '0'}
                                            <td valign="top">
                                                <input type="hidden" name="selectedGroups_{$k1}" value="">
                                                <select name="groups_{$k1}" {if $v1.max_groups != '1'} multiple style="height:150px;width:150px;" {else} style="width:150px;" {/if} > 

                                                    {if $v1.max_groups == '1' && $v1.group_mandatory != 'T'}
                                                        <option value=""></option>
                                                    {/if}      

                                                    {foreach from=$v1.groups key=k2 item=v2}
                                                        {* SS: salvato in campo hidden selectedGroups_<nome_applicazione>*}
                                                        <option value="{$v2.gr_name}" {if $v2.status == 'ON'}selected{/if}>{$v2.gr_name}</option>
                                                    {/foreach}
                                                </select>
                                            </td>
                                        {/if}

                                        {if $v1.has_user_perm != 'F'}
                                            <td>
                                                <input type="hidden" name="selectedPerms_{$k1}" value="">
                                                <select name="perms_{$k1}" multiple style="height:150px;width:200px;"> 
                                                    {foreach from=$v1.perms key=k2 item=v2}
                                                        {* SS: salvato in campo hidden selectedPerms_<nome_applicazione>*}
                                                        <option value="{$v2.ac_verb}|{$v2.ac_name}" {if $v2.ua_status == 'ALLOW'}selected{/if}>{$v2.ac_verb} {$v2.ac_name}</option>
                                                    {/foreach}
                                                </select>
                                            </td>
                                        {/if}

                                        {if $v1.has_user_perm_negate != 'F'}
                                            <td>
                                                <input type="hidden" name="selectedPerms_n_{$k1}" value="">
                                                <select name="perms_n_{$k1}" multiple style="height:150px;width:200px;"> 
                                                    {foreach from=$v1.perms_n key=k2 item=v2}
                                                        {* SS: salvato in campo hidden selectedPerms_n_<nome_applicazione>*}
                                                        <option value="{$v2.ac_verb}|{$v2.ac_name}" {if $v2.ua_status == 'ALLOW'}selected{/if}>{$v2.ac_verb} {$v2.ac_name}</option>
                                                    {/foreach}
                                                </select>
                                            </td>
                                        {/if}

                                    </tr>
                                    {if $v1.max_groups > 1 || $v1.has_user_perm != 'F' || $v1.has_user_perm_negate != 'F' }
                                        <tr>
                                            <td colspan="4">{if !isset($lbl.um_select_multiple)}{t}Ctrl + click per selezioni multiple{/t}{else}{$lbl.um_select_multiple}{/if}</td>
                                        </tr>
                                    {/if}
                                </table>
                            </div>
                        {/if}
                    {/foreach}
                {/if} {* /if of count($grp_perm) > 1 *}

            </td>
        </tr>
    </table>

    <br>
    {if $act != 'show'}
        <input type="button" name="btnSave"   value="{if !isset($btn.save)}{t}Salva{/t}{else}{$btn.save}{/if}" onclick="submitForm();" style="height:25px;width:70px;" />
        <input type="button" name="btnCancel"  value="{if !isset($btn.abort)}{t}Annulla{/t}{else}{$btn.abort}{/if}"  onClick="showList();" style="height:25px;width:70px;" />
    {else}
        <input type="button" name="btnBack"  value="{if !isset($btn.back)}{t}Indietro{/t}{else}{$btn.back}{/if}" onClick="showList();" style="height:25px;width:70px;" />
        {if $USER_CAN_ADD_USER}
            <input type="button" name="btnEdit"  value="{if !isset($btn.edit)}{t}Modifica{/t}{else}{$btn.edit}{/if}" onClick="do_edit();" style="height:25px;width:70px;" />
        {/if}
    {/if}
    {/if}   {* if $dn_name == '' *}


    </form>

    {literal}
        <script>
            if (document.modForm.app_code && !document.modForm.app_code.disabled) {
                document.modForm.app_code.focus();
            } else if (document.modForm.us_name && !document.modForm.us_name.readOnly && !document.modForm.us_name.type != 'hidden') {
                try {
                    document.modForm.us_name.focus();
                    document.modForm.us_name.select();
                } catch (e) {
                }
            }
    
        {/literal}
        {* attivo tab di defautl *}
        {foreach from=$grp_perm key=k1 item=v1 name=sw}
            try {literal}{{/literal}
            {if $smarty.foreach.sw.first}
                    enableTab('{$k1}'); 
            {elseif $k1 == $smarty.const.APPLICATION_CODE}
                    enableTab('{$k1}');
            {/if}
            {literal}
                } catch (e) {
                }
            {/literal}
        {/foreach}
        {literal}
            if (document.modForm.us_password)    setTimeout("document.modForm.us_password.value = ''", 100);
            if (document.modForm.us_password2)   setTimeout("document.modForm.us_password2.value = ''", 100);
        </script>
    {/literal}
    {if $message != ''}
        <script>
                alert("{$message}");
        </script>
    {/if}

</body>
</html>