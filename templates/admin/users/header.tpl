{* UTF-8 FILE: òàèü *}
<html>
<head>
  <title>{$APPLICATION_TITLE}{if $APPLICATION_VERSION <> ''} - {$APPLICATION_VERSION}{/if} {if $APPLICATION_DEBUG_LEVEL >= 4} - [DEBUG MODE]{/if}</title>
  {$meta_contenttype}
  
  {* Include CSS Files *}
  <!-- Include Stylesheets -->
  {foreach from=$umDependencies.css item=src}
  <link type="text/css" rel="stylesheet" href="{$src}" />
  {/foreach}
  
  {* Include JS Vars *}
  <!-- JS initialization vars -->
  <script type="text/javascript">
  {foreach from=$umDependencies.js_vars key=var_name item=var_value}
  {if $var_value === null} var {$var_name} = null; {elseif is_numeric($var_value)} var {$var_name}={$var_value}; {else} var {$var_name}="{$var_value}"; {/if}
  {/foreach}
  </script>
  
  {* Include JS Files *}
  <!-- Include JS libraries -->
  {foreach from=$umDependencies.js item=src}
  {if strpos($src, 'charset.js') !== false}
  {* charset.js need ISO_8859-1 otherwise IE 6 throws a error *}
  <script type="text/javascript" src="{$src}" charset="ISO_8859-1"></script>
  {else}
  <script type="text/javascript" src="{$src}"></script>
  {/if}
  {/foreach}
</head>
<body>