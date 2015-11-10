<?php

if (defined("__R3_AUTH__"))
    return;
define("__R3_AUTH__", 1);

/**
 * Library version
 */
define('R3AUTH_VERSION', '1.3');

/**
 * Returned if session exceeds idle time
 */
//define('AUTH_IDLED',                    -1);

/**
 * Returned if authentication is OK
 */
define('AUTH_OK', 0);

/**
 * Returned if session has expired
 */
//define('AUTH_EXPIRED',                  -2);
/**
 * Returned if container is unable to authenticate user/password pair
 */
//define('AUTH_WRONG_LOGIN',              -3);
/**
 * Returned if a container method is not supported.
 */
//define('AUTH_METHOD_NOT_SUPPORTED',     -4);
/**
 * Returned if new Advanced security system detects a breach
 */
//define('AUTH_SECURITY_BREACH',          -5);
/**
 * Returned if checkAuthCallback says session should not continue.
 */
//define('AUTH_CALLBACK_ABORT',           -6);


/**
 * Returned if the user is not logged id. Can be returned on cookie or session problems
 */
define('AUTH_NOT_LOGGED_IN', -9);

/**
 * Returned if the account is disabled
 */
define('AUTH_ACCOUNT_DISABLED', -11);

/**
 * Returned if the account start date is in the future
 */
define('AUTH_ACCOUNT_NOT_STARTED', -12);

/**
 * Returned if the account is expired
 */
define('AUTH_ACCOUNT_EXPIRED', -13);

/**
 * Returned if the user IP is allow to connect
 */
define('AUTH_INVALID_IP', -14);

/**
 * Returned if password is expired. Password update is needed.
 * <b>NOTE:</b> performLogin return true to permit the chenge of the password
 */
define('AUTH_PASSWORD_EXPIRED', -15);

/**
 * Returned if the user was disconnected by the administraror
 */
define('AUTH_USER_DISCONNECTED', -16);

/**
 * Returned if the password will expire in few days. Constant has a positiva value => authentication OK
 */
define('AUTH_PASSWORD_IN_EXPIRATION', 11);

/**
 * Returned if the password is to change at first login. Constant has a positiva value => authentication OK
 */
define('AUTH_PASSWORD_REPLACE', 12);

/**
 * Returned if the authentication data is not valid
 */
define('AUTH_INVALID_AUTH_DATA', 13);  // positivo (?)


/**
 * Super user UID
 */
define('SUPERUSER_UID', 0);

class R3AuthInstance {

    static protected $instance;

    static function set(IR3Auth $auth) {
        return self::$instance = $auth;
    }

    static function get() {
        return self::$instance;
    }

}

require_once 'Auth.php';
require_once 'Log.php';
require_once 'Log/observer.php';

// Definizione eccezioni
class EPermissionDenied extends Exception {
    
}

class EDatabaseError extends Exception {

    private $params;

    public function __construct($message, $code = 0, array $params = array()) {

        parent::__construct($message, $code);
        $this->params = $params;
    }

    final function getParams() {   // Field of the exception
        return $this->params;
    }

}

interface IR3Auth {

    function getUID();

    function isAuth();

    function getDomainID();
}

// Estendo classe di partenza
class R3Auth extends Auth implements IR3Auth {

    /**
     * All the user permisisons (User + groups) cached
     *
     * @var  array
     * @access private
     */
    public $cachePerm = null; // permessi attivi dell'utente (somma gruppo, utente)

    /**
     * Additional options for the storage container
     *
     * @var  array
     * @access protected
     */
    protected $options = array();

    /**
     * Current domain ID
     *
     * @var  integer
     * @access protected
     */
    protected $domainID = null;

    /**
     * Current application ID
     *
     * @var  integer
     * @access protected
     */
    protected $applicationID = null;

    /**
     * Current application code
     *
     * @var  string
     * @access private
     */
    protected $applicationCode = null;

    /**
     * Current user ID
     *
     * @var  integer
     * @access protected
     */
    protected $UID = null;

    /**
     * MDB2 object
     *
     * @var  object
     * @access protected
     */
    protected $db = null;

    /**
     * Don't update the user status
     *
     * @var  boolean
     * @access protected
     * @see updateStatus
     */
    protected $skipUpdateStatus = false;

    /**
     * R3DBIni object
     *
     * @var  object
     * @access protected
     */
    protected $dbini = null;

    /**
     * User information (database record)
     *
     * @var  array
     * @access protected
     */
    private $userInfo = array();

    /**
     * If true the class is destroing itself. This variabled is used to raise an exception (not destroing) or
     * triggen an error (destroing). In PHP it's not possible to raise an exception on destroy.
     *
     * @var  boolean
     * @access protected
     */
    private $isDestroying = false;

    /**
     * If true the isAuth function will ignore expired password
     *
     * @var  boolean
     * @access public
     */
    public $ignoreExpiredPassword = false;
    public $passwordStatus = null;
    protected $domain = null;
    protected $login = null;
    protected $lastAction = null;

    /**
     * Location where to store session parameters for user
     *
     * @var  array
     * @access protected
     */
    protected $sessionParameters = array();

    /**
     * Constructor
     *
     * Set up the storage driver.
     *
     * @param mixed     database dsn
     * @return void
     */
    function __construct($dsn, $options = array(), $application = null, $logger = null) {
        $defOpt = array('settings_table' => 'auth.settings',
            // 'auth_settings_table' => 'auth.auth_settings',
            'applications_table' => 'auth.applications',
            'users_groups_table' => 'auth.users_groups',
            'users_table' => 'auth.users',
            'domains_table' => 'auth.domains',
            'groups_table' => 'auth.groups',
            'groups_acl_table' => 'auth.groups_acl',
            'users_acl_table' => 'auth.users_acl',
            'users_ip_table' => 'auth.users_ip',
            'domains_applications_table' => 'auth.domains_applications',
            'log_table' => 'auth.logs',
            'domains_name_table' => 'auth.domains_name',
            'acnames_table' => 'auth.acnames',
            'table' => 'auth.users',
            'usernamecol' => 'us_login',
            'passwordcol' => 'us_password',
            'cryptType' => 'md5',
            'auto_quote' => false,
            'db_where' => '1=1',
            'enable_logging' => true,
            'log_path' => null,
        );


        $options = array_merge($defOpt, $options);
        parent::__construct('', $options, null, false);

        $this->options['dsn'] = $dsn;
        $this->options['options'] = $options;
        $this->application = $application;

        $this->options['options']['expirationTime'] = 0;
        $this->options['options']['idleTime'] = 0;

        //@TODO: tirare fuori info utente
        if ($logger !== null) {
            $this->attachLogObserver($logger);
        }

        $this->post['authsecret'] = false;
        $this->isLoggedIn = false;
        $this->skipUpdateStatus = false;
        $this->allowMultipleApplications = false;

        // if true all the hasPerm will return true
        $this->userIsSuperuser = false;
    }

