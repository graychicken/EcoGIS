/*
 */


(function($, undefined) {


	$.widget("gcTool.mapContext", $.ui.gcTool, {

		widgetEventPrefix: "mapContext",

		options: {
			label: OpenLayers.i18n('Map Context'), //LANG
			icons: {
				primary: 'mapContext'
			},
			text: false,
			mapContextServiceUrl: null
		},
		
		internalVars: {
		},

		_create: function() {
			var self = this;
			
			self.options.mapContextServiceUrl = gisclient.getMapOptions().mapContextServiceUrl;

			$.ui.gcTool.prototype._create.apply(self, arguments);
			
			var container = '<div id="gc_map_context_dialog"></div>';
			$('body').append(container);
			
			var html = '<div class="noflow">'+OpenLayers.i18n('Title')+': <input type="text" name="title">'+
				'<div class="buttons"><button name="save">'+OpenLayers.i18n('Save')+'</button></div></div>'+
				'<div class="noflow"><hr><ul></ul></div>'+
				'<div class="logs"></div>'+
				'</div>';
							
			$('#gc_map_context_dialog').html(html);
			$('#gc_map_context_dialog').dialog({
				draggable:true,
				title:OpenLayers.i18n('Map Context'),
				autoOpen: false
			});
			
			$('#gc_map_context_dialog button[name="save"]').click(function() {
				self._save();
			});
		},
		
		_click: function(event) {
			var self = event.data.self;
			
			$('#gc_map_context_dialog').dialog('open');
			self.getContextList();
			$('#gc_map_context_dialog div.logs').empty();
		},
		
		_deactivate: function() {
			if($('#gc_map_context_dialog').dialog('isOpen')) $('#gc_map_context_dialog').dialog('close');
			$('#gc_map_context_dialog div.logs').empty();
		},
		
		_save: function() {
			var self = this;
			
			var title = $.trim($('#gc_map_context_dialog input[name="title"]').val());
			if(title == '') {
				return $('#gc_map_context_dialog div.logs').html(OpenLayers.i18n('Insert a title')); //LANG
			}
			
            var saveObject = {
                title: title,
                success: function() {
                    self.getContextList();
                },
                error: function() {
                    alert('Error');
                }
            };
            
            gisclient.componentObjects.contextHandler.save(saveObject);
		},
		
		getContextList: function() {
			var self = this;
			
			$('#gc_map_context_dialog ul').empty();
			
			$.ajax({
				type: 'GET',
				url: self.options.mapContextServiceUrl,
				dataType: 'json',
				data: {action:'list', mapset: gisclient.getMapOptions().mapsetName},
				success: function(response) {
					if(typeof(response) != 'object' || response == null || typeof(response.result) == 'undefined' || response.result != 'ok') {
						return alert('Error');
					}
					var html = '';
					var mapContextUrl;
					$.each(response.contextes, function(e, context) {
						mapContextUrl = gisclient.componentObjects.contextHandler.getContextUrl(context.id)
						html += '<li style="margin-bottom:5px;"><a href="#" data-context_id="'+context.id+'" data-action="load">'+context.title+'</a> '+
							'<a href="'+mapContextUrl+'" class="gc_ui-icon-minimized" target="_blank" data-action="link">'+OpenLayers.i18n('Link')+'</a> '+
							'<a href="#" data-context_id="'+context.id+'" data-action="delete" class="gc_ui-icon-minimized">'+OpenLayers.i18n('Delete')+'</a></li>';
					});
					$('#gc_map_context_dialog ul').html(html);
					$('#gc_map_context_dialog ul a[data-action="link"]').button({icons:{primary:'ui-icon-link'},text:false});
					$('#gc_map_context_dialog ul a[data-action="load"]').click(function(event) {
						event.preventDefault();
						
						gisclient.getContext($(this).attr('data-context_id'));
					});
					$('#gc_map_context_dialog ul a[data-action="delete"]').button({icons:{primary:'ui-icon-trash'},text:false}).click(function(event) {
						event.preventDefault();
						
						self.deleteContext($(this).attr('data-context_id'));
					});
				},
				error: function() {
					alert('Error');
				}
			});
		},
		
		deleteContext: function(id) {
			var self = this;
			
			$.ajax({
				type: 'POST',
				url: self.options.mapContextServiceUrl,
				dataType: 'json',
				data: {action:'delete', id: id},
				success: function(response) {
					if(typeof(response) != 'object' || response == null || typeof(response.result) == 'undefined' || response.result != 'ok') {
						return alert('Error');
					}
					self.getContextList();
				},
				error: function() {
					alert('Error');
				}
			});
		}

	});

	$.extend($.gcTool.mapContext, {
		version: "3.0.0"
	});
})(jQuery);
