<?php

if (defined("__R3_DBINI__"))
    return;
define("__R3_DBINI__", 1);


define('R3DBINI', '0.5a');

require_once 'MDB2.php';

class R3DBIni {

    /**
     * @var class|null      The object instance
     */
    static private $instance = null;

    /**
     * Cache variable wich contains all the configuration data loaded from the database
     * to prevent multiple database requests.
     * If null, a database select is required.
     *
     * @var  array
     */
    private $cacheData = null;

    /**
     * Cache variable wich contains all the configuration data to store to database
     * to prevent multiple database requests.
     * If null, no data to write.
     *
     * @var  array
     */
    private $writeCacheData = null;

    /**
     * MDB2 object
     *
     * @var  object
     */
    private $db = null;

    /**
     * Domain id
     *
     * @var  integer
     */
    private $do_id = null;

    /**
     * Application id
     *
     * @var  integer
     */
    private $app_id = null;

    /**
     * User id
     *
     * @var  integer
     */
    private $us_id = null;

    /**
     * If true the class is destroing itself. This variabled is used to raise an exception (not destroing) or
     * triggen an error (destroing). In PHP it's not possible to raise an exception on destroy.
     *
     * @var  boolean
     */
    private $isDestroying = false;

    /**
     * Class options
     *
     * For the table structure see the sql script
     *
     * @var  array
     */
    protected $options = null;

    /**
     * inTransaction
     *
     * indicate if there is a transaction active (prevent multiple transaction or savepoint)
     *
     * @var  bool
     */
    protected $inTransaction = false;

    /**
     * Return the instance of the class
     * @return class    the instance
     */
    static function getInstance($db = null, $options = array(), $dn_name = null, $app_code = null, $us_login = null) {
        if (R3DBIni::$instance == null) {
            R3DBIni::$instance = new R3DBIni($db, $options, $dn_name, $app_code, $us_login);
        }
        return R3DBIni::$instance;
    }

    /**
     * Constructor
     *
     * @example r3dbini_sample.php <b>How to use this the class</b>
     *
     * @param mixed     database dsn or MDB2 object
     * @param array     class options. Valid options are: 
     *                  - settings_table: the main settings table
     *                  - applications_table: the application table
     *                  - users_table: the user table
     *                  - domains_table: the domain table
     *                  - domains_name_table: the domains_name table
     * @param string    domain name. If specified only the settings of the specified domain are used
     * @param string    application code. If specified only the settings of the specified application are used
     * @param string    login. If specified only the settings of the specified user are used. domain must be set
     * @return void
     */
    function __construct($db, $options = array(), $dn_name = null, $app_code = null, $us_login = null) {

        $this->db = $db;
        $this->options = $options;
        $this->showPrivate = false;

        if ($dn_name !== null) {
            if ($this->setDomainName($dn_name) === false) {
                throw new Exception("Invalid domain '$dn_name'");
            }
        }

        if ($app_code !== null) {
            if ($this->setApplicationCode($app_code) === false) {
                throw new Exception("Invalid application '$app_code'");
            }
        }

        if ($dn_name !== null && $us_login !== null) {
            if ($this->setUserLogin($dn_name, $us_login) === false) {
                throw new Exception("Invalid user '$dn_name/$us_login'");
            }
        }
    }

    // }}}
    // {{{ R3DBIni() [destructor]

    /**
     * Destructor
     *
     * Destroy the class and write data to db. On error an error is triggered instead of an exception (PHP can't handle exception on destroy)
     *
     * @return void
     */
    function __destruct() {

        $this->isDestroying = true;    // In the __destruct() method is not allowed to throw an exception. So in this case I use trigger_error instead
        $this->flushWriteCache();
    }

    // }}}

    /**
     * database error check
     *
     * throw an exception if a db error occurs
     *
     * @param object          the MDB2 object to check
     * @param integer         the line number with the error
     * @access private
     */
    private function checkDBError($dbObj, $line = null) {

        if (PEAR::isError($dbObj)) {
            $txt = $dbObj->getMessage();
            if ($line !== null)
                $txt .= " at line " . $line;
            if ($this->isDestroying)
                trigger_error($txt);
            else
                throw new Exception($txt);
        }
    }