    function __destruct() {

        $this->log(__METHOD__ . "[" . __LINE__ . "]:----", AUTH_LOG_DEBUG);
    }

    protected function checkDBError($dbObj, $line = null, array $params = array()) {

        if (PEAR::isError($dbObj)) {
            $txt = $dbObj->getMessage();
            if ($line !== null) {
                $txt .= " at line " . $line;
            }
            if ($this->isDestroying) {
                trigger_error($txt);
            } else {
                throw new EDatabaseError($txt, 0, $params);
            }
        }
    }

    /**
     * Get the module version
     *
     * @param array           name ot the class to get the version
     * @return string|null    return the version text or null if faild
     * @access public
     */
    public function getVersionString($className = null) {

        if ($className == '' || $className == 'R3Auth') {
            return R3AUTH_VERSION;
        } else if ($className == 'R3DBIni') {
            $this->loadconfig();
            return $this->dbini->getVersionString();
        } else if ($className == 'PEAR::Auth') {
            return $this->version;
        } else if ($className == 'PEAR::MDB2') {
            return '?';
        }
        return null;
    }

    public function getUID() {

        return $this->UID;
    }

    /**
     * Return the groups of the current user
     */
    public function getGroupNames() {
        static $groups = null;/** cache the statement */
        if ($groups === null) {
            $sql = "SELECT \n" .
                    "  " . $this->options['options']['groups_table'] . ".gr_id, gr_name " .
                    "FROM " . $this->options['options']['groups_table'] . " " .
                    "INNER JOIN " . $this->options['options']['users_groups_table'] . " ON " .
                    "  " . $this->options['options']['groups_table'] . ".gr_id=" . $this->options['options']['users_groups_table'] . ".gr_id " .
                    "WHERE us_id=" . $this->UID;

            $res = & $this->db->query($sql);
            $this->checkDBError($res, __LINE__);
            $groups = array();
            while ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
                $groups[$row['gr_id']] = $row['gr_name'];
            }
        }
        return $groups;
    }

    public function getLogin() {

        return $this->login;
    }

    public function getDomainName() {

        return $this->domain;
    }

    public function getApplicationCode() {

        return $this->applicationCode;
    }

    /**
     * Returns the Domain ID
     * @since 0.2b
     *
     * @return integer
     */
    public function getDomainID() {

        return $this->domainID;
    }

    /**
     * Returns the IP Address
     * @since 1.2
     *
     * @return string
     */
    private function getIPAddress() {
        if (isset($_SERVER['REMOTE_ADDR'])) {
            return $_SERVER['REMOTE_ADDR'];
        } else {
            //gethostname() not works in command line!
            return gethostbyname(php_uname('n'));
        }
    }

    /**
     * Connect to database by using the given DSN string, to get the authentication method
     *
     * @access protected
     * @param  string DSN string
     * @return mixed  Object on error, otherwise bool
     */
    protected function dbConnect() {
        $this->log(__METHOD__ . "[" . __LINE__ . "]: called.", AUTH_LOG_DEBUG);

        $dsn = $this->options['dsn'];
        if (is_string($dsn) || is_array($dsn)) {
            $this->db = & MDB2::connect($dsn, $this->options['options']);
            $this->log(__METHOD__ . "[" . __LINE__ . "]: new connection established.", AUTH_LOG_DEBUG);
        } elseif (is_subclass_of($dsn, 'MDB2_Driver_Common')) {
            $this->db = $dsn;  /* DSN is ad db object */
            $this->log(__METHOD__ . "[" . __LINE__ . "]: current connection used.", AUTH_LOG_DEBUG);
        } elseif (is_object($dsn) && MDB2::isError($dsn)) {
            return PEAR::raiseError($dsn->getMessage(), $dsn->code);
        } else {
            return PEAR::raiseError('The given dsn was not valid in file ' . __FILE__ . ' at line ' . __LINE__, 41, PEAR_ERROR_RETURN, null, null
            );
        }

        if (MDB2::isError($this->db) || PEAR::isError($this->db)) {
            return PEAR::raiseError($this->db->getMessage(), $this->db->code);
        }

        $this->db->loadModule('Extended');

        if ($this->options['dsn']->phptype == 'oci8') {
            /* Change oracle date format */
            $this->db->exec('ALTER SESSION SET nls_date_format="yyyy-mm-dd"');
            $this->db->exec('ALTER SESSION SET nls_timestamp_format="yyyy-mm-dd hh24:mi:ss"');
            $this->db->exec('ALTER SESSION SET nls_numeric_characters=". "');
        }
        return true;
    }

    public function allowMultipleApplications($allowMultipleApplications) {

        $this->allowMultipleApplications = $allowMultipleApplications;
    }

    private function stringToOptions($text) {

        $result = array();
        $a = explode("\n", $text);
        foreach ($a as $value) {
            if ($value == '' || $value[0] == ';' || $value[0] == '#')
                continue;
            if (($p = strpos($value, '=')) === null)
                $result[trim($value)] = null;
            else
                $result[trim(substr($value, 0, $p))] = trim(substr($value, $p + 1));
        }
        return $result;
    }

    /**
     * Assign data from login form to internal values
     *
     * This function takes the values for username and password
     * from $HTTP_POST_VARS/$_POST and assigns them to internal variables.
     * If you wish to use another source apart from $HTTP_POST_VARS/$_POST,
     * you have to derive this function.
     *
     * @global $HTTP_POST_VARS, $_POST
     * @see    Auth
     * @return void
     * @access private
     */
    function assignData() {
        $this->log(__METHOD__ . "[" . __LINE__ . "]: called.", AUTH_LOG_DEBUG);
        $this->post[$this->_postUsername] = $this->username;
        $this->post[$this->_postPassword] = $this->password;
    }

    /**
     * Return true if the given IP address is included in the given IP/MASK
     *
     * @param string    IP address to check
     * @param string    IP or IP/MASK (default mask 255.255.255.255)
     * @return boolean  Return true if the IP address is valid
     * @access private
     */
    private function isValidIP($ip, $validIP, $validMask) {

        if ($ValidMask == '') {
            $ValidMask = '255.255.255.255';
        }
        return (ip2long($ip) & ip2long($validMask)) == (ip2long($validIP) & ip2long($validMask));
    }

    /**
     * try to login an user
     *
     * On success the user session data is stored to mantain the authentication valid
     *
     * @param string    user login (mandatory)
     * @param string    user password
     * @param string    domain (optional)
     * @return boolean  Return true if successfully logged in
     * @access public
     */
    public function performLogin($login, $password, $domain = null) {
        if (isset($this->session['login']) && $this->session['login'] !== trim($login)) {
            $this->log(__METHOD__ . "[" . __LINE__ . "]: isAuth TRUE but ({$this->session['login']} is different from {$login}).", AUTH_LOG_DEBUG);
            $this->status = AUTH_WRONG_LOGIN;
            return false;
        }
        $this->log(__METHOD__ . "[" . __LINE__ . "]:({$login}, ***, {$domain}) called.", AUTH_LOG_DEBUG);

        $res = $this->dbConnect();
        if (PEAR::isError($res)) {
            throw new Exception($res->getMessage());
        }

        if (!$this->skipUpdateStatus) {
            if (isset($this->options['options']['log_table']) &&
                    isset($this->options['options']['enable_logging'])) {
                $this->log(__METHOD__ . "[" . __LINE__ . "]: Clearing old logs entry", AUTH_LOG_DEBUG);
                if (isset($this->options['options']['access_log_lifetime']) &&
                        $this->options['options']['access_log_lifetime'] > 0) {
                    $this->db->extended->autoExecute($this->options['options']['log_table'], null, MDB2_AUTOQUERY_DELETE, "log_auth_type='N' AND log_time<'" . date('Y-m-d H:i:s', time() - $this->options['options']['access_log_lifetime']) . "'");
                }
                if (isset($this->options['options']['login_log_lifetime']) &&
                        $this->options['options']['login_log_lifetime'] > 0) {
                    $this->db->extended->autoExecute($this->options['options']['log_table'], null, MDB2_AUTOQUERY_DELETE, "(log_auth_type IN ('I', 'O', 'X') AND log_auth_type<>'U' AND log_time<'" . date('Y-m-d H:i:s', time() - $this->options['options']['login_log_lifetime']) . "'");
                }
            }
        }

        $this->username = $this->login = trim($login);
        $this->password = trim($password);
        $this->domain = trim($domain);
        $this->lastAction = null;  //Needed for disconnect

        $sql = "
SELECT us.*, d.do_auth_type, d.do_auth_data, dn.dn_type, app.app_id, app.app_code, app.app_name
FROM {$this->options['options']['users_table']} us
LEFT JOIN {$this->options['options']['domains_table']} d ON us.do_id=d.do_id
LEFT JOIN {$this->options['options']['domains_name_table']} dn ON d.do_id=dn.do_id
LEFT JOIN {$this->options['options']['domains_applications_table']} da ON d.do_id=da.do_id
LEFT JOIN {$this->options['options']['applications_table']} app ON da.app_id=app.app_id
WHERE UPPER(us.us_login)=UPPER(" . $this->db->quote($this->username) . ") AND dn.dn_name=" . $this->db->quote($this->domain) . " AND us_status<>'X' ";
        if (!$this->allowMultipleApplications) {
            $sql .= "  AND app_code=" . $this->db->quote($this->application) . " \n ";
        }
        $res = & $this->db->query($sql);
        $this->checkDBError($res, __LINE__);

        $this->log(__METHOD__ . "[" . __LINE__ . "]: executing: {$sql}", AUTH_LOG_DEBUG);

        $i = 0;
        $userInfo = array();
        while ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
            $userRow = $row;

            // Replace login insert by user with database login (needed by pear)
            $this->username = $this->login = trim($row['us_login']);

            $this->userIsSuperuser = isset($userRow['us_is_superuser']) && strtoupper($userRow['us_is_superuser']) == 'T';
            $i++;
            foreach ($row as $key => $value) {
                if ($key == 'us_id') {
                    $UID = $value;
                } else if ($key == 'us_login') {
                    $Login = $value;
                } else if ($key == 'do_auth_type') {
                    $do_auth_type = $value;
                } else if ($key == 'do_auth_data') {
                    $do_auth_data = $value;
                }
                $userInfo[$key] = $value;
            }
            if ($row['dn_type'] != 'N') {
                /** get the real domain name */
                $sql2 = "SELECT dn_name FROM {$this->options['options']['domains_name_table']} WHERE do_id={$row['do_id']} AND dn_type='N'";
                $res2 = & $this->db->query($sql2);
                $this->checkDBError($res2, __LINE__);
                $row2 = $res2->fetchRow(MDB2_FETCHMODE_ASSOC);
                $this->domain = $row2['dn_name'];
            }

            $this->UID = $row['us_id'];
            $this->applicationID = $row['app_id'];
            $this->applicationCode = $row['app_code'];

            $this->domainID = $row['do_id'];
            $this->auth_type = $do_auth_type;
            $this->auth_data = $do_auth_data;
            $this->lastAction = $row['us_last_action'];
        }
        $res->free();
        if ($i == 0) {
            $this->log(__METHOD__ . "[" . __LINE__ . "]: No user found.", AUTH_LOG_INFO);
            $sql = "SELECT d.do_id 
                    FROM {$this->options['options']['domains_table']} d
                    INNER JOIN {$this->options['options']['domains_name_table']} dn ON d.do_id=dn.do_id
                    WHERE dn_name=" . $this->db->quote($domain);
            $this->domainID = & $this->db->queryOne($sql);
            $this->checkDBError($res, __LINE__);

            $sql = "SELECT app_id 
                    FROM {$this->options['options']['applications_table']}
                    WHERE app_code=" . $this->db->quote($this->application);
            $this->applicationID = & $this->db->queryOne($sql);
            $this->checkDBError($this->applicationID, __LINE__);

            if (isset($this->options['options']['login_log_lifetime']) &&
                    $this->options['options']['login_log_lifetime'] <> 0) {
                $this->internalDBLog(LOG_ERR, 'I', 'User "' . $this->username . '" not found');
            }

            $this->status = AUTH_WRONG_LOGIN;
            $this->doLogout();
            return false;
        }

        if (!$this->allowMultipleApplications && $i > 1) {
            // too much user. Shound be never here!
            $this->log(__METHOD__ . "[" . __LINE__ . "]: Too much users.", AUTH_LOG_ERR);
            if (isset($this->options['options']['login_log_lifetime']) &&
                    $this->options['options']['login_log_lifetime'] <> 0) {
                $this->internalDBLog(LOG_ERR, 'I', 'Too much users');
            }
            throw new Exception('Too much users');
        }

        if (!in_array($do_auth_type, array('DB', 'POP3', 'IMAP', 'LDAP'))) {
            throw new Exception("Invalid auth_type ({$do_auth_type})");
        }
        $this->userInfo = $userInfo;

        if (isset($this->options['options']['auth_settings_table'])) {
            // LDAP authentication
            $sql = "
SELECT as_type, as_data, as_change_password
FROM {$this->options['options']['users_table']}
INNER JOIN {$this->options['options']['domains_name_table']} USING (do_id)
INNER JOIN {$this->options['options']['auth_settings_table']} USING (as_id)
WHERE UPPER(us_login)=UPPER(" . $this->db->quote($this->login) . ") AND dn_name=" . $this->db->quote($this->domain);
            $this->log(__METHOD__ . "[" . __LINE__ . "]: executing: {$sql}", AUTH_LOG_DEBUG);
            $res = & $this->db->query($sql);
            $this->checkDBError($res, __LINE__);
            while ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
                $do_auth_type = $row['as_type'];
                $do_auth_data = $row['as_data'];
                $this->ignoreExpiredPassword = true;
            }
        }

        $this->log(__METHOD__ . "[" . __LINE__ . "]: User $this->username found.", AUTH_LOG_INFO);
        $options = $this->stringToOptions($do_auth_data);

        $this->log(__METHOD__ . "[" . __LINE__ . "]: Authentication method: $do_auth_type.", AUTH_LOG_DEBUG);

        if ($do_auth_type == 'DB') {
            $do_auth_type = 'MDB2';
            if (isset($options['dsn'])) {
                $this->log(__METHOD__ . "[" . __LINE__ . "]: new dsn: " . $options['dsn'], AUTH_LOG_DEBUG);
            } else {
                $options['dsn'] = $this->options['dsn'];
                if (!isset($this->options['table'])) {
                    $options['table'] = $this->options['options']['users_table'];
                }
                if (!isset($this->options['usernamecol']))
                    $options['usernamecol'] = 'us_login';
                if (!isset($this->options['passwordcol']))
                    $options['passwordcol'] = 'us_password';
                if (!isset($this->options['db_fields']) && isset($this->options['db_fields']))
                    $options['db_fields'] = $this->options['db_fields'];
                if (isset($this->options['options']['cryptType'])) {
                    $options['cryptType'] = $this->options['options']['cryptType'];
                } else {
                    $options['cryptType'] = 'md5';
                }
                if (!isset($this->options['auto_quote']) && isset($this->options['auto_quote'])) {
                    $options['auto_quote'] = $this->options['auto_quote'];
                } else {
                    $options['auto_quote'] = false;
                }
                $options['db_where'] = "do_id={$userInfo['do_id']} AND us_status<>'X'";

                $this->log(__METHOD__ . "[" . __LINE__ . "]: Using table {$options['table']} ({$options['usernamecol']}, {$options['passwordcol']})", AUTH_LOG_DEBUG);
            }
        } else if ($do_auth_type == 'POP3' || $do_auth_type == 'IMAP') {
            if ($options['username'] != '')
                $this->username = str_replace('<username>', $this->username, $options['username']);
            if ($options['password'] != '')
                $this->password = str_replace('<password>', $this->password, $options['password']);
        }

        $this->session['_storage_driver'] = $do_auth_type;
        $this->session['_storage_options'] = $options;

        if ($this->options['options']['idleTime'] > 0) {
            $this->setIdle($this->options['options']['idleTime']);
        }
        if ($this->_isAuth()) {
            $this->setAllowLogin(false);

            if ($this->options['options']['expirationTime'] == '')
                $this->options['options']['expirationTime'] == 0;

            if ($this->options['options']['expirationTime'] >= 0) {
                $this->session['login'] = $this->login;
                $this->session['password'] = $this->password;
                $this->session['domain'] = $this->domain;

                $this->session['last_UID'] = $this->UID;
                $this->session['last_applicationID'] = $this->applicationID;
                $this->session['last_applicationCode'] = $this->applicationCode;
            }

            $this->status = AUTH_OK;
            $ipAddr = array();
            if ($this->isSuperuser()) {
                $userRow['us_status'] = 'E';
                $userRow['us_start_date'] = '';
                $userRow['us_expire_date'] = '';
                $userRow['us_pw_expire'] = '180';
                $userRow['us_pw_expire_alert'] = '60';
            } else {
                /** Get the valid IP addresses */
                $sql = "SELECT \n" .
                        "  ip_addr, ip_mask, ip_kind \n" .
                        "FROM \n" .
                        "  " . $this->options['options']['users_ip_table'] . " \n" .
                        "WHERE " .
                        "  (app_id IS NULL OR app_id=$this->applicationID) AND \n" .
                        "  (us_id IS NULL OR us_id=$this->UID) \n" .
                        "ORDER BY \n" .
                        "  ip_order";
                $res = & $this->db->query($sql);
                $this->checkDBError($res, __LINE__);
                while ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
                    $ipAddr[] = $row;
                }
                $res->free();
            }

            /** Check for account status */
            if ($userRow['us_status'] != 'E') {
                if (isset($this->options['options']['login_log_lifetime']) &&
                        $this->options['options']['login_log_lifetime'] <> 0) {
                    $this->internalDBLog(LOG_ERR, 'I', 'Account disabled');
                }
                $this->status = AUTH_ACCOUNT_DISABLED;
                $this->log(__METHOD__ . "[" . __LINE__ . "]: User {$this->username} disabled.", AUTH_LOG_INFO);
                $this->doLogout();
                return false;
            }

            /** Check for account start date */
            if ($userRow['us_start_date'] != '' && $userRow['us_start_date'] > date('Y-m-d')) {
                if (isset($this->options['options']['login_log_lifetime']) &&
                        $this->options['options']['login_log_lifetime'] <> 0) {
                    $this->internalDBLog(LOG_ERR, 'I', 'Account not started');
                }
                $this->status = AUTH_ACCOUNT_NOT_STARTED;
                $this->log(__METHOD__ . "[" . __LINE__ . "]: The account of the user {$this->username} is not started.", AUTH_LOG_INFO);
                $this->doLogout();
                return false;
            }

            /** Check for account expiration date */
            if ($userRow['us_expire_date'] != '' && $userRow['us_expire_date'] < date('Y-m-d')) {
                if (isset($this->options['options']['login_log_lifetime']) &&
                        $this->options['options']['login_log_lifetime'] <> 0) {
                    $this->internalDBLog(LOG_ERR, 'I', 'Account expired');
                }
                $this->status = AUTH_ACCOUNT_EXPIRED;
                $this->log(__METHOD__ . "[" . __LINE__ . "]: The account of the user {$this->username} is expired.", AUTH_LOG_INFO);
                $this->doLogout();
                return false;
            }

            /** Check for valid IP address */
            if (count($ipAddr) > 0) {
                $allow = false;
                foreach ($ipAddr as $ip_mask) {
                    if ($this->IsValidIP($this->getIPAddress(), $ip_mask['ip_addr'], $ip_mask['ip_mask'])) {
                        $allow = ($ip_mask['ip_kind'] == 'A');
                    }
                }
                if (!$allow) {
                    if (isset($this->options['options']['login_log_lifetime']) &&
                            $this->options['options']['login_log_lifetime'] <> 0) {
                        $this->internalDBLog(LOG_ERR, 'I', 'Unauthorized IP address'); /* The IP is in the log data */
                    }
                    $this->status = AUTH_INVALID_IP;
                    $this->log(__METHOD__ . "[" . __LINE__ . "]: Invalid IP address [" . $this->getIPAddress() . "] for user $this->username.", AUTH_LOG_INFO);
                    $this->doLogout();
                    return false;
                }
            }

            /** Check for password expiration date */
            $this->passwordStatus = 0;
            if ($userRow['us_pw_last_change'] != '' && $userRow['us_pw_expire'] != '') {
                $last_pw_change = mktime(0, 0, 0, substr($userRow['us_pw_last_change'], 5, 2), substr($userRow['us_pw_last_change'], 8, 2), substr($userRow['us_pw_last_change'], 0, 4), -1);
                $last_pw_change_days = ceil((time() - $last_pw_change) / (24 * 60 * 60)) - 1;
                $dd = $userRow['us_pw_expire'] - $last_pw_change_days;
                $this->log(__METHOD__ . "[" . __LINE__ . "]: DD-Value = {$dd}", AUTH_LOG_INFO);
                if ($dd < 0) {
                    /** Password already expired. Return the expiration time in days */
                    if (isset($this->options['options']['login_log_lifetime']) &&
                            $this->options['options']['login_log_lifetime'] <> 0) {
                        $this->internalDBLog(LOG_NOTICE, 'I', 'Password expired');
                    }
                    $this->passwordStatus = $dd;
                    $this->status = AUTH_PASSWORD_EXPIRED;
                    $this->log(__METHOD__ . "[" . __LINE__ . "]: Password for user {$this->username} expired.", AUTH_LOG_INFO);
                } else if ($dd < $userRow['us_pw_expire_alert']) {
                    /** Password is expiring. Return the left days to the expiration date */
                    if (isset($this->options['options']['login_log_lifetime']) &&
                            $this->options['options']['login_log_lifetime'] <> 0) {
                        $this->internalDBLog(LOG_INFO, 'I', 'Password in expiration');
                    }
                    $this->passwordStatus = $dd + 1;
                    $this->status = AUTH_PASSWORD_IN_EXPIRATION;
                    $this->log(__METHOD__ . "[" . __LINE__ . "]: Password for user {$this->username} is expiring.", AUTH_LOG_INFO);
                } else {
                    $this->passwordStatus = $dd + 1;
                }
            } else {
                $dd = 0;
            }

            if (!$this->skipUpdateStatus) {
                /* log only if login. This function is also called internally */
                if (isset($this->options['options']['login_log_lifetime']) &&
                        $this->options['options']['login_log_lifetime'] <> 0) {
                    $this->internalDBLog(LOG_INFO, 'I', 'User "' . $this->username . '" logged in');
                }
            }

            /** Password change forced (first login) */
            if (!$this->ignoreExpiredPassword && $userRow['us_pw_last_change'] == '') {
                if (isset($this->options['options']['login_log_lifetime']) &&
                        $this->options['options']['login_log_lifetime'] <> 0) {
                    $this->internalDBLog(LOG_NOTICE, 'I', 'Password change forced');
                }
                $this->status = AUTH_PASSWORD_REPLACE;
                $this->passwordStatus = -1;
                $this->log(__METHOD__ . "[" . __LINE__ . "]: Password for user {$this->username} must be changed at first login.", AUTH_LOG_INFO);
            }

            /** Store the password status */
            $this->session['passwordStatus'] = $this->passwordStatus;

            $this->isLoggedIn = true;
            if (!$this->skipUpdateStatus) {
                $this->updateStatus(true);
            }
            return true;
        }
        if (isset($this->options['options']['login_log_lifetime']) &&
                $this->options['options']['login_log_lifetime'] <> 0) {
            $this->internalDBLog(LOG_ERR, 'I', 'Invalid password for user "' . $this->username . '"');
        }
        return false;
    }

    public function start() {

        $this->log(__METHOD__ . "[" . __LINE__ . "]: called.", AUTH_LOG_DEBUG, true);
        if ($this->session['_storage_driver'] == '') {
            $this->log(__METHOD__ . "[" . __LINE__ . "]: faild: No storage defined.", AUTH_LOG_DEBUG);
            return false;
        }
        $this->log(__METHOD__ . "[" . __LINE__ . "]: Storage driver: {$this->session['_storage_driver']}", AUTH_LOG_DEBUG);

        if ($this->options['options']['idleTime'] > 0) {
            $this->setIdle($this->options['options']['idleTime']);
        }

        $this->storage_driver = $this->session['_storage_driver'];
        $this->storage_options = & $this->session['_storage_options'];
        parent::start();
        return true;
    }

    /**
     * logout the user
     *
     * @return boolean   Return true on success. False is returned if the user was not logged in
     * @access public
     */
    public function dologout() {

        $this->log(__METHOD__ . "[" . __LINE__ . "]: called.", AUTH_LOG_DEBUG);
        $this->updateStatus(false, true);

        $this->domainID = null;
        $this->applicationID = null;
        $this->applicationCode = null;
        $this->UID = null;

        $this->isLoggedIn = false;

        return parent::logout();
    }

    /**
     * logout the user
     *
     * @return boolean   Return true on success. False is returned if the user was not logged in
     * @access public
     */
    public function logout() {

        if (isset($this->options['options']['login_log_lifetime']) &&
                $this->options['options']['login_log_lifetime'] <> 0) {
            $this->internalDBLog(LOG_INFO, 'O', 'Logged out');
        }
        $result = $this->dologout();
        session_unset();
        session_destroy();
        return $result;
    }

    /**
     * Check if the user is authenticated
     *
     * @return boolean   Return true if the user is authenticated and the authentication state is valid
     *                   Return FALSE if the password is expired!
     * @access public
     */
    private function _isAuth() {

        $this->log(__METHOD__ . "[" . __LINE__ . "]: called.", AUTH_LOG_DEBUG, true);
        if (!$this->start()) {
            return false;
        }
        $checkAuthResult = $this->checkAuth();
        $allowLoginResult = $this->allowLogin;
        if (!$checkAuthResult) {
            $this->log(__METHOD__ . "[" . __LINE__ . "]: parent::checkAuth() return FALSE", AUTH_LOG_DEBUG);
        }
        if (!$this->allowLogin) {
            $this->log(__METHOD__ . "[" . __LINE__ . "]: allowLogin IS FALSE", AUTH_LOG_DEBUG);
        }
        return ($checkAuthResult && $allowLoginResult);
    }

    // OVERRIDE THE ORIGINAL FUNCTION TO FIX THE session_regenerate_id PROBLEM
    function setAuth($username) {
        $this->regenerateSessionId = true;
        parent::setAuth($username);
        $this->regenerateSessionId = false;
    }

    public function isAuth() {

        $this->log(__METHOD__ . "[" . __LINE__ . "]: called.", AUTH_LOG_DEBUG);
        if (!session_id()) {
            session_start();
        }
        if ($this->isLoggedIn) {
            $this->log(__METHOD__ . "[" . __LINE__ . "]: Preview call was OK, return OK again", AUTH_LOG_DEBUG, true);
            return true;
        }
        if (!isset($this->session['login'])) {
            $this->dbConnect();
            $sql = "SELECT d.do_id FROM " . $this->options['options']['domains_table'] . " d " .
                    "INNER JOIN " . $this->options['options']['domains_name_table'] . " dn ON d.do_id=dn.do_id " .
                    "WHERE dn_name=" . $this->db->quote($this->domainID);
            $this->domainID = & $this->db->queryOne($sql);
            $this->checkDBError($this->domainID, __LINE__);

            $sql = "SELECT app_id FROM " . $this->options['options']['applications_table'] . " " .
                    "WHERE app_code=" . $this->db->quote($this->application);
            $this->applicationID = & $this->db->queryOne($sql);
            $this->checkDBError($this->applicationID, __LINE__);
            if (isset($this->options['options']['login_log_lifetime']) &&
                    $this->options['options']['login_log_lifetime'] <> 0) {
                $this->internalDBLog(LOG_ERR, 'X', 'User not logged in');
            }
            $this->log(__METHOD__ . "[" . __LINE__ . "]: Not logged in or invalid session data", AUTH_LOG_DEBUG);
            $this->status = AUTH_NOT_LOGGED_IN;
            $this->doLogout();
            return false;
        }

        $this->passwordStatus = $this->session['passwordStatus'];
        if (!$this->ignoreExpiredPassword && $this->passwordStatus < 0) {
            if (isset($this->options['options']['login_log_lifetime']) &&
                    $this->options['options']['login_log_lifetime'] <> 0) {
                $this->internalDBLog(LOG_ERR, 'X', 'Password expired');
            }
            $this->log(__METHOD__ . "[" . __LINE__ . "]: Password expired", AUTH_LOG_DEBUG);
            $this->status = AUTH_PASSWORD_EXPIRED;

            // Added for multi domain: keep login data on password expiring  aaaaa
            $this->UID = $this->session['last_UID'];
            $this->applicationID = $this->session['last_applicationID'];
            $this->applicationCode = $this->session['last_applicationCode'];
            $this->login = $this->session['login'];
            $this->username = $this->login;
            $this->password = $this->session['password'];
            $this->domain = $this->session['domain'];
            $sql = "SELECT d.do_id FROM " . $this->options['options']['domains_table'] . " d " .
                    "INNER JOIN " . $this->options['options']['domains_name_table'] . " dn ON d.do_id=dn.do_id " .
                    "WHERE dn_name=" . $this->db->quote($this->domain);
            $this->domainID = & $this->db->queryOne($sql);
            $this->checkDBError($this->domainID, __LINE__);
            return false;
        }

        if (($this->options['options']['expirationTime'] == 0) ||
                ($this->options['options']['expirationTime'] > 0 && isset($this->session['timestamp']) && ($this->session['timestamp'] + $this->options['options']['expirationTime']) < time())) {
            $this->log(__METHOD__ . "[" . __LINE__ . "]: Session time end. Login required", AUTH_LOG_DEBUG);
            $this->skipUpdateStatus = true;

            $result = $this->performLogin($this->session['login'], $this->session['password'], $this->session['domain']);
            $this->skipUpdateStatus = false;

            /** Check for disconnection (us_last_action is null) */
            if ($this->lastAction == '') {
                if (isset($this->options['options']['login_log_lifetime']) &&
                        $this->options['options']['login_log_lifetime'] <> 0) {
                    $this->internalDBLog(LOG_ERR, 'X', 'User disconnected by administrator');
                }
                $this->log(__METHOD__ . "[" . __LINE__ . "]: User disconnected", AUTH_LOG_DEBUG);
                $this->status = AUTH_USER_DISCONNECTED;
                $this->doLogout();
                return false;
            }

            if ($result) {
                $this->setAuth($this->session['login']);
            } else {
                $this->doLogout();
            }
            $this->isLoggedIn = $result;
            if ($result) {
                /** restore the old password status */
                $this->passwordStatus = $this->session['passwordStatus'];
            }

            if ($result) {
                if (isset($this->options['options']['access_log_lifetime']) &&
                        $this->options['options']['access_log_lifetime'] <> 0) {
                    $this->internalDBLog(LOG_INFO, 'N', null);
                }
                $this->updateStatus();
            }
            return $result;
        }

        $result = $this->_isAuth();

        $this->isLoggedIn = $result;
        if ($result) {
            if (isset($this->options['options']['access_log_lifetime']) &&
                    $this->options['options']['access_log_lifetime'] <> 0) {
                $this->internalDBLog(LOG_INFO, 'N', null);
            }
            $this->updateStatus();
        }
        return $result;
    }

    private function updateStatus($isLogin = false, $isLogout = false) {
        if ($this->UID === null) {
            return;
        }

        // update IP-Address
        $sql = "UPDATE " . $this->options['options']['users_table'] . " SET \n" .
                "  us_last_ip = " . $this->db->quote($this->getIPAddress()) . "\n";


        $more_where = array();
        if ($isLogout) {
            $sql .= ",\n  us_last_action = NULL ";
            $more_where[] = "1=1";
        } else {
            $sql .= ",\n  us_last_action = CURRENT_TIMESTAMP ";
            if ($this->options['dsn']->phptype <> 'oci8' && isset($this->options['options']['update_status_skip_time'])) {
                $more_where[] = "AGE(CURRENT_TIMESTAMP, us_last_action) > '" . $this->options['options']['update_status_skip_time'] . " seconds'";
            } else {
                $more_where[] = "1=1";
            }
        }
        if ($isLogin) {
            $sql .= ",\n  us_last_login = CURRENT_TIMESTAMP ";
            $more_where[] = "1=1";
        }
        $sql .= "WHERE \n" .
                "  us_id=" . $this->UID . " AND ";
        $sql .= "  (us_last_ip <> " . $this->db->quote($this->getIPAddress()) . " OR ";
        $sql .= "  " . implode(' OR ', $more_where) . ")";

        $start = microtime(true);

        $this->log(__METHOD__ . "[" . __LINE__ . "]: $sql", AUTH_LOG_DEBUG);
        $res = & $this->db->exec($sql);
        $this->checkDBError($res, __LINE__);
    }

    private function internalDBLog($log_type, $log_auth_type, $log_text) {

        if (isset($this->options['options']['log_table']) &&
                isset($this->options['options']['enable_logging']) &&
                $this->options['options']['enable_logging'] == true) {

            $res = $this->dbConnect();
            $this->checkDBError($res, __LINE__);

            if (is_string($log_type)) {
                $log_type = strToupper(substr($log_type, 0, 1));
            }
            switch ($log_type) {
                case LOG_CRIT:
                case 'C':
                    $log_type = 'C';
                    break;
                case LOG_WARNING:
                case 'W':
                    $log_type = 'W';
                    break;
                case LOG_NOTICE:
                case 'N':
                    $log_type = 'N';
                    break;
                case LOG_INFO:
                case 'I':
                    $log_type = 'I';
                    break;
                case LOG_DEBUG:
                case 'D':
                    $log_type = 'D';
                    break;
                default:
                    $log_type = 'E';
            }

            $log_page = $_SERVER['SCRIPT_FILENAME'];
            $root = $_SERVER['DOCUMENT_ROOT'];
            if ($root <> '' && $root[strlen($root) - 1] <> '/') {
                $root = $root . '/';
            }

            if (!empty($root) && strpos($log_page, $root) == 0) {
                $log_page = './' . substr($log_page, strlen($root));
            }
            if (strlen($log_page) > 80) {
                $log_page = '...' . substr($log_page, -77);
            }

            $fields = array('do_id' => $this->domainID,
                'app_id' => $this->applicationID,
                'us_id' => $this->UID,
                'log_type' => $log_type,
                'log_auth_type' => $log_auth_type,
                'log_time' => date('Y-m-d H:i:s'),
                'log_ip' => $this->getIPAddress(),
                'log_page' => $log_page,
                'log_text' => $log_text);
            $res = $this->db->extended->autoExecute($this->options['options']['log_table'], $fields, MDB2_AUTOQUERY_INSERT);
            $this->checkDBError($res, __LINE__);

            return true;
        }
        return false; /* No log table defined */
    }

    /**
     * Text-Log to write into database. Requires "log_table" as authentication option.
     *
     * @param log_type ['CRITICAL' or LOG_CRIT, 'ERROR' or LOG_ERR, 'WARNING' or LOG_WARNING, 'NOTICE' or LOG_NOTICE, 'INFO' or LOG_INFO, 'DEBUG' or LOG_DEBUG]
     * @param log_text
     * @return boolean if log-entry was successfully (true) or not (false)
     */
    public function dblog($log_type, $log_text) {
        return $this->internalDBLog($log_type, null, $log_text);
    }

    public function log($message, $level = AUTH_LOG_DEBUG, $debug_backtrace = false) {
        if (isset($this->options['options']['log_path']) && $this->options['options']['log_path'] <> '') {
            $filename = $this->options['options']['log_path'] . '/';
            if (defined('DOMAIN_NAME')) {
                $filename .= strToLower(DOMAIN_NAME) . '_';
            }
            if (defined('APPLICATION_CODE')) {
                $filename .= strToLower(APPLICATION_CODE) . '_';
            }
            $filename .= 'auth.log';
            if ($message == '----') {
                file_put_contents($filename, "---\n", FILE_APPEND);
            } else {
                file_put_contents($filename, basename($_SERVER['PHP_SELF']) . "[$level]: " . $message . "\n", FILE_APPEND);
            }

            if ($debug_backtrace) {
                $trace = debug_backtrace();
                $caller = array_shift($trace);
                $function_name = $caller['function'];
                file_put_contents($filename, sprintf('%s: Called from %s:%s', $function_name, $caller['file'], $caller['line']) . "\n", FILE_APPEND);
                foreach ($trace as $entry_id => $entry) {
                    $entry['file'] = $entry['file'] ? : '-';
                    $entry['line'] = $entry['line'] ? : '-';
                    if (empty($entry['class'])) {
                        file_put_contents($filename, sprintf('%s %3s. %s() %s:%s', $function_name, $entry_id + 1, $entry['function'], $entry['file'], $entry['line']) . "\n", FILE_APPEND);
                    } else {
                        file_put_contents($filename, sprintf('%s %3s. %s->%s() %s:%s', $function_name, $entry_id + 1, $entry['class'], $entry['function'], $entry['file'], $entry['line']) . "\n", FILE_APPEND);
                    }
                }
            }
        }

        parent::log($message, $level);
    }

    /**
     * Get the last user status (eg: 0 ok, -1 password expired...)
     *
     * @return integer   Return the last status
     * @access public
     */
    public function getStatus() {

        $res = parent::getStatus();
        if ($res == AUTH_OK) {
            $res = $this->status;
        }
        return $res;
    }

    /**
     * Get the last user status as a stirng (eg: AUTH00000)
     *
     * @return string   Return the last status
     * @access public
     */
    public function getStatusText() {

        return sprintf('AUTH%05d', $this->getStatus());
    }

    /**
     * Get the user status as a text loaded from external file r3auth_text.php
     *
     * @return string   Return the status message
     * @access public
     */
    public function getStatusMessage($statusCode) {
        static $statusText = null;

        if ($statusText === null) {
            $statusText = array();
            $fileName = dirname(__FILE__) . '/r3auth_text.php';
            if (file_exists($fileName)) {
                include $fileName;
            }
        }
        if (isset($statusText[$statusCode])) {
            return $statusText[$statusCode];
        }
        return sprintf('Error #%d', $statusCode);
    }

    function setIdleTime($time) {
        $this->options['options']['idleTime'] = $time;
    }

    protected function doLoadPermission($app_id, $UID, $setID = false) {
        $this->log(__METHOD__ . "[" . __LINE__ . "]: called.", AUTH_LOG_DEBUG);

        $this->dbConnect();
        $sql = "SELECT DISTINCT \n" .
                "  " . $this->options['options']['groups_acl_table'] . ".ac_id as id, " .
                "  ac_verb as verb, ac_name as name, ga_kind as kind, ac_order as ordr \n" .
                "FROM  \n" .
                "  " . $this->options['options']['groups_acl_table'] . " \n" .
                "  INNER JOIN " . $this->options['options']['users_groups_table'] . " ON \n" .
                "    " . $this->options['options']['groups_acl_table'] . ".gr_id = " . $this->options['options']['users_groups_table'] . ".gr_id \n" .
                "  INNER JOIN " . $this->options['options']['acnames_table'] . " ON \n" .
                "    " . $this->options['options']['groups_acl_table'] . ".ac_id = " . $this->options['options']['acnames_table'] . ".ac_id \n" .
                "WHERE \n" .
                "  us_id = ? AND \n" .
                "  ac_active = 'T' AND \n" .
                "  app_id = ? \n\n" .
                "UNION \n\n" .
                "SELECT DISTINCT \n" .
                "  " . $this->options['options']['users_acl_table'] . ".ac_id as id, " .
                "  ac_verb as verb, ac_name as name, ua_kind as kind, ac_order as ordr\n" .
                "FROM \n" .
                "  " . $this->options['options']['users_acl_table'] . " \n" .
                "  INNER JOIN " . $this->options['options']['acnames_table'] . " ON \n" .
                "    " . $this->options['options']['users_acl_table'] . ".ac_id = " . $this->options['options']['acnames_table'] . ".ac_id \n" .
                "WHERE \n" .
                "  us_id = ? AND \n" .
                "  ac_active = 'T' AND \n" .
                "  app_id = ? \n\n" .
                "ORDER BY " .
                "	ordr, verb, name \n";

        $sth = $this->db->prepare($sql, null, MDB2_PREPARE_RESULT);
        $this->checkDBError($sth, __LINE__);
        $this->log(__METHOD__ . "[" . __LINE__ . "]: executing: $sql", AUTH_LOG_DEBUG);

        $res = $sth->execute(array($UID, $app_id, $UID, $app_id));
        $this->checkDBError($res, __LINE__);

        $result = array();
        while ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
            if ($row['kind'] == 'A') {
                if ($setID) {
                    $result[$row['verb']][$row['name']] = $row['id'];
                } else {
                    $result[$row['verb']][$row['name']] = true;
                }
            } else {
                if (isset($result[$row['verb']][$row['name']]))
                    unset($result[$row['verb']][$row['name']]);
            }
        }
        $res->free();
        return $result;
    }

    private function loadPermission($forceReload = false) {

        $this->log(__METHOD__ . "[" . __LINE__ . "]: called.", AUTH_LOG_DEBUG);
        if ($this->cachePerm === null) {
            $this->cachePerm = $this->doLoadPermission($this->applicationID, $this->UID);
        }
    }

    // Restituisce un array con tutte le permission dell'utente autenticato
    public function getAllPerms() {

        $this->loadPermission();
        return $this->cachePerm;
    }

    // Restituisce un array con tutte le permission dell'utente autenticato
    function getAllPermsAsString($prefix = 'USER_CAN_', $separator = '_') {

        $this->loadPermission();
        $result = array();

        foreach ($this->cachePerm as $key1 => $value1) {
            foreach ($value1 as $key2 => $value2) {
                $result[] = $prefix . $key1 . $separator . $key2;
            }
        }

        return $result;
    }

    // Restituisce un array con tutte le permission dell'utente autenticato
    function hasPerm($verb, $name) {

        if ($this->isSuperuser()) {
            /** Superuser has all permission */
            return true;
        }

        if ($this->passwordStatus < 0) {
            /** Privileges to set if the password expire */
            $this->cachePerm['USE']['APPLICATION'] = true;
        } else {
            $this->loadPermission();
        }

        if (isset($this->options['options']['acnames_upper']) && $this->options['options']['acnames_upper'] == true) {
            $verb = strToUpper($verb);
            $name = strToUpper($name);
        }
        return isset($this->cachePerm[$verb][$name]);
    }

    // Restituisce true se l'utente è superuser (UID=0)
    public function isSuperuser() {
        if ($this->userIsSuperuser) {
            return true;
        }
        return ($this->UID != '' && $this->UID == SUPERUSER_UID);
    }

    private function loadConfig() {

        $this->log(__METHOD__ . "[" . __LINE__ . "]: called.", AUTH_LOG_DEBUG);
        if ($this->dbini === null) {
            $this->dbConnect();
            require_once 'r3dbini.php';
            if (!isset($this->applicationCode)) {
                $this->applicationCode = 'MANAGER';
            }
            $this->dbini = new R3DBIni($this->db, $this->options['options'], $this->domain, $this->applicationCode, $this->login);
        }
    }

    public function reloadConfig() {

        $this->log(__METHOD__ . "[" . __LINE__ . "]: called.", AUTH_LOG_DEBUG);
        $this->loadconfig();
    }

    // Configurazione
    function getConfigValue($section, $param, $default = null) {

        $this->loadConfig();
        return $this->dbini->getValue($section, $param, $default);
    }

    function setConfigValue($section, $param, $value, array $opt = array()) {
        $defOpt = array('persistent' => false, 'type' => 'STRING', 'type_ext' => null, 'private' => 'T', 'order' => '0', 'description' => null);
        $opt = array_merge($defOpt, $opt);
        $this->loadConfig();
        if ($opt['persistent']) {
            $result = $this->dbini->setAttribute($this->domain, $this->applicationCode, $this->login, $section, $param, $value, strtoupper($opt['type']), $opt['type_ext'], $opt['private'], $opt['order'], $opt['description']);
        } else {
            // Not persistent
            $result = $this->dbini->setValue($section, $param, $value);
        }
        return $result;
    }

    // Configurazione
    function getAllConfigValues($section = null) {

        $this->loadConfig();
        return $this->dbini->getAllValues($section);
    }

    function getAllConfigValuesAsString($section = null, $prefix = 'USER_CONFIG_', $separator = '_') {

        $this->loadConfig();
        $result = array();
        foreach ($this->dbini->getAllValues($section) as $key1 => $value1) {
            foreach ($value1 as $key2 => $value2) {
                $result[$prefix . $key1 . $separator . $key2] = $value2;
            }
        }
        return $result;
    }

    function getParam($name, $default = null) {

        if (isset($this->userInfo[$name])) {
            return $this->userInfo[$name];
        }
        return $default;
    }

    function setParam($name, $value, $permanent = false) {

        $value = trim($value);
        if (in_array($name, array('us_id', 'us_status', 'us_start_date', 'us_expire_date', 'do_id',
                    'us_pw_expire', 'us_pw_last_change', 'us_last_ip', 'us_last_login', 'us_last_action',
                    'us_mod_user', 'us_mod_date'))) {
            throw new Exception('Permission denied');
        }
        if (in_array($name, array('us_login'))) {
            throw new Exception('Permission denied');
        }

        if ($name == 'us_login') {
            $this->login = $value;
        }
        if ($name == 'us_password') {
            $value = md5($value);
        }

        $this->userInfo[$name] = $value;
        if ($permanent) {
            // Update only if data changed
            if ($name == 'us_password') {
                /** Password change */
                $this->passwordStatus = 1;
                $this->session['passwordStatus'] = $this->passwordStatus;
                $sql = "UPDATE " . $this->options['options']['users_table'] . " SET \n" .
                        "  us_password = " . $this->db->quote($value) . ", \n" .
                        "  us_pw_last_change=CURRENT_TIMESTAMP, \n" .
                        "  us_mod_date=CURRENT_TIMESTAMP, \n" .
                        "  us_mod_user=" . $this->UID . " \n" .
                        "WHERE \n" .
                        "  us_id=" . $this->UID;
            } else {
                /** Field change */
                $sql = "UPDATE " . $this->options['options']['users_table'] . " SET \n" .
                        "  $name=" . $this->db->quote($value) . ", \n" .
                        "  us_mod_date=CURRENT_TIMESTAMP, \n" .
                        "  us_mod_user=" . $this->UID . " \n" .
                        "WHERE \n" .
                        "  us_id=" . $this->UID;
            }
            $this->log(__METHOD__ . "[" . __LINE__ . "]: $sql", AUTH_LOG_DEBUG);
            $res = & $this->db->query($sql);
            $this->checkDBError($res, __LINE__);
        }
    }

    public function getOptions() {
        return $this->options;
    }

    /**
     * Return all session parameters
     * @return array
     */
    public function getAllSessionParameters() {
        return $this->sessionParameters;
    }

    /**
     * Return the session parameter value by name
     * @param mixed $name
     * @param mixed $default
     * @return mixed 
     */
    public function getSessionParam($name, $default = null) {

        if (isset($this->sessionParameters[$name])) {
            return $this->sessionParameters[$name];
        }
        return $default;
    }

    /**
     * Set a session parameter by name
     * @param mixed $name
     * @param mixed $value 
     */
    public function setSessionParam($name, $value) {
        $this->sessionParameters[$name] = $value;
    }

}
