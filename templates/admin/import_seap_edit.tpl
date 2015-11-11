{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

<h3 id="page_title">{$page_title}</h3>

{literal}
    <script language="JavaScript" type="text/javascript">

        function askDelImportSeap(doc_id) {
            ajaxConfirm('edit.php', {
                'on': 'import_seap',
                'id': doc_id,
                'method': 'confirmDeleteImport'}, function () {
                delImportSeap(doc_id, function () {
                    addObject()
                });
            });
        }

        $(document).ready(function () {

            $('#btnSave').bind('click', function () {
                $('input[type=button]').prop('disabled', true);
                $.getJSON('edit.php', {
                    'on': $('#on').val(),
                    'mu_id': $('#mu_id').val(),
                    'method': 'checkImport'
                }, function (response) {
                    $('input[type=button]').prop('disabled', false);
                    if (response.status == 'OK') {
                        var canImport = true;
                        if (response.alert) {
                            canImport = false;
                            alert(response.alert);
                        } else if (response.confirm) {
                            if (!confirm(response.confirm)) {
                                canImport = false;
                            }
                        }
                        if (canImport) {
                            submitFormDataDocument('#modform');
                        }
                    } else {
                        alert('Error');
                    }
                });
            });

            $('#btnCancel,#btnBack').bind('click', function () {
                listObject();
            });
            $('#download_document').bind('click', function () {
                downloadDocument($('#doc_file_id').val(), 'import_seap');
            });
            $('#btnDelete').bind('click', function () {
                askDelImportSeap($('#doc_id').val(), 'import_seap');
            });

            if ($('#act').val() != 'show') {
                setupInputFormat('#modform');
            }
            initChangeRecord();
            $('#modform').show();
            $("#progressbar").progressbar({value: 100});
        });

    </script>
{/literal}

<div {if $vlu.doc_id==0}class="info_container"{/if}><img border="0" src="../images/icons/ico_xls.gif"> {t}Per importare i dati, bosogna scaricare il{/t} <b><a href="getfile.php?type=download&file=Template_Import_PAES.xls&disposition=download&">{t}template vuoto{/t}</a></b> {t}in formato Microsoft Excel, compilarlo e caricarlo.{/t}</div>

<form name="modform" id="modform" action="edit.php?method=submitFormData" method="post" style="xdisplay: none">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="doc_file_id" id="doc_file_id" value="{$vlu.doc_file_id}">
    <input type="hidden" name="doc_id" id="doc_id" value="{$vlu.doc_id}">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="{$key}" value="{$val}" />
    {/foreach}

    {* tabella paes *}
    <table class="table_form" xstyle="width: 850px;">
        <tr class="evidence"><td colspan="6">{t}Import template PAES{/t}</td></tr>
        <tr {if $lkp.mu_values.tot.municipality == 1}style="display: none"{/if}>
            <th><label class="required" for="mu_id">{if $lkp.mu_values.tot.collection > 0}{t}Comune/raggruppamento{/t}{else}{t}Comune{/t}{/if}:</label></th>
            <td>
                <select name="mu_id" id="mu_id" style="width:250px" >
                    {if $lkp.mu_values.tot.municipality > 1}<option value="">{t}-- Selezionare --{/t}</option>{/if}
                    {html_options options=$lkp.mu_values.data selected=$vlu.mu_id}
                </select>
            </td>
        </tr>

        {if $act <> 'add'}
            <tr>
                <th><label class="required" for="gst_name_1">{t}Template caricato{/t}:</label></th>
                <td><a href="#" id="download_document">{$vlu.doc_file}</a></td>
            </tr>

            <tr>
                {if $vlu.doc_data|@count > 0}
                    <th><label class="required" for="gst_name_1">{t}Log import{/t}:</label></th>
                    <td>
                        <ul>
                            {foreach from=$vlu.doc_data item=row}
                                {if $row.level <> 'debug'}
                                    <li class='log_{$row.level}'>{$row.message}</li>
                                    {/if}
                                {/foreach}
                        </ul>
                    </td>
                {else}
                    <td></td>
                    <td>Import avvenuto con successo</td>
                {/if}
            </tr>
        {/if}
        {if $act == 'add'}
            <tr>
                <th><label for="doc_file">{t}File{/t}{if $act <> 'show'} (Max {$config.upload_max_filesize}B){/if}:</label></th>
                <td>
                    <input type="file" name="doc_file[]" id="doc_file" maxlength="1" accept="xls|xlsx" class="upload" size="20">
                    <div id="progressbar_wrapper" style="height:7px; width: 200px; display: none" class="ui-widget-default">
                        <div id="progressbar" style="height:100%;"></div>
                    </div>
                </td>
            </tr>
        {/if}
        <tr><td colspan="2">{include file="record_change.tpl"}</td></tr>

    </table>
    <br />

    {if $vlu.doc_id>0}
        <input type="button" id="btnDelete" name="btnDelete"  value="{t}Elimina dati importati{/t}" style="width:150px;height:25px;" />
    {else}
        <input type="button" id="btnSave" name="btnSave"  value="{t}Importa{/t}"    style="width:150px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
    {/if}

    {if $vars.stay_to_edit <> 'T'}
        <input type="button" name="btnCancel" id="btnCancel" value="{t}Torna alla lista{/t}" style="width:150px;height:25px;">
    {/if}
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}