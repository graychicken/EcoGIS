/*
 * NOTE: for lat/lon transformation the proj4js library is required
 */


(function($, undefined) {


	$.widget("gcComponent.loadingHandler", $.ui.gcComponent, {

		widgetEventPrefix: "loadingHandler",

		options: {
			gisclient: null
		},

		_create: function() {
			var self = this;
			
			$.ui.gcComponent.prototype._create.apply(self, arguments);
			
			$(self.element).hide();
			
			var html = '<div id="loading_locker" class="ui-widget-overlay" style="display:none;">'+OpenLayers.i18n('Loading')+' ........ </div>';
			$('body').append(html);
		},
		
		show: function() {
			var self = this;
			
			$(self.element).css({'z-index':$.maxZIndex()+20});
			$(self.element).show();
		},
		
		hide: function() {
			var self = this;
			
			$(self.element).hide();
		},
		
		lock: function() {
			$('#loading_locker').css({'z-index':$.maxZIndex()+50});
			$('#loading_locker').show();
		},
		
		unlock: function() {
			$('#loading_locker').hide();
		}
		
	});

	$.extend($.gcComponent.loadingHandler, {
		version: "3.0.0"
	});
})(jQuery);
