<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>GUIDA</title>
    </head>
    <body>
        <div id="mu_id">
            {t escape=no}Nel caso si tratti di un <u>fattore di conversione specifico per un singolo comune</u>, indicarne il nome (Es: fattore di conversione elettrico per il Comune di Roma)
            Se il comune non viene specificato, il fattore di conversione sarà valido per tutti i comuni{/t}
        </div>
        <div id="es_id">
            {t}Indicare il tipo di alimentazione a cui associare il fattore di conversione{/t}
        </div>
        <div id="udm_id">
            {t}Per alcune fonti di alimentazione è possibile indicare diverse unità di misura. Sciegliere quella per il fattore di conversione che si vuole immettere{/t}
        </div>
        <div id="esu_kwh_factor">
            {t}Indicare il fattore di conversione tra la fonte di alimentazione e l'unità di misura scielte e i KWh{/t}
        </div>
        <div id="esu_co2_factor">
            {t escape=no}Indicare il fattore di conversione tra la fonte di alimentazione e l'unità di misura scielte e i la CO<sub>2</sub>{/t}
        </div>
        <div id="esu_tep_factor">
            {t escape=no}Indicare il fattore di conversione tra la fonte di alimentazione e l'unità di misura scielte e i TEP (<u>T</u>onnellate <u>E</u>quivalenti di <u>P</u>etrolio){/t}
        </div>
        <div id="esu_is_consumption">
            {t escape=no}Indicare se la fonte (e i relativi fattori di conversione) potranno essere utilizzati in contatori a consumo (Es: metano, gasolio, corrente elettrica){/t}
        </div>
        <div id="esu_is_production">
            {t escape=no}Indicare se la fonte (e i relativi fattori di conversione) potranno essere utilizzati in contatori a produzione (Es: corrente elettrica){/t}
        </div>
        <div id="ges_name">
            {t escape=no}Questo campo indica la fonte equivalente nel Patto dei Sindaci{/t}
        </div>
        <div id="ges_full_name">
            {t escape=no}Indica dove è posizionata questa alimentazione all'interno dell'inventario. Parametro non modificabile{/t}
        </div>
    </body>
</html>