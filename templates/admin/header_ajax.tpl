<html>
    <head>
    </head>
    <body>
        {* JS vars initialized here because of chrome problems *}
        {if count($js_vars) > 0}
            <!-- JS initialization vars -->
            <script type="text/javascript">
                {foreach from=$js_vars key=key item=val}
                    {if $val === null}  var {$key} = null; {elseif is_numeric($val)}  var {$key} ={$val}; {else}  var {$key} = "{$val}"; {/if}
                {/foreach}
            </script>
        {/if}
        {if $USER_CONFIG_APPLICATION_INLINE_JS <> 'T'} {* ONLY FOR EXTERNAL JS *}
                <!-- Extra JS files -->
                {foreach from=$js_files item=file}
                    <script type="text/javascript" src="{$file}"></script>
                {/foreach}
            {/if}
            {if $USER_CONFIG_APPLICATION_INLINE_JS == 'T'}
                <!-- Inline javascript -->
                <script type="text/javascript">
                    {foreach from=$js_files item=data}
                        {$data}
                    {/foreach}
                </script>
            {/if}
            {if $USER_CONFIG_APPLICATION_NUM_LANGUAGES <> ''}
                <script type="text/javascript">
                    var numLanguages = {$USER_CONFIG_APPLICATION_NUM_LANGUAGES};
                </script>
            {/if}
