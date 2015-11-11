{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="header_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="header_w_menu.tpl"}{/if}

<h3>{$page_title}</h3>

<p>{t}Il software R3 EcoGIS 2 è stato parzialmente realizzato con un finanziamento del Programma "Competitività regionale ed occupazione FESR 2007-2013".{/t}</p>
<img src="../images/provinz_bz.png" />


<br /><br />
<p>{t}Hanno contruibuito principalmente alla realizzazione del programma i seguenti partner:{/t}</p>

<h4>{t}Aspetti tecnici ed energetici:{/t}</h4>
<a href="http://www.syneco-consulting.it/" target="_blank">Syneco srl</a><br />
<a href="http://www.qubiq.it/" target="_blank">Qubiq sas</a><br />
<a href="http://www.oekoinstitut.it/" target="_blank">{t}Ecoistituto Südtirol-Alto Adige ONLUS{/t}</a>

<br /><br />
<h4>{t}Sviluppo software:{/t}</h4>
<a href="http://www.r3-gis.com/" target="_blank">R3 GIS srl</a>

{if $USER_CONFIG_APPLICATION_MODE=='FRAME'}{include file="footer_no_menu.tpl"}{else if $USER_CONFIG_APPLICATION_MODE=='HTML'}{include file="footer_w_menu.tpl"}{/if}