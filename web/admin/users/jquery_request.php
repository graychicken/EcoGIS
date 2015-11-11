<?php
require_once('../../../etc/config.php');
require_once(R3_LIB_DIR . 'r3auth.php');
require_once(R3_LIB_DIR . 'simplephoto.php');
$auth = new R3Auth($mdb2, $auth_options, APPLICATION_CODE);
if (!$auth->isAuth()) {
    Header("location: logout.php?status=" . $auth->getStatusText());
    die();
}
if (!function_exists('json_encode'))
    require_once(R3_LIB_DIR . 'jsonwrapper/jsonwrapper.php');

define('R3_REQUEST_OK', 0);
define('R3_REQUEST_ERROR', -1);
define('R3_REQUEST_WARNING', -2);

if (isset($_GET['act']) && $_GET['act'] == 'add_signature') {
    if (!$auth->hasPerm('ADD', 'SIGNATURE')) {
        $ret['status'] = R3_REQUEST_ERROR;
        $ret['error'] = 'Permission denied';
        echo json_encode($ret);
        die();
    }
    if ($_FILES['us_signature']['error'] <> 0) {
        $ret['status'] = R3_REQUEST_ERROR;
        $ret['error'] = _('Caricamento fallito: problema sconosciuto.');
        echo json_encode($ret);
        die();
    }
    $validMime = array('image/gif', 'image/jpg', 'image/jpeg', 'image/pjpeg', 'image/png');
    if (!in_array($_FILES['us_signature']['type'], $validMime)) {
        $ret['status'] = R3_REQUEST_ERROR;
        $ret['error'] = _('Caricamento fallito: formato immagine non supportato.');
        $ret['mime'] = $_FILES['us_signature']['type'];
        $ret['validMimes'] = $validMime;
        echo json_encode($ret);
        die();
    }
    
    try {
        switch($_FILES['us_signature']['type']) {
            case 'image/gif':
                $ext = 'gif';
            break;
            case 'image/jpg':
            case 'image/jpeg':
            case 'image/pjpeg':
                $ext = 'jpg';
            break;
            case 'image/png':
                $ext = 'png';
            break;
        }
        
        $resizedFile = R3_TMP_DIR.md5(microtime()).".{$ext}";
        pSimplePhoto::CreateThumb($_FILES['us_signature']['tmp_name'], $resizedFile, 350, 350, true, false);
        
        $file = file_get_contents($resizedFile);
        $mime = $_FILES['us_signature']['type'];
        $data = array($file, $mime);
        
        $sql = "UPDATE auth.users SET " .
               "    us_signature=?, ".
               "    us_signature_mime=? ".
               "WHERE " .
               "    us_id=".$auth->getUID();
        $sth = $mdb2->prepare($sql, array('blob', 'text'));
        $affectedRows = $sth->execute($data);
        
        $ret['status'] = R3_REQUEST_OK;
        $ret['random'] = md5(microtime());
        echo json_encode($ret);
        die();
    } catch(Exception $e) {
        if ($_FILES['us_signature']['error'] <> 0) {
            $ret['status'] = R3_REQUEST_ERROR;
            $ret['error'] = _('Unknown Error.');
            echo json_encode($ret);
            die();
        }
    }
} else if (isset($_GET['act']) && $_GET['act'] == 'show_signature') {
    if (!$auth->hasPerm('ADD', 'SIGNATURE')) {
        $ret['status'] = R3_REQUEST_ERROR;
        $ret['error'] = 'Permission denied';
        echo json_encode($ret);
        die();
    }
    
    $result =& $mdb2->query("SELECT us_signature, us_signature_mime FROM auth.users WHERE us_id=".$auth->getUID(), array('blob'));
    if (PEAR::isError($result) || !$result->valid()) {
        $ret['status'] = R3_REQUEST_ERROR;
        $ret['error'] = _('Unknown Error.');
        echo json_encode($ret);
        die();
    }
    $row = $result->fetchRow();
    
    // fetch the Binary LOB into the $blob_value variable
    $blob = $row[0];
    if (!PEAR::isError($blob) && is_resource($blob)) {
        $blob_value = '';
        while (!feof($blob)) {
            $blob_value.= fread($blob, 8192);
        }
        $mdb2->datatype->destroyLOB($blob);
    } else {
        $ret['status'] = R3_REQUEST_ERROR;
        $ret['error'] = _('Unknown Error.');
        echo json_encode($ret);
        die();
    }
    
    header("Content-Type: ".$row[1]);
    echo $blob_value;
    //free the result
    $result->free();
    die();
} else if (isset($_GET['act']) && $_GET['act'] == 'del_signature') {
    if (!$auth->hasPerm('ADD', 'SIGNATURE')) {
        $ret['status'] = R3_REQUEST_ERROR;
        $ret['error'] = 'Permission denied';
        echo json_encode($ret);
        die();
    }
    
    $sql = "UPDATE auth.users SET " .
           "    us_signature=null, ".
           "    us_signature_mime=null ".
           "WHERE " .
           "    us_id=".$auth->getUID();
    $sth = $mdb2->prepare($sql);
    $affectedRows = $sth->execute();
    
    $ret['status'] = R3_REQUEST_OK;
    echo json_encode($ret);
    die();
}
?>