(function($){

    function replacePlaceholdersInTemplate(tpl, valuesMap) {
        var finalLink = tpl;
        for (var placeholder in valuesMap) {
            if (valuesMap.hasOwnProperty(placeholder)) {
                var needle_re = new RegExp('\{:'+placeholder+'\}', 'g');
                finalLink = finalLink.replace(needle_re, valuesMap[placeholder]);
            }
        }
        return finalLink;
    }
    
    $.widget("gcComponent.detailTable", $.ui.gcComponent, {
        widgetEventPrefix: 'detailTable',
		
		options: {
            serviceUrl: null,
            linkTemplates: null
		},
		
		internalVars: {
			data: {},
			selectedFeature: null
		},
		
        _create: function() {
            var self = this;
			$.ui.gcComponent.prototype._create.apply(self, arguments);
            
            self.options.serviceUrl = gisclient.getMapOptions().detailServiceUrl;
            self.options.linkTemplates = gisclient.getMapOptions().detailLinkTemplates;
			
			var html = '<table id="detail_table" border="1"></table>';
			self.element.html(html);
			
            var dialogOptions = $.extend({}, gisclient.options.dialogDefaultPosition, {
                draggable:true,
                width: 800,
				title: OpenLayers.i18n('Table'),
				height: 600,
                autoOpen:false,
				close: function(event, self) {
					var self = gisclient.componentObjects.detailTable;
					self._clear();
				}
            });
            self.element.dialog(dialogOptions);
        },
        
        show: function(relationId, value) {
            var self = this;
            
            $.ajax({
                type: 'POST',
                url: self.options.serviceUrl,
                dataType: 'json',
                data: {
                    relation_id: relationId,
                    f_key_value: value
                },
                success: function(response) {
                    if(typeof(response) !== 'object' || typeof(response.result) === 'undefined' || response.result !== 'ok') {
                        return alert(OpenLayers.i18n('System error'));
                    }
                    var html = '<table><tr>';
                    var exportFields = [];
                    $.each(response.data.fields, function(e, field) {
                        html += '<th>'+field.field_header+'</th>';
                        
                        // add fields to export list
                        exportFields.push({
                            title: field.field_header,
                            field_name: field.field_name
                        });
                    });
                    
                    $.each(response.data.results, function(e, row) {
                        html += '<tr>';
                        $.each(response.data.fields, function(e, field) {
                            html += '<td>';
                            var key = false;
                           
                            // is there a template for this query relation and key
                            // this field a?
                            if (relationId in self.options.linkTemplates &&
                                field.field_name in self.options.linkTemplates[key]) {
                                // yes, a specific one
                                key = relationId;
                            } else if ('__any__' in self.options.linkTemplates &&
                                field.field_name in self.options.linkTemplates['__any__']) {
                                // yes, the generic one
                                key = '__any__';
                            }
                            
                            var cellContent;
                            if (key) {
                                var tpl = self.options.linkTemplates[key][field.field_name];
                                cellContent = replacePlaceholdersInTemplate(tpl, row);
                            } else {
                                cellContent = row[field.field_name];
                            }
                            html += cellContent;
                            html += '</td>';
                        });
                        html += '</tr>';
                    });
                    html += '</table><br><a href="#" data-action="export_xls">Export</a>';
                    
                    $('table', self.element).html(html);
                    
                    $('table a[data-action="export_xls"]', self.element).click(function(event) {
                        event.preventDefault();

                        var params = {
                            export_format: 'xls',
                            fields: exportFields,
                            data: response.data.results
                        };
                        
                        $.ajax({
                            type:'POST',
                            dataType:'json',
                            url:gisclient.getMapOptions().mapExportServiceUrl,
                            data: params,
                            success: function(response) {
                                if(typeof response !== 'object' || typeof response.result === 'undefined' || response.result !== 'ok') {
                                    alert('Error');
                                }
                                location.href = response.file;
                            },
                            error: function() {
                                alert('Error');
                            }
                        });
                        
                    });
                    
                    $(self.element).dialog('open');
                },
                error: function() {
                    alert(OpenLayers.i18n('System error'));
                }
            });
        },
		
		_clear: function() {
			var self = this;
			
			$('table', self.element).empty();
		}
    });

    $.extend($.gcComponent.detailTable, {
        version: "3.0.0"
    });
})(jQuery);
