<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
    "http://www.w3.org/TR/html4/strict.dtd">
<html>
    <head>
        <title>{$APPLICATION_TITLE}</title>
        <link rel="stylesheet" type="text/css" href="{$smarty.const.R3_CSS_URL}{$smarty.const.BUILD}/login.css">
    </head>
    <body>
        {if $APPLICATION_WELCOME_MESSAGE != ''}
            <div class="Lmessage">{$APPLICATION_WELCOME_MESSAGE}</div>
        {/if}
        <div class="Lcontainer">
            <div class="Lheader">
                {if $smarty.const.R3_IS_MULTIDOMAIN}
                    {* Multi-domain logo *}
                    <div class="Llogodx"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/logo/{$smarty.const.CURRENT_DOMAIN_NAME|lower}/login_sx.png" /></div>
                    <div class="Llogosx"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/logo/{$smarty.const.CURRENT_DOMAIN_NAME|lower}/login_dx.png" /></div>
                    {else}
                    <div class="Llogodx"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/logo/{$smarty.const.DOMAIN_NAME|lower}/login_dx.png" /></div>
                    <div class="Llogosx"><img src="{$smarty.const.R3_IMAGES_URL}{$smarty.const.BUILD}/logo/{$smarty.const.DOMAIN_NAME|lower}/login_sx.png" /></div>
                    {/if}

            </div>
            <div class="Ltitle">
                <strong>{$APPLICATION_TITLE}{if $APPLICATION_VERSION <> ''} - {$APPLICATION_VERSION}{/if}</strong>
            </div>
            <div class="Lform">
                <form name="frmLogin" id="frmLogin" method="post" action="login.php" onsubmit="return onFormSubmit();">
                    <div>{t}Login{/t}    <input type="text"     id="login"    name="login"    value="" style="width:200px;" /></div>
                    <div>{t}Password{/t} <input type="password" id="password" name="password" value="" style="width:200px;" /></div>
                    <input type="submit" name="btnLogin" id="btnLogin" value="{t}Login{/t}" style="width:80px;height:25px;" />
                </form>
            </div>
            {if $warnmsg <> ''}
                <div id="divWarning" class="Lwarning">{$warnmsg}</div>
            {/if}
            <div id="divLoading" class="Lloading">Loading...</div>
            <div class="Lfooter">
                <div style="text-align:right;">Powered by <a href="http://www.r3-gis.com/" target="blank"><span style="color:#FF6600;">R3</span> GIS</a></div>
            </div>
        </div>
        <script type="text/javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD}/jquery/jquery.js" ></script>
        <script type="text/javascript" src="{$smarty.const.R3_JS_URL}{$smarty.const.BUILD}/jquery/jquery-ui/jquery-ui.js" ></script>
        <script type="text/javascript" language="JavaScript">
            {literal}

                function onFormSubmit() {
                    $('#divLoading').css('visibility', '');
                    $('#btnLogin').attr("disabled", true);
                    return true;
                }
                function doFocus() {
                    // Focus
                    if ($("#login").val() == '') {
                        $("#login").focus();
                    } else if ($("#password").val() == '') {
                        $("#password").focus();
                    } else {
                        $("#btnLogin").focus();
                    }
                }
            {/literal}
            {if $errmsg <> ''}
                $(document).ready(function () {ldelim}
                    alert("{$errmsg}")
                {rdelim});
            {/if}
            {literal}
                $(document).ready(function () {
                    if (top != window) {
                        top.document.location = 'login.php'
                    }
                    $('#divLoading').hide();
                    doFocus();
                });

            {/literal}
        </script>
    </body>
</html>