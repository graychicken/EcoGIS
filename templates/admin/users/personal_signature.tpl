{include file="users/header.tpl"}{* UTF-8 FILE: òàèü *}
<script type="text/javascript" src="{$smarty.const.R3_JS_URL}jquery/plugins/jquery.form.js"></script>
<script type="text/javascript" language="javascript">
function do_save() {ldelim}
    r3AjaxStart();
    $("#modForm").ajaxSubmit({ldelim}dataType: 'json', success: do_save_success{rdelim});
{rdelim}
function do_save_success(response) {ldelim}
    if (response.status == 0) {ldelim}
        $('#currentSignature').css('display', '');
        $('#us_signature_preview').attr('src', 'jquery_request.php?act=show_signature&'+response.random);
        $('#us_signature').val('');
    {rdelim} else {ldelim}
        alert(response.error);
    {rdelim}
    r3AjaxStop();
{rdelim}
function do_remove() {ldelim}
    r3AjaxStart();
    $.get("jquery_request.php", {ldelim}act: "del_signature"{rdelim}, do_remove_success);
{rdelim}
function do_remove_success(response) {ldelim}
    $('#currentSignature').css('display', 'none');
    r3AjaxStop();
{rdelim}
function do_abort() {ldelim}
    $(location).attr('href', 'personal_signature.php');
{rdelim}
function r3AjaxStart() {ldelim}
    $('#modForm :input[name=btnSave]').attr('disabled', true);
    $('#modForm :input[name=btnCancel]').attr('disabled', true);
    $('#modForm :input[name=btnRemove]').attr('disabled', true);
    $('#ajaxLoading').css('visibility', '');
{rdelim}
function r3AjaxStop() {ldelim}
    $('#ajaxLoading').css('visibility', 'hidden');
    $('#modForm :input[name=btnSave]').attr('disabled', false);
    $('#modForm :input[name=btnCancel]').attr('disabled', false);
    $('#modForm :input[name=btnRemove]').attr('disabled', false);
{rdelim}
</script>

<h3>{t}Impostazione firma digitale{/t}</h3>

{* SS: per AL: Verificare tutte le action delle varie form gestione utenti *}

<form id="modForm" name="modForm" method="post" action="jquery_request.php?act=add_signature" enctype="multipart/form-data">
<table class="um_table_form app_table_form">
    <tr id="currentSignature" {if !$showCurrentSignature}style="display:none;"{/if}>
        <th>{t}Firma attuale{/t}</th>
        <td><img id="us_signature_preview" src="jquery_request.php?act=show_signature" /></td>
    </tr>
    <tr>
        <th>{t}Nuova Firma{/t}</th>
        <td><input type="file" id="us_signature" name="us_signature" /><img id="ajaxLoading" src="../../images/ajax_loading.gif" style="visibility:hidden;" /></td>
    </tr>
</table>
<br />
<input type="button" name="btnSave"   value="{t}Salva{/t}" onclick="do_save();" style="height:25px;width:70px;" />
<input type="button" name="btnCancel" value="{t}Annulla{/t}" onClick="do_abort();" style="height:25px;width:70px;" />&nbsp;&nbsp;&nbsp;
<input type="button" name="btnRemove" value="{t}Cancella{/t}" onClick="do_remove();" style="height:25px;width:70px;" />
</form>
</body>
</html>