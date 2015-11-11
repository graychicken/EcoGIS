<?php

class R3DbCatalog_Pgsql extends R3DbCatalog_Base {
    const maxIdLength = 63;

    static public function cropId($identifier) {
        if (mb_strlen($identifier) > self::maxIdLength) {
            $identifier = mb_substr($identifier, 0, self::maxIdLength);
        }
        return $identifier;
    }

    public function extractTableDesc($name) {
        $res = $this->db->query("SELECT current_schema()");
        checkDBError($res, __LINE__);
        $currentSchema = $res->fetchOne();

        $default = array('table' => '', 'schema' => $currentSchema);
        if (is_array($name)) {
            return array_merge($default, $name);
        }
        list($default['schema'], $default['table']) = self::getPath($name, $default['schema']);
        return $default;
    }

    public function tableExists($name, $schema=null) {
        if ($schema === null) {
            $schema = 'public';
            if (!empty($this->options['schema'])) {
                $schema = $this->options['schema'];
            }
            list($schema, $name) = self::getPath($name, $schema);
        }

        $name = strtolower($name);
        $schema = strtolower($schema);
        $sql = "SELECT count(*) FROM pg_tables WHERE " .
                "schemaname=" . $this->db->quote($schema) . " AND " .
                "tablename=" . $this->db->quote($name);
        $res = $this->db->query($sql);
        checkDBError($res, __LINE__);
        return (int) $res->fetchOne();
    }

    public function viewExists($name, $schema=null) {

        $name = $this->extractTableDesc($name);
        $sql = "SELECT count(*) FROM pg_views WHERE " .
                "schemaname=" . $this->db->quote($name['schema']) . " AND " .
                "viewname=" . $this->db->quote($name['table']);
        $res = & $this->db->query($sql);
        checkDBError($res, __LINE__);
        return (int) $res->fetchOne();
    }

    /**
     * Return if field exists
     *
     * @access public
     * @param string table or schema.table
     * @param string name of field
     * @return boolean
     */
    public function fieldExists($table, $fieldName, $schema=null) {
        if (is_null($schema) && strpos('.', $table) !== TRUE) {
            list($schema, $table) = explode('.', $table);
        }
        $fieldDefinition = $this->getTableDesc($schema.".".$table);
        foreach ($fieldDefinition as $field) {
            if ($fieldName == $field['column_name'])
                return true;
        }
        return false;
    }

    public function createIndexDDL($schema, $table, $columns, $options = array()) {
        $unique = '';
        if (isset($options['unique']) && $options['unique']) {
            $unique = " UNIQUE ";
        }
        $sql = "CREATE $unique INDEX ";
        $sql .= $table . "_" . implode('_', $columns) . "_uq \n";
        $sql .= "ON $schema.$table USING btree (" . implode(',', $columns) . ")";
        return $sql;
    }

    /**
     * Return the table definition DDL
     *
     * @param string         table or schema.table
     * @return array
     * @access public
     */
    public function getTableDescDDL($table) {

        $table = strTolower($table);
        // TODO: if table has no schema part, should we then read the search_path?
        if (strpos($table, '.') === false) {
            // Search for temporary first!
            $schema = 'public';
        } else {
            list($schema, $table) = explode('.', $table);
        }
        $sql = "SELECT " .
                "  column_name, column_default, is_nullable, data_type, character_maximum_length, " .
                "  numeric_precision, numeric_scale, datetime_precision " .
                "FROM " .
                "  information_schema.columns " .
                "WHERE " .
                "  table_schema='$schema' AND " .
                "  table_name='$table' " .
                "ORDER BY " .
                "  ordinal_position";
        // echo $sql;
        return $sql;
    }

    /**
     * Return the table definition
     *
     * @param string         table or schema.table
     * @return array
     * @access public
     */
    public function getTableDesc($table) {

        $sql = $this->getTableDescDDL($table);
        $rows = $this->db->queryAll($sql, null, MDB2_FETCHMODE_ASSOC);
        checkDBError($rows, __LINE__);
        return $rows;
    }

