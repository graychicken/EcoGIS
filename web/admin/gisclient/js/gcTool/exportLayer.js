(function($, undefined) {


	$.widget("gcTool.exportLayer", $.ui.gcTool, {

		widgetEventPrefix: "exportLayer",

		options: {
			label: OpenLayers.i18n('Export'), //LANG
			icons: {
				primary: 'exportDbt'
			},
			text: false,
            tables: [], // {name: 'tabella_sul_db', label: 'Testo da visualizzare'} oppure {layer: 'nome feature type', label: 'Testo da visualizzare'}, se vuoto prende i layer interrogabili
            minScale: null, //es. 5000
			mapExportServiceUrl: null
		},
		
		internalVars: {
		},

		_create: function() {
			var self = this;
            
            $(self.element).remove();
            delete gisclient.toolObjects.exportLayer;
			
            if(!self.options.mapExportServiceUrl) {
                self.options.mapExportServiceUrl = gisclient.options.mapsetURL + 'services/export.php';
            }

			$.ui.gcTool.prototype._create.apply(self, arguments);
			
			var container = '<div id="gc_map_export_dialog"></div>';
			$('body').append(container);
			
            var html = '';
            if(self.options.minScale) {
                html = '<div class="noflow min_scale">'+OpenLayers.i18n('Export is available only for scales between 1 and ${scale}', {scale:self.options.minScale})+'</div>';
            }
			html += '<div class="noflow scale_ok">'+OpenLayers.i18n('Zoom to the desired extent and click on the Export button')+'<br><br>'+OpenLayers.i18n('Format')+': <select name="format"><option value="dxf">DXF</option><option value="shp">Shapefiles</option></select>'+
                '<div class="noflow" data-role="layerlist"></div>'+
				'<div class="buttons scale_ok"><button name="export">'+OpenLayers.i18n('Export')+'</button></div></div>'+
				'<hr><div class="noflow" data-role="export-list"></div>'+
				'<div class="logs"></div>'+
				'</div>';
			$('#gc_map_export_dialog').html(html);
			$('#gc_map_export_dialog').dialog({
				draggable:true,
				title:OpenLayers.i18n('Export'),
				autoOpen: false
			});
            
            var exportableLayers = [];
            if(!self.options.tables) {
                var queryableLayers = gisclient.componentObjects.gcLayersManager.getQueryableLayers();
                $.each(queryableLayers, function(featureType, config) {
                    exportableLayers.push({
                        layer: featureType,
                        label: config.title
                    });
                });
                self.options.tables = exportableLayers;
            } else {
                exportableLayers = self.options.tables;
            }
            
            var html = '';
            $.each(exportableLayers, function(e, layer) {
                var fieldName = (layer.layer ? 'layer' : 'table');
                html += '<input type="checkbox" name="'+fieldName+'" value="'+ (layer.layer || layer.table) + '"> '+layer.label + '<br>';
            });
            $('#gc_map_export_dialog div[data-role="layerlist"]').html(html);
			
			$('#gc_map_export_dialog button[name="export"]').click(function() {
				self._export();
			});
            self.options.control = new OpenLayers.Control();
		},
		
		_click: function(event) {
			var self = event.data.self;
			
			$('#gc_map_export_dialog').dialog('open');
            self._checkScale();
            gisclient.map.events.register('zoomend', self, self._checkScale);
		},
		
		_deactivate: function() {
            var self = this;
            
			if($('#gc_map_export_dialog').dialog('isOpen')) $('#gc_map_export_dialog').dialog('close');
			$('#gc_map_export_dialog div.logs').empty();
            gisclient.map.events.unregister('zoomend', self, self._checkScale);
		},
        
        _checkScale: function() {
            var self = this;
            
            var currentRes = gisclient.map.getResolution();
            var scale = OpenLayers.Util.getScaleFromResolution(currentRes, 'm');
            if(scale <= self.options.minScale) {
                $('#gc_map_export_dialog div.scale_ok').show();
                $('#gc_map_export_dialog div.min_scale').hide();
            } else {
                $('#gc_map_export_dialog div.scale_ok').hide();
                $('#gc_map_export_dialog div.min_scale').show();
            }
        },
        
        _export: function() {
            var self = this;
            
            gisclient.componentObjects.loadingHandler.show();
            $('#gc_map_export_dialog div[data-role="export-list"]').empty();
            
            var tablesToExport = [];
            $.each(self.options.tables, function(e, layer) {
                var fieldName = (layer.layer ? 'layer' : 'table');
                if($('#gc_map_export_dialog div[data-role="layerlist"] input[name="'+fieldName+'"][value="'+layer[fieldName]+'"]').is(':checked')) tablesToExport.push(layer);
            });
            
            var params = {
                srid: gisclient.getProjection(),
                extent: gisclient.map.getExtent().toArray(),
                export_format: $('#gc_map_export_dialog select[name="format"]').val(),
                tables: tablesToExport
            };
            
            $.ajax({
                url: self.options.mapExportServiceUrl,
                type: 'POST',
                dataType: 'json',
                data: params,
                success: function(response) {
                    gisclient.componentObjects.loadingHandler.hide();
                    if(response === null || typeof(response.result) === 'undefined' || response.result !== 'ok') {
                        return alert('Error');
                    }
                    
                    $('#gc_map_export_dialog div[data-role="export-list"]').append('<a href="'+response.file+'" target="_blank">'+OpenLayers.i18n('Click here to download')+'</a><br>');
                },
                error: function() {
                    gisclient.componentObjects.loadingHandler.hide();
                    alert('Error');
                }
            });
        }
	});

	$.extend($.gcTool.exportDbt, {
		version: "3.0.0"
	});
})(jQuery);
