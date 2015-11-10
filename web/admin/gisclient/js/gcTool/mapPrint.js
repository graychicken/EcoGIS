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
				data: params,
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
