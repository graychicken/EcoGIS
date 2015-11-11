<?php  /* UTF-8 FILE: òàèü */
$isUserManager = true;

require_once '../../../etc/config.php';
if (file_exists(R3_APP_ROOT . 'lib/r3_auth_gui_start.php')) {
    require_once R3_APP_ROOT . 'lib/r3_auth_gui_start.php';
}
require_once R3_LIB_DIR . 'r3auth_manager.php';
require_once R3_APP_ROOT . 'lib/default.um.php';
require_once R3_LIB_DIR . 'xajax.php';
require_once R3_LIB_DIR . 'storevar.php';
require_once R3_LIB_DIR . 'config_interpreter.php';
require_once R3_APP_ROOT . 'lang/lang.php';


/** Authentication and permission check */
$auth = R3AuthInstance::get();
if (is_null($auth)) {
    $auth = new R3AuthManager($mdb2, $auth_options, APPLICATION_CODE);
    R3AuthInstance::set($auth);
}

if (!$auth->isAuth()) {
    Header("location: logout.php?status=" . $auth->getStatusText());
	die();
} else if (!$auth->hasPerm('ADD', 'SIGNATURE')) {
    die("PERMISSION DENIED\n");
}

/** Ajax request */
//SS: Prevent proxy problems ?
header('ETag: ' . date('YmdHis') . md5(microtime(true) + rand(0, 65535)));
header('Last-Modified: '.gmdate('D, d M Y H:i:s') . ' GMT'); 
header('Expires: Sat, 26 Jul 1997 05:00:00 GMT'); 
header('Cache-Control: no-store, no-cache, must-revalidate');     // HTTP/1.1 
header('Cache-Control: pre-check=0, post-check=0, max-age=0', false);    // HTTP/1.1 
header('Cache-Control: max-age=0, s-maxage=0, proxy-revalidate', false);
header('Pragma: no-cache'); 



// $url = R3_DOMAIN_URL . $_SERVER['REQUEST_URI'] . (strpos($_SERVER['REQUEST_URI'], '?') === false ? '?' : '&') . 'proxytime=' . md5(time());
// $objAjax = new xajax($url);
// $objAjax->registerExternalFunction('submitForm', 'personal_settings_ajax.php');
// $objAjax->processRequests();
// $smarty->assign('xajax_js_include', $objAjax->getJavascript(R3_JS_URL));

if (file_exists(R3_APP_ROOT . 'lib/custom.um.php')) {
    require_once(R3_APP_ROOT . 'lib/custom.um.php');
    $umDependenciesObj = getUmDependenciesObject();
} else {
    $umDependenciesObj = new R3UmDependenciesDefault();
}
$smarty->assign('umDependencies', $umDependenciesObj->get());

if (!isset($includeSmartyAssign) || $includeSmartyAssign === true) {
    require_once R3_WEB_ADMIN_DIR . 'smarty_assign.php';
}


// TODO: Add this query to library
$sql = "SELECT count(*) FROM auth.users WHERE us_id=".$auth->getUID()." AND us_signature IS NOT NULL ";
$result =& $mdb2->query($sql);
$vlu = $result->fetchRow();
$smarty->assign('showCurrentSignature', (boolean)$vlu[0]);


$smarty->display('users/personal_signature.tpl');
die();



// $data = $auth->getUserData($auth->getDomainName(), $auth->application, $auth->getLogin());

// TODO: Include function for following code (function interpreted extra_fields)

/** User extra field for the common section */
// $extra_fields = $auth->getConfigValue('USER_MANAGER', 'EXTRA_FIELDS', array());

// if (isset($users_extra_fields)) {
    // $extra_fields = array_merge($extra_fields, $users_extra_fields);
// }

// readFieldArray($mdb2, $auth, $extra_fields, $data);
 
// $canChangePassword = $auth->canChangePassword();

// TODO: MULTILANGUAGE
// if ($status <> '' && $status <> '0') {
    // if (isset($txt['auth_error_' . $status])) {
        // $text = $txt['auth_error_' . $status];
    // } else if (isset($auth_err['auth_error_' . $status])) {
        // $text = $auth_err['auth_error_' . $status];
    // } else {
        // $text = $auth->getStatusMessage($status);
    // }
    // $smarty->assign('status', $status);
    // $smarty->assign('statusText', $text);
  // }  
  
// $smarty->assign('canChangePassword', $canChangePassword && ($auth->getConfigValue('USER_MANAGER', 'CHANGE_USER_PASSWORD') != 'F'));
// $smarty->assign('extra_fields', $extra_fields);
// $smarty->assign('vlu', $data);


  
?>