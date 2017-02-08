<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>GUIDA</title>
    </head>
    <body>
        <div id="popup_wo_code">
            {t}Indica il numero propgressivo dell'intervento e viene assegnato in automatico dal sistema{/t}
        </div>
        <div id="ws_id">
            {t}Indica lo stato dell'intervento{/t}
        </div>
        <div id="wo_type">
            {t}Indicare la tipologia dell'intervento che si vuole inserire{/t}
        </div>
        <div id="wo_descr_1">
            {t}Breve descrizione dell'intervento{/t}
        </div>
        <div id="wo_start_date">
            {t}Data prevista (o effettiva nel caso di intervento in corso di realizzazione o realizzato) di inizio intervento{/t}
        </div>
        <div id="wo_end_date">
            {t}Data prevista (o effettiva nel caso di intervento realizzato) di fine intervento{/t}
        </div>
        <div id="wo_estimated_cost">
            {t}Costo stimato dell'intervento{/t}
        </div>
        <div id="wo_effective_cost">
            {t}Costo effettivo dell'intervento{/t}
        </div>
        <div id="wo_estimated_contribution">
            {t}Contributi stimati che si stima di ricevere a seguito dell'intervetno{/t}
        </div>
        <div id="wo_effective_contribution">
            {t}Contributi effettivi ricevuti a seguito dell'intervetno{/t}
        </div>
        <div id="wo_net_estimated_contribution">
            {t}Contributo netto stimato (costo_stimano - contributo_stimato). Viene calcolato automaticamente dal sistema{/t}
        </div>
        <div id="wo_net_effective_contribution">
            {t}Contributo netto effettivo (costo_effettivo - contributo_effettivo). Viene calcolato automaticamente dal sistema{/t}
        </div>
        <div id="wo_year_mainten_cost">
            {t}Costo di manutenzione annua{/t}
        </div>
        <div id="wo_discount_rate">
            {t}Tasso di sconto applicato{/t}
        </div>
        <div id="ft_id">
            {t}Indicare il modo con cui verrà pagato il finanziamento{/t}
        </div>
        <div id="ft_extradata_1">
            {t}Specificare il modo con cui verrà pagato il finanziamento{/t}
        </div>
        <div id="wo_funding_lifetime">
            {t}Indicare la vita utile dell'investimento (in anni){/t}
        </div>
        <div id="wo_funding_return_perc">
            {t}Indicare il tasso di ritorno dell'investimento (in percentuale){/t}
        </div>
        <div id="wo_funding_return_year">
            {t}Ritorno dell'investimento espresso in anni. Viene calcolato automaticamente dal sistema, una volta inserita la vita utile dell'investimento ed il risparmio previsto{/t}
        </div>
        <div id="wo_van">
            {t escape=no}
            Il valore attuale netto (VAN) è una metodologia tramite cui si definisce il valore attuale di una serie attesa di flussi di cassa non solo sommandoli contabilmente ma attualizzandoli sulla base del tasso di rendimento (costo opportunità dei mezzi propri).
            {/t}
        </div>
        <div id="wo_primary_energy">
            {t escape=no}Indicare l'energia annua stimata che si andrà a risparmiare a seguito dell'intervento{/t}
        </div>
        <div id="wo_electricity">
            {t escape=no}Indicare l'energia elettrica annua che si andrà a risparmiare a seguito dell'intervento{/t}
        </div>
        <div id="wo_primary_energy_tot">
            {t escape=no}Totale energia risparmiata<br />
            <b>NOTA</b>: Il totale dell'energia è dato dall'energia primaria (eventualmente convertito in kWh) + (energia secondaria moltiplicato per {/t}{$ELECTRICITY_KWH_FACTOR}{t}){/t}
        </div>
        <div id="wo_total_energy_saved_spec">
            {t escape=no}Totale energia risparmiata rapportata alla superficie dell'edificio{/t}
        </div>
        <div id="ec_id_work">
            Indicare se a seguito dell'intervento si ritiene che la classe energetica dell'edificio verrà modificata
        </div>
        <div id="ecl_id_work">
            Indicare se a seguito dell'intervento si ritiene che la descrizione della classe energetica dell'edificio verrà modificata
        </div>
    </body>
</html>