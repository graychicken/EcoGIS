<tr class="tplBenefitYear">
	<td colspan="4" nowrap>
		Anno: <input type="text" rel="benefit_year" name="benefit_year[]" style="width:50px;" maxlength="4" id="benefit_year_{$n}" class="year" value="{$vlu2.acby_year}">
                Percentuale raggiungimento <input type="text" rel="benefit_benefit" name="benefit_benefit[]" style="width:50px;" maxlength="4" {* id="benefit_year_{$n}" *} class="float" value="{$vlu2.acby_benefit}"> [%]
				
	</td>
        {if $act <> 'show'}
	<td align="right"><img src="../images/ico_del_small.gif" title="{t}Elimina{/t}" alt="{t}Elimina{/t}" class="btnRemoveBenefitYear" /></td>
        {/if}
</tr>