    /**
     * Start a transaction o insert a savepoint
     *
     * @param string     savepoint name
     * @return string    true on success, exception on error
     * @access private
     */
    private function beginTransaction() {

        if (!$this->db->supports('transactions')) {
            /** Transaction NOT supported */
            throw new Exception("Transaction not supported");
        }
        if ($this->inTransaction) {
            /** Transaction alteady started */
            throw new Exception("Transaction alteady started");
        }
        $res = $this->db->beginTransaction();
        $this->checkDBError($res, __LINE__);
        $this->inTransaction = true;
        return true;
    }

    /**
     * commit a transaction (only if savepoint is empty)
     *
     * @param string     savepoint name
     * @return string    true on success, exception on error
     * @access private
     */
    private function commitTransaction() {

        if (!$this->db->inTransaction() || !$this->inTransaction) {
            /** Not in transaction */
            throw new Exception("Not in transaction");
        }
        $res = $this->db->commit();
        $this->checkDBError($res, __LINE__);
        $this->inTransaction = false;
        return true;
    }

    /**
     * Get the module version
     *
     * @param  mixed         Not used
     * @return string        return the version text or null if faild
     * @access public
     */
    public function getVersionString($className = null) {

        return R3DBINI;
    }

    /**
     * return true if the regular expression in $pattern is valid
     *
     * @param string   text to validate
     * @param string   regular expression pattern. Default: ^[A-Za-z_@%$#][A-Za-z0-9._@%$&=#-]*$
     * @return bool    true if done
     * @access public
     */
    public function validCharsRegEx($s, $pattern = '/^[A-Za-z_@%$#][A-Za-z0-9._@%$&=#-]*$/') {
        return preg_match($pattern, $s) > 0;
    }

