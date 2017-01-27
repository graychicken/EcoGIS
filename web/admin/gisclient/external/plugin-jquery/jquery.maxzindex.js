$.maxZIndex = $.fn.maxZIndex = function(selector) {
    var zmax = 0;
    if (typeof selector == 'undefined') {
        selector='body > *';
    }
    $(selector).each(function() {
		var cur = parseInt($(this).css('z-index'));
        zmax = cur > zmax ? cur : zmax;
    });
	return zmax;
}