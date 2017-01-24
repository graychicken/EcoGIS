(function($, undefined) {

	$.widget("gcTool.mapPrint", $.ui.gcTool, {

		widgetEventPrefix: "mapPrint",

		options: {
			label: OpenLayers.i18n('Print'),
			icons: {
				primary: 'print' // TODO: choose better name
			},
			text: false,
			printServiceUrl: null,
			northArrow: null
		},
		
		internalVars: {
			mapImageDialog: null
		},

		_create: function() {
			var self = this;
			$.ui.gcTool.prototype._create.apply(self, arguments);
			
            if(!self.options.printServiceUrl) {
                self.options.printServiceUrl = gisclient.getMapOptions().printServiceUrl;
            }
		},
		
		_click: function(event) {
			var self = event.data.self;

                        //disable other controls as in gcTool:_toggleControl()
                        //It seems this is needed because this tool doesn't have a OLControl and is not in the toggle list.
                        $.each(gisclient.toolObjects, function(tool, object) {
				if(object.options.control == null) return;
				if(object.options.control != null /*&& self.options.control != null*/) {
					/*if(object.options.control.id != self.options.control.id) */ object._deactivate();
				}
			});

                        var controls = gisclient.map.getControlsByClass(/OpenLayers.Control.+/);
			$.each(controls, function(i, control) {
				if(typeof(control.isPermanent) == 'undefined' || !control.isPermanent) {
					control.deactivate();
				}
			});

			self.initForm();
		},
		
		initForm: function() {
			var self = this;
			
			self.internalVars.mapImageDialog = gisclient.componentObjects.mapImageDialog;
			self.internalVars.mapImageDialog.switchTool('print', self);
			
			var time = new Date();
			var date = time.getUTCDate()+'/'+(time.getUTCMonth()+1)+'/'+time.getUTCFullYear();
			var scale = gisclient.componentObjects.scaleDropDown.getCurrentScale();
			
			self.internalVars.mapImageDialog.setDefault('scale', scale);
			self.internalVars.mapImageDialog.setDefault('date', date);
			
			self.internalVars.mapImageDialog.showForm();
		},
		
		_deactivate: function() {
			var self = this;
			
			self.internalVars.mapImageDialog.closeDialog();
		},
		
		processRequest: function() {
			var self = this;
			
			var params = self.internalVars.mapImageDialog.getParams();
			$.ajax({
				url: self.options.printServiceUrl,
				type: 'POST',
				data: JSON.stringify(params),
				dataType: 'json',
				success: function(response) {
					if(response && typeof response.result  !== 'undefined' && response.result == 'ok') {
						self.internalVars.mapImageDialog.showResult(response.file, response.format);
					} else self.internalVars.mapImageDialog.showError(OpenLayers.i18n('Error'));
				},
				error: function() {
					self.internalVars.mapImageDialog.showError(OpenLayers.i18n('Error'));
				}
			});
		}

	});

	$.extend($.gcTool.mapPrint, {
		version: "3.0.0"
	});
})(jQuery);
