{if $exclude_main_menu}{include file="header_no_menu.tpl"}{else}{include file="header_w_menu.tpl"}{/if}
{if $footer_height != ''}
<script type="text/javascript">
var footer_height={$footer_height};  {* Prevent footer text (Power by) *}
</script>
{/if}
{literal}
<script type="text/javascript">
function getTopPosition(id) {
    obj = document.getElementById(id);
    if (!obj) {
        return null;
    }
    y = 0;
    tmpobj = obj;
    while (tmpobj.offsetParent != null) {
        y += tmpobj.offsetTop;
        tmpobj = tmpobj.offsetParent;
    }
    y += tmpobj.offsetTop;
    return y;
}
function getInnerHeight() {
    
    if (self.innerWidth) {
        return self.innerHeight;
    } else if (document.documentElement && document.documentElement.clientHeight) {
        return document.documentElement.clientHeight;
    } else if (document.body) {
        return document.body.clientHeight;
    } else 
        return;

}
function setHeight(id, height) {
    obj = document.getElementById(id)
    if (obj) {
        obj.height = Math.max(0, height);
    }
}
function doResize() {
    setHeight('framework', getInnerHeight() - getTopPosition('framework') - 15);
}
window.onresize=function() {
    doResize();
};


window.onload=function() {
    document.body.style.overflow="hidden";
    obj = document.getElementById('framework');
    obj.style.display = '';
    doResize();
    
};

</script>
{/literal}
{if $obj != 'personal_settings' && $obj != 'personal_signature' && $hasMenu}
<iframe name="framework_menu" id="framework_menu" frameborder="0" scrolling="no" src="users/menu.php?{if $status}status={$status}&amp;{/if}{if $obj}obj={$obj}&amp;{/if}" width="100%" height="20"></iframe>
{/if}
<iframe name="framework" id="framework" frameborder="0" style="display: none" scrolling="auto" src="users/index.php?{if $status}status={$status}&amp;{/if}{if $obj}obj={$obj}&amp;{/if}st=0&amp;pg=1" width="100%" height="600"></iframe>
<img src="../images/spacer.gif" width="100%" height="1">

{if isset($exclude_main_menu) && $exclude_main_menu}{include file="footer_no_menu.tpl"}{else}{include file="footer.tpl"}{/if}