<?php
require_once dirname(__FILE__) . '/r3mdb2.php';
if (!class_exists('R3DbCatalog_Base'))
    require_once dirname(__FILE__) . '/r3dbcatalog.php';

abstract class R3ArchiveImport {

	/**
	 * return an array with the files in the specified path (or compressed file)
	 *
	 * @param string|array  path or (compressed) file name to search for.
	 *                      If  the param is an array all the values are checked
	 * @param  string       valid file pattern. Default = '*'
	 * @param  boolean      if True the function is recursive
	 * @return array        Return an array with the list of the matched files.
	 *                      If the input parameter is an array the returned array is a 2D array. The first key is the path
	 * @access public
	 */
	abstract public function getFileList($archives, $pattern=null, $recursive=false);


	/**
	 * Expand the archive or a part of it
	 *
	 * @param string|array  path or (compressed) file name to expand.
	 *                      If  the param is an array all the values are checked
	 * @param  null|array   Files to extract. If null all files will be extract
	 * @param  string       The output base directory. Default current directory
	 * @return array        Return an array with the list of the expanded files (with path)
	 * @access public
	 */

	abstract public function expandFile($archive, $files=null, $output_dir=null);


	/**
	 * Compress files into an archive
	 *
	 * @param string         path or (compressed) file name to create/append.
	 * @param  string|array  Files to add. If null all the files of the current directory are added
	 * @param  string        The output base directory. Default current directory
	 * @return array         Return an array with the list of the expanded files (with path)
	 * @access public
	 */

	//abstract public function compressFile($archive, $files=null);

	//pub func compressFile(zip_file(s), $tmp_dir);

	//pub func getFileInfo(zip_file(s)); // ritorna array('compress_size' =>, 'expendanded_size' =>)

	/**
	 * Return the extension of a file (without dot)
	 *
	 * @param string         file name
	 * @param  boolean       if true the extension is returned in lower case
	 * @return string        the extensione
	 * @access public
	 */
	static public function getExt($fileName, $forceLower=false) {

		return substr(strrchr($fileName, '.'), 1);
	}
}

class R3DirImport extends R3ArchiveImport {

	private function doGetFileList($archive, $pattern=null, $recursive=false) {

		$res = array();

		if (substr($archive, -1) != '/') {
			$archive .= '/';
		}
		$files = glob($archive . '*');
		foreach($files as $file) {
			if ($recursive && is_dir($file)) {
				$filesInDir = $this->doGetFileList($file, $pattern, $recursive);
				$res = array_merge($res, $filesInDir);
			} else if (is_file($file) && ($pattern === null || preg_match($pattern, basename($file)))) {
				$res[] = $file;
			}
		}
		return $res;
	}

	public function getFileList($archives, $pattern=null, $recursive=false) {

		$res = array();
		if (is_array($archives)) {
			foreach($archives as $archive) {
				$res = array_merge($res, $this->doGetFileList($archive, $pattern, $recursive));
			}
		} else {
			$res = $this->doGetFileList($archives, $pattern, $recursive);
		}
		sort($res, SORT_REGULAR);
		return $res;
	}

	public function expandFile($archive, $files=null, $output_dir=null) {

	}

}

class R3ZIPImport extends R3ArchiveImport {

	function __construct() {
		if (!extension_loaded('zip')) {
			throw new Exception('ZIP extension not available');
		}
	}

	public function doGetFileList($archive, $pattern=null, $recursive=false) {

		$res = array();
		$zip = new ZipArchive();
		$zip->open($archive);
		for ($i = 0; $i < $zip->numFiles; $i++) {
			$node = $zip->statIndex($i);
			$res[] = $node['name'];
		}
		$zip->close();
		return $res;
	}

	public function getFileList($archives, $pattern=null, $recursive=false) {

		$res = array();
		if (is_array($archives)) {
			foreach($archives as $archive) {
				$res[$archive] = $this->doGetFileList($archive, $pattern, $recursive);
				sort($res[$archive], SORT_REGULAR);
			}
		} else {
			$res = $this->doGetFileList($archives, $pattern, $recursive);
			sort($res, SORT_REGULAR);
		}
		return $res;
	}

