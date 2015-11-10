{if $vlu.ins_user <> '' || $vlu.mod_user <> ''}
    <table width="100%" class="table_form change_record">
        <tr class="separator">
            <td colspan="3"></td>
        </tr>
        <tr class="evidence openclose_evidence" style="cursor: pointer">
            <td colspan="3">
                <img class="openclose_evidence_img" src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_closed.gif" />
                <img class="openclose_evidence_img" src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/ico_opened.gif" style="display:none"/>
                {t}Ultima modifica{/t}:</td>
        </tr>

        {if $vlu.ins_date_fmt <> ''}
            <tr class="view_info openclose_evidence_row" style="display:none">
                <th style="width: 200px">{t}Inserimento:{/t}</th>
                <td style="width: 200px">{$vlu.ins_date_fmt}</td>
                <td>{$vlu.ins_user}</td>
            </tr>
        {/if}
        {if $vlu.mod_date_fmt <> ''}
            <tr class="view_info openclose_evidence_row" style="display:none">
                <th style="width: 200px">{t}Ultima modifica:{/t}</th>
                <td style="width: 200px">{$vlu.mod_date_fmt}</td>
                <td>{$vlu.mod_user}</td>
            </tr>
        {/if}
    </table>
{/if}