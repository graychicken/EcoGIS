{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}

{$xajax_js_include}

<script type="text/javascript" language="javascript">

    var timer = null;
    
    function disableControls(status) {ldelim}
    
    document.modForm.btnSave.disabled = status;
    document.modForm.btnCancel.disabled = status;
    {rdelim}
    
    function xajaxCallFaild() {ldelim}
        
    if (typeof js_html_entity_decode == "function")
        alert(js_html_entity_decode('{if !isset($txt.timeout_server)}{t}Timeout del server. Riprovare!{/t}{else}{$txt.timeout_server}{/if}'));
    else
        alert('{if !isset($txt.timeout_server)}{t}Timeout del server. Riprovare!{/t}{else}{$txt.timeout_server}{/if}');
    disableControls(false);
    {rdelim}
    
    function formCheckDone() {ldelim}
    if('{$popup}' == 't'){ldelim}
    window.close();
    if('{$list_uri}' != ''){ldelim}
    window.opener.top.window.location = "../../{$list_uri}";
    {rdelim}
    return;
    {rdelim}
    
    try {ldelim}
    clearTimeout(timer);
    {rdelim} catch (e) {ldelim}
    {rdelim}
    document.modForm.us_password.value = '';
    document.modForm.us_password2.value = '';
    if (typeof js_html_entity_decode == "function")
        alert(js_html_entity_decode('{if !isset($txt.store_successful)}{t}Salvataggio avvenuto con successo!{/t}{else}{$txt.store_successful}{/if}'));
    else
        alert('{if !isset($txt.store_successful)}{t}Salvataggio avvenuto con successo!{/t}{else}{$txt.store_successful}{/if}');
    unlockScreen();
    disableControls(false);
    
    // SS: Called parent function
    if (parent.parent.userSettingsChanged) {ldelim}
    parent.parent.userSettingsChanged(status);
    {rdelim}
    // document.location='personal_settings.php';
    {rdelim}
    
    function formCheckError(text, element_name) {ldelim}

    try {ldelim}
    clearTimeout(timer);
    {rdelim} catch (e) {ldelim}
    {rdelim}
    if (typeof js_html_entity_decode == "function")
        alert(js_html_entity_decode(text));
    else
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

    function checkField(e, type) {ldelim}
    // Nothing to check      
    {rdelim}
    
    function submitForm() {ldelim}

    timer = setTimeout("xajaxCallFaild()", 10000);
    disableControls(true);
    xajax_submitForm(getAllValues(), "formCheckDone", "formCheckError");
    {rdelim}
    
    
    
    /** lock the outside part of the software */
    function getTopPosition(obj) {ldelim}
    
    y = 0;
    tmpobj = obj;
    while (tmpobj.offsetParent != null) {ldelim}
    y += tmpobj.offsetTop;
    tmpobj = tmpobj.offsetParent;
    {rdelim}
    y += tmpobj.offsetTop;
    return y;
    {rdelim}
    
    function getLeftPosition(obj) {ldelim}
    
    x = 0;
    tmpobj = obj;
    while (tmpobj.offsetParent != null) {ldelim}
    x += tmpobj.offsetLeft;
    tmpobj = tmpobj.offsetParent;
    {rdelim}
    x += tmpobj.offsetLeft;
    return x;
    {rdelim}
    
    function lockScreen() {ldelim}
    
		if (!top) {ldelim}
			// No top to lock
			return; 
		{rdelim}
		var lockIFrame = top.document.getElementById('lockIFrame');
		if (!lockIFrame) {ldelim}
			var lockIFrame=top.document.createElement('iframe');
			lockIFrame.setAttribute('id','lockIFrame');
			lockIFrame.style.border='0px';
			lockIFrame.scrolling = 'no';
		{rdelim} else {ldelim}
			lockIFrame.style.display = '';
		{rdelim}
		lockIFrame.src = "javascript:document.write('');";
		lockIFrame.style.position="absolute";
		lockIFrame.style.left = '0px';
		lockIFrame.style.top = '0px';
		lockIFrame.style.width = '100%';
		lockIFrame.style.height = '100%';
        
		lockIFrame.style.filter = 'alpha(opacity=40)';
		lockIFrame.style.opacity = '0.4';
		lockIFrame.style.background = '#ffffff';
		
		lockIFrame.style.zIndex = 1000000;  // very high number
		IFrameObj = top.document.body.appendChild(lockIFrame);
        
		var frameworkIFrame = top.document.getElementById('framework');
		if (!frameworkIFrame) {ldelim}
			frameworkIFrame = top.document.getElementById('R3FrameworkID');
		{rdelim}
		
		if (frameworkIFrame) {ldelim}
			if (jQuery) {ldelim}
				var td = jQuery(frameworkIFrame).parent();
				td.width(td.width());
			{rdelim}
			frameworkIFrame.style.left = getLeftPosition(frameworkIFrame) + 'px';
			frameworkIFrame.style.top = getTopPosition(frameworkIFrame) + 'px';
			frameworkIFrame.style.width = '650';
			frameworkIFrame.style.height = '450';
			frameworkIFrame.style.position="absolute";
			frameworkIFrame.style.zIndex = 1000001;  // very high number + 1
		{rdelim}
    {rdelim}
    
    function unlockScreen() {ldelim}
    
    if (!top) {ldelim}
    // No top to un lock
    return; 
    {rdelim}
    var lockIFrame = top.document.getElementById('lockIFrame');
    if (!lockIFrame) {ldelim}
    // No lock frame
    return;
    {rdelim}
        
    lockIFrame.style.display = 'none';
    {rdelim}


    {if $status}

    var status = '{$status}';

    function lock() {ldelim}
    lockScreen();
    if (typeof js_html_entity_decode == "function")
        alert(js_html_entity_decode('{$statusText}'));
    else
        alert('{$statusText}');
    if (document.modForm.us_password && !document.modForm.us_password.disabled) {ldelim}
    document.modForm.us_password.focus();
    {rdelim}
    {rdelim}
    
    window.onload=function() {ldelim}
    /** timer needed for firefox */
    setTimeout('lock()', 100);
    {rdelim};
    

    window.onunload=function() {ldelim}
    unlockScreen();
    {rdelim};
    {/if}
    
</script>

<h3>{if !isset($lbl.um_title)}{t}Impostazioni personali{/t}{else}{$lbl.um_title}{/if}</h3>

{* SS: per AL: Verificare tutte le action delle varie form gestione utenti *}

<form name="modForm" method="post" autocomplete="off">

    <table class="um_table_form app_table_form">
        {* Questi compi vengono presi dalla configurazione *}
        {foreach from=$extra_fields key=k1 item=v1 name=foo}
        {if strToUpper($v1.position) == 'TOP'}
        {if $v1.kind[0] != 'H'} 
        {if $smarty.foreach.foo.first || $wrap != 'no'}
        <tr>
            {/if}
            {* label *}
            <th><label for="{$k1}">{$v1.label}</label></th>
            {* campo *}
            <td {if $v1.wrap != 'no' && $colspan_count<>1}colspan="3"{/if}>
                {if $v1.type == 'string' || $v1.type == 'email' || $v1.type == 'integer' || ($v1.type == 'select' && $v1.kind[0] == 'R')}
                <input type="text" name="{$k1}" id="{$k1}" value="{$v1.value}" {if $v1.size}style="width:{$v1.size}px;"{/if} {if $v1.maxlength}maxlength="{$v1.maxlength}"{/if} {if $v1.kind[0] == 'R'}readonly class="input_readonly" tabindex="-1"{/if} onBlur="checkField(this, '{$v1.type}')">
                {elseif $v1.type == 'text'}
                <textarea name="{$k1}" id="{$k1}" {if $v1.size}style="width:{$v1.size[0]}px; height:{$v1.size[1]}px;"{/if} {if $v1.kind[0] == 'R'}readonly disabled{/if} onBlur="checkField(this, '{$v1.type}')">{$v1.value}</textarea>
                {elseif $v1.type == 'select'}
                <select name="{$k1}" id="{$k1}" {if $v1.size}style="width:{$v1.size}px;"{/if}>
                {html_options options=$v1.values selected=$v1.value}
                </select>
				{/if}
			</td>
			{if $smarty.foreach.foo.last || $wrap}
			</tr>
			{/if}
		{/if}
		{* Imposto una variabile smarty per indicare se devo andare a capo (genero </tr><tr>) *}
        {if $v1.wrap == 'no'}
        {assign var='wrap' value='no'}
		{assign var='colspan_count' value=1}
        {else}
        {assign var='wrap' value=''}
		{assign var='colspan_count' value=''}
        {/if}
        {/if}
        {/foreach}
		<tr>
			<th>{if !isset($lbl.um_name)}{t}Nome utente{/t}{else}{$lbl.um_name}{/if}</th>
			<td colspan="3"><input type="text" name="us_name" value="{$vlu.us_name}" style="width:100%;" class="input_readonly" readonly tabindex="-1" /></td>
		</tr>
		<tr>
			<th>{if !isset($lbl.um_login)}{t}Login{/t}{else}{$lbl.um_login}{/if}</th>
			<td colspan="3"><input type="text" name="us_login" value="{$vlu.us_login}" style="width:100%;" class="input_readonly" readonly tabindex="-1" /></td>
		</tr>
		{if $canChangePassword}
		{* Password su server esterni potrebbero essere fisse *}
		<tr>
			<th>{if !isset($lbl.um_password)}{t}Password{/t}{else}{$lbl.um_password}{/if}</th>
			<td><input type="password" name="us_password" style="width:150px;" {$view_style} /></td>
			<th>{if !isset($lbl.um_password_repeat)}{t}Ripeti password{/t}{else}{$lbl.um_password_repeat}{/if}</th>
			<td><input type="password" name="us_password2" style="width:150px;" {$view_style} /></td>
		</tr>
		{if $vlu.us_pw_expire != ''}
		<tr>
			<th>{if !isset($lbl.um_password_expire)}{t}Scadenza password{/t}{else}{$lbl.um_password_expire}{/if}</th>
			<td colspan="3"><input type="text" name="us_pw_expire" style="width:80px;" value="{$vlu.us_pw_expire}" class="input_readonly" readonly disabled /> {if !isset($lbl.um_password_day)}{t}giorni{/t}{else}{$lbl.um_password_day}{/if}</td>
		</tr>
		{/if}
		{/if}    

		{* Questi compi vengono presi dalla configurazione *}
		{foreach from=$extra_fields key=k1 item=v1 name=foo}
		{if strToUpper($v1.position) != 'TOP'}
		{if $v1.kind[0] != 'H'} 
		{if $smarty.foreach.foo.first || $wrap != 'no'}
		<tr>
        {/if}
        {* label *}
        <th><label for="{$k1}">{$v1.label}</label></th>
        {* campo *}
        <td {if $v1.wrap != 'no' && $colspan_count<>1}colspan="3"{/if}>
            {if $v1.type == 'string' || $v1.type == 'email' || $v1.type == 'integer' || ($v1.type == 'select' && $v1.kind[0] == 'R')}
            <input type="text" name="{$k1}" id="{$k1}" value="{$v1.value}" {if $v1.size}style="width:{$v1.size}px;"{/if} {if $v1.maxlength}maxlength="{$v1.maxlength}"{/if} {if $v1.kind[0] == 'R'}readonly class="input_readonly" tabindex="-1"{/if} onBlur="checkField(this, '{$v1.type}')">
               {elseif $v1.type == 'text'}
               <textarea name="{$k1}" id="{$k1}" {if $v1.size}style="width:{$v1.size[0]}px; height:{$v1.size[1]}px;"{/if} {if $v1.kind[0] == 'R'}readonly disabled{/if} onBlur="checkField(this, '{$v1.type}')">{$v1.value}</textarea>
            {elseif $v1.type == 'select'}
            <select name="{$k1}" id="{$k1}" {if $v1.size}style="width:{$v1.size}px;"{/if}>
            {html_options options=$v1.values selected=$v1.value}
			</select>
			{/if}
		</td>
		{if $smarty.foreach.foo.last || $wrap}
		</tr> 
		{/if}
		{/if}
		{* Imposto una variabile snarty per indicare se devo andare a capo (genero </tr><tr>) *}
		{if $v1.wrap == 'no'}
		{assign var='wrap' value='no'}
		{assign var='colspan_count' value=1}
		{else}
		{assign var='wrap' value=''}
		{assign var='colspan_count' value=''}
		{/if}
		{/if}
		{/foreach}
</table>

<br />
{if $popup == 't'}
<input type="button" name="btnSave"   value="{if !isset($btn.save)}{t}Salva{/t}{else}{$btn.save}{/if}" onclick="submitForm();" style="height:25px;width:70px;" />
<input type="button" name="btnCancel" value="{if !isset($btn.abort)}{t}Annulla{/t}{else}{$btn.abort}{/if}"  onClick="javascript:window.close();"  style="height:25px;width:70px;" />
{else}
<input type="button" name="btnSave"   value="{if !isset($btn.save)}{t}Salva{/t}{else}{$btn.save}{/if}" onclick="submitForm();" style="height:25px;width:70px;" />
<input type="button" name="btnCancel"  {if $status}disabled{/if} value="{if !isset($btn.abort)}{t}Annulla{/t}{else}{$btn.abort}{/if}"  onClick="document.location='personal_settings.php'" style="height:25px;width:70px;" />
       {/if}

       {if !$status}{literal}
<script language="JavaScript">
    if (document.modForm.us_password && !document.modForm.us_password.disabled) {
        try {
            document.modForm.us_password.focus();
        } catch (e) {
        }
        
    }
</script>
{/literal}{/if}
</form>

</body>
</html>