	public function expandFile($archive, $files=null, $output_dir=null) {

	}

}

abstract class R3ImportDriver {

	/* Log data (2D array) */
	protected $logData = null;

	/* The current debug level */
	protected $currentDebugLevel = LOG_NOTICE;

	/* Default options */
	protected $defaultOpt = array(
            'srid'=>-1,
            'create'=>true,
            'data'=>true,
            'geometry_column'=>'the_geom',
            'dump_format'=>'B',
            'case_sensitive'=>false,
            'force_int4'=>false,
            'keep_precision'=>true,
            'simple_geometry'=>false,
            'source_encoding'=>'AUTO',
            'policy'=>'INSERT',
            'debug_level'=>LOG_NOTICE,
            'cmd_path'=>'',
            'tmp_path'=>'/tmp',
            'table'=>null,
            'table_nr'=>null,
            'sql'=>null,
            'read_buffer'=>8192,
            'first_line_header'=>true,
            'separator'=>',',
            'quote_char'=>'"',
            'line_feed'=>"\r\n",
            'validate_schema'=>false,
            'dbtype' => 'pgsql',
            'create_gid' => true
	);

	/** database connection */
	protected $db;

    /** informations about the import */
    protected $importInfo = array();

  	/**
	 * Constructor
	 */
	public function __construct(){
	}

	/**
	 * Return the valid extension in a 2D array. The 1D is the generic name and the 2D is the index of the mandatory extensions
	 * If no extension available null is returned (eg: database connection)
	 *
	 * @return array  The valid extension(s)
	 * @access public
	 */

	abstract public function getExtensions();


	/**
	 * Return the priority of the driver (if you have same extensions)
	 *
	 * @return integer  The priority. Default 50
	 * @access public
	 */

	abstract public function getPriority();

	/**
	 * the file format may potentially contain more then 1 table
	 *
	 * @return boolean
	 * @access public
	 */
	public function isMultiTable(){
		return false;
	}

	/**
	 * return an array with the table names
	 *
	 * @param string $fileName  Source file name
	 * @param array  $opt       optional array with driver specific options
	 * @return array            numerically indexed array with table names
	 * @access public
	 */
	public function getMultiTableIndex($fileName, $opt=array()) {
		return array();
	}

	/**
	 * Import the specified file to the specified database
	 *
	 * @param string   Source file name (or database connection)
	 * @param string   Destination (schema.)table name
	 * @param mixed   A valid DSN string or array, or a valid MDB2 connection
	 * @param array    Options. Valid options are:
	 *  - srid: postgis srid (default -1)
	 *  - create: If true the create the table (default true)
	 *  - data: If true append the data to the table (default true)
	 *  - geometry_column: The name of the geometry column  (default the_geom)
	 *  - dump_format: 'B'=bulk, 'I'=insert statement (default 'B')
	 *  - case_sensitive: true to maintain the case on the table. Default false
	 *  - unique_field: Unique field name. If '' a gid field and a sequence are created.
	 *  - force_int4: If true all the integer field are converted in int4. Default (false)
	 *  - keep_precision: If true the precision of the data is maintained and NOT converted. Default true
	 *  - simple_geometry: If true a simple geometry is created instead of a multi geomerty
	 *  - source_encoding: Specify the character encoding of Shape's attribute column. (default : "ASCII")
	 *  - policy: Specify NULL geometries handling policy (INSERT, SKIP, ABORT)
	 *  - cmd_path: The path of the command(s) to execute. If empty the command must be in the system path. Default ''
	 *  - tmp_path: The temporary path to use. Default '/tmp';
	 *  - debug_level: specify the debug level (?)
	 *  - table if multi-table format or database, set the table to import
	 *  - table_nr if multi-table format or database, set the table index (start 0) to import
	 *  - sql   if database, set the sql to execute to extract data (> priority than table)
	 *  - read_buffer   the read buffer size (default 8192)
	 *  - first_line_header  if true the first line of the file is the header line
	 *  - separator  the field sepatatr character
	 *  - line_feed  the CR (or LF or CRLF sequence)
	 *  - quote_char the quote char
	 * @return string  ?????????????
	 * @access public
	 */

