<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>GUIDA</title>
    </head>
    <body>
        <div id="mu_id">{t}Indica il comune su cui si vuole realizzare il PAES (Piani di Azione per l'Energia Sostenibile){/t}</div>
        <div id="gst_name_1">{t}Indicare un nome esplicativo da dare al PAES{/t}{if $NUM_LANGUAGES > 1} {t}(in italiano){/t}{/if}</div>
        <div id="gst_name_2">{t}Indicare un nome esplicativo da dare al PAES{/t}{if $NUM_LANGUAGES > 1} {t}(in tedesco){/t}{/if}</div>
        <div id="gst_target_descr_1">{t escape="no"}In questa sezione si prega di illustrate {/t}{if $NUM_LANGUAGES > 1} {t}(in italiano){/t}{/if}{t} la visione a lungo termine del vostro comune (almeno) fino al 2020, indicando:{/t}<br>
                <ol type="a">
                    <li>{t escape="no"}le aree intervento prioritarie. In quali settori prevedete di realizzare le maggiori riduzioni di CO2? Quali sono le vostre azioni principali?{/t}</li>
                    <li>{t escape="no"}quali sono le tendenze principali in termini di emissioni di CO2 nel vostro territorio/comune e in che cosa consistono le sfide maggiori che siete chiamati ad affrontare?{/t}</li>
                </ol>
        </div>
        <div id="gst_target_descr_2">{t escape="no"}In questa sezione si prega di illustrate {/t}{if $NUM_LANGUAGES > 1} {t}(in tedesco){/t}{/if}{t} la visione a lungo termine del vostro comune (almeno) fino al 2020, indicando:{/t}<br>
                <ol type="a">
                    <li>{t escape="no"}le aree intervento prioritarie. In quali settori prevedete di realizzare le maggiori riduzioni di CO2? Quali sono le vostre azioni principali?{/t}</li>
                    <li>{t escape="no"}quali sono le tendenze principali in termini di emissioni di CO2 nel vostro territorio/comune e in che cosa consistono le sfide maggiori che siete chiamati ad affrontare?{/t}</li>
                </ol>
        </div>
        <div id="gst_reduction_target">{t escape="no"}Indicare qual è l'obiettivo generale di riduzione delle emissioni di CO2 del vostro comune espresso in percentuale.<br />
            <b>Si ricorda che, conformemente a quanto previsto dal Patto dei sindaci, è necessario ridurre le emissioni di CO2 di almeno il <u>20%</u> entro il <u>2020</u></b>{/t}</div>
        <div id="gst_reduction_target_citizen">{t escape="no"}Indicare il numero di abitanti previsti nell'anno dell'obiettivo{/t}</div>

        <div id="gst_reduction_target_year">{t escape="no"}Indicare l'anno entro il quale si vuole raggiungere l'obiettivo di riduzioni delle emissioni di CO2 nel vostro comune.<br />
            <b>Si ricorda che, conformemente a quanto previsto dal Patto dei sindaci, è necessario ridurre le emissioni di CO2 di almeno il <u>20%</u> entro il <u>2020</u></b>{/t}</div>
        <div id="gst_reduction_target_absolute">{t}In linea di principio, occorre fissare l'obiettivo di riduzione come valore "assoluto" (percentuale della quantità di emissioni di CO2 calcolata per l'anno di riferimento). In alternativa, l'obiettivo può essere fissato "pro capite". In questo caso, le emissioni dell'anno di riferimento vengono divise per il numero di abitanti nello stesso anno e l'obiettivo di riduzione percentuale delle emissioni viene calcolato su quella base.{/t}</div>
        <div id="gst_reduction_target_long_term">{t escape="no"}Indicare qual è l'obiettivo generale di riduzione delle emissioni di CO2 del vostro comune espresso in percentuale in un periodo di lungo termine.{/t}</div>
        <div id="gst_reduction_target_year_long_term">{t escape="no"}Indicare l'anno entro il quale si vuole raggiungere l'obiettivo di riduzioni delle emissioni di CO2 nel vostro comune in un periodo di lungo termine.{/t}</div>
        <div id="gst_reduction_target_citizen_long_term">{t escape="no"}Indicare il numero di abitanti previsti nell'anno dell'obiettivo a lungo termine{/t}</div>
        <div id="gst_reduction_target_absolute_long_term">{t}In linea di principio, occorre fissare l'obiettivo di riduzione come valore "assoluto" (percentuale della quantità di emissioni di CO2 calcolata per l'anno di riferimento). In alternativa, l'obiettivo può essere fissato "pro capite". In questo caso, le emissioni dell'anno di riferimento vengono divise per il numero di abitanti nello stesso anno e l'obiettivo di riduzione percentuale delle emissioni viene calcolato su quella base.{/t}</div>
        <div id="gst_emission_factor_type_ipcc">{t escape="no"}Selezionare la tipologia dei fattori di conversione{/t}
            <ol>
                <li>{t escape="no"}<b>IPCC</b> (Intergovernmental Panel on Climate Change): fattori di emissione "standard", che comprendono tutte le emissioni di CO2 derivanti dall'energia consumata nel territorio municipale, sia direttamente, tramite la combustione di carburanti all'interno del comune, che indirettamente, attraverso la combustione di carburanti associata all'uso dell'elettricità e del riscaldamento/raffreddamento nell'area municipale.{/t}</li>
                <li>{t escape="no"}<b>LCA</b> (Life Cycle Assessment) fattori di conversione che prendono in considerazione l'intero ciclo di vita del vettore energetico. Tale approccio tiene conto non solo delle emissioni della combustione finale, ma anche di tutte le emissioni della catena di approvvigionamento che si verificano al di fuori del territorio comunale.{/t}</li>
            </ol>
        </div>
        <div id="gst_emission_unit_co2">{t escape="no"}Indicare se le emissioni indicate sono in CO2 o equivalenti di CO2.{/t}</div>
        <div id="gst_coordination_text_1">{t escape="no"}In questa sezione si prega di indicare {/t}{if $NUM_LANGUAGES > 1} {t}(in italiano){/t}{/if}{t}le strutture specifiche create dal vostro comune per attuare l'iniziativa "Patto dei sindaci".{/t}</div>
        <div id="gst_coordination_text_2">{t escape="no"}In questa sezione si prega di indicare {/t}{if $NUM_LANGUAGES > 1} {t}(in tedesco){/t}{/if}{t} le strutture specifiche create dal vostro comune per attuare l'iniziativa "Patto dei sindaci".{/t}</div>
        <div id="gst_staff_nr">{t}Si prega di indicare quante persone lavorano (nei rispettivi impieghi a tempo pieno) alla preparazione e alla realizzazione del piano d'azione per l'energia sostenibile del vostro comune.{/t}</div>
        <div id="gst_citizen_text_1">{t}I firmatari del Patto dei sindaci si impegnano a mobilitare la società civile all'interno del loro territorio al fine di coinvolgerla nello sviluppo del piano d'azione. Indicate {/t}{if $NUM_LANGUAGES > 1} {t}(in italiano){/t}{/if}{t}in che modo avete coinvolto i cittadini e i vari gruppi di soggetti interessati nella preparazione del piano d'azione e come intendete coinvolgerli durante la sua realizzazione.{/t}</div>
        <div id="gst_citizen_text_2">{t}I firmatari del Patto dei sindaci si impegnano a mobilitare la società civile all'interno del loro territorio al fine di coinvolgerla nello sviluppo del piano d'azione. Indicate {/t}{if $NUM_LANGUAGES > 1} {t}(in tedesco){/t}{/if}{t}in che modo avete coinvolto i cittadini e i vari gruppi di soggetti interessati nella preparazione del piano d'azione e come intendete coinvolgerli durante la sua realizzazione.{/t}</div>
        <div id="gst_budget_text_1">{t}In questa sezione si prega di descrivere {/t}{if $NUM_LANGUAGES > 1} {t}(in italiano){/t}{/if}{t} il bilancio complessivo stanziato a favore sia dello sviluppo che della realizzazione della vostra strategia generale (compreso il calendario del bilancio stimato).{/t}</div>
        <div id="gst_budget_text_2">{t}In questa sezione si prega di descrivere {/t}{if $NUM_LANGUAGES > 1} {t}(in tedesco){/t}{/if}{t} il bilancio complessivo stanziato a favore sia dello sviluppo che della realizzazione della vostra strategia generale (compreso il calendario del bilancio stimato).{/t}</div>
        <div id="gst_budget">{t}In questa sezione si prega di indicare l'importo del bilancio complessivo stanziato a favore sia dello sviluppo che della realizzazione della vostra strategia generale (compreso il calendario del bilancio stimato).{/t}</div>
        <div id="gst_financial_text_1">{t}Si prega di indicare {/t}{if $NUM_LANGUAGES > 1} {t}(in italiano){/t}{/if}{t} i principali stanziamenti (o storni) previsti nel bilancio municipale e le fonti esterne (ad esempio schemi di finanziamento europei, nazionali o regionali, sponsor, eccetera) da cui prevedete di ricevere finanziamenti per la realizzazione delle azioni principali del vostro piano d'azione.{/t}</div>
        <div id="gst_financial_text_2">{t}Si prega di indicare {/t}{if $NUM_LANGUAGES > 1} {t}(in tedesco){/t}{/if}{t} i principali stanziamenti (o storni) previsti nel bilancio municipale e le fonti esterne (ad esempio schemi di finanziamento europei, nazionali o regionali, sponsor, eccetera) da cui prevedete di ricevere finanziamenti per la realizzazione delle azioni principali del vostro piano d'azione.{/t}</div>
        <div id="gst_monitoring_text_1">{t}Si prega di indicare {/t}{if $NUM_LANGUAGES > 1} {t}(in italiano){/t}{/if}{t} in che modo il comune intende organizzare il monitoraggio e la valutazione del piano d'azione. Si segnala inoltre che i firmatari del Patto dei sindaci dovranno presentare una relazione di attuazione su base biennale. La prima relazione dovrà essere elaborata due anni dopo la presentazione del piano d'azione sull'energia sostenibile.{/t}</div>
        <div id="gst_monitoring_text_2">{t}Si prega di indicare {/t}{if $NUM_LANGUAGES > 1} {t}(in tedesco){/t}{/if}{t} in che modo il comune intende organizzare il monitoraggio e la valutazione del piano d'azione. Si segnala inoltre che i firmatari del Patto dei sindaci dovranno presentare una relazione di attuazione su base biennale. La prima relazione dovrà essere elaborata due anni dopo la presentazione del piano d'azione sull'energia sostenibile.{/t}</div>
        <div id="ge_id">{t}Indacare l'inventario emissioni da utilizzare per il Patto dei sindaci{/t}</div>
        <div id="ge_id_2">{t}E' possibile indicare un secondo inventario emissioni da utilizzato per il Patto dei sindaci{/t}</div>
        <div id="gp_id">{t}Si prega di indicare il piano d'azione da utilizzare per il Patto dei sindaci{/t}</div>
    </body>
</html>