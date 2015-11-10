(function($, undefined) {


    $.widget("ui.gcComponent", {

		widgetEventPrefix: "gcComponent",

		options: {
			gisclient: null,
			numDigits: 2
		},
		
		_create: function() {
			var self = this;
			gisclient.componentObjects[self.widgetEventPrefix] = self;
		},
		
		_addWidgetElementPrefix: function(name) { // spostarle nell'oggetto parent???
			var options = this.options;
			if (options.widgetElementPrefix !== null)
				return options.widgetElementPrefix+'_'+name;
			else
				return name;
		},
		
		removeWidgetElementPrefix: function(name) {
			var options = this.options;
			if (options.widgetElementPrefix !== null) {
				return name.replace(options.widgetElementPrefix+'_', '');
			} else return name;
		}
		
	});

	$.extend($.ui.gcComponent, {
		version: "3.0.0"
	});
})(jQuery);