	abstract public function import($file, $table, $db, $opt=array());
	 
	 
	/**
	 * Clear the log data
	 *
	 * @access public
	 */

	public function clearLog() {

		$this->logData = array();
	}

	/**
	 * Return the log data
	 *
	 * @param integer   Maximum log level to return
	 * @param boolean   If true extract only the specified level
	 * @return array    The logs entry
	 * @access public
	 */

	public function getLog($level=null, $strict=false) {

		if ($level === null) {
			return $this->logData;
		}
		$res = array();
		if (is_array($this->logData)) {
			foreach($this->logData as $id=>$val) {
				$k = key($val);
				if (($strict === true && $k == $level) ||
				($strict === false && $k <= $level) ||
				($strict === true && $level == LOG_INFO && ($k == LOG_INFO || $k == LOG_NOTICE))) {
					$res[$id][$k] = $val[$k];
				}
			}
		}
		return $res;
	}

	/**
	 * Clear the info data
	 *
	 * @access public
	 */
    public function clearInfo() {
        return $this->importInfo = array();
    }

	/**
	 * Get info data
	 *
	 * @access public
	 */
    public function getInfo() {
        return $this->importInfo;
    }

	/**
	 * Log
	 *
	 * @param integer: Log level (priority)
	 * @param string: Log text
	 * @access protected
	 */
	 
	protected function log($level, $message) {
		static $id = 0;

		if ($this->currentDebugLevel >= $level) {
			$addToLog = true;
			if (function_exists('R3ImportDriverLogCallback')) {
				$addToLog = R3ImportDriverLogCallback($this, $level, $message);
			}
			if($addToLog) {
				$this->logData[$id][$level] = $message;
				$id++;
			}
			return $addToLog;
		}
		return false;
	}


	/**
	 * Return the debug log data
	 *
	 * @param boolean   If true extract only the specified level
	 * @return array    The logs entry
	 * @access public
	 */

	public function getDebugLog($strict=false) {
		return $this->getLog(LOG_DEBUG, $strict);
	}


	/**
	 * Return the info and notice log data
	 *
	 * @param boolean   If true extract only the specified level
	 * @return array    The logs entry
	 * @access public
	 */

	public function getInfoLog($strict=false) {
		return $this->getLog(LOG_INFO, $strict);
	}


	/**
	 * Return the warning log data
	 *
	 * @param boolean   If true extract only the specified level
	 * @return array    The logs entry
	 * @access public
	 */

	public function getWarningLog($strict=false) {
		return $this->getLog(LOG_WARNING, $strict);
	}

	/**
	 * Return the error log data
	 *
	 * @param boolean   If true extract only the specified level
	 * @return array    The logs entry
	 * @access public
	 */

	public function getErrorLog($strict=false) {
		return $this->getLog(LOG_ERR, $strict);
	}

	protected function checkDBError($dbObj, $line=null) {

		if (PEAR::isError($dbObj)) {
			$txt = $dbObj->getMessage();
			if ($line !== null)
			$txt .= " at line " . $line;
			throw new EDatabaseError($txt);
		}
	}

	/**
	 * Connect to database by using the given DSN string, to get the authentication method
	 *
	 * @access protected
	 * @param  string DSN string
	 * @return mixed  Object on error, otherwise bool
	 */
	protected function dbConnect($db, $opt) {

		if (is_string($db) || is_array($db)) {
			$this->log(LOG_DEBUG, 'Connecting to database');
			$this->db = MDB2::connect($db);
		} elseif (is_subclass_of($db, 'MDB2_Driver_Common')) {
			$this->db = $db;
		} else {
			throw new Exception('Invalid DSN or connection');
		}
		checkDBError($this->db, __LINE__);
	}

	/**
	 * Return the current debug level of the driver
	 *
	 * @return integer   The debug level
	 * @access public
	 */

