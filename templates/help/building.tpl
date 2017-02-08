<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>GUIDA</title>
    </head>
    <body>
        <div>Indice</div>
        <div id="mu_id">{t}Indicare il nome del comune ove è ubicato l'edificio{/t}</div>
        <div id="bu_id_dummy">{t}E'l'identificativo interno ed univoco dell'edificio. Non può essere modificato{/t}</div>
        <div id="bu_code">{t}E' il codice dell'edificio. Viene assegnato automaticamente dal sistema, e può essere modificato{/t}</div>
        <div id="bu_name_1" title="Nome dell'edificio">{t}E' il nome descrittivo dell'edificio (Es. Municipio, Palazzo "Grassi", ecc){/t}</div>
        <div id="bu_name_2">{t}E' il nome descrittivo dell'edificio nella seconda lingua{/t}</div>
        <div id="fr_id">{t}Se indicato rappresenta il nome della frazione su cui è ubicato l'edificio. E'possibile aggiungere nuove frazioni tramite il bottone "Aggiungi"{/t}</div>
        <div id="st_id">{t}Rappresenta il nome della via, piazza, ecc su cui è ubicato l'edificio. E'possibile aggiungere nuove vie tramite il botttone "Aggiungi"{/t}</div>
        <div id="bu_nr_civic">{t escape=no}E' il numero civico dell'edificio.<br />Il civico ed il barrato vanno indicati separatamente{/t}</div>
        <div id="cm_id">{t}E' il comune catastale in cui è ubicato l'edificio. E'possibile aggiungere un nuovo comune catastale tramite il botttone "Aggiungi"{/t}</div>
        <div id="cm_number">{t}E'la particella catastale edificiale in cui è ubicato l'edificio{/t}</div>
        <div id="bu_section">{t}Sezione catastale{/t}</div>
        <div id="bu_sheet">{t}E' il foglio catastale dell'edificio{/t}</div>
        <div id="bu_part">{t}E' la particella catastale dell'edificio{/t}</div>
        <div id="bu_sub">{t}E' il subalterno dell'edificio{/t}</div>
        <div id="bu_survey_date">{t}E'la data in cui è stato effettualo l'audit dell'edificio{/t}</div>
        <div id="bt_id">{t escape=no}Indicare la tipologia costruttiva dell'edificio.<br />Per alcune di esse è possibile immettere un breve testo di speigazione nel campo "Altro"{/t}</div>
        <div id="bpu_id"title="Destinazione d'uso">{t escape=no}E' la destinazione d'uso dell'edificio.<br />Il valore inserito determinerà in quale categoria verrà ubicato l'edificio all'intero dell'inventario delle imissioni{/t}</div>
        <div id="bby_id">{t}Indicare l'anno di costruzione dell'edificio{/t}</div>
        <div id="bry_id">{t}Se l'edificio è stato ristrutturato, indicare quì l'anno di ultima ristrutturazione{/t}</div>
        <div id="bu_restructure_descr_1">{t}Nel caso in cui l'edificio sia stato ristrutturato, è possibile indicare qui un testo esplicativo sulla ristrutturazione effettuata{/t}</div>
        <div id="bu_restructure_descr_2">{t}Nel caso in cui l'edificio sia stato ristrutturato, è possibile indicare qui un testo (nella seconda lingua) esplicativo sulla ristrutturazione effettuata{/t}</div>
        <div id="bu_area_heating">{t escape=no}Indicare la superficie utile riscaldata dell'edificio (dell'involucro). Questo campo è molto importante ai fini statistici per calcolare i consume e la produzione di CO<sub>2</sub> specifici{/t}</div>
        <div id="bu_area">{t escape=no}Indicare il volume lordo riscaldato dell'edificio{/t}</div>  
        <div id="bu_sv_factor">{t escape=no}E' il fattore di forma dell'edificio.<br />
            Il "Fattore di forma S/V" è il rapporto tra la "Superficie disperdente" che delimita verso ambienti non dotati di riscaldamento e verso l'esterno il volume lordo riscaldato V, ed il "Volume lordo riscaldato V"{/t}
        </div>  
        <div id="bu_glass_area">{t}Indicare la superficie vetrata dell'edificio{/t}</div>  
        <div id="bu_usage_h_from">{t}Indicare l'orario di utilizzo tipico dell'edificio. Ad esempio per un ufficio l'orario tipo potrebbe essere dalle 08:00 alle 19:00{/t}</div> 
        <div id="bu_daily_use_h">{t}Ore totali di utilizzo giornaliero dell'edificio. Questo valore viene calcolato in base all'orario di utilizzo indicato{/t}</div> 
        <div id="bu_usage_days">{t}Indicare per quanti giorni viene utilizzato tipicamente l'edificio. Ad esempio per un ufficio l'utilizzo tipo potrebbe essere di 5 giorni alla settimana{/t}</div> 
        <div id="bu_usage_weeks">{t}Indicare per quante settimana viene utilizzato tipicamente l'edificio. Ad esempio per una scuola il numero di giorni potrebbe essere 200{/t}</div> 
        <div id="bu_hour_year_use">{t}Ore totali di utilizzo dell'edificio. Questo valore viene calcolato in base all'uso giornaliero, settimanale ed annuale dell'edificio{/t}</div> 
        <div id="bu_persons">{t}Indicare il numero medio di occupanti dell'edificio{/t}</div> 
        <div id="bu_descr_1">{t}E' possibile indicare delle note generiche sull'edificio{/t}</div> 
        <div id="bu_descr_2">{t}E' possibile indicare delle note generiche nella seconda lingua sull'edificio{/t}</div> 
        <div id="bu_to_check">{t}Indicare se l'inserimento dell'edificio è da controllare{/t}</div> 
        <div id="bu_photo">{t escape=no}E' possibile caricare una foto rappresentativa dell'edifico (ad esempio la facciata principale).<br /><b>NOTA</b>: La dimensione massima di tutte le immagini da caricare non può superare quella indicata{/t}</div>
        <div id="bu_label">{t escape=no}E' possibile caricare un'immagine della targa energetica dell'edifico.<br /><b>NOTA</b>: La dimensione massima di tutte le immagini da caricare non può superare quella indicata{/t}</div>
        <div id="bu_thermography">{t escape=no}E' possibile caricare un'immagine della termografia dell'edifico.<br /><b>NOTA</b>: La dimensione massima di tutte le immagini da caricare non può superare quella indicata{/t}</div>
        <div id="bu_map">{t}Premere il bottone "Digitalizza su mappa" per aprire la mappa e procedere con la digitalizzazione dell'edificio{/t}</div> 
    </body>
</html>