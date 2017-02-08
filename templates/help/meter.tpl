<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>GUIDA</title>
    </head>
    <body>
        <div id="popup_em_serial">
            {t escape=no}Matricola / POD (<u>P</u>oint <u>O</u>f <u>D</u>elivery) indica il numero di presa dell'allacciamento, cioè rappresenta la locazione fisica su cui viene erogata la fornitura del servizio.
            <br />E' possibile reperire questo numero su ogni singola bolletta o sul contratto sottoscritto con il fornitore del servizio.
            <br><b>NOTA</b> Nel caso di utenze multiple, si consiglia di indicare una descrizione contenente il numero dei contatori (ande evitare di dover inserire i singoli contatori){/t}
        </div>
        <div id="popup_em_is_production">
            Indica la tipologia del contatore: Contatore a consumo oppure contatore di produzione energia (Es: pannelli fotovoltaici)
        </div>
        <div id="popup_es_id">
            Indica la fonte di alimentazione misurata dal contatore. Questo valore non può essere cambiato se vi sono degli impianti o delle bollette inserite per il contatore
        </div>
        <div id="popup_em_descr_1">
            Breve descrizione del contatore
        </div>
        <div id="popup_em_descr_2">
            Breve descrizione del contatore in <i>tedesco</i>
        </div>
        <div id="popup_us_id">
            E' possibile indicare un "fornitore di servizio" tra quelli presenti in elenco. Se viene indicato i fattori di conversione applicati non saranno quelli standard, ma quelli del fornitore selezionato.<br />
            <hr />
            Se il fornitore non è in elenco, o si vuole applicare i fattori di conversione standard, sarà necessario specificare una fonte e la relativa unità di misura del contatore<br />
            <hr />
            I campi "Fornitore" e "Alimentazione" sono mutualmente esclusivi.
        </div>
        <div id="popup_up_id">
            E' possibile indicare il contratto con il fornitore selezionato. A contratti differenti, corrispondono fattori di conversione differenti
        </div>
    </body>
</html>