	public function getDebugLevel() {
		return $this->currentDebugLevel;
	}

	/**
	 * Set the debug level of the driver
	 *
	 * @parma integer $level   The new debug level
	 * @access public
	 */

	public function setDebugLevel($level) {
		$this->currentDebugLevel = $level;
	}

    /**
     * Eventually remove the extension.
     *
     * @param string $file File name
     * @return string
     */
    public function getBaseName($file) {
        $baseName = NULL;
        $extensions = $this->getExtensions();
        foreach ($extensions as $name => $exts) {
            foreach ($exts as $ext) {
                $extLen = strlen($ext) + 1;
                if (strlen($file) > $extLen) {
                    if (strtolower(mb_substr($file, -$extLen)) == '.' . $ext) {
                        $baseName = mb_substr($file, 0, -$extLen);
                        break;
                    }
                }
            }
            if (!is_null($baseName)) {
                break;
            }
        }
        if (is_null($baseName)) {
            $baseName = $file;
        }
        return $baseName;
    }

}

class R3Import {

	/**
	 * Return the R3ImportDriver
	 *
	 * @param string         file name
	 * @return string        the extensione
	 * @access public
	 */

	static function factory($driver) {
		$includeName = dirname(__FILE__) . '/r3impexp/r3imp_' . strToLower($driver) . '.php';
		if (file_exists($includeName)) {
			require_once $includeName ;
			$className = 'R3ImportDriver_' . strToLower($driver);
			return new $className;
		} else {
			throw new Exception('Unsupported format "' . $driver . '"');
		}
	}


	/**
	 * Return the R3ImportDriver from a file name
	 *
	 * @param string         file name
	 * @param  boolean       if true an exception is raised if no driver available, if false null is returned (on failure)
	 * @return string|null   the driver or null is returned.
	 * @access public
	 */
	static function factoryFromFile($fileName, $exceptOnFail=true) {

		$capabilities = R3Import::getCapabilities();

		/* Search in every available driver */
		foreach ($capabilities as $capability) {
			try {
				$driver = R3Import::factory($capability);
				$extensions = $driver->getExtensions();
				if ($extensions !== null) {
					$ext = strtolower(substr(strrchr($fileName, '.'), 1));
					/* Is the given file extension in the extensions list? */
					if (in_array($ext, $extensions[key($extensions)])) {
                        $nameNoExt = substr($fileName, 0, -strlen($ext));
						$extToCheck = $extensions[key($extensions)];
						/* Are all extensions present? */
						$done = true;
						foreach($extToCheck as $e) {
							if (!file_exists($nameNoExt . $e)) {
								$done = false;
								break;
							}
						}
						if ($done) {
							if ($ext == $extensions[key($extensions)][0]) {
								return $driver;
							} else {
								return null;
							}
						}
					}
				}
			} catch (Exception $e) {
			}
		}
		if ($exceptOnFail) {
			throw new Exception('Unsupported format for file "' . basename($fileName) . '"');
		}
		return null;
	}


	/**
	 * Return the available capabilities. You can use the capabilities to factory the import class
	 *
	 * @return string        the available capabilities
	 * @access public
	 */

	static function getCapabilities() {
		static $capabilities = null; /* Cache the capabilities to prevent multiple filesystem access */

		if ($capabilities === null) {
			$capabilityTmp = array();
			$files = glob(dirname(__FILE__) . '/r3impexp/r3imp_*.php');
			foreach($files as $file) {
				$capability = substr(substr(strrchr($file, '/'), 7), 0, -4);
				try {
					$driver = R3Import::factory($capability);
					$priority = $driver->getPriority();
					$capabilityTmp[$priority][] = $capability;
				} catch (Exception $e) {
				}
			}
			ksort($capabilityTmp);
			$capabilities = array();
			foreach($capabilityTmp as $capabilitySorted) {
				foreach($capabilitySorted as $capability) {
					$capabilities[] = $capability;
				}
			}
		}
		return $capabilities;
	}
}




