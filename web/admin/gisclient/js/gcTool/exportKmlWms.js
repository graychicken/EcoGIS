/* 
OpenLayers.Util.extend(OpenLayers.Lang.it, {
    'DBT Export': 'Export DBT',
    'Export is available only for scales between 1 and ${scale}': 'L\'export Ã¨ disponibile solo a scala inferiore a 1:${scale}',
    'Zoom to the desired extent, select the layers to export and click on the Export button': 'Inquadrare la zona da esportare, selezionare i layer e cliccare sul pulsante Esporta',
    'Export': 'Esporta'
}); */

(function($, undefined) {


	$.widget("gcTool.exportKmlWms", $.ui.gcTool, {

		widgetEventPrefix: "exportKmlWms",

		options: {
			label: OpenLayers.i18n('KML Export'), //LANG
			icons: {
				primary: 'exportKml'
			},
			text: false,
            layers: undefined,
            minScale: 9999999999
		},
		
		internalVars: {
		},

		_create: function() {
			var self = this;

			$.ui.gcTool.prototype._create.apply(self, arguments);
			
			var container = '<div id="gc_kmlwms_export_dialog"></div>';
			$('body').append(container);
            
            var layersManager = gisclient.componentObjects.gcLayersManager;
            
            var exportable = {};
            
            var themes = layersManager.getThemesOrder().slice();
            themes.reverse();
            var len = themes.length;
            for(var i = 0; i < len; i++) {
                var theme = layersManager.getTheme(themes[i]);
                
                var layergroups = layersManager.getLayers(theme.id);
                $.each(layergroups, function(layerId, layer) {
                    if(layer.type != 1) return;
                    if(!self.isSameDomain(layer.url)) return;
                    if(!exportable[theme.id]) exportable[theme.id] = {
                        name: theme.id,
                        title: theme.title,
                        layers: []
                    };
                    exportable[theme.id].layers.push({
                        name: layer.id,
                        title: layer.title
                    });
                });
            }

            var treeHtml = '';
            for(var i = 0; i < len; i++) {
                if(!exportable[themes[i]]) continue;
                var exp = exportable[themes[i]];
                var layers = [];
                for(var j = 0; j < exp.layers.length; j++) {
                    layers.push('<li><input type="checkbox" data-role="layer" data-key="'+exp.layers[j].name+'" data-parent="'+exp.name+'">'+exp.layers[j].title+'</li>');
                }
                treeHtml += '<li><input type="checkbox" data-role="theme" data-key="'+exp.name+'">'+exp.title+'<ul>'+layers.join('')+'</ul></li>';
            }

			var html = '<div class="noflow min_scale instructions ui-state-highlight ui-cornel-all" style="padding:2px;"><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span>'+OpenLayers.i18n('Export is available only for scales between 1 and ${scale}', {scale:self.options.minScale})+'</div>';
            var html = '<div class="noflow scale_ok"><div class=" instructions ui-state-highlight ui-cornel-all" style="padding:2px;"><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span>'+OpenLayers.i18n('Zoom to the desired extent, select the layers to export and click on the Export button')+'</div><br>'+
                '<div data-role="tree" style="background-color: white !important; margin-bottom:10px;"></div>'+
                //'<span style="float: left; margin-top: 5px;">'+OpenLayers.i18n('Format')+': </span><select name="format"><option value="dxf">DXF</option><option value="shp">Shapefiles</option></select>'+
				'<div class="buttons scale_ok" style="padding-top:5px;"><button name="export">'+OpenLayers.i18n('Export')+'</button></div></div>'+
				'<hr><div class="noflow" data-role="export-list"></div>'+
				'<div class="logs"></div>';
            
            $('#gc_kmlwms_export_dialog').html(html);
			$('#gc_kmlwms_export_dialog').dialog({
				draggable:true,
                width: 350,
				title:OpenLayers.i18n('KML Export'),
				autoOpen: false
			});
            
			$('#gc_kmlwms_export_dialog button[name="export"]').click(function() {
				self._export();
			});
            
            $('#gc_kmlwms_export_dialog div[data-role="tree"]').jstree({
                "themes" : {
                    "theme" : "default",
                    "dots" : true,
                    "icons" : false
                },
                "core" : {
                    "initially_open" : []
                },
                "html_data" : {
                    "data" : '<ul>'+treeHtml+'</ul>'
                },
				"plugins" : [ "themes", "html_data", 'crrm' ]
            }).delegate('input', 'click', {self: self}, function(event) {
                var key = $(this).attr('data-key');
                if($(this).prop('checked')) {
                    $('#gc_kmlwms_export_dialog input[type="checkbox"][data-parent="'+key+'"]').prop('checked', 'checked');
                } else {
                    $('#gc_kmlwms_export_dialog input[type="checkbox"][data-parent="'+key+'"]').removeAttr('checked');
                }
			});

            self.options.control = new OpenLayers.Control();
		},
        
        isSameDomain: function(url) {
            return (this.getDomain(url) == this.getDomain(gisclient.options.mapsetURL)); 
        },
        
        getDomain: function(url) {
            var prefix = /^https?:\/\//;
            var domain = /^[^\/]+/;
            // remove any prefix
            url = url.replace(prefix, "");
            // assume any URL that starts with a / is on the current page's domain
            if (url.charAt(0) === "/") {
                url = window.location.hostname + url;
            }
            // now extract just the domain
            var match = url.match(domain);
            if (match) {
                return(match[0]);
            }
            return(null);
        },
		
		_click: function(event) {
			var self = event.data.self;
			
			$('#gc_kmlwms_export_dialog').dialog('open');
            //self._checkScale();
            gisclient.map.events.register('zoomend', self, self._checkScale);
		},
		
                
		_deactivate: function() {
            var self = this;
            
			if($('#gc_kmlwms_export_dialog').dialog('isOpen')) $('#gc_kmlwms_export_dialog').dialog('close');
			$('#gc_kmlwms_export_dialog div.logs').empty();
            gisclient.map.events.unregister('zoomend', self, self._checkScale);
		},
        
        _checkScale: function() {
            var self = this;
            
            var currentRes = gisclient.map.getResolution();
            var scale = OpenLayers.Util.getScaleFromResolution(currentRes, 'm');
            if(scale <= self.options.minScale) {
                $('#gc_kmlwms_export_dialog div.scale_ok').show();
                $('#gc_kmlwms_export_dialog div.min_scale').hide();
            } else {
                $('#gc_kmlwms_export_dialog div.scale_ok').hide();
                $('#gc_kmlwms_export_dialog div.min_scale').show();
            }
        },
        
        _export: function() {
            var self = this;
                        
            $('#gc_kmlwms_export_dialog div[data-role="export-list"]').empty();
            var layersManager = gisclient.componentObjects.gcLayersManager;
            
            var layers = [];
            var themes = layersManager.getThemesOrder();
            themes.reverse();
            var len = themes.length;
            var oneLayer = {theme: null, layer: null};
            for(var i = 0; i < len; i++) {
                var layergroups = layersManager.getLayers(themes[i]);
                $.each(layergroups, function(id, layergroup) {
                    if($('#gc_kmlwms_export_dialog input[data-role="layer"][data-key="'+id+'"]').prop('checked')) {
                        oneLayer.theme = themes[i];
                        oneLayer.layer = id;
                        layers.push(id);
                    }
                });            
            }
            
            if(!oneLayer.theme) {
                return alert('Select at least one layer to export');
            }
            
            var oneLayer = layersManager.getLayer(oneLayer.theme, oneLayer.layer);
            var url = oneLayer.url;
            var size = gisclient.map.getSize();
            var params = $.extend({}, oneLayer.parameters, {
                service: 'WMS',
                request: 'GetMap',
                version: '1.1.1',
                styles: '',
                width: size.w,
                height: size.h,
                format: 'kml',
                layers: layers.join(','),
                bbox: gisclient.map.getExtent().toString(),
                srs: gisclient.getProjection()
            });
            
            url = self.buildUrl(url, params);
            
            $('#gc_kmlwms_export_dialog div[data-role="export-list"]').append('<a href="'+url+'" target="_blank">'+OpenLayers.i18n('Click here to download')+'</a><br>');
            
            return console.log(layers);
                
            $.each(self.options.tables, function(e, strato) {
                $.each(strato.children, function(f, tema) {
                    if($('#gc_kmlwms_export_dialog input[data-role="tema"][data-key="'+tema.key+'"]').attr('checked') == 'checked') {
                        $.each(tema.tables, function(g, table) { tables.push(table); });
                    }
                });
            });
            
            var params = {
                srid: gisclient.getProjection(),
                extent: gisclient.map.getExtent().toArray(),
                export_format: $('#gc_kmlwms_export_dialog select[name="format"]').val(),
                tables: tables
            };
            
            $.ajax({
                url: self.options.mapExportServiceUrl,
                type: 'POST',
                dataType: 'json',
                data: params,
                success: function(response) {
                    gisclient.componentObjects.loadingHandler.hide();
                    if(response == null || typeof(response.result) == 'undefined' || response.result != 'ok') {
                        return alert('Error');
                    }
                    
                    $('#gc_kmlwms_export_dialog div[data-role="export-list"]').append('<a href="'+response.file+'" target="_blank">'+OpenLayers.i18n('Click here to download')+'</a><br>');
                },
                error: function() {
                    gisclient.componentObjects.loadingHandler.hide();
                    alert('Error');
                }
            });
            
        },
        
        buildUrl: function(url, data) {
            var ret = [];
            for (var d in data)
                ret.push(encodeURIComponent(d).toUpperCase() + "=" + encodeURIComponent(data[d]));
            
            url += '?' + ret.join('&');

            return url;
        }

	});

	$.extend($.gcTool.exportDbt, {
		version: "3.0.0"
	});
})(jQuery);

