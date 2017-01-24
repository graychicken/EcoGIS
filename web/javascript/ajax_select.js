/**
 * Ajax Select
 *
 * JavaScript
 *
 * @category  Control Fields
 * @package   js.ajax-utils
 * @author    R3 GIS <info@r3-gis.com>
 * @copyright 2007 R3 GIS s.r.l.
 * @license   Commercial http://www.r3-gis.com
 * @version   1.0.1
 * @link      http://www.r3-gis.com
 */

// 26/07/2007: For function startLoading added parameter extraParam
// 18/09/2007: - New Function restore which fills target object with initial options
// 11/10/2007: - In funzion startLoading the parentID can be a text
// 28/01/2008: Critical Bug Fix: Restore was only for text values and not for option values.
// 11/03/2008: [1.0.1] Add new feature: set ajax function-name, default will be called xajax_load_select (for backward compatibility)

/**
 * Global Vars
 */
 
 var AjaxSelectObj = null;
 
 if (!AjaxS_LoadingLabel) var AjaxS_LoadingLabel = 'Loading';
 if (!AjaxS_LoadingTime)  var AjaxS_LoadingTime  = 500;

/**
 * AjaxSelect constructor
 */
function AjaxSelect(targetID, callfunc) {

  // Register Target
  this.targetID = targetID;
  
  // - set XAjax Function name (since 1.0.1)
  this.callfunc = '';
  if (callfunc)
    this.callfunc = callfunc;
  
  // Init Vars
  this.isLoading = false;
  
  // Register Object for him self and return reference
  AjaxSelectObj = this;
  
  return this;
}

/**
 * Set XAjax Function Name
 * @since 1.0.1
 *
 * @param string function name
 */
AjaxSelect.prototype.setXAjaxFunctionName = function(callfunc) {
  this.callfunc = callfunc;
}

/**
 * Register Target Element
 */
AjaxSelect.prototype.registerTargetElem = function() {
  AjaxSelectObj = this;
  
  if (this.targetElem) return false;
  
  // Set Target Element
  this.targetElem = document.getElementById(this.targetID);
  
  // Set Init Value
  this.targetInitValues = new Array();
  this.targetInitText = new Array();
  for(var i=0;i<this.targetElem.options.length;i++) {
    this.targetInitValues.push(this.targetElem.options[i].value);
    this.targetInitText.push(this.targetElem.options[i].text);
  }
  
  if (!this.targetElem)
    alert('Error: Target Element is not defined');
}

/**
 * Remove All Options from Target Elem
 */
AjaxSelect.prototype.removeOptions = function() {
  // Remove Option Groups
  var elems = this.targetElem.getElementsByTagName("optgroup");
  while(elems.length > 0)
    this.targetElem.removeChild(elems[0]);
  
  // Remove Current Options
  while(this.targetElem.length > 0) {
      this.targetElem.options[0] = null;
  }
  return null;
}

/**
 * Pre Loading Function
 */
AjaxSelect.prototype.preLoading = function() {
  if (!this.isLoading) return false;
  
  // Remove Current Options
  this.removeOptions();
  
  var tmpArr = AjaxS_LoadingLabel.split(' ');
  if (tmpArr.length > 1) {
    if (tmpArr[1].length == 1)      AjaxS_LoadingLabel = tmpArr[0] + ' ..';
    else if (tmpArr[1].length == 2) AjaxS_LoadingLabel = tmpArr[0] + ' ...';
    else if (tmpArr[1].length == 3) AjaxS_LoadingLabel = tmpArr[0] + ' .';
  } else {
    AjaxS_LoadingLabel = AjaxS_LoadingLabel + ' .';
  }
  
  // Add Loading Text
  this.targetElem.disabled = true;
  this.targetElem.options[this.targetElem.length] = new Option(AjaxS_LoadingLabel, '', false, true);
  
  setTimeout("AjaxSelectObj.preLoading()", AjaxS_LoadingTime);
  
  return false;
}

