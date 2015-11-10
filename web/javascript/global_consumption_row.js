function openGlobalConsumptionMap(isGisClient) {

    var params = 'layer=paes&' +
            'act=' + $('#act').val() + '&' +
            'geometryStatus=' + $('#geometryStatus').val() + '&' +
            'zoom_type=zoomextent&';
    if ($('#popup_gs_id').val() > 0 && $('#has_geometry').val()) {
        params += 'mapoper_zoom=paes&' +
                'mapoper_id=' + $('#popup_gs_id').val() + '&';
    } else {
        // Mixed zoom oper look for zoom on street, fraction, municipality
        params += 'mapoper_zoom=mixed&';
        if ($('#mu_id').val() > 0) {
            params += 'mu_id=' + $('#mu_id').val() + '&';
        }
        if ($('#fr_id').val() > 0) {
            params += 'fr_id=' + $('#fr_id').val() + '&';
        }
        if ($('#st_id').val() > 0) {
            params += 'st_id=' + $('#st_id').val() + '&';
        }
        params += 'mapoper_id=&';
    }
    params += 'ecogis_digitize=T&';

    if (isGisClient) {
        var url = gisClientURL;
        url = url + (url.indexOf('?') < 0 ? '?' : '&') + params;
        openGisClient(url);
    } else {
        GenericOpenMap('edit_layer&' + params);
    }
}