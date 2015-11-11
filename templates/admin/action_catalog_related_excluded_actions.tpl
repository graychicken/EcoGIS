<tr class="tplRelatedExcludedActions">
    <td colspan="4" nowrap>
        <select rel="related_actions" name="related_excluded_action_id[]" style="width:650px;" id="related_excluded_action_{$n}">
            <option value="">{t}-- Selezionare --{/t}</option>
            {foreach from=$lkp.ac_related_actions_list item=related_action}
            <option {if !empty($vlu_excluded.ac_id) && $related_action.ac_id==$vlu_excluded.ac_id}selected{/if} value="{$related_action.ac_id}">{$related_action.name}</option>
            {/foreach}
        </select>
    </td>
    {if $act <> 'show'}
    <td><img src="../images/ico_del_small.gif" title="{t}Elimina{/t}" alt="{t}Elimina{/t}" class="btnRemoveRelatedExcludedActions" /></td>
    {/if}
</tr>