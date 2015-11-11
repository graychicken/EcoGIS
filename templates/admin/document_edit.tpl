{include file="header_ajax.tpl"}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#popup_modform .help').bind('click', function () {
                showR3Help('document', this)
            });
            $('#popup_btnSave').bind('click', function () {
                submitFormDataDocument('#popup_modform');
            });
            $('#popup_btnCancel').bind('click', function () {
                closeR3Dialog()
            });

            if ($('#popup_act').val() == 'show') {
                setupShowMode('popup');  // Setup the show mode
                setupInputFormat('#popup_modform', false);
            } else {
                setupInputFormat('#popup_modform');
                setupRequired('#popup_modform');
                $('#popup_modform .date').datepicker('option', {yearRange: '-10:+0'});
            }

            $("#progressbar").progressbar({value: 100});

            $('#popup_modform').toggle(true);  // Show the form
            $('#popup_doc_title_1').focus();
            $('#antivirus_logo').fadeIn(2000);

        });
    </script>
{/literal}
<form name="modform" id="popup_modform" action="edit.php?method=submitFormData" method="post" style="display:none">
    <input type="hidden" name="on" id="popup_on" value="{$object_name}" />
    <input type="hidden" name="act" id="popup_act" value="{$act}">
    <input type="hidden" name="id" id="popup_doc_id" value="{$vlu.doc_id}">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" id="popup_{$key}" value="{$val}" />
    {/foreach}
    <table class="form">
        <tr>
            <th><label class="help required" for="popup_doc_title_1">{t}Titolo{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td><input type="text" name="doc_title_1" id="popup_doc_title_1" value="{$vlu.doc_title_1}" style="width:500px"></td>
        </tr>
        { if $NUM_LANGUAGES>1 }
        <tr>
            <th><label class="help required" for="popup_doc_title_2">{t}Titolo{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
            <td><input type="text" name="doc_title_2" id="popup_doc_title_2" value="{$vlu.doc_title_2}" style="width:500px"></td>
        </tr>
        { /if }
        </tr>
        <tr>
            <th><label class="help" for="popup_doc_descr_1">{t}Descrizione{/t}{$LANG_NAME_SHORT_FMT_1}:</label></th>
            <td>
                {if $act!='show'}
                    <textarea name="doc_descr_1" id="popup_doc_descr_1" style="width:500px; height:50px">{$vlu.doc_descr_1}</textarea>
                {else}
                    <div class="textarea_readonly">{$vlu.doc_descr_1}&nbsp;</div>
                {/if}
            </td>
        </tr>
        { if $NUM_LANGUAGES>1 }
        <tr>
            <th><label class="help" for="popup_doc_descr_2">{t}Descrizione{/t}{$LANG_NAME_SHORT_FMT_2}:</label></th>
            <td>
                {if $act!='show'}
                    <textarea name="doc_descr_2" id="popup_doc_descr_2" style="width:500px; height:50px">{$vlu.doc_descr_2}</textarea>
                {else}
                    <div class="textarea_readonly">{$vlu.doc_descr_2}&nbsp;</div>
                {/if}
            </td>
        </tr>
        { /if }
        <tr>
            <th><label class="help" for="popup_doc_date">{t}Data{/t}:</label></th>
            <td><input type="text" name="doc_date" id="popup_doc_date" value="{$vlu.doc_date}" class="date"></td>
        </tr>
        <tr>
            <th><label class="help" for="popup_doc_file">{t}File{/t}{if $act <> 'show'} (Max {$config.upload_max_filesize}B){/if}:</label></th>
            <td>
                {if $act == 'show'}
                    <input type="text" name="doc_file" id="popup_doc_file" value="{$vlu.doc_file}" size="80">
                {else}
                    <input type="file" name="doc_file[]" id="popup_doc_file" maxlength="1" class="upload" size="20">
                {/if}
                <div id="progressbar_wrapper" style="height:7px; width: 200px; display: none" class="ui-widget-default">
                    <div id="progressbar" style="height:100%;"></div>
                </div>
            </td>
        </tr>
        <tr><td colspan="2">{include file="record_change.tpl"}</td></tr>
    </table>
    <br />
    {* if $USER_CONFIG_APPLICATION_ANTIVIRUS_LOGO <> ''}<img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD|lower}/{$USER_CONFIG_APPLICATION_ANTIVIRUS_LOGO}" id="antivirus_logo" class="antivirus" alt="{t}Tutti i file caricati nel sistema vengono controllati con {/t}{$USER_CONFIG_APPLICATION_ANTIVIRUS_NAME}" title="{if $USER_CONFIG_APPLICATION_ANTIVIRUS_NAME <> ''}{t}Tutti i file caricati nel sistema vengono controllati con {/t}{$USER_CONFIG_APPLICATION_ANTIVIRUS_NAME}{/if}">{/if *}
    {if $act == 'show'}
        <input type="button" id="popup_btnCancel" name="popupBtnCancel"  value="{t}Chiudi{/t}" style="width:120px;height:25px;" />
    {else}
        <input type="button" id="popup_btnSave" name="popupBtnSave"  value="{t}Salva{/t}" style="width:120px;height:25px;" />&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="button" id="popup_btnCancel" name="popupBtnCancel"  value="{t}Annulla{/t}" style="width:120px;height:25px;" />
    {/if}
    {if $USER_CONFIG_APPLICATION_ANTIVIRUS_NAME <> ''}<div class="antivirus_msg">{t}Tutti i file caricati nel sistema vengono controllati con{/t} <strong>{$USER_CONFIG_APPLICATION_ANTIVIRUS_NAME}</strong></div>{/if}
</form>

{include file="footer_ajax.tpl"}