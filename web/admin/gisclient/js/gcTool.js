/* 
 */


(function($, undefined) {


    $.widget("ui.gcTool", $.ui.button, {

		widgetEventPrefix: "gcTool",

		options: {
			gisclient: null,
			control: null
		},

		_create: function() {
			var self = this;

			$.ui.button.prototype._create.apply(self, arguments);

			// bind default action
			self.element.bind('click.'+self.widgetEventPrefix, {
				self: self
			}, self._click);
			gisclient.toolObjects[self.widgetEventPrefix] = self;
		},

		_click: function(event) {
			var self = event.data.self;
			
			gisclient.componentObjects.loadingHandler.hide();
			gisclient.componentObjects.errorHandler.hide();

			self._toggleControl();

			// call event change
			self._trigger( "click", event, self._getUIHash() );
			
			$(gisclient.element).focus(); //IE workaround
		},

		_toggleControl: function() {
			var self = this;

			$.each(gisclient.toolObjects, function(tool, object) {
				if(object.options.control == null) return;
				if(object.options.control != null && self.options.control != null) {
					if(object.options.control.id != self.options.control.id) object._deactivate();
				}
			});

                        //close mapImageDialog from here if it exists, not in control list.
                        if(typeof gisclient.componentObjects.mapImageDialog !== "undefined") {
                            gisclient.componentObjects.mapImageDialog.closeDialog();
                        }

			// deactivate all controls first
			var controls = gisclient.map.getControlsByClass(/OpenLayers.Control.+/);
			$.each(controls, function(i, control) {
				if(typeof(control.isPermanent) == 'undefined' || !control.isPermanent) {
					control.deactivate();
				}
			});
			var deactive =  function(toolName, toolObject) {
				if(toolObject.element != self.element){
					toolObject.element.prop('checked', false);
				}
			};
			$.each(gisclient.toolObjects, deactive);
			if(self.options.control != null) self.options.control.activate();
			self.element.prop('checked', true);
			
		},
		
		_deactivate: function() {
		},

		_getUIHash: function() {
			var self = this;

			var uiHash = {
				gisclient: self.options.gisclient,
				control: self.options.control
			};
			
			return uiHash;
		}
	});

	$.extend($.ui.gcTool, {
		version: "3.0.0"
	});
})(jQuery);