/**
 * Start Loading (XAjax Function xajax_load_select is required)
 * @since 1.0.1
 *
 * @return boolean false if reset target element
 */
AjaxSelect.prototype.startRequest = function() {
  this.registerTargetElem();
  
  this.isLoading = true;
  this.preLoading();
  
  var argArray = new Array();
  for(var i=0; i<arguments.length; i++)
    argArray.push(arguments[i]);
  
  // Reset Target Elem to Init Status
//  if (parentID && parentID.length == 0) {
//    this.restore();
//    this.targetElem.disabled = true;
//    return false;
//  }
  
  if (xajax && this.callfunc) {
    xajax.call(this.callfunc, argArray);
  } else if (!xajax) {
    alert('AjaxSelect Error: "xajax" - Object does not exist');
  } else if (!this.callfunc) {
    alert('AjaxSelect Error: Function "'+this.callfunc+'" does not exist');
  }
}

/**
 * Start Loading (XAjax Function xajax_load_select is required)
 * @deprecated since 1.0.1 (use startRequest)
 */
AjaxSelect.prototype.startLoading = function(type, parentID, selID, extraParam) {
  this.registerTargetElem();
  
  this.isLoading = true;
  this.preLoading();
  
  // Reset Target Elem to Init Status
  if (parentID && parentID.length == 0) {
    this.restore();
//    this.isLoading = false;
//    this.removeOptions();
    
//    for(var i=0;i<this.targetInitValues.length;i++) {
//      this.addOption('', this.targetInitValues[i]);
//    }
    
    this.targetElem.disabled = true;
    
    return false;
  }
  
  if (!parentID)   parentID = '';
  if (!selID)      selID = '';
  if (!extraParam) extraParam = '';
  
  if (xajax_load_select) {
    xajax_load_select(type, parentID, selID, extraParam);
  } else {
    alert('Error: Function "xajax_load_select" is not defined!');
  }
}

/**
 * Stop Loading
 */
AjaxSelect.prototype.stopLoading = function() {
  
  this.isLoading = false;
  
  this.targetElem.disabled   = false;
  this.targetElem.options[0] = null;
  
  return false;
}

/**
 * Add Option
 */
AjaxSelect.prototype.addOption = function(value, text, title, style, groupId, groupLabel) {
  var target = this.targetElem;
  // OPTGROUP HANDLING
  if (groupId) {
    if (!document.getElementById(groupId)) {
      var optgroup = document.createElement("optgroup");
      optgroup.id = groupId;
      optgroup.label = (groupLabel ? groupLabel : groupId);
      this.targetElem.appendChild(optgroup);
    }
    target = document.getElementById(groupId);
  }
  
  var objOption = document.createElement("option");
  objOption.innerHTML = text;
  objOption.value = value;
  if (title)
    objOption.setAttribute('title', title);
  if (style) {
    objOption.style.setAttribute('cssText', style, 0);  // IE
    objOption.style = style;                            // Firefox
  }
  target.appendChild(objOption);
  return false;
}

/**
 * Select Options
 */
AjaxSelect.prototype.selOption = function(value) {
  var idx = 0;
  
  // Get Index
  for(var i=0; i<this.targetElem.length; i++) {
    if (this.targetElem.options[i].value == value) {
      idx = i;
      break;
    }
  }
  
  // Set Index
  this.targetElem.selectedIndex = idx;
  
  return false;
}

/**
 * Restore all options
 */
AjaxSelect.prototype.restore = function() {
  
  this.isLoading = false;
  this.removeOptions();
  
  for(var i=0;i<this.targetInitValues.length;i++) {
    this.addOption(this.targetInitValues[i], this.targetInitText[i]);
  }
  
  return false;
}

/**
 * Disable Input
 */
AjaxSelect.prototype.disableInput = function() {
  this.targetElem.disabled = true;
  
  return false;
}