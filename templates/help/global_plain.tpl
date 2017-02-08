<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>{t}GUIDA{/t}</title>
    </head>
    <body>
        <div id="mu_id">{t}Indica il comune su cui si vuole realizzare il pianio di azione{/t}</div>
        <div id="gp_name_1">{t}Inserire il titolo {/t}{if $NUM_LANGUAGES > 1} {t}(in italiano){/t}{/if}{t} del piano d'azione per l'energia sostenibile.{/t}</div>
        <div id="gp_name_2">{t}Inserire il titolo {/t}{if $NUM_LANGUAGES > 1} {t}(in tedesco){/t}{/if}{t} del piano d'azione per l'energia sostenibile.{/t}</div>
        <div id="gp_approval_date">{t}Inserire la data di approvazione formale del Piano di azione.{/t}</div>
        <div id="gp_approving_authority_1">{t}Inserire il nome {/t}{if $NUM_LANGUAGES > 1} {t}(in italiano){/t}{/if}{t} dell'autorità che ha approvato il piano di azione che si andrà ad inserire{/t}</div>
        <div id="gp_approving_authority_2">{t}Inserire il nome {/t}{if $NUM_LANGUAGES > 1} {t}(in tedesco){/t}{/if}{t} dell'autorità che ha approvato il piano di azione che si andrà ad inserire{/t}</div>
        <div id="gp_url_1">{t}E' possibile inserire un link ad un sito web pubblico {/t}{if $NUM_LANGUAGES > 1} {t}(in italiano){/t}{/if}{t} in cui è spiegato il priano di azione{/t}</div>
        <div id="gp_url_2">{t}E' possibile inserire un link ad un sito web pubblico {/t}{if $NUM_LANGUAGES > 1} {t}(in tedesco){/t}{/if}{t} in cui è spiegato il priano di azione{/t}</div>
        <div id="popup_gc_name">{t}E'il settore (macro categoria) in cui indicare gli obiettivi{/t}</div> {* SUM e ROW *}
        <div id="popup_gpa_id">{t}Indica l'azione principale per questa entry del piano d'azione{/t}</div> {* SUM e ROW *}
        <div id="popup_gpr_responsible_department_1">{t}Indica la persona o l'ente responsabile dell'azione{/t}</div> {* SUM e ROW *}
        <div id="popup_gpr_responsible_department_2">{t}Indica la persona o l'ente responsabile dell'azione nella seconda lingua{/t}</div> {* SUM e ROW *}
        <div id="popup_gpr_start_date">{t}Indica il periodo si attuazione dell'azione{/t}</div> {* SUM e ROW *}
        <div id="popup_gpr_estimated_cost">{t}Sono i costi stimati (in Euro) previsti per l'attuazione dell'azione{/t}</div>
        <div id="popup_gpr_expected_energy_saving">{t}Risparmio energetico previsto a seguito dell'applicazione dell'azione{/t}</div>
        <div id="popup_gpr_expected_renewable_energy_production">{t}Produzione di energia prevista a seguito dell'attuazione dell'azione{/t}</div>
        <div id="popup_gpr_expected_co2_reduction">{t escape=no}Riduzione di CO<sub>2</sub> prevista a seguito dell'attuazione dell'azione{/t}</div>
        {* global plain sum *}
        <div id="popup_gps_expected_energy_saving">{t}E'l'obiettivo di risparmio energetico espresso in MWh previsto nel 2020{/t}</div>
        <div id="popup_gps_expected_renewable_energy_production">{t}E'l'obiettivo di produzione locale di energia rinnovabileo espresso in MWh previsto nel 2020{/t}</div>
        <div id="popup_gps_expected_co2_reduction">{t escape=no}E'l'obiettivo di riduzione di CO<sub>2</sub> espresso in MWh previsto nel 2020{/t}</div>
        {* global plain row *}
        <div id="popup_gc_id">{t}E'il settore specifico in cui indicare gli obiettivi{/t}</div>
        {* DA FINIRE *}
    </body>
</html>