abstract class R3ExportDriver {

	/* Log data (2D array) */
	protected $logData = null;

	/** Default options */
	protected $defaultOpt = array('srid'=>-1, 'create'=>true, 'data'=>true, 'geometry_column'=>'the_geom', 'raw_format'=>false,
                            'case_sensitive'=>false, /*'force_int4'=>false, */'keep_precision'=>true, /*'simple_geometry'=>false, */
                            'destination_encoding'=>'AUTO', 'policy'=>'INSERT', 'debug_level'=>LOG_NOTICE, 'cmd_path'=>'', 'tmp_path'=>'/tmp',
                            'table'=>null, 'separator'=>',', 'quote_char'=>'"', 'line_feed'=>"\r\n", 'id' => 'gid', 'dbtype' => 'pgsql');

	/** actual options */
	protected $opt = array();

	/** database connection */
	protected $db;


	const STYLE_SHEET_FILE = 1;
    const STYLE_SHEET_STRING = 2;
    const STYLE_SHEET_ARRAY = 3;

    /** Style sheet */
    protected $styleSheet;

    /** Style sheet type */
    protected $styleSheetType;
    
	/**
	 * Constructor
	 */
	public function __construct(){
	}
    
	/**
	 * Return the valid extension in a 2D array. The 1D is the generic name and the 2D is the index of the mandatory extensions
	 *
	 * @return array  The valid extension(s)
	 * @access public
	 */
	abstract public function getExtensions();

	/**
	 * the file format may potentially contain more then 1 table
	 *
	 * @return boolean
	 * @access public
	 */
	public function isMultiTable(){
		return false;
	}

	/**
	 * return the table index
	 *
	 * @param string   Source file name
	 * @return array
	 * @access public
	 */
	public function getMultiTableIndex($fileName, $opt=array()) {
		return array();
	}

	/**
	 * export the specified file to the specified database
	 *
	 * @param string   Destination (schema.)table name
	 * @param string   Source file name
	 * @param mixed   A valid DSN string or array, or a valid MDB2 connection
	 * @param array    Options. Valid options are:
	 *  - srid: postgis srid (default -1)
	 *  - create: If true the create the table (default true)
	 *  - data: If true append the data to the table (default true)
	 *  - geometry_column: The name of the geometry column  (default the_geom)
	 *  - dump_format: 'B'=bulk, 'I'=insert statement (default 'B')
	 *  - case_sensitive: true to maintain the case on the table. Default false
	 *  - unique_field: Unique field name. If '' a gid field and a sequence are created.
	 *  - force_int4: If true all the integer field are converted in int4. Default (false)
	 *  - keep_precision: If true the precision of the data is maintained and NOT converted. Default true
	 *  - simple_geometry: If true a simple geometry is created instead of a multi geomerty
	 *  - source_encoding: Specify the character encoding of Shape's attribute column. (default : "ASCII")
	 *  - policy: Specify NULL geometries handling policy (INSERT, SKIP, ABORT)
	 *  - cmd_path: The path of the command(s) to execute. If empty the command must be in the system path. Default ''
	 *  - tmp_path: The temporary path to use. Default '/tmp';
	 *  - debug_level: specify the debug level (?)
	 *  - table if multi-table format, set the table to export
	 * @return string  ?????????????
	 * @access public
	 */
	abstract public function export($table, $file, $db, $opt=array());
	 
	 
	/**
	 * Clear the log data
	 *
	 * @access public
	 */
	public function clearLog() {

		$this->logData = array();
	}

	/**
	 * Return the log data
	 *
	 * @param integer   Maximum log level to return
	 * @param boolean   If true extract only the specified level
	 * @return array    The logs entry
	 * @access public
	 */
	public function getLog($level=null, $strict=false) {

		if ($level === null) {
			return $this->logData;
		}
		$res = array();
		foreach($this->logData as $id=>$val) {
			$k = key($val);
			if (($strict === true && $k == $level) ||
			($strict === false && $k <= $level) ||
			($strict === true && $level == LOG_INFO && ($k == LOG_INFO || $k == LOG_NOTICE))) {
				$res[$id][$k] = $val[$k];
			}
		}
		return $res;
	}