    /**
     * Set the domain name. A database query is performed. The write cache is flushed
     *
     * @param string         domain name (dn_name). If null or empty the domain id is set to null. True is returned
     * @param bool           if true a negative do_id is stored and returned. 
     * @return bool|integer  true if dn_name is null or empty, 
      false if the domain is not found (function faild)
      positive dn_id if force is flase,
      negative dn_id if force is true.
      NOTE:
      A negative dn_id allow to load ONLY the data of the given domain (dn_id=NULL records are ignored).
      A >=0 dn_id load the dn_id=NULL records AND dn_id NOT NULL records
      NULL-Domains data are override by the NOT-NULL_Domain data (by same section/parameter)
     * @access public
     */
    public function setDomainName($dn_name, $force = false) {

        $this->flushWriteCache();
        $this->cacheData = null;

        if ($dn_name != '') {
            if ($this->options['domains_table'] == '') {
                throw new Exception('setDomainName: domains_table not defined');
            }
            $sql = "SELECT\n " .
                    "  do_id " .
                    "FROM " .
                    "  " . $this->options['domains_name_table'] . " \n" .
                    "WHERE " .
                    "  dn_name = " . $this->db->quote($dn_name);
            $res = & $this->db->query($sql);
            $this->checkDBError($res, __LINE__);
            if ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
                // write cache + flush
                $id = ($force ? -$row['do_id'] : $row['do_id']);
                $this->cacheData = null;
                $this->do_id = $id;
                $res->free();
                return $id;
            }
            $res->free();
            return false;
        } else {
            $this->do_id = null;
            return true;
        }
    }

    /**
     * Set the application name. A database query is performed. The write cache is flushed
     *
     * @param string         application code (app_code). If null or empty the application id is set to null. True is returned
     * @param bool           if true a negative app_id is stored and returned. 
     * @return bool|integer  true if app_code is null or empty, 
      false if the application is not found (function faild)
      positive app_id if force is flase,
      negative app_id if force is true.
      NOTE:
      A negative app_id allow to load ONLY the data of the given application (app_id=NULL records are ignored).
      A >=0 app_id load the app_id=NULL records AND app_id NOT NULL records
      NULL-Application data are override by the NOT-NULL_Application data (by same section/parameter)
     * @access public
     */
    public function setApplicationCode($app_code, $force = false) {

        $this->flushWriteCache();
        $this->cacheData = null;

        if ($app_code != '') {
            if ($this->options['applications_table'] == '') {
                throw new Exception('setApplicationCode: applications_table not defined');
            }
            $sql = "SELECT\n " .
                    "  app_id " .
                    "FROM " .
                    "  " . $this->options['applications_table'] . " \n" .
                    "WHERE " .
                    "  app_code = " . $this->db->quote($app_code);
            $res = & $this->db->query($sql);
            $this->checkDBError($res, __LINE__);
            if ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
                $id = ($force ? -$row['app_id'] : $row['app_id']);
                $this->cacheData = null;
                $this->app_id = $id;
                $res->free();
                return $id;
            }
            $res->free();
            return false;
        } else {
            $this->app_id = null;
            return true;
        }
    }

    /**
     * Set the login/domain name. A database query is performed. The write cache is flushed
     *
     * @param string         domain name (dn_name).
     * @param string         user login (us_login)
     * @param bool           if true a negative us_id is stored and returned. 
     * @return bool|integer  true if dn_naem and ul_login are null or empty, 
      false if the dn_name and us_login are not found (function faild)
      positive us_id if force is flase,
      negative us_id if force is true.
      NOTE:
      A negative us_id allow to load ONLY the data of the given user (us_id=NULL records are ignored).
      A >=0 us_id load the us_id=NULL records AND us_id NOT NULL records
      NULL-User data are override by the NOT-NULL_User data (by same section/parameter)
     * @access public
     */
    public function setUserLogin($dn_name, $us_login, $force = false) {

        $this->flushWriteCache();
        $this->cacheData = null;

        if ($dn_name != '' && $us_login != '') {
            if ($this->options['domains_table'] == '') {
                throw new Exception('setUserLogin: domains_table not defined');
            }
            $sql = "SELECT\n " .
                    "  us_id \n" .
                    "FROM \n" .
                    "  " . $this->options['users_table'] . " \n" .
                    "  INNER JOIN " . $this->options['domains_name_table'] . " ON \n" .
                    "    " . $this->options['users_table'] . ".do_id = " . $this->options['domains_name_table'] . ".do_id \n" .
                    "WHERE " .
                    "  dn_name = " . $this->db->quote($dn_name) . " AND \n" .
                    "  us_login = " . $this->db->quote($us_login) . " \n";

            $res = & $this->db->query($sql);
            $this->checkDBError($res, __LINE__);
            if ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
                $id = ($force ? -$row['us_id'] : $row['us_id']);
                //echo $id;
                $this->cacheData = null;
                $this->us_id = $id;
                $res->free();
                return $id;
            }
            $res->free();
            return false;
        } else {
            $this->us_id = null;
            return true;
        }
    }

    /**
     * Set the showPrivate parameter.
     * if showPrivate is false the private parameters are not returned. The cache is flushed
     *
     * @param boolean        showPrivate value to set
     * @access public
     */
    public function setShowPrivate($showPrivate = true) {

        $this->cacheData = null;
        $this->showPrivate = $showPrivate;
    }

    /**
     * Set the writeAll parameter.
     * if writeAll is true the system allow to write dati with empry UID or dn_name or app_id
     *
     * @param boolean        writeAll value to set
     * @access public
     */
    public function setWriteAll($writeAll = false) {

        $this->writeAll = $writeAll;
    }

    /**
     * load all the value from database
     * if the cache is empty or the $force value is true, load the data from the database
     *
     * @param boolean   force the data to be read from the database (instead of the cache)
     * @param string    comma separated field list to get
     * @param string    extra where condition
     * @param boolean   comma separated field to order
     * @access private
     * <b>NOTE</b>: If us_id < 0 (set with setUserLogin). Only the user data are loaded. If >= 0 the NULL_us_id data are sum with the NOT_NULL_us_id data
     */
    private function loadValues($force = false, $fields = null, $extraWhere = null, $order = null) {

        if ($force || $this->cacheData === null) {
            $sql = "SELECT\n ";
            if ($fields === null) {
                $sql .= "  " . $this->options['settings_table'] . ".se_order, " .
                        $this->options['settings_table'] . ".se_section, " .
                        $this->options['settings_table'] . ".se_param, " .
                        $this->options['settings_table'] . ".se_value, " .
                        $this->options['settings_table'] . ".se_type, " .
                        $this->options['settings_table'] . ".do_id, " .
                        $this->options['settings_table'] . ".app_id\n ";
            } else {
                $sql .= "  $fields\n ";
            }
            $sql .= "FROM\n " .
                    "  " . $this->options['settings_table'] . "\n ";
            if ($this->options['applications_table'] !== null) {
                $sql .= "  LEFT JOIN " . $this->options['applications_table'] . " ON\n " .
                        "    " . $this->options['settings_table'] . ".app_id = " . $this->options['applications_table'] . ".app_id\n ";
            }
            if ($this->options['domains_table'] !== null) {
                $sql .= "  LEFT JOIN " . $this->options['domains_table'] . " ON\n " .
                        "    " . $this->options['settings_table'] . ".do_id = " . $this->options['domains_table'] . ".do_id\n ";
            }

            $sql .= "WHERE \n " .
                    "  1 = 1 \n";
            /** Domain filter */
            if ($this->options['domains_table'] !== null) {
                if ($this->do_id === null) {
                    /** do_id IS NULL */
                    $sql .= "  AND " . $this->options['settings_table'] . ".do_id IS NULL\n ";
                } else if ($this->do_id < 0) {
                    /** only do_id (absolute) */
                    $sql .= "  AND " . $this->options['settings_table'] . ".do_id = " . abs($this->do_id) . "\n ";
                } else {
                    /** do_id + do_id */
                    $sql .= "  AND (" . $this->options['settings_table'] . ".do_id IS NULL OR " . $this->options['settings_table'] . ".do_id = $this->do_id)\n ";
                }
            }

            /** Application filter */
            if ($this->options['applications_table'] !== null) {
                /** user table is defined */
                if ($this->app_id === null) {
                    /** UID IS NULL */
                    $sql .= "  AND " . $this->options['settings_table'] . ".app_id IS NULL\n ";
                } else if ($this->app_id < 0) {
                    /** ONLY UID (absolute) */
                    $sql .= "  AND " . $this->options['settings_table'] . ".app_id = " . abs($this->app_id) . "\n ";
                } else {
                    /** UID NULL + UID */
                    $sql .= "  AND (" . $this->options['settings_table'] . ".app_id IS NULL OR " . $this->options['settings_table'] . ".app_id = $this->app_id)\n ";
                }
            }

            /** User filter */
            if ($this->options['users_table'] !== null) {
                /** user table is defined */
                if ($this->us_id === null) {
                    /** UID IS NULL */
                    $sql .= "  AND " . $this->options['settings_table'] . ".us_id IS NULL\n ";
                } else if ($this->us_id < 0) {
                    /** ONLY UID (absolute) */
                    $sql .= "  AND " . $this->options['settings_table'] . ".us_id = " . abs($this->us_id) . "\n ";
                } else {
                    /** UID NULL + UID */
                    $sql .= "  AND (" . $this->options['settings_table'] . ".us_id IS NULL OR " . $this->options['settings_table'] . ".us_id = $this->us_id)\n ";
                }
            }

            if ($extraWhere !== null)
                $sql .= "  AND ($extraWhere)\n ";

            /** ORDER BY */
            $sql .= "ORDER BY\n ";
            $sql .= "  COALESCE(" . $this->options['settings_table'] . ".us_id, -1)";
            $sql .= ", COALESCE(" . $this->options['settings_table'] . ".app_id, -1)";
            $sql .= ", COALESCE(" . $this->options['settings_table'] . ".do_id, -1)";

            if ($order !== null) {
                $sql .= ', ' . $order;
            } else {
                $sql .= ",  " . $this->options['settings_table'] . ".se_section";
                $sql .= ",  " . $this->options['settings_table'] . ".se_param";
            }

            $res = & $this->db->query($sql);
            $this->checkDBError($res, __LINE__);

            $this->cacheData = array();
            while ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
                $this->app_id = $row['app_id'];
                $this->do_id = $row['do_id'];

                if ($row['se_type'] == 'ARRAY') {
                    $row['se_value'] = @unserialize($row['se_value']);
                }

                if ($fields === null) {
                    $this->cacheData[$row['se_section']][$row['se_param']] = $row['se_value'];
                } else {
                    if ($row['se_type'] == 'STRING' &&
                            $row['se_type_ext'] == '')
                        $row['se_type_ext'] = 255;
                    $this->cacheData[$row['se_section']][$row['se_param']] = $row;
                }
            }
            $res->free();

            // Merge the write cache values
            if ($this->writeCacheData !== null) {
                foreach ($this->writeCacheData as $key1 => $value1) {
                    foreach ($value1 as $key2 => $value) {
                        if ($fields === null) {
                            $this->cacheData[$key1][$key2] = $value;
                        } else {
                            $this->cacheData[$key1][$key2]['se_value'] = $value;
                        }
                    }
                }
            }
        }
    }

    /**
     * return a single value. If the value is not found the default value is returned.
     * if the cache is empty load the data from the database
     *
     * @param string    section name
     * @param string    parameter value
     * @param string    default value (optional)
     * @return mixed    return the requested value or the default value if not found
     * @access public
     */
    public function getValue($section, $param, $default = null) {

        $this->loadValues();
        if (!isset($this->cacheData[$section][$param])) {
            return $default;
        }
        return $this->cacheData[$section][$param];
    }

    /**
     * return all values for one or all sections
     * if the section parameter is given, only the values from the specified section is returned
     *
     * @param string    section name (optional)
     * @return mixed    return a 1D array if the section parameter is given, else a 2D array. Return null if no data
     * @access public
     */
    public function getAllValues($section = null) {

        $this->loadValues();
        if ($section !== null) {
            if (isset($this->cacheData[$section])) {
                return $this->cacheData[$section];
            } else {
                return array();
            }
        }
        return $this->cacheData;
    }

    /**
     * return all values for one or all sections as an array of string
     * if the section parameter is given, only the values from the specified section is returned
     *
     * @param string    section name (optional)
     * @param string    prefix (optional, default "CONGIG_" )
     * @param string    section name (optional, default "_" )
     * @return mixed    return a 1D array with the key: prefix + section + separator + param. The value is the configuration value. 
      eg: CONFIG_USER_ROWS = 10
     * @access public
     */
    function getAllValuesAsString($section = null, $prefix = 'CONFIG_', $separator = '_') {

        $this->loadValues();
        $result = array();

        foreach ($this->getAllValues($section) as $key1 => $value1) {
            foreach ($value1 as $key2 => $value2) {
                $result[$prefix . $key1 . $separator . $key2] = $value2;
            }
        }
        return $result;
    }

    /**
     * return all sections (not the values)
     *
     * @return array    return an allay with all the sections.
     * @access public
     */
    public function getAllSections() {

        $result = array();
        $this->loadValues();
        foreach ($this->cacheData as $key => $val) {
            $result[] = $key;
        }
        sort($result);
        return $result;
    }

    /**
     * return all attributes for one or all sections. NO CACHE IS USED
     * if the section parameter is given, only the values from the specified section is returned
     *
     * @param string    section name
     * @param boolean   public only: if true return only the public settings
     * @return mixed    return a 2D array if the section parameter is given, else a 3D array. Return null if no data
     * @access public
     */
    public function getAllAttributes($section = null) {

        $result = array();
        $moreWhere = "1 = 1 \n";

        if ($section !== null)
            $moreWhere .= " AND " . $this->options['settings_table'] . ".se_section = " . $this->db->quote($section);
        if (!$this->showPrivate)
            $moreWhere .= " AND " . $this->options['settings_table'] . ".se_private = 'T' ";

        $order = $this->options['settings_table'] . '.se_order, ' .
                $this->options['settings_table'] . '.se_section, ' .
                $this->options['settings_table'] . '.se_param';

        $oldCache = $this->cacheData;
        $this->loadValues(true, '*', $moreWhere, $order);
        $result = $this->cacheData;
        $this->cacheData = $oldCache;
        return $result;
    }

    /**
     * Clear the settings cache
     *
     * @access public
     */
    public function clearReadCache() {

        $this->cacheData = null;
    }

    /**
     * Clear the settings cache (alias for clearReadCache)
     *
     * @access public
     * @see ClearReadCache
     */
    public function clearCache() {

        return $this->ClearReadCache();
    }

    /**
     * Clear the write settings cache. No data written to database
     *
     * @access public
     */
    public function clearWriteCache() {

        $this->writeCacheData = null;
    }

    /**
     * Flush the write cache to db
     *
     * @access public
     */
    public function flushWriteCache() {

        if ($this->writeCacheData !== null) {
            $trans = $this->db->beginTransaction();

            /** can't create a prepared sql because some parameters can be null ??? */
            foreach ($this->writeCacheData as $key1 => $value1) {
                foreach ($value1 as $key2 => $value) {
                    $fields = array('do_id' => $this->absOrNull($this->do_id),
                        'app_id' => $this->absOrNull($this->app_id),
                        'us_id' => $this->absOrNull($this->us_id),
                        'se_section' => $key1,
                        'se_param' => $key2);

                    $sql = "UPDATE " . $this->options['settings_table'] . " SET \n" .
                            "  se_value = " . $this->db->quote($this->writeCacheData[$key1][$key2]) . " \n" .
                            "WHERE \n" . $this->array2Where($fields);
                    $affectedRows = $this->db->exec($sql);
                    $this->checkDBError($affectedRows, __LINE__);
                    if ($affectedRows == 0) {
                        $sql = "INSERT INTO " . $this->options['settings_table'] . " " .
                                "  (do_id, app_id, us_id,se_section, se_param, se_value) " .
                                "VALUES " .
                                "  (" . $this->db->quote($this->absOrNull($this->do_id)) . ", " .
                                $this->db->quote($this->absOrNull($this->app_id)) . ", " .
                                $this->db->quote($this->absOrNull($this->us_id)) . ", " .
                                $this->db->quote($key1) . ", " .
                                $this->db->quote($key2) . ", " .
                                $this->db->quote($this->writeCacheData[$key1][$key2]) . ")";
                        $res = $this->db->exec($sql);
                        $this->checkDBError($res, __LINE__);
                    }
                }
            }
            $trans = $this->db->commit();
            $this->writeCacheData = null;
        }
    }

    /**
     * cache a single value for write.
     *
     * @param string    section name
     * @param string    parameter value
     * @param mixed     value
     * @return mixed    return the value
     * @access public
     */
    private function cacheValue($section, $param, $value) {

        if (!is_array($this->writeCacheData)) {
            $this->writeCacheData = array();
        }

        $this->cacheData[$section][$param] = $value;
        $this->writeCacheData[$section][$param] = $value;

        $this->flushWriteCache();
        $this->writeCacheData = null;
        return $value;
    }

    /**
     * set single value for a user. This function use a write cache
     *
     * @param string    section name
     * @param string    parameter value
     * @param mixed     value
     * @return mixed    return the value
     * @access public
     */
    public function setValue($se_section, $se_param, $value) {

        if ($se_section == '') {
            throw new Exception('setValue: Missing se_section', 1);
        }
        if (!$this->validCharsRegEx($se_section)) {
            throw new Exception('setValue: Invalid se_section', 2);
        }
        if ($se_param == '') {
            throw new Exception('setValue: Missing se_param', 3);
        }
        if (!$this->validCharsRegEx($se_param)) {
            throw new Exception('setValue: Invalid se_param', 4);
        }

        return $this->cacheValue($se_section, $se_param, $value);
    }

    /**
     * return the abs value of the given value, or null if the value is null
     *
     * @param integer|null  the param to evaluate
     * @return integer|null  return null if value is null, else abs(value)
     * @access private
     */
    private function absOrNull($value) {

        if ($value === null) {
            return null;
        }
        return abs($value);
    }

    /**
     * from an associative array ([filed]=value) return the where statement
     *
     * @param array     associative array ([field]=param)
     * @param string    where condition (AND or OR. Default AND)
     * @return string   return the where condition generated
     * @access private
     */
    private function array2Where($array, $operator = 'AND') {

        $out = array();
        foreach ($array as $key => $val) {
            if ($val === null) {
                $out[] = $key . ' IS NULL';
            } else {
                $out[] = $key . ' = ' . $this->db->quote($val);
            }
        }
        return implode(' ' . $operator . ' ', $out);
    }

    /**
     * Return a single attribute from dn_name, app_code, us_login, se_section, se_param returned
     *
     * @param string    domain name (dn_name)
     * @param string    application code (app_code)
     * @param string    user_login (us_login)
     * @param string    section name
     * @param string    param name
     * @return array    return a 2D array if the section parameter is given, else a 3D array. Return null if no data
     * @access public
     */
    public function getAttribute($dn_name, $app_code, $us_login, $se_section, $se_param) {

        $result = array();
        /** getting the domain, application , user IDs */
        if ($dn_name != '') {
            /** Getting the do_id */
            $do_id = $this->setDomainName($dn_name);
            if ($do_id === false) {
                throw new Exception('getAttribute: Invalid dn_code', 6);
            }
        } else {
            $do_id = null;
        }

        if ($app_code != '') {
            /** Getting the app_id */
            $app_id = $this->setApplicationCode($app_code);
            if ($app_id === false) {
                throw new Exception('getAttribute: Invalid app_code', 7);
            }
        } else {
            $app_id = null;
        }

        if ($us_login != '') {
            /** Getting the us_id */
            $us_id = $this->setUserLogin($dn_name, $us_login);
            if ($us_id === false) {
                throw new Exception('getAttribute: Invalid us_login', 8);
            }
        } else {
            $us_id = null;
        }

        $fields = array('do_id' => $do_id,
            'app_id' => $app_id,
            'us_id' => $us_id,
            'se_section' => $se_section,
            'se_param' => $se_param);

        $field_list = 'do_id, app_id, us_id, se_section, se_param, ' .
                'se_value, se_type, se_type_ext, se_private, se_order, se_descr';
        $sql = "SELECT $field_list FROM " . $this->options['settings_table'] . " WHERE " . $this->array2Where($fields);
        $res = & $this->db->query($sql);
        $this->checkDBError($res, __LINE__);
        if ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
            $row['dn_name'] = $dn_name;
            $row['app_code'] = $app_code;
            $row['us_login'] = $us_login;
            if ($row['se_type'] == 'ARRAY') {
                $row['se_value'] = @unserialize($row['se_value']);
            }
            $res->free();
            return $row;
        } else {
            $res->free();
            return null;
        }


        return $result;
    }

    /**
     * set attributes for a single item
     *
     * @param string    section name
     * @param string    parameter value
     * @param mixed     value
     * @return mixed    return the value
     * @access public
     */
    public function setAttribute($dn_name, $app_code, $us_login, $se_section, $se_param, $se_value, $se_type = 'STRING', $se_type_ext = '', $se_private = 'T', $se_order = 0, $se_descr = null) {

        /** check fields */
        if ($se_section == '') {
            throw new Exception('setAttribute: Missing se_section', 1);
        }
        if (!$this->validCharsRegEx($se_section)) {
            throw new Exception('setAttribute: Invalid se_section', 2);
        }
        if ($se_param == '') {
            throw new Exception('setAttribute: Missing se_param', 3);
        }
        if (!$this->validCharsRegEx($se_param)) {
            throw new Exception('setAttribute: Invalid se_param', 4);
        }
        if (!in_array($se_type, array('STRING', 'TEXT', 'NUMBER', 'ENUM', 'ARRAY', 'JSON'))) {
            throw new Exception('setAttribute: Invalid se_type', 5);
        }

        /** getting the domain, application , user IDs */
        if ($dn_name != '') {
            /** Getting the do_id */
            $do_id = $this->setDomainName($dn_name);
            if ($do_id === false) {
                throw new Exception('setAttribute: Invalid dn_code', 6);
            }
        } else {
            $do_id = null;
        }

        if ($app_code != '') {
            /** Getting the app_id */
            $app_id = $this->setApplicationCode($app_code);
            if ($app_id === false) {
                throw new Exception('setAttribute: Invalid app_code', 7);
            }
        } else {
            $app_id = null;
        }

        if ($us_login != '') {
            /** Getting the us_id */
            $us_id = $this->setUserLogin($dn_name, $us_login);
            if ($us_id === false) {
                throw new Exception('setAttribute: Invalid us_login', 8);
            }
        } else {
            $us_id = null;
        }

        if ($se_order == '') {
            $se_order = 0;
        }

        $fields = array('do_id' => $do_id,
            'app_id' => $app_id,
            'us_id' => $us_id,
            'se_section' => $se_section,
            'se_param' => $se_param,
            'se_value' => $se_value,
            'se_type' => $se_type,
            'se_type_ext' => $se_type_ext,
            'se_private' => $se_private,
            'se_order' => $se_order,
            'se_descr' => $se_descr);

        $del_fields = array('do_id' => $do_id,
            'app_id' => $app_id,
            'us_id' => $us_id,
            'se_section' => $se_section,
            'se_param' => $se_param);

        $inTransaction = $this->inTransaction;
        if (!$inTransaction) {
            $this->beginTransaction();
        }
        $sql = "DELETE FROM " . $this->options['settings_table'] . " WHERE " . $this->array2Where($del_fields);
        $res = $this->db->exec($sql);
        $this->checkDBError($res, __LINE__);
        $res = $this->db->extended->autoExecute($this->options['settings_table'], $fields, MDB2_AUTOQUERY_INSERT);
        $this->checkDBError($res, __LINE__);
        if (!$inTransaction) {
            $this->commitTransaction();
        }
        return true;
    }

    /**
     * clear an attribute entry for a single item
     *
     * @param string    section name
     * @param string    parameter value
     * @param mixed     value
     * @return mixed    return the value
     * @access public
     */
    public function removeAttribute($dn_name, $app_code, $us_login, $se_section, $se_param) {

        /** getting the domain, application , user IDs */
        if ($dn_name != '') {
            /** Getting the do_id */
            $do_id = $this->setDomainName($dn_name);
            if ($do_id === false) {
                throw new Exception('setAttribute: Invalid dn_code', 6);
            }
        } else {
            $do_id = null;
        }

        if ($app_code != '') {
            /** Getting the app_id */
            $app_id = $this->setApplicationCode($app_code);
            if ($app_id === false) {
                throw new Exception('setAttribute: Invalid app_code', 7);
            }
        } else {
            $app_id = null;
        }

        if ($us_login != '') {
            /** Getting the us_id */
            $us_id = $this->setUserLogin($dn_name, $us_login);
            if ($us_id === false) {
                throw new Exception('setAttribute: Invalid us_login', 8);
            }
        } else {
            $us_id = null;
        }

        $del_fields = array('do_id' => $do_id,
            'app_id' => $app_id,
            'us_id' => $us_id,
            'se_section' => $se_section,
            'se_param' => $se_param);

        $sql = "DELETE FROM " . $this->options['settings_table'] . " WHERE " . $this->array2Where($del_fields);

        $res = $this->db->exec($sql);
        $this->checkDBError($res, __LINE__);
        return true;
    }

    /**
     * Replace an existing attribute with a new one. 
     * This function is implemented using removeAttribute and setAttribute in db-transaction
     *
     * @param string    old section name
     * @param string    old application code
     * @param string    old user login
     * @param string    old section
     * @param string    old param
     * @param string    new section name
     * @param string    new application code
     * @param string    new user login
     * @param string    new section
     * @param string    new param
     * @param string    new value
     * @param string    new value
     * @param string    new type
     * @param string    new type-extended
     * @param string    new private flag
     * @param integer   new order
     * @param string    new description
     * @param bool      fail if the old value doesn't exist. Dafault false
     * @return mixed    return true on success, else false
     * @access public
     */
    public function replaceAttribute($old_dn_name, $old_app_code, $old_us_login, $old_se_section, $old_se_param, $dn_name, $app_code, $us_login, $se_section, $se_param, $se_value, $se_type = 'STRING', $se_type_ext = '', $se_private = 'T', $se_order = 0, $se_descr = null, $failIfNotExists = false) {

        if ($failIfNotExists) {
            if (getAttribute($old_dn_name, $old_app_code, $old_us_login, $old_se_section, $old_se_param) == null) {
                return false;
            }
        }

        $inTransaction = $this->inTransaction;
        if (!$inTransaction) {
            $this->beginTransaction();
        }
        $this->removeAttribute($old_dn_name, $old_app_code, $old_us_login, $old_se_section, $old_se_param);
        $this->setAttribute($dn_name, $app_code, $us_login, $se_section, $se_param, $se_value, $se_type, $se_type_ext, $se_private, $se_order, $se_descr);
        if (!$inTransaction) {
            $this->commitTransaction();
        }
    }

}
