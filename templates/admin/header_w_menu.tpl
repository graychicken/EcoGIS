<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <title>{if $USER_CONFIG_APPLICATION_TITLE<>''}{$USER_CONFIG_APPLICATION_TITLE}{else}R3 ECOGIS{/if}</title>
        {$meta_contenttype}
        <link rel="stylesheet" href="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/jquery/jquery-ui/css/orange/ui.all.css" type="text/css" />
        <link rel="stylesheet" href="{$smarty.const.R3_CSS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/{$smarty.const.APPLICATION_CODE|lower}_orange.css" type="text/css" />
        {if 1==1}
            <script type="text/javascript" language="javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/jquery.all.js" ></script>
            <script type="text/javascript" language="javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/jquery.all.i18n.{$lang_code}.js" ></script>
            <script type="text/javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/ecogis2_core.all.js" ></script>
            <script type="text/javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD|lower}/custom/{$DOMAIN_NAME|lower}/ecogis2_all.js" ></script>
        {else}
        {/if}
        <script type="text/javascript">
            $(window).bind('resize', frameworkResize);
            $(document).ready(frameworkInit);
        </script>
        <!-- Extra JS files -->
        {foreach from=$js_files item=file}
            <script type="text/javascript" src="{$file}"></script>
        {/foreach}

        {if $USER_CONFIG_APPLICATION_INLINE_JS == 'T'}
            <!-- Inline javascript -->
            <script type="text/javascript">
                {foreach from=$js_files item=data}
                    {$data}
                {/foreach}
            </script>
        {/if}

        <!-- default JS settings -->
        <script type="text/javascript">
            {if $USER_CONFIG_APPLICATION_MODE=='FRAME'}
            var R3MenuNavigateDefaultTarget = R3FrameworkID;   // Default target for menu click
                {if $USER_CONFIG_APPLICATION_MESSAGE != ''}
            var R3FrameworkDeltaHeight = -20;           // Power by height
            var R3FrameworkMenuDeltaHeight = -40;           // Power by height
                {else}
            var R3FrameworkMenuDeltaHeight = -40;           // Power by height
                {/if}
            {/if}

            {* Map settings *}
            {if $USER_CONFIG_SETTINGS_MAP_RES==''} {* Default map resoluzion *}
                    {assign var=mapsize value='x'|explode:"1024x768"}
                {else}
                    {assign var=mapsize value='x'|explode:$USER_CONFIG_SETTINGS_MAP_RES}
                {/if}
            var UserMapWidth ={$mapsize[0]};
            var UserMapHeight ={$mapsize[1]};
            var PopupErrorMsg = "{t}ATTENZIONE!\n\nBlocco dei popup attivo. Impossibile aprire la mappa. Disabilitare il blocco dei popup del browser e riprovare{/t}";
                var MapFileName = "../map/index.php";
                var MapName = "ECOGIS";
                {if $smarty.const.GC_URL <> ''}
                var gisClientURL = '{$smarty.const.GC_URL}';
                {/if}
                {literal}

                    var checkLogoutTimeout = 5 * 60 * 1000;

                    function reloadAll(on) {
                        document.location = 'app_manager.php?on=' + on + '&init&';
                    }

                    function userSettingsChanged(status) {
                        //if (status == 12) {
                        document.location = '../main.php';
                        //}
                    }

                    function checkLogout() {
                        $.getJSON('check_timeout.php', function (response) {
                            if (response.expired) {
                                document.location = 'logout.php?status=-1';  // session expired
                            } else {
                                $('#R3WorkAreaMessage').toggle(response.message != '');
                                $('#R3WorkAreaMessage').html(response.message);
                            }
                        });
                        setTimeout("checkLogout()", checkLogoutTimeout);
                    }

                    $(document).ready(function () {
                        setTimeout("checkLogout()", checkLogoutTimeout);
                    });
                {/literal}
            </script>
        </head>
        <body>
            <div style="display: none" id="application_title">{if $USER_CONFIG_APPLICATION_TITLE<>''}{$USER_CONFIG_APPLICATION_TITLE}{else}R3 ECOGIS{/if}</div>
            <div id="R3WorkAreaAll">
                <div id="ajaxWait"><div class="waiting_top"><img src="../images/ajax_loader.gif" /> {t}Attendere...{/t}</div></div>
                <!-- Warning message -->
                <div id="R3WorkAreaMessage" {if $USER_CONFIG_APPLICATION_MESSAGE == ''}style="display:none"{/if}>{$USER_CONFIG_APPLICATION_MESSAGE}</div>
                {if $ERROR_MESSAGE != ''}
                    <!-- error message -->
                    <div id="R3WorkAreaErrorMessage">{$ERROR_MESSAGE}</div>
                {/if}

                <!-- Header-->
                <div id="R3WorkAreaHeader">
                    <div id="Logos">
                        <div id="LogoSwDx"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/logo/{$DOMAIN_NAME|lower}/logo_dx.png" height="40" alt="logo_dx" /></div>
                        <div id="LogoSwSx"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/logo/{$DOMAIN_NAME|lower}/logo_sx.png" height="40" alt="logo_sx" /></div>
                    </div>
                    <div id="R3WorkAreaTitle">
                        <div id="Logout" style="z-index:99999"><a href="logout.php"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD|lower}/ico_logout.png" alt="logout" />{t}Logout{/t}</a></div>
                        <div id="SwTitle">{$USER_CONFIG_APPLICATION_TITLE} 
                            {if $APPLICATION_VERSION <> ''} - {$APPLICATION_VERSION}{/if} | 
                            {$USER_NAME}
                            {if $USER_MUNICIPALITY <> ''} - {$USER_MUNICIPALITY}{/if}
                        </div>
                        {* if $USER_CONFIG_APPLICATION_DATE <> $USER_CONFIG_APPLICATION_REAL_DATE}
                        {if $USER_MUNICIPALITY == ''}
                        <div id="SwInvalidDate"> - [<a href="set_app_param.php?kind=reset_date" class="error"> {$USER_CONFIG_APPLICATION_REAL_DATE|date_format:"%d/%m/%Y %H:%M"} </a>]</div>
                        {else}
                        <div id="SwTitle"> - [ {$USER_CONFIG_APPLICATION_REAL_DATE|date_format:"%d/%m/%Y %H:%M"} ]</div>
                        {/if}
                        {/if *}
                    </div>
                </div>  <!-- closing #R3WorkAreaHeader -->

                <!-- wrapper -->

                <div id="R3WorkAreaWrapper">  
                    <div id="R3WorkAreaMenu">
                        <div class="R3WorkAreaSpacer"></div><!-- header space -->

                        {if $domains|@count > 1}
                            <div id="R3WorkAreaExtra">
                                <form name="frmDomain" id="frmDomain" method="post" action="set_app_param.php">
                                    <input type="hidden" name="kind" value="domain" />
                                    <label for="global_domain">{t}Ente{/t}:</label>
                                    <select name="global_domain" id="global_domain" onChange="onChangeDomain()">
                                        {html_options options=$domains selected=$do_id}
                                    </select>
                                </form>
                            </div>
                        {/if}
                        <div id="R3FrameworkMenuID">
                            {$menu}
                        </div>

                        <div id="R3WorkAreaFooter">
                            <a href="javascript:R3MenuNavigate(this,'edit.php?on=about&amp;init')">Credits</a><br />
                            Powered by <a href="http://www.r3-gis.com/" target="blank"><span style="color:#FF6600;">R3</span> GIS</a>
                        </div>

                    </div> <!-- closing #R3WorkAreaMenu -->
                    <div id="R3WorkAreaMenuOff" style="display: none"></div>

                    <div id="right">
                        <div class="R3WorkAreaSpacer"></div><!-- header space -->

