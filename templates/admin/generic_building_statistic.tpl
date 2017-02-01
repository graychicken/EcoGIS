{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}
<h3 id="page_title">{$page_title}<span id="page_subtitle" style="display: none"></span></h3>

<script language="JavaScript" type="text/javascript">
    var hasData={if $vlu.data.rows|@count>0}true{else}false{/if};
</script>
{literal}
    <script language="JavaScript" type="text/javascript">
        function loadGraph() {
            var width = $(window).width(); // - $('#chartImg').offset().left - 30;
            width = Math.min(Math.max(250, width), 1280) - 30;
            height = width / 2;

            var params = [];
            params.push('lang='+$('#lang').val());
            params.push('stat_type='+$('#stat_type').val());
            params.push('mu_id='+$('#mu_id').val());
            params.push('udm_divider='+$('#udm_divider').val());
            params.push('bpu_id='+$('#bpu_id').val());
            params.push('width='+width);
            params.push('height='+height);

            var chartUrl = "edit.php?on=generic_building_statistic_graph&act=list&" + params.join('&');
            if (hasData) {
                $('#chartImg')
                    .prop('src', chartUrl)
                    .one('load', function() {
                        ajaxWait(false);
                });
                ajaxWait(true);
            } else {
                $('#chartImg').hide();
            }
        }
        
        $(document).ready(function () {
            $('.consumption_tree tr').bind('mouseenter', function () {
                $(this).addClass('tr_hover')
            });
            $('.consumption_tree tr').bind('mouseleave', function () {
                $(this).removeClass('tr_hover')
            });
            $('#stat_type,#mu_id,#udm_divider,#bpu_id').change(function() {
                ajaxWait(true);
                $('#modform').submit();
                $('select').prop('disabled', true);
            });
            loadGraph();
        });
        
        var timer=null;
        $(window).resize(function () {
            ajaxWait(true);
            clearTimeout(timer);
            timer = setTimeout(function() { loadGraph() }, 500);
        });
    </script>
{/literal}

<form name="modform" id="modform" action="edit.php?method=submitFormData" method="get">
    <input type="hidden" name="on" id="on" value="{$object_name}" />
    <input type="hidden" name="act" id="act" value="{$act}">
    <input type="hidden" name="lang" id="lang" value="{$lang}">
    {foreach from=$vars key=key item=val}
        {if $key <> 'tabs'}<input type="hidden" name="{$key}" id="{$key}" value="{$val}" />{/if}
    {/foreach}
    
    {if $lkp.mu_values|@count > 1}
        <label for="mu_id">{t}Comune{/t}:</label>
        <select name="mu_id" id="mu_id">
            <option value="">{t}-- Selezionare --{/t}</option>
            {html_options options=$lkp.mu_values selected=$vlu.mu_id}
        </select>
    {/if}
            
    <label for="stat_type">{t}Tipo statistica{/t}:</label>
    <select id="stat_type" name="stat_type">
        {html_options options=$lkp.stat_types selected=$vlu.stat_type}
    </select>
    
    {if $vlu.stat_type == 'building_purpose_use'}
    <label for="bpu_id">{t}Destinazione d'uso{/t}:</label>
    <select id="bpu_id" name="bpu_id">
        <option value="">{t}-- Selezionare --{/t}</option>
        {foreach from=$lkp.bpu_values key=key item=val}
        <option label="{$val.bpu_name}" {if $key==$vlu.bpu_id}selected{/if} value="{$key}">{$val.bpu_name}</option>
        {/foreach}
    </select>
    {/if}
    
    <label for="udm_divider">{t}Unità di misura{/t}:</label>
    <select id="udm_divider" name="udm_divider">
        {html_options options=$lkp.udm_dividers selected=$vlu.udm_divider}
    </select>

    <ul class="consumption_tree">
        <li>
            <table>
                <tr>
                    <th>{t}Anno{/t}</th>
                    {if $vlu.stat_type == 'building_purpose_use'}
                    <th>{t}Destinazione d'uso{/t}</th>
                    {/if}
                    <th>{t}Riscaldamento{/t} ({$vlu.consumption_unit})</th>
                    {if $vlu.data.has_heating_degree_day}
                        <th>{t}Riscaldamento{/t} ({$vlu.consumption_unit}) <div style="font-size: 10px">({t}Con gradi giorno{/t})</div></th>
                    {/if}
                    {if $vlu.data.heating2_label<>''}
                        <th>{$vlu.data.heating2_label} ({$vlu.consumption_unit})</th>
                        {if $vlu.data.has_heating_degree_day}
                            <th>{$vlu.data.heating2_label} ({$vlu.consumption_unit}) <div style="font-size: 10px">({t}Con gradi giorno{/t})</div></th>
                        {/if}
                    {/if}
                    <th>{t}Energia elettrica{/t} ({$vlu.consumption_unit})</th>
                    <th>{t escape=no}CO<sub>2</sub>{/t} ({$vlu.emission_unit})</th>
                    {* if $vlu.data.has_heating_degree_day *}
                        <th>{t escape=no}CO<sub>2</sub>{/t} ({$vlu.emission_unit}) <div style="font-size: 10px">({t}Con gradi giorno{/t})</div></th>
                    {* /if *}
                </tr>
                {foreach from=$vlu.data.rows item=row}
                <tr>
                    <td class="td_right">
                        {if $row.co_year<>$last_year}
                        {$row.co_year}
                        {/if}
                    </td>
                    {if $vlu.stat_type == 'building_purpose_use'}
                    <td>{$row.bpu_name}</td>
                    {/if}
                    <td class="td_right">{$row.heating_fmt}</td>
                    {if $vlu.data.has_heating_degree_day}
                        <td class="td_right">{$row.heating_gg_fmt}</td>
                    {/if}
                    {if $vlu.data.heating2_label<>''}
                        <td class="td_right">{$row.heating_utility_fmt}</td>
                        {if $vlu.data.has_heating_degree_day}
                            <td class="td_right">{$row.heating_utility_gg_fmt}</td>
                        {/if}
                    {/if}
                    <td class="td_right">{$row.electricity_fmt}</td>
                    <td class="td_right">{$row.co2_fmt}</td>
                    {if $vlu.data.has_heating_degree_day}
                        <td class="td_right">{$row.co2_gg_fmt}</td>
                    {/if}
                    {assign var=last_year value=$row.co_year}
                </tr>
                {/foreach}
            </table>
        </li>
    </ul>
</form>

<div style="margin-top: 25px">
<img id="chartImg" src="../images/ajax_loader.gif" />
</div>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}