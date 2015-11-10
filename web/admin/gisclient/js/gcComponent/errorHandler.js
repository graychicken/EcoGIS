/*
 * NOTE: for lat/lon transformation the proj4js library is required
 */


(function($, undefined) {


	$.widget("gcComponent.errorHandler", $.ui.gcComponent, {

		widgetEventPrefix: "errorHandler",

		options: {
			gisclient: null,
			isOpen: false
		},

		_create: function() {
			var self = this;
			
			$.ui.gcComponent.prototype._create.apply(self, arguments);
			
			var html = '<br /><button id="error_handler_close">'+OpenLayers.i18n('Close')+'</button>';
			$(self.element).append(html);
			$('#error_handler_close').click(function(event) {
				event.preventDefault();
				self.hide();
			});
			
			$(self.element).hide();
		},
		
		show: function(text) {
			var self = this;
			
			if(!self.options.isOpen) {
				$(self.element).css({'z-index':$.maxZIndex()+5});
				$(self.element).find('span').empty();
				$(self.element).show();
				self.options.isOpen = true;
			}
			$(self.element).find('span').append(text+'<br />');
			gisclient.componentObjects.loadingHandler.hide();
		},
		
		hide: function() {
			var self = this;
			
			$(self.element).hide();
			$(self.element).find('span').empty();
			self.options.isOpen = false;
		}
		
	});

	$.extend($.gcComponent.errorHandler, {
		version: "3.0.0"
	});
})(jQuery);
