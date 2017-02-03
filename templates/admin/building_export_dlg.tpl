{include file="header_ajax.tpl"}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#popupBtnExport').click(function () {
                exportBuildings();
             });
        });
    </script>
{/literal}

<form name="exportform" id="exportform">
    {foreach from=$vars key=key item=val}
        {if $key <> 'tabs'}<input type="hidden" name="{$key}" id="{$key}" value="{$val}" />{/if}
    {/foreach}
    <div>{t}Indicare il formato con cui si desidera esportare i dati{/t}</div>
    <div>{t escape=no}<b>NOTA</b>: La generazione del template potrà richiedere fino ad un minuto di calcolo{/t}</div>
    <div style="margin: 10px 0px 20px 0px">
        <span>{t}Formato{/t}:</span>
        <select name="format">
            <option value="xlsx">Excel</option>
            <option value="shp">Shape</option>
        </select>
    </div>
    <input type="button" id="popupBtnExport" name="popupBtnExport"  value="{t}Esporta{/t}" style="width:75px;height:25px;" />
</form>
{include file="footer_ajax.tpl"}
