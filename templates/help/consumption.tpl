<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>GUIDA</title>
    </head>
    <body>
        <div id="popup_insert_type">
            {t escape=no}Tipo di inserimento desiderato:<br />
            <b>Bolletta singola</b>: Permitte di inserire una singola bolletta per volta indicando tutti i parametri manualmente<br />
            <b>Bollette mensile</b>: Permitte un inserimento multiplo di tutte le bollette dell'anno in un unica volta. Verranno memorizzati esclusivamente valori con consumo e spesa indicati<br>
                <b>Bollette annuale</b>: Permitte di inserire un unica bolletta con i consumi da gennaio a dicembre<br />
                Per inserire bollette con periodicità diversa usare l'inserimento singolo in combinazione con il bottone "Salva e inserisci nuovamente"{/t}
        </div>
        <div id="popup_dev_em_name">{t}E'il contatore al quale è allacciato l'impainto{/t}</div>
        <div id="popup_dev_esu_name">{t}E' il tipo di alimentazione dell'impianto. Coincide con quella specificata nel contatore a cui tale impianto è collegato{/t}</div>
        <div id="poput_insert_year">{t}Per le bollette mensili ed annuali indica l'anno di riferimento delle bollette{/t}</div>
        <div id="popup_co_start_date_free">{t}E' il periodo iniziale (data) a cui la bolletta si riferisce{/t}</div>
        <div id="popup_co_end_date_free">{t}E' il periodo finale (data) a cui la bolletta si riferisce{/t}</div>
        <div id="popup_co_value_free">{t escape=no}E' il <u>consumo totale</u> di energia indicato nella bolletta<br>Nel caso di produzione di produzione inserire il valore di produzione energia.{/t}</div>
        <div id="popup_co_bill_free">{t escape=no}E' il <u>costo totale</u> di energia indicati nella bolletta. <u>Sono pertanto esclusi eventuali costi di attivazioni o simili</u><br>Nel caso di produzione di produzione inserire il valore di produzione energia.{/t}</div>
        <div id="popup_co_energy_costs_free">{t escape=no}E' il costo unitario di energia calcolato dal sistema in base all'energia consumata e alla spesa inseriti{/t}</div>
    </body>
</html>