	/**
	 * Log
	 *
	 * @param integer: Log level (priority)
	 * @param string: Log text
	 * @access protected
	 */
	protected function log($level, $message) {
		static $id = 0;

		$this->logData[$id][$level] = $message;
		$id++;
		//echo $message . "\n";
		return $message;
	}


	/**
	 * Return the debug log data
	 *
	 * @param boolean   If true extract only the specified level
	 * @return array    The logs entry
	 * @access public
	 */
	public function getDebugLog($strict=false) {
		return $this->getLog(LOG_DEBUG, $strict);
	}


	/**
	 * Return the info and notice log data
	 *
	 * @param boolean   If true extract only the specified level
	 * @return array    The logs entry
	 * @access public
	 */
	public function getInfoLog($strict=false) {
		return $this->getLog(LOG_INFO, $strict);
	}


	/**
	 * Return the warning log data
	 *
	 * @param boolean   If true extract only the specified level
	 * @return array    The logs entry
	 * @access public
	 */
	public function getWarningLog($strict=false) {
		return $this->getLog(LOG_WARNING, $strict);
	}

	/**
	 * Return the error log data
	 *
	 * @param boolean   If true extract only the specified level
	 * @return array    The logs entry
	 * @access public
	 */
	public function getErrorLog($strict=false) {
		return $this->getLog(LOG_ERR, $strict);
	}

	protected function checkDBError($dbObj, $line=null) {

		if (PEAR::isError($dbObj)) {
			$txt = $dbObj->getMessage();
            $txt .= "\n".$dbObj->getUserInfo();
			if ($line !== null)
			$txt .= " at line " . $line;
			throw new EDatabaseError($txt);
		}
	}

	/**
	 * Connect to database by using the given DSN string, to get the authentication method
	 *
	 * @access protected
	 * @param  string DSN string
	 * @return mixed  Object on error, otherwise bool
	 */
	protected function dbConnect($db, $opt) {

		if (is_string($db) || is_array($db)) {
			$this->log(LOG_DEBUG, 'Connecting to database');
			$this->db =& MDB2::connect($db);
		} elseif (is_subclass_of($db, 'MDB2_Driver_Common')) {
			$this->db = $db;
		} else {
			throw new Exception('Invalid DSN or connection');
		}
		checkDBError($this->db, __LINE__);
	}

   /**
     * Set a style sheet for the expoted data
     *
     * @param string $styleSheet filename or string
     * @param unknown_type $type       
     */
    public function setStyleSheet($styleSheet, $type = self::STYLE_SHEET_FILE ){
         $this->styleSheet = $styleSheet;
         $this->styleSheetType = $type;
    }
    
    /**
     * This method can be used to close file handles, clean up stuff, etc.
     */
    public function closeDatabase() {
        
    }
}


class R3Export {

	/**
	 * Return the R3ExportDriver
	 *
	 * @param string         file name
	 * @return string        the extensione
	 * @access public
	 */
	static function factory($driver) {

		$includeName = dirname(__FILE__) . '/r3impexp/r3exp_' . strToLower($driver) . '.php';
		if (file_exists($includeName)) {
			require_once $includeName ;
			$className = 'R3ExportDriver_' . strToLower($driver);
			return new $className;
		} else {
			throw new Exception('Unsupported format "' . $driver . '"');
		}
	}

	/**
	 * Return the available capabilities. You can use the capabilities to factory the export class
	 *
	 * @return string        the available capabilities
	 * @access public
	 */
	static function getCapabilities() {
		static $capabilities = null; /* Cache the capabilities to prevent multiple filesystem access */

		if ($capabilities === null) {
			$capabilityTmp = array();
			$files = glob(dirname(__FILE__) . '/r3impexp/r3exp_*.php');
			foreach($files as $file) {
				$capabilities[] = substr(substr(strrchr($file, '/'), 7), 0, -4);
			}
		}
		return $capabilities;
	}
}

