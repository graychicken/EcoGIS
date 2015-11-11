/*
 Handle HTML Tag required
 required can be: T, TRUE, YES, Y
 */

function getRequiredValuesByTag(tag, DOM_LVL) {
    var ret = new Array();

    if (!DOM_LVL)
        DOM_LVL = false;

    // Get All Elements From Document
    switch (DOM_LVL) {
        case 'top':
            elemArr = top.document.getElementsByTagName(tag);
            break;
        case 'parent':
            elemArr = parent.document.getElementsByTagName(tag);
            break;
        default:
            elemArr = document.getElementsByTagName(tag);
    }

    // Filter Required Elements
    for (i = 0; i < elemArr.length; i++) {
        reqAttr = elemArr[i].getAttribute('required');
        if (typeof reqAttr == 'string')
            reqAttr = reqAttr.toUpperCase();

        // Check If Element is required
        req = false;
        req = (req || (reqAttr == 'T'));
        req = (req || (reqAttr == 'TRUE'));
        req = (req || (reqAttr == 'YES'));
        req = (req || (reqAttr == 'Y'));

        // Assign Element to Result Array
        if (req) {
            reqType = elemArr[i].getAttribute('type');
            if (typeof reqAttr == 'string' && reqType.toUpperCase() == 'CHECKBOX') {
                if (elemArr[i].checked)
                    ret.push(elemArr[i].name + '|' + elemArr[i].value);
                else
                    ret.push(elemArr[i].name + '|');
            } else
                ret.push(elemArr[i].name + '|' + elemArr[i].value);
        }
    }

    return ret;
}

function getValuesByTag(tag, DOM_LVL) {
    var ret = new Array();

    if (!DOM_LVL)
        DOM_LVL = false;

    // Get All Elements From Document
    switch (DOM_LVL) {
        case 'top':
            elemArr = top.document.getElementsByTagName(tag);
            break;
        case 'parent':
            elemArr = parent.document.getElementsByTagName(tag);
            break;
        default:
            elemArr = document.getElementsByTagName(tag);
    }

    // Filter Required Elements
    for (i = 0; i < elemArr.length; i++) {

        reqType = elemArr[i].getAttribute('type');

        if (!elemArr[i].getAttribute('disabled')) {
            if (reqType && reqType.toUpperCase() == 'CHECKBOX') {
                if (elemArr[i].checked)
                    ret.push(elemArr[i].name + '|' + elemArr[i].value);
                else
                    ret.push(elemArr[i].name + '|');
            } else
                ret.push(elemArr[i].name + '|' + elemArr[i].value);
        }
    }

    return ret;
}

function getAllValues(DOM_LVL) {

    elems = new Array();
    elems = elems.concat(getValuesByTag('input', DOM_LVL));
    elems = elems.concat(getValuesByTag('select', DOM_LVL));
    elems = elems.concat(getValuesByTag('textarea', DOM_LVL));
    return elems;
}