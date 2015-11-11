{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

<h3 id="page_title">{$page_title}</h3>

{literal}
    <script language="JavaScript" type="text/javascript">

        function submitFormDataLookup() {
            submitData('#modform');
        }

        function submitFormDataDoneLookup(id) {
            document.location = 'lookup_list.php?on=' + $('#on').val() + '&';
        }

        // Cancel the filter
        function listLookupObject() {
            ajaxWait(true);
            disableButton(true);
            document.location = 'lookup_list.php?on=' + $('#on').val() + '&';
        }

        $(document).ready(function () {
            $('#btnSave').bind('click', function () {
                submitFormDataLookup('#modform')
            });
            $('#btnCancel').bind('click', function () {
                listLookupObject()
            });
            if ($('#act').val() == 'show') {
                setupShowMode();  // Setup the show mode
                setupInputFormat('#modform', false);
            } else {
                setupInputFormat('#modform');
                setupRequired('#modform');
            }
            setupReadOnly('#modform');
            initChangeRecord();
        });
    </script>
{/literal}

{include file=inline_help.tpl}

<form name="modform" id="modform" action="lookup_edit.php?method=submitFormData" method="post">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="id" id="id" value="{$vlu.id}">
    {foreach from=$vars key=key item=val}
        <input type="hidden" name="{$key}" value="{$val}" />
    {/foreach}

    {* Campi hidden *}
    {foreach from=$form item=v}
        {if $v.type == 'hidden' || $v.visible=='F'}<input type="hidden" name="{$v.name}" id="{$v.name}" value="{$vlu[$v.name]}">{/if}
    {/foreach}

    <table class="table_form">
        {* Campi NON hidden *}
        {assign var='wrap' value='T'}
        {foreach from=$form key=k item=v1 name=foo}
            {if $v1.type != 'hidden' && $v1.type != 'constant' && $v1.kind[0] != 'H' && $v1.visible=='T'}
                {if $smarty.foreach.foo.first || $wrap == 'F'}
                    <tr>
                    {/if}
                    {* label *}
                    {if $v1.show_label == 'T'}
                        <th><label for="{$v1.name}">{$v1.label}{if $v1.required == 'T'}*{/if}</label>:</th>
                        {/if}
                        {* campo *}
                    <td {if $v1.wrap == 'T'}colspan="3"{/if}>
                        {if $v1.type == 'text' || $v1.type == 'number' || $v1.type == 'integer' || $v1.type == 'float'}
                            <input type="text"
                                   name="{$v1.name}"
                                   id="{$v1.name}"
                                   value="{$vlu[$v1.name]}"
                                   {if $v1.width}style="width:{$v1.width}px; {if $v1.type == 'number' || $v1.type == 'float' || $v1.type == 'integer'}text-align: right; {/if}"{/if}
                                   {if $v1.size}maxlength="{$v1.size}"{/if}
                                   class="{if $v1.kind[0] == 'R'}readonly {/if}{if $v1.type=='integer'}integer {/if}{if $v1.type=='number' || $v1.type=='float'}float {/if}"
                                   {if $v1.kind[0] == 'R'}tabindex="-1"{/if}>
                        {elseif $v1.type == 'date'}
                            {r3datepicker name=$v1.name value=$vlu[$v1.name]}
                        {elseif $v1.type == 'memo'}
                            <textarea name="{$v1.name}" id="{$v1.name}" {if $v1.width > 0 || $v1.height > 0}style="{if $v1.width > 0}width:{$v1.width}px{/if}; {if $v1.height > 0}height:{$v1.height}px{/if};"{/if} {if $v1.kind[0] == 'R'}readonly disabled{/if} {if $v1.mandatory}class="input_mandatory"{/if}>{$vlu[$v1.name]}</textarea>
                        {elseif $v1.type == 'boolean'}
                            <input type="checkbox" name="{$v1.name}" id="{$v1.name}" value="T" {if $vlu[$v1.name] == 'T'}checked{/if} {if $v1.kind[0] == 'R'}readonly disabled{/if} {if $v1.mandatory}class="input_mandatory"{/if}></th>
                        {elseif $v1.type == 'select'}
                            {if $v1.kind[0] == 'R'}
                                {assign var='cur_id' value=$vlu[$v1.name]}
                                <input type="hidden" name="{$v1.name}" id="{$v1.name}" value="{$vlu[$v1.name]}" />
                                <input name="{$v1.name}_dummy" id="{$v1.name}_dummy" value="{$v1.data[$cur_id]}"{if $v1.width}style="width:{$v1.width}px;"{/if} class="readonly" disabled>
                            {else}
                                <select name="{$v1.name}" id="{$v1.name}" {if $v1.width}style="width:{$v1.width}px;"{/if}>
                                    {html_options options=$v1.data selected=$vlu[$v1.name]}
                                </select>
                            {/if}
                        {/if}
                    </td>
                    {if $smarty.foreach.foo.last || $wrap == 'T'}
                    </tr> 
                {/if}
                {* Imposto una variabile snarty per indicare se devo andare a capo (genero </tr><tr>) *}
                {if $v1.wrap == 'F'}
                    {assign var='wrap' value='F'}
                {else}
                    {assign var='wrap' value='T'}
                {/if}
            {/if}
        {/foreach}
        <tr>
        <tr><td colspan="2">{include file="record_change.tpl"}</td></tr>
        <td colspan="2">
            {if $act == 'show'}
                <input type="button" name="btnCancel" id="btnCancel" value="{t}Indietro{/t}" style="width:70px;" />
            {else}
                <input type="button" name="btnSave" id="btnSave" value="{t}Salva{/t}" style="width:70px;" />
                <input type="button" name="btnCancel" id="btnCancel" value="{t}Annulla{/t}" style="width:70px;" />
            {/if}
        </td>  
        </tr>  
    </table>
</form>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}