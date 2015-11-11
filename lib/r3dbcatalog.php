<?php

require_once "r3mdb2.php";

abstract class R3DbCatalog_Base {

    protected $db, $options;

    public function __construct($db, $options = array()) {
        $this->db = $db;
        $this->options = $options;
    }

    abstract static public function cropId($identifier);

    abstract public function tableExists($name, $schema = null);

    abstract public function createIndexDDL($schema, $table, $columns, $options = array());

    abstract public function getTableDesc($table);

    abstract public function setClientEncoding($encoding);

    static public function getPath($name, $defaultSchema = 'public') {
        if (($p = strpos($name, '.')) === false) {
            $schema = $defaultSchema; // Read seach_path?
            $table = $name;
        } else {
            $schema = substr($name, 0, $p);
            $table = substr($name, $p + 1);
        }
        return array($schema, $table);
    }

}

class R3DbCatalog {

    static private $instance;

    /**
     * Return the R3ImportDriver
     *
     * @param string         file name
     * @return string        the extensione
     * @access public
     */
    static function factory($driver, $db, $options = array()) {
        $includeName = dirname(__FILE__) . '/r3dbcatalog/' . strToLower($driver) . '.php';
        if (file_exists($includeName)) {
            require_once $includeName;
            $className = 'R3DbCatalog_' . ucfirst(strToLower($driver));
            return new $className($db, $options);
        } else {
            throw new Exception('Unsupported database "' . $driver . '"');
        }
    }

    static public function set($instance) {
        return (R3DbCatalog::$instance = $instance);
    }

    static public function get() {
        return R3DbCatalog::$instance;
    }

}
