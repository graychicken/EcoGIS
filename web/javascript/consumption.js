/**
 * Submit form data
 */
function submitFormDataConsumption(reinsert) {
    $('#popup_reinsert').val(reinsert ? 'T' : 'F');
    submitData('#popup_modform');
}

/**
 * Submit form data
 * param integer id     the meter id
 */
function submitFormDataDoneConsumption(ids, reinsert) {
    reloadTab(undefined, undefined, undefined, {'meter_last_id': '', 'device_last_id': '', 'consumption_last_id': ids[0]});
    ajaxWait(false);
    disableButton(false);
    if (reinsert == 'T') {
        alert('reinsert');
    } else {
        closeR3Dialog();
    }
}

/**
 * Switch the insert type
 */
function insertTypeChange() {
    var types = ['free', 'month', 'year'];
    var currType = $('#popup_insert_type').val();
    $('.year_data').toggle(currType != 'free');  // Show/hide the year selection
    $.each(types, function () {
        $('#kind_' + this).toggle(currType == this);
    });
}

/**
 * Switch the insert year
 */
function insertYearChange() {
    var days = [31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var currType = $('#popup_insert_type').val();
    var currYear = $('#popup_insert_year').val();
    var m, d;

    // Monthly dates
    for (var i = 1; i <= 12; i++) {
        m = (i < 10 ? '0' : '') + i;
        if (i == 2)
            d = ((currYear % 4 == 0) && (currYear % 1000 != 0)) ? 29 : 28;
        else
            d = days[i - 1];
        d = (d < 10 ? '0' : '') + d;
        $('#popup_co_start_date_month_' + i).val('01' + date_separator + m + date_separator + currYear);
        $('#popup_co_end_date_month_' + i).val(d + date_separator + m + date_separator + currYear);
    }

    // Yearly dates
    $('#popup_co_start_date_year').val('01' + date_separator + '01' + date_separator + currYear);
    $('#popup_co_end_date_year').val('31' + date_separator + '12' + date_separator + currYear);
}

function calcEnergyCostValue(qtySelector, priceSelector) {
    var qty = locale2float($(qtySelector).val());
    var price = locale2float($(priceSelector).val());
    if (qty == '' || price == '') {
        return '';
    }
    return float2locale(roundNumber(price / qty, 2));
}

function calcValue() {
    var currType = $('#popup_insert_type').val();
    if (currType == 'month') {
        for (var i = 1; i <= 12; i++) {
            $('#popup_co_energy_costs_month_' + i).val(calcEnergyCostValue('#popup_co_value_month_' + i, '#popup_co_bill_month_' + i));
        }
    } else if (currType == 'year') {
        $('#popup_co_energy_costs_year').val(calcEnergyCostValue('#popup_co_value_year', '#popup_co_bill_year'));
    } else {
        $('#popup_co_energy_costs_free').val(calcEnergyCostValue('#popup_co_value_free', '#popup_co_bill_free'));
    }
}

