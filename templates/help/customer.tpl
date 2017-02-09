<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>GUIDA</title>
    </head>
    <body>
        <div id="dn_name" title="Dominio">
            {t escape=no}Il dominio è un codice (Es: MERANO) che viene assegnato al cliente e con cui quest'ultimo si dovrà loggare inserendolo dopo il proprio nome utente (Es: mario.rossi@merano).<br />
            Esso potrà contenere solo caratteri alfanumerici maiuscoli e il carattere di sottolineatura.<br>
                <u>NOTA:</u> Questo parametro è modificabile solo in fase di inserimento dei dati{/t}
        </div>
        <div id="dn_name_alias" title="Alias (di un dominio)">
            {t escape=no}E' possibile indicare un alias per il dominio in fase di creazione. Eventuali ulteriori alias possono essere configurati dalla gestione utenti (Es: MERAN)<br>
                <u>NOTA:</u> Questo parametro è modificabile solo in fase di inserimento dei dati{/t}
        </div>
        <div id="do_template">
            {t escape=no}E' possibile indicare un dominio tra quelli creati in precedenza da cui andare a copiarsi i gruppi e gli altri parametri di configurazione{/t}
        </div>
        <div id="cus_name_1">
            {t escape=no}E' il nome dell'ente nella lingua 1 (Es: Comune di Merano){/t}
        </div>
        <div id="cus_name_2">
            {t escape=no}E' il nome dell'ente nella lingua 2 (Es: Gemeinde Meran){/t}
        </div>
        <div id="do_database_user">
            {t escape=no}E' l'utente database (postgres) che verrà creato in concomitanza alla creazione del nuovo dominio.
            Questo permette una maggiore sicurezza nell'accesso ai dati.
            Memorizzare tali dati per futuri usi (Accesso al database da map file).{/t}
        </div>
        <div id="do_first_user">
            {t escape=no}In fase di inserimento è possibile creare un primo utente con cui entrare nel sistema. ulteriori utenti dovranno essere creati successivamente dalla gestione utenti{/t}
        </div>
        <div id="us_name">
            {t escape=no}E' il nome dell'utente (Es: Ing. Mario Rossi){/t}
        </div>
        <div id="us_group">
            {t escape=no}E' il gruppo a cui legare il primo utente (Es: ADMIN){/t}
        </div>
    </body>
</html>