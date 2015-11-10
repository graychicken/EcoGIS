{include file="header_w_menu.tpl"}

{if $USER_CONFIG_PREFETCH_START_DELAY_TIME > 0 && $prefetchFiles|@count > 0}
    {literal}
        <script language="JavaScript" type="text/javascript">
            var prefetchTime = {/literal}{$prefetchTime}{literal};
            var prefetchTime2 = 100;
            var prefetchFiles = ['{/literal}{$prefetchFiles}{literal}'];

            function prefetchFile(fileNo) {
                $.get(prefetchFiles[fileNo], function (data) {
                    fileNo = fileNo + 1;
                    if (fileNo < prefetchFiles.length) {
                        setTimeout("prefetchFile(" + fileNo + ")", prefetchTime2);
                    }
                }, 'html');
            }

            $(document).ready(function () {
                setTimeout("prefetchFile(0)", prefetchTime);
            });

        </script>
    {/literal}
{/if}
<iframe name="R3FrameworkID" id="R3FrameworkID" frameborder="0" src="{$url}" scrolling="auto"></iframe>

{include file="footer_w_menu.tpl"}

