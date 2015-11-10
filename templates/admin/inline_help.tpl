{* HELP *}

{literal}
    <script language="JavaScript" type="text/javascript">
        $(document).ready(function () {
            $('#help_container_close').bind('click', function () {
                hideR3Help()
            });
        });
    </script>
{/literal}
<div class="help_container" id="help_container" style="display: none">
    <div class="help_container_header" id="help_container_header" style="height: 20px;">
        <img id="help_container_loader" style="float: left" src="../images/{if $smarty.const.BUILD != ''}{$smarty.const.BUILD|lower}/{/if}ajax_loader.gif">
        <b>{t}HELP{/t}</b>
        <img id="help_container_close" style="float: right" src="../images/{if $smarty.const.BUILD != ''}{$smarty.const.BUILD|lower}/{/if}ico_close.gif">
    </div>
    <div class="help_container_title" id="help_container_title">{t}Loading...{/t}</div>
    <div class="help_container_body" id="help_container_body"></div>
</div>  
