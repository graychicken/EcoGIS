(function($, undefined) {

	$.widget("gcTool.mapImageDownload", $.ui.gcTool, {

		widgetEventPrefix: "mapImageDownload",

		options: {
			label: OpenLayers.i18n('Download image'),
			icons: {
				primary: 'download_map' // TODO: choose better name
			},
			text: false,
			downloadFile: 'download.php',
			downloadFileUrl: null,
			northArrow: null
		},
		
		internalVars: {
			mapImageDialog: null
		},

		_create: function() {
			var self = this;
			$.ui.gcTool.prototype._create.apply(self, arguments);
			
            self.options.downloadFileUrl = gisclient.getMapOptions().mapDownloadServiceUrl;
		},
		
		_click: function(event) {
			var self = event.data.self;
			self.initForm();
		},
		
		initForm: function() {
			var self = this;
			
			self.internalVars.mapImageDialog = gisclient.componentObjects.mapImageDialog;
			self.internalVars.mapImageDialog.switchTool('download', self);
			
			var scale = gisclient.componentObjects.scaleDropDown.getCurrentScale();
			self.internalVars.mapImageDialog.setDefault('scale', scale);
			
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
				url: self.options.downloadFileUrl,
				type: 'POST',
				data: params,
				dataType: 'json',
				success: function(response) {
					if(typeof response.result !== 'undefined' && response.result == 'ok') {
						self.internalVars.mapImageDialog.showResult(response.file, response.format);
					} else self.internalVars.mapImageDialog.showError(OpenLayers.i18n('Error'));
				},
				error: function() {
					self.internalVars.mapImageDialog.showError(OpenLayers.i18n('Error'));
				}
			});
		}

	});

	$.extend($.gcTool.mapImageDownload, {
		version: "3.0.0"
	});
})(jQuery);
