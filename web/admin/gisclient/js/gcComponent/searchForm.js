(function($, undefined) {


    $.widget("gcComponent.searchForm", $.ui.gcComponent, {
        widgetEventPrefix: "searchForm",
        options: {
            gisclient: null,
            widgetElementPrefix: 'searchForm',
            queryModels: {},
            featureId: null,
            tooltips: true,
            tooltipWidth: 200,
            idDataList: null,
            idTree: null,
            hoverControl: null,
            requests: {},
            cols: {},
            useWfs: true,
            limitLayers: [],
            actionSelectionParent: 'searchForm_fields', // the parent of the after selection action radio button
            limitVectorFeatures: 100, // if the selected features are more of this limit, the user must to confirm the selection
            displayFeatures: true // if true, vector features will be downloaded and displayed
        },
        internalVars: {
            noResultsMsg: 'No results'
        },
        _create: function() {
            var self = this;

            // extend this object with the searchEngine functions (used by selectByBox too)
            $.extend(this, $.searchEngine);

            $.ui.gcComponent.prototype._create.apply(self, arguments);

            // create a dropdown for the layer selection
            var htmlModels = OpenLayers.i18n('Searchable layers') + '<br />'//LANG
                    + '<select name="searchForm_themes" id="searchForm_themes" style="width: 250px;">'
                    + '<option value="0">' + OpenLayers.i18n('Select') + '</option>';

            self.options.queryModels = gisclient.componentObjects.gcLayersManager.getQueryableLayers(false, true);
            if (self.options.queryModels === null)
                return;

            var filteredQueryModels = {};
            $.each(self.options.queryModels, function(featureType, featureSpecs) {
                //console.log(featureSpecs);
                if (!featureSpecs.searchable)
                    return;
                //console.log(self.options.limitLayers);
                if (self.options.limitLayers.length > 0) {
                    if ($.inArray(featureType, self.options.limitLayers) == -1)
                        return;
                }
                var hasSearchableFields = false;
                $.each(featureSpecs.fields, function(e, field) {
                    if (field.searchType != 0) {
                        hasSearchableFields = true;
//                        return false;
                    }
                });
                if (!hasSearchableFields)
                    return;
                filteredQueryModels[featureType] = featureSpecs;
            });
            self.options.queryModels = filteredQueryModels;

            var currentGroup = null;
            $.each(self.options.queryModels, function(featureId, layer) {
                if (currentGroup != layer.groupTitle) {
                    htmlModels += '<optgroup label="' + layer.groupTitle + '">';
                    currentGroup = layer.groupTitle;
                }
                htmlModels += '<option value="' + self._addWidgetElementPrefix(featureId) + '">' + layer.title + '</option>';
            });

            htmlModels += '</select><div id="searchForm_fields"></div>';

            $(self.element).html(htmlModels);

            // on dropdown change, update the query model
            $('#searchForm_themes').change(function() {
                if ($(this).val() == '0')
                    return;
                self._changeQueryModel($(this).val());
            });

            // create html for the result tab
            var html = '<div id="datalist_options"></div><div id="datalist_searchresults"></div>';
            $('#' + self.options.idDataList).html(html);
            $('#datalist_options > input[name="datalist_show_tooltips"]').click(function(event) {
                self._toggleToolTipOption($(this).attr('checked'));
            });

            // add an hover control to the map to activate the reciprocal highlight feature
            var selectionLayer = gisclient.componentObjects.gcLayersManager.getSelectionLayer();
            self.options.hoverControl = new OpenLayers.Control.SelectFeature(selectionLayer, {hover: true});
            self.options.hoverControl.events.register('featurehighlighted', self, self._highlightTableRow);
            self.options.hoverControl.events.register('featureunhighlighted', self, self._unhighlightTableRow);
            gisclient.map.addControl(self.options.hoverControl);

            $('#dataListTab').hide();

            // select width ie8 fix
            $('select#searchForm_themes').ieSelectWidth({
                containerClassName: 'select-container',
                overlayClassName: 'select-overlay'
          });
        },
        _changeQueryModel: function(featureId) {
            var self = this;

            var featureId = self.removeWidgetElementPrefix(featureId);
            self.options.featureId = featureId;
            var queryModel = self.options.queryModels[featureId];

            // create html based on the selected querymodel
            var html = '<fieldset><legend>' + OpenLayers.i18n('Search fields') + '</legend>';//LANG
            var datepickers = [];
            var autocompletes = {};
            var numericOperators = {'EQUAL_TO': '=', 'NOT_EQUAL_TO': '!=', 'LESS_THAN': '<', 'GREATER_THAN': '>'};

            // build the form based on the field search type
            $.each(queryModel.fields, function(fieldId, field) {
                if (field.searchType != 0) {
                    var inputId = self._addWidgetElementPrefix(fieldId);
                    var htmlField = '<p>' + field.fieldHeader + '</p>';
                    var size = '';
                    if (field.searchType == 4) {
                        htmlField += '<select class="floating_select" id="' + self._addWidgetElementPrefix('op_' + fieldId) + '">';
                        $.each(numericOperators, function(key, val) {
                            htmlField += '<option value="' + key + '">' + val + '</option>';
                        });
                        html += '</select>';
                        var size = ' size="10"';
                    }
                    if (field.searchType == 5) {
                        htmlField += '<input name="' + inputId + '" id="' + inputId + '" rel="user_inputs" type="hidden" ' + size + '/>';
                        htmlField += '<input name="' + inputId + '_dummy" id="' + inputId + '_dummy" type="text" ' + size + '>';
                    } else {
                        htmlField += '<input name="' + inputId + '" id="' + inputId + '" rel="user_inputs" type="text" ' + size + '/>';
                    }
                    html += htmlField + '';
                    if (field.searchType == 5)
                        datepickers.push(inputId);
                    if (field.searchType == 3 || field.searchType == 6) {
                        var autoCompleteConfig = {feature: queryModel, selectedField: fieldId};
                        if (field.searchType == 6)
                            autoCompleteConfig.useWfs = false;
                        autocompletes[inputId] = autoCompleteConfig;
                    }
                }
            });
            html += '<div><input type="radio" id="' + self._addWidgetElementPrefix('logical') + '_AND" name="' + self._addWidgetElementPrefix('logical') + '" value="AND" checked><label for="' + self._addWidgetElementPrefix('logical') + '_AND">' + OpenLayers.i18n('AND') + '</label> <input type="radio" name="' + self._addWidgetElementPrefix('logical') + '" id="' + self._addWidgetElementPrefix('logical') + '_OR" value="OR"><label for="' + self._addWidgetElementPrefix('logical') + '_OR">' + OpenLayers.i18n('OR') + '</label></div>';
            html += '</fieldset>';
            html += '<fieldset><legend>' + OpenLayers.i18n('After selection action') + '</legend>';//LANG
            html += '<div><input type="radio" name="after_selection_action" id="zoom" value="zoom" checked> <label for="zoom">' + OpenLayers.i18n('Zoom') + '</label> <input type="radio" name="after_selection_action" id="center" value="center">  <label for="center">' + OpenLayers.i18n('Center') + '</label> <input type="radio" name="after_selection_action" id="none" value="none"> <label for="none">' + OpenLayers.i18n('None') + '</label></div>';
            html += '<div><input type="checkbox" name="limit_to_extent" id="limit_to_extent"> <label for="limit_to_extent">' + OpenLayers.i18n('Limit to current extent') + '</label></div>';
            html += '<div><input type="checkbox" name="display_features" id="' + self._addWidgetElementPrefix('display_features') + '" checked="checked"> <label for="' + self._addWidgetElementPrefix('display_features') + '">' + OpenLayers.i18n('Display Vector Features') + '</label></div>';
            html += '</fieldset><br />';
            html += '<input type="submit" name="submit" id="' + self._addWidgetElementPrefix('submit') + '" value="' + OpenLayers.i18n('Search') + '"> <button name="annulla_selezione">' + OpenLayers.i18n('Unselect all') + '</button>';
            // add form HTML to DOM
            $('#searchForm_fields').html(html);
            // init the datepickers for data fields
            $.each(datepickers, function(i, fieldId) {
                $('#' + fieldId + '_dummy').datepicker({altField: '#' + fieldId, altFormat: "yy-mm-dd"});
            });
            // init autocomplete
            $.each(autocompletes, function(inputId, autocompleteObj) {
                var field, preFilterField, preFilterInputId;
                $.each(autocompleteObj.feature.fields, function(fieldName, fieldObj) {
                    if (fieldName == autocompleteObj.selectedField)
                        field = fieldObj;
                });
                if (field && field.filterFieldName) {
                    if ($('#' + self._addWidgetElementPrefix(field.filterFieldName)).length > 0) {
                        preFilterInputId = '#' + self._addWidgetElementPrefix(field.filterFieldName);
                        preFilterField = field.filterFieldName;
                    }
                }

                var useWfs = self.options.useWfs;
                if (typeof(autocompleteObj.useWfs) != 'undefined' && autocompleteObj.useWfs === false) {
                    useWfs = false;
                }

                $('#' + inputId).autocomplete({
                    minLength: 0,
                    feature: autocompleteObj.feature,
                    selectedField: autocompleteObj.selectedField,
                    useWfs: useWfs,
                    preFilterField: preFilterField,
                    preFilterInputId: preFilterInputId,
                    source: gisclient.autocompleteFromQueryableLayer
                });

                $('#' + inputId).click(function() {
                    $('#' + inputId).autocomplete('search', '').select();
                });
            });

            $('#searchForm_submit').click(function(event) {
                event.preventDefault();
                self._startSearch(event);
            });
            $('#searchForm_fields button[name="annulla_selezione"]').click(function(event) {
                event.preventDefault();
                self.unSelectAll();
            });
        },
        _startSearch: function(event) {
            var self = this;

            // activate the hoverControl if it is not active yet
            if (!self.options.hoverControl.active)
                self.options.hoverControl.activate();

            gisclient.componentObjects.loadingHandler.show();

            self.unSelectAll();

            self.options.displayFeatures = $('#' + self._addWidgetElementPrefix('display_features')).attr('checked');
            var featureId = self.options.featureId;
            var queryModel = self.options.queryModels[featureId];
            var $inputs = $('#searchForm_fields :input[rel="user_inputs"]');
            // build a filters array with the inputs filled by user
            var filters = [];
            $inputs.each(function() {
                if ($(this).val() != '' && $(this).attr('type') != 'radio') {
                    var key = self.removeWidgetElementPrefix(this.id);
                    filters.push({featureId: featureId, field: key, value: $(this).val()});
                }
            });
            // there must be at least one key to start search
            if (filters.length > 0) {
                if (filters.length == 1) {
                    var filter = self._buildOLFilter(featureId, filters[0]);
                } else {
                    var logicalValue = $('input[name=' + self._addWidgetElementPrefix('logical') +']:checked').val();
                    // default logical is AND
                    var logical = OpenLayers.Filter.Logical.AND;
                    if (logicalValue == 'OR')
                        logical = OpenLayers.Filter.Logical.OR;
                    var OLfilters = [];
                    // build OL filters
                    $.each(filters, function(i, filter) {
                        OLfilters.push(self._buildOLFilter(featureId, filter));
                    });
                    // ..and concatenate them with logical operator
                    var filter = new OpenLayers.Filter.Logical({
                        type: logical,
                        filters: OLfilters
                    });
                }

                if (queryModel.defaultFilters != null) { // add default filters
                    filters = [];
                    $.each(queryModel.defaultFilters, function(e, defaultFilter) {
                        filters.push(defaultFilter);
                    });
                    filters.push(filter);

                    filter = new OpenLayers.Filter.Logical({
                        type: OpenLayers.Filter.Logical.AND,
                        filters: filters
                    });
                }

                if ($('#searchForm_fields input[name="limit_to_extent"]').attr('checked')) {
                    var bboxFilter = new OpenLayers.Filter.Spatial({
                        type: OpenLayers.Filter.Spatial.BBOX,
                        property: 'the_geom',
                        value: gisclient.map.getExtent()
                    });
                    var filter = new OpenLayers.Filter.Logical({
                        type: OpenLayers.Filter.Logical.AND,
                        filters: [filter.clone(), bboxFilter]
                    });

                    self.internalVars.noResultsMsg = 'No results in this area';
                }

                // create the XML filter
                var filter_1_1 = new OpenLayers.Format.Filter({version: "1.1.0"});
                var xml = new OpenLayers.Format.XML();
                var filterValue = xml.write(filter_1_1.write(filter));
                filterValue = filterValue.replace('<ogc:PropertyIsLike wildCard="*" singleChar="." escapeChar="!">', '<ogc:PropertyIsLike wildCard="*" singleChar="." escapeChar="!" matchCase="false">');

                var params = {
                    PROJECT: queryModel.layer.parameters.project,
                    MAP: queryModel.layer.parameters.map,
                    SERVICE: 'WFS',
                    LANG: gisclient.getLanguage(),
                    VERSION: '1.0.0',
                    REQUEST: 'GETFEATURE',
                    SRS: gisclient.getProjection(),
                    TYPENAME: featureId,
                    FILTER: filterValue
                };

                // fill the requests object (to use common functions with selectbybox)
                self.options.requests[featureId] = {
                    url: queryModel.layer.url,
                    params: params,
                    featureId: featureId,
                    fields: queryModel.fields,
                    title: queryModel.title,
                    themeId: queryModel.themeId,
                    layerId: queryModel.layerId,
                    showGeometry: queryModel.showGeometry,
                    count: false,
                    result: false
                };
                // count features (on searchEngine.js)
                self._countFeatures(featureId, queryModel.fields);
            } else {
                gisclient.componentObjects.loadingHandler.hide();
                var string = OpenLayers.i18n('You must specify at least one parameter');
                alert(string);
            }
        },
        // get search type based on the searchType given by settings and eventually the operator chosen by user
        _getSearchType: function(featureId, fieldId) {
            var self = this;
            var gcType = self.options.queryModels[featureId].fields[fieldId].searchType;
            if (gcType == 2)
                return OpenLayers.Filter.Comparison.LIKE;
            if (gcType == 4) {
                var operator = $('#' + self._addWidgetElementPrefix('op_' + fieldId)).val();
                var filter;
                switch (operator) {
                    case 'NOT_EQUAL_TO':
                        filter = OpenLayers.Filter.Comparison.NOT_EQUAL_TO;
                        break;
                    case 'LESS_THAN':
                        filter = OpenLayers.Filter.Comparison.LESS_THAN;
                        break;
                    case 'GREATER_THAN':
                        filter = OpenLayers.Filter.Comparison.GREATER_THAN;
                        break;
                    default:
                        filter = OpenLayers.Filter.Comparison.EQUAL_TO;
                        break;
                }
                return filter;
            }
            return OpenLayers.Filter.Comparison.EQUAL_TO;
        },
        // build the OL comparison filter
        _buildOLFilter: function(featureId, filter) {
            var self = this;

            var type = self._getSearchType(featureId, filter.field);
            if (type == OpenLayers.Filter.Comparison.LIKE)
                filter.value = '*' + filter.value + '*';
            return new OpenLayers.Filter.Comparison({
                type: type,
                property: filter.field,
                value: filter.value
            });
        }

    });

    $.extend($.gcComponent.searchForm, {
        version: "3.0.0"
    });
})(jQuery);