    /**
     * Set the client encoding
     *
     * @param string $encoding        a valid postgres encoding
     * @access public
     */
    public function setClientEncoding($encoding) {
        $sql = "SET client_encoding to '$encoding'";
        $res = $this->db->exec($sql);
        checkDBError($res, __LINE__);
    }

    /**
     * Return the user list DDL
     *
     * @param array $opt         options (not used now)
     * @return string
     * @access public
     */
    public function getUserListDDL(array $opt=array()) {
        return "SELECT rolname AS name FROM pg_catalog.pg_roles ORDER BY rolname";
    }

    /**
     * Return the user list
     *
     * @param array $opt         options (not used now)
     * @return string
     * @access public
     */
    public function getUserList(array $opt=array()) {
        $sql = $this->getUserListDDL();
        $res = $this->db->query($sql);
        checkDBError($res, __LINE__);
        $result = array();
        while (($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC))) {
            $result[$row['name']] = $row['name'];
        }
        return $result;
    }

    /**
     * Return a single-user attribute SQL
     * @param string $name
     * return string
     */
    public function getUserDataDDL($name) {
        $name = $this->db->quote($name);
        $sql = "SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolconnlimit, rolvaliduntil
                FROM pg_catalog.pg_roles
                WHERE rolname={$name}
                ORDER BY rolname";
        return $sql;
    }

    /**
     * Return a single-user attribute
     * @param string $name
     * return string
     */
    public function getUserData($name=null) {
        if ($name === null) {
            $name = $this->db->queryOne("SELECT current_user");  // Current user
        }
        $sql = $this->getUserDataDDL($name);
        $res = $this->db->query($sql);
        checkDBError($res, __LINE__);
        $result = array();
        while (($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC))) {
            return $row;
        }
        return null;
    }

    /**
     * Return true if an user is superuser
     * @param string $name
     * return boolean
     */
    public function isSuperuser($name=null) {
        if ($name === null) {
            $name = $this->db->queryOne("SELECT current_user");  // Current user
        }
        $sql = $this->getUserDataDDL($name);
        $res = $this->db->query($sql);
        checkDBError($res, __LINE__);
        $result = array();
        while (($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC))) {
            return $row['rolsuper'] == 't';
        }
        return null;
    }

    /**
     * Return if a user exists
     *
     * @param string $login      the user login
     * @param array $opt         options (not used now)
     * @return boolean
     * @access public
     */
    public function userExists($login, array $opt=array()) {
        return array_key_exists($login, $this->getUserList());
    }

    /**
     * Return the create user statement
     *
     * @param string $login      the user login
     * @param string $password   the user password
     * @param array $opt         options (not used now)
     * @return string
     * @access public
     */
    function createUserDDL($login, $password, array $opt=array()) {
        return "CREATE USER $login LOGIN PASSWORD '$password' NOINHERIT VALID UNTIL 'infinity'";
    }

    /**
     * Create a new user
     *
     * @param string $login      the user login
     * @param string $password   the user password
     * @param array $opt         options (not used now. Values tip: privileges, dba, ecc)
     * @access public
     */
    function createUser($login, $password, array $opt=array()) {
        $sql = $this->createUserDDL($login, $password, $opt);
        $res = $this->db->exec($sql);
        checkDBError($res, __LINE__);
    }

    /**
     * Return the schema list DDL
     *
     * @param array $opt         options (not used now)
     * @return string
     * @access public
     */
    public function getSchemaListDDL(array $opt=array()) {
        return "SELECT  nspname AS name " .
        "FROM pg_catalog.pg_namespace " .
        "WHERE (nspname !~ '^pg_temp_' AND " .
        "       nspname <> 'pg_catalog' AND " .
        "       nspname <> 'information_schema' AND " .
        "       nspname !~ '^pg_toast') " .
        "ORDER BY name";
    }

    /**
     * Return the schema list
     *
     * @param array $opt         options (not used now)
     * @return string
     * @access public
     */
    public function getSchemaList(array $opt=array()) {
        $sql = $this->getSchemaListDDL();
        $res = $this->db->query($sql);
        checkDBError($res, __LINE__);
        $result = array();
        while (($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC))) {
            $result[$row['name']] = $row['name'];
        }
        return $result;
    }

    /**
     * Return if a schema exists
     *
     * @param string $name       the schema name
     * @param array $opt         options (not used now)
     * @return boolean
     * @access public
     */
    public function schemaExists($name, array $opt=array()) {
        return array_key_exists($name, $this->getSchemaList());
    }

    /**
     * Return the create schema statement
     *
     * @param string $name       the schema name
     * @param array $opt         options (not used now)
     * @return string
     * @access public
     */
    function createSchemaDDL($name, array $opt=array()) {
        $sql = "CREATE SCHEMA $name ";
        if (isset($opt['owner']) && $opt['owner'] <> '')
            $sql .= "AUTHORIZATION {$opt['owner']} ";
        return $sql;
    }

    /**
     * Create a new schema
     *
     * @param string $name       the schema login
     * @param array $opt         options (not used now. Values tip: privileges, dba, ecc)
     * @access public
     */
    function createSchema($name, array $opt=array()) {
        $sql = $this->createSchemaDDL($name, $opt);
        $res = $this->db->exec($sql);
        checkDBError($res, __LINE__);
    }

    /**
     * Return the database list DDL
     *
     * @param array $opt         options (not used now)
     * @return string
     * @access public
     */
    function getDatabaseListDDL(array $opt=array()) {
        return "SELECT datname AS name FROM pg_catalog.pg_database WHERE datname not in ('postgres', 'postgis', 'template0', 'template1') ORDER BY name";
    }

    /**
     * Create a new user
     *
     * @param array $opt         options (not used now)
     * @access public
     */
    function getDatabaseList(array $opt=array()) {
        $sql = $this->getDatabaseListDDL($opt);
        $res = $this->db->query($sql);
        checkDBError($res, __LINE__);
        $result = array();
        while (($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC))) {
            $result[$row['name']] = $row['name'];
        }
        return $result;
    }

    function getVersion() {
// Versione database
    }

    /**
     * Return the unique index of a table DDL
     *
     * @param array $opt         options (not used now)
     * @return string
     * @access public
     */
    function getTableIndexListDDL($table, array $opt=array()) {
        $name = $this->extractTableDesc($table);
        return " SELECT i.indisprimary, i.indisunique, i.indisclustered, pg_catalog.pg_get_indexdef(i.indexrelid, 0, true)
                 FROM pg_catalog.pg_class c
                 INNER JOIN pg_catalog.pg_roles r ON r.oid = c.relowner
                 LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace 
                 LEFT JOIN pg_catalog.pg_index i ON i.indexrelid = c.oid 
                 LEFT JOIN pg_catalog.pg_class c2 ON i.indrelid = c2.oid 
                 WHERE nspname='{$name['schema']}' AND c2.relname = '{$name['table']}' 
                 ORDER BY i.indisprimary DESC, i.indisunique DESC, c2.relname ";
    }

    function getTableIndexList($table, $opt=array()) {
        $sql = $this->getTableIndexListDDL($table, $opt);

        $res = $this->db->query($sql);
        checkDBError($res, __LINE__);
        $result = array();
        $uniqueids = array();
        while (($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC))) {
            if ($row['indisprimary'] == 't' && $row['indisunique'] == 't') {
                //SG: TODO!
                $result['primary'][] = $row['pg_get_indexdef'];
            } else if ($row['indisprimary'] == 'f' && $row['indisunique'] == 't') {
                $result['unique'][] = $this->getUniqueInfo($row['pg_get_indexdef']);
            } else {
                //SG: TODO!
                $result['index'][] = $row['pg_get_indexdef'];
            }
        }
        return $result;
    }

    /* Return all the tables of the system */

    function getTableList($options = array()) {
        $result = array();
        $where = '';
        if (!empty($options['schema'])) {
            $where = " AND n.nspname=" . $this->db->quote($options['schema']) . " ";
            //$values[] = $options['schema'];
        }
        $result = array();
        $sql = "SELECT n.nspname AS schema_name, c.relname AS table_name 
                FROM pg_catalog.pg_class c
                LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace 
                WHERE 
                  c.relkind IN ('r','') AND 
                  n.nspname NOT IN ('pg_catalog', 'pg_toast', 'import', 'information_schema') 
                {$where}
                ORDER BY schema_name, table_name";
        $stmt = $this->db->prepare($sql);
        $res = $stmt->execute();
        while ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
            $result[] = array('schema' => $row['schema_name'], 'table' => $row['table_name']);
        }
        return $result;
    }

    /* Return all the tables of the system */

    function getViewList($options = array()) {
        $result = array();
        $where = '';
        if (!empty($options['schema'])) {
            $where = " AND n.nspname=" . $this->db->quote($options['schema']) . " ";
            //$values[] = $options['schema'];
        }
        $result = array();
        $sql = "SELECT n.nspname AS schema_name, c.relname AS table_name 
                FROM pg_catalog.pg_class c
                LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace 
                WHERE 
                  c.relkind IN ('v','') AND 
                  n.nspname NOT IN ('pg_catalog', 'pg_toast', 'import', 'information_schema') 
                {$where}
                ORDER BY schema_name, table_name";
        $stmt = $this->db->prepare($sql);
        $res = $stmt->execute();
        while ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
            $result[] = array('schema' => $row['schema_name'], 'table' => $row['table_name']);
        }
        return $result;
    }

    function getUniqueInfo($IndexList) {
        //$pattern = "/(btree|rtree|hash|gist)\s\(([\s\w_,]+)\)/i";
        $pattern = "/CREATE UNIQUE INDEX ([\s\w_,]+) ON ([\s\w_,]+) USING (btree|rtree|hash|gist)\s\(([\s\w_,]+)\)/i";
        if (preg_match($pattern, $IndexList, $a) > 0) {
            $info = array('name' => $a[1], 'type' => $a[3], 'fields' => preg_split('/\s*,\s*/', $a[4]));
            return $info;
        }
        return null;
    }

    function checkUniques($mdb2, $uniqueArr = array(), $orig, $import) {
        $name = $this->extractTableDesc($orig);
        $result = null;
        if (array_key_exists('unique', $uniqueArr)) {
            foreach ($uniqueArr['unique'] as $uniques) {
                $unique = implode(', ', $uniques['fields']);
                $groupby = "imp." . implode(', imp.', $uniques['fields']) . ", ori." . implode(', ori.', $uniques['fields']);
                $case = '';
                $join = '';
                foreach ($uniques['fields'] as $key => $field) {
                    $case .= " CASE  WHEN imp.$field IS NOT NULL THEN imp.$field WHEN ori.$field IS NOT NULL THEN ori.$field END AS $field, ";
                    $join .= " ori.$field=imp.$field AND";
                }


                $join = substr($join, 0, -3);

                $sql = " SELECT $case " .
                        " COUNT(*) AS cnt " .
                        " FROM $orig ori " .
                        " RIGHT OUTER JOIN $import imp ON " .
                        " $join " .
                        " GROUP BY $groupby " .
                        " HAVING COUNT(*) > 1 ";
                $res = $mdb2->query($sql);
                checkDBError($res, __LINE__);
                $resString = '';
                $result = array();
                while ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
                    $status = true;
                    foreach ($uniques['fields'] as $key => $field) {
                        if ($status === true) {
                            $resString .= '(' . $row[$field] . ', ';
                        } else if (count($uniques['fields']) == $key + 1) {
                            $resString .= $row[$field] . ') ';
                        } else {
                            $resString .= $row[$field] . ', ';
                        }
                        $status = false;
                    }
                }
                if (!empty($resString)) {
                    $result = array($uniques['name'] => $resString);
                }
            }
        }
        return $result;
    }

    function getTableForeignKeyListDDL($table, array $opt=array()) {
        $name = $this->extractTableDesc($table);
        return "SELECT conname, pg_catalog.pg_get_constraintdef(ch.oid, false) AS condef 
                FROM pg_catalog.pg_constraint ch 
                INNER JOIN pg_class t ON ch.conrelid=t.oid 
                INNER JOIN pg_namespace n ON ch.connamespace=n.oid 
                WHERE ch.contype='f' AND 
                      n.nspname='{$name['schema']}' AND t.relname='{$name['table']}' 
                ORDER BY ch.conname";
    }

    function getTableForeignKeyList($table, $opt=array()) {
        $sql = $this->getTableForeignKeyListDDL($table, $opt);
        $result = array();
        $pattern = "/FOREIGN KEY \(([a-zA-Z_0-9,\s]+)\) REFERENCES (([a-zA-Z_0-9]+)\.){0,1}([a-zA-Z_0-9]+)\(([a-zA-Z_0-9,\s]+)\)/";
        $name = $this->extractTableDesc($table);
        $res = $this->db->query($sql);
        checkDBError($res, __LINE__);
        while ($row = $res->fetchRow(MDB2_FETCHMODE_ASSOC)) {
            preg_match($pattern, $row['condef'], $a);
            $result[$row['conname']] = array('table' => "{$name['schema']}.{$name['table']}",
                'fields' => explode(',', str_replace(' ', '', $a[1])),
                'foreign_table' => ($a[3] == '' ? $name['schema'] : $a[3]) . '.' . $a[4],
                'foreign_fields' => explode(',', str_replace(' ', '', $a[5])));
        }
        return $result;
    }

    public function getIndexNameFromTableAndColumns($schema = null, $table, array $columns) {
        $indexName = null;
        if (is_null($schema)) {
            $visibleCondition = "pg_catalog.pg_table_is_visible(c.oid)";
        } else {
            $visibleCondition = "n.nspname='$schema'";
        }

        // look for all indeces in this table
        $sql = <<<EOQ
        SELECT relname, pg_index.indisunique, pg_index.indisprimary, indclass,
                                pg_index.indkey, pg_index.indrelid
                          FROM pg_class, pg_index
                          WHERE oid IN ( SELECT indexrelid
                                 FROM pg_index i
                                 INNER JOIN pg_class c ON c.oid=i.indrelid
                                 LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
                                 WHERE c.relname='$table' AND $visibleCondition
                              )
                       AND pg_index.indexrelid = oid
EOQ;
        $res = $this->db->query($sql);
        $ind = $res->fetchAll(MDB2_FETCHMODE_ASSOC);

        // check column by column if these match
        foreach ($ind as $i) {
            if (!is_numeric($i['indkey'])) {
                continue;
            }

            $sqlIndex = <<<EOQ
        SELECT t.relname, a.attname, a.attnum
     FROM pg_index c
LEFT JOIN pg_class t
       ON c.indrelid  = t.oid
LEFT JOIN pg_attribute a
       ON a.attrelid = t.oid
      AND a.attnum = ANY(indkey)
    WHERE t.relname = '$table'
      AND a.attnum = {$i['indkey']};
EOQ;
            $resIndex = $this->db->query($sqlIndex);
            $indexColumns = array();
            while ($rowIndex = $resIndex->fetchRow(MDB2_FETCHMODE_ASSOC)) {
                $indexColumns[] = $rowIndex['attname'];
            }

            if (count($indexColumns) == count($columns) && count(array_diff($indexColumns, $columns)) == 0) {
                $indexName = $i['relname'];
                break;
            }
        }
        return $indexName;
    }

    public function getPrimaryKeys($schema = NULL, $table) {
        $tableString = $table;
        if (!is_null($schema)) {
            $tableString = $schema . '.' . $tableString;
        }
        $sql = <<<EOQ
SELECT
  pg_attribute.attname,
  format_type(pg_attribute.atttypid, pg_attribute.atttypmod)
FROM pg_index, pg_class, pg_attribute
WHERE
  pg_class.oid = '$tableString'::regclass AND
  indrelid = pg_class.oid AND
  pg_attribute.attrelid = pg_class.oid AND
  pg_attribute.attnum = any(pg_index.indkey)
  AND indisprimary
EOQ;
        $stmt = $this->db->query($sql);
        $columns = array();
        while ($row = $stmt->fetchRow(MDB2_FETCHMODE_ASSOC)) {
            $columns[] = $row['attname'];
        }
        return $columns;
    }

}
