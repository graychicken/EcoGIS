<table class="catalog actions" width="100%">
    {* TABLE HEADER *}
    <tr>
        <th rowspan="2">{t}Settori{/t}</th>
            {if $vlu.table=='NORMAL'}
            <th rowspan="2">{t}Nome{/t}</th>
            <th rowspan="2">{t}Azioni principali{/t}</th>
            {/if}
        <th colspan="{$vlu.years|@count}" width="{math equation="x * 80" x=$vlu.years|@count}">{$vlu.summarytype_list[$vlu.type]}</th>
            {* <th rowspan="2" width="80">{t}Totale{/t}</th> *}
    </tr>
    {if $vlu.years|@count>0}
        <tr>
            {foreach from=$vlu.years item=year}
                <th>{$year}</th>
                {/foreach}
        </tr>
        {if $vlu.table=='NORMAL'}

            {foreach from=$vlu.data key=key item=data}
                {if $vlu.macro_category==''}
                    <tr class="selected_row_summary-{$key}" >
                        <td style="text-align:left;font-weight:bold;color:white;background-color: #330099" colspan="{math equation="x + 3" x=$vlu.years|@count}">{$data.name}</td>
                        {* <td style="text-align:right;font-weight:bold;color:white;background-color: #330099">{$data.tot}</th> *}
                    </tr>
                {/if}
                {foreach from=$data.data.row key=cat_key item=cat}
                    <tr>
                        <th>{$cat.gc_name}</th>
                        <td>{$cat.ac_name}</td>
                        <td>{$cat.gpa_name} {$cat.gpa_extradata}</td>
                        {foreach from=$cat.year item=val}
                            <td style="text-align:right">{$val.value}</td>
                        {/foreach}
                        {* <td style="text-align:right;font-weight:bold">{$cat.tot}</th> *}
                    </tr>
                {/foreach}
            {/foreach}
        {else}
            {foreach from=$vlu.data key=key item=data}
                <tr class="selected_row_summary-{$key}" >
                    <td style="text-align:left;font-weight:bold;color:white;background-color: #330099">{$data.name}</td>
                    {foreach from=$data.data.sum.year item=val}
                        <td style="text-align:right">{$val.value}</td>
                    {/foreach}
                    {* <td style="text-align:right;font-weight:bold">{$data.tot}</th> *}
                </tr>
            {/foreach}
        {/if}

        {* somme *}
        <tr style="font-weight:bold">
            <td colspan="{if $vlu.table=='NORMAL'}3{else}1{/if}" style="text-align:right">{t}Totale{/t}</td>
            {foreach from=$vlu.sum.year item=sum}
                <td style="text-align:right">{$sum.value}</td>
            {/foreach}
            {* <td style="text-align:right;font-weight:bold">{$vlu.tot}</th> *}
        </tr>
    {/if} {* years>0 *}
    </table>
    <br />
