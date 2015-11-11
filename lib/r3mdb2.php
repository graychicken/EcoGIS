<?php


if (defined("R3MDB2")) return;
define('R3MDB2', '01a');

require_once 'MDB2.php';

/**
 * database error check
 *
 * Raise an exception or trigger an error if a db error occurs.
 *
 * @param object    MDB2 error object
 * @param integer   Line that generate the error (optional)
 * @param boolean   if false an exception is raised, if true an error is generated. default false
 * @access private
 */
if (!function_exists('checkDBError')) {
    function checkDBError($dbObj, $line=null, $triggerError=false) {

        if (PEAR::isError($dbObj)) {
            $txt = $dbObj->getMessage();
            if ($txt == 'MDB2 Error: unknown error') {
                foreach(explode("\n", $dbObj->getDebugInfo()) as $val) {
                    if (strpos($val, 'Native message') !== false) {
                        $txt = trim(substr($val, 16, -1));
                    }
                }
            }
            if ($line !== null) {
                $txt .= " at line " . $line;
            }

            if ($triggerError) {
                trigger_error($txt);
            } else {
                throw new Exception($txt);
            }
            return true;
        }
        return false;
    }
}

class R3Mdb2Utils {
    static function sanitizeDb($db) {
        if (is_string($db)) {
            require_once 'MDB2.php';
            // $dsn = MDB2::parseDSN($db);
            $db = MDB2::connect($db);
        } else if (is_object($db) && is_subclass_of($db, 'MDB2_Driver_Common')) {
            /* MDB2 driver */
            ;
        } else if (is_array($db) && count(array_diff(array(0, 1, 2, 3, 4), array_keys($db))) == 0) {
            $dsnString = $db[0] . '://' . $db[2] . ':' . $db[3] . '@' . $db[1] . '/' . $db[4];
            $db = MDB2::connect($dsnString);
        } else if (is_array($db) && array_key_exists('phptype', $db)) {
            $db = MDB2::connect($db);
        } else {
            throw new Exception('Invalid database');
        }

        $dsn = MDB2::parseDSN($db->dsn);
        if (!$dsn['database']) {
            // sometimes the database name is not set here, so try to recover
            $dsn['database']=$db->database_name;
        }

        return array($db, $dsn);
    }
}
