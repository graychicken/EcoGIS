{* UTF-8 FILE: òàèü *}
{* Questi compi vengono presi dalla configurazione *}
{* ATTENTION: var position_for_extra_fields should be set before including this file *}
{foreach from=$extra_fields key=k1 item=v1 name=foo}
  {if strToUpper($v1.position) == $position_for_extra_fields}
    {if $smarty.foreach.foo.first || $wrap != 'no'}
    <tr>
    {/if}
  
    {* label *}
    <th><label for="{$k1}">{$v1.label}:</label></th>
    {* campo *}
    <td {if $v1.wrap != 'no'}colspan="3"{/if}>
    {if $v1.type == 'string' || $v1.type == 'email' || $v1.type == 'integer'}
    <input type="text" name="{$k1}" id="{$k1}" value="{$v1.value|escape:'html'}" {if $v1.size}style="width:{$v1.size}px;"{/if} {if $v1.maxlength}maxlength="{$v1.maxlength}"{/if} onBlur="checkField(this, '{$v1.type}')" {if $act == 'show'}class="input_readonly" readOnly {/if}>
    {elseif $v1.type == 'text'}
    <textarea name="{$k1}" id="{$k1}" {if $v1.size}style="width:{$v1.size[0]}px; height:{$v1.size[1]}px;"{/if} onBlur="checkField(this, '{$v1.type}')" {if $act == 'show'}class="input_readonly" readOnly {/if}>{$v1.value|escape:'html'}</textarea>
    {elseif $v1.type == 'select' || $v1.type == 'select-multiple'}
      {if $act != 'show'}
      <select name="{$k1}" id="{$k1}" {if $v1.type == 'select-multiple'}multiple="multiple"{/if}>
        {html_options options=$v1.values selected=$v1.value}
      </select>
      {else}
      {if is_array($v1.value)}
      <textarea type="html" name="{$k1}" id="{$k1}" class="input_readonly" readOnly> - {foreach from=$v1.value item=valueIndex}{$v1.values[$valueIndex]} - {/foreach}</textarea>
      {else}
      <input type="text" name="{$k1}" id="{$k1}" value="{$v1.values[$v1.value]}" {if $v1.size}style="width:{$v1.size}px;"{/if} class="input_readonly" readOnly>
      {/if}
      {/if}
    {/if}
    </td>
  
    {if $smarty.foreach.foo.last || $wrap}
    </tr> 
    {/if}
  
    {* Imposto una variabile snarty per indicare se devo andare a capo (genero </tr><tr>) *}
    {if $v1.wrap == 'no'}
    {assign var='wrap' value='no'}
    {else}
    {assign var='wrap' value=''}
    {/if}
  {/if}      
{/foreach}