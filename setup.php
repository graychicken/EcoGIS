<?php
// Return general settings
$autoinit = false;
require_once 'etc/config.php';

$ver = @trim(file_get_contents('web/version.txt'));
echo "\nR3-EcoGIS v{$ver} setup\n";
echo "========================================\n";
echo DOMAIN_NAME . " " . (R3_IS_MULTIDOMAIN ? 'multi-domain ':'') . "installation. Database {$dsn['dbname']} on {$dsn['dbhost']}\n";

// Filesystem check
dirCheck(R3_EZC_DIR, array('fatal'=>true));
dirCheck(R3_PHPEXCEL_DIR, array('fatal'=>true));
dirCheck(R3_SMARTY_ROOT_DIR, array('fatal'=>true));
dirCheck(R3_SMARTY_PLUGIN_DIR, array('fatal'=>true));
dirCheck(R3_CACHE_DIR, array('fatal'=>false, 'create'=>true, 'writeable'=>true));
dirCheck(R3_CACHE_DIR . 'mappreview', array('fatal'=>false, 'create'=>true, 'writeable'=>true));

dirCheck(R3_TMP_DIR, array('fatal'=>false, 'create'=>true, 'writeable'=>true));

dirCheck(R3_UPLOAD_DIR, array('fatal'=>false, 'create'=>true));
dirCheck(R3_UPLOAD_DIR . 'building', array('fatal'=>false, 'create'=>true, 'writeable'=>true));
dirCheck(R3_UPLOAD_DIR . 'document', array('fatal'=>false, 'create'=>true, 'writeable'=>true));
dirCheck(R3_UPLOAD_DIR . 'import_seap', array('fatal'=>false, 'create'=>true, 'writeable'=>true));

dirCheck(R3_UPLOAD_DIR . 'data', array('fatal'=>false, 'create'=>true, 'writeable'=>true));
dirCheck(R3_UPLOAD_DIR . 'data/' . strtolower(DOMAIN_NAME), array('fatal'=>false, 'create'=>true));
dirCheck(R3_UPLOAD_DIR . 'data/' . strtolower(DOMAIN_NAME) . '/style', array('fatal'=>false, 'create'=>true, 'writeable'=>true));
dirCheck(R3_UPLOAD_DIR . 'data/' . strtolower(DOMAIN_NAME) . '/js', array('fatal'=>false, 'create'=>true, 'writeable'=>true));
dirCheck(R3_UPLOAD_DIR . 'data/' . strtolower(DOMAIN_NAME) . '/logo', array('fatal'=>false, 'create'=>true, 'writeable'=>true));

// Copy default logos
$logosPath = R3_UPLOAD_DIR . 'data/' . strtolower(DOMAIN_NAME) . '/logo/';
if (!file_exists("{$logosPath}login_dx.png")) {
    echo "Copy default logos\n";
    copy(R3_WEB_DIR . "images/login_dx.png", "{$logosPath}login_dx.png");
    chmod("{$logosPath}login_dx.png", 0770);
}
if (!file_exists("{$logosPath}login_sx.png")) {
    copy(R3_WEB_DIR . "images/login_sx.png", "{$logosPath}login_sx.png");
    chmod("{$logosPath}login_sx.png", 0770);
}
if (!file_exists("{$logosPath}logo_sx.png")) {
    copy(R3_WEB_DIR . "images/logo_sx.png", "{$logosPath}logo_sx.png");
    chmod("{$logosPath}logo_sx.png", 0770);
}
if (!file_exists("{$logosPath}logo_dx.png")) {
    copy(R3_WEB_DIR . "images/logo_dx.png", "{$logosPath}logo_dx.png");
    chmod("{$logosPath}logo_dx.png", 0770);
}



dirCheck(R3_SMARTY_TEMPLATE_DIR, array('fatal'=>true));
dirCheck(R3_SMARTY_TEMPLATE_C_DIR_ADMIN, array('fatal'=>false, 'create'=>true, 'writeable'=>true));
dirCheck(R3_LOG_DIR, array('fatal'=>false, 'create'=>true, 'writeable'=>true));

fileCheck(R3_FOP_CMD, array('fatal'=>true));


// Error mail check
if (R3_ERROR_SYSLOG) {
	echo "Warning: R3_ERROR_SYSLOG is true\n";
}
if (!R3_ERROR_ERRLOG) {
	echo "Warning: R3_ERROR_SYSLOG is false\n";
}
if (!R3_ERROR_MAIL) {
	echo "Warning: R3_ERROR_MAIL is false\n";
} else {
	echo "Mail notify to " . R3_ERROR_MAIL_ADDR . " (limit to " . R3_ERROR_MAX_EMAIL . ")\n";
}

try {
    echo "Connectiong to {$dsn['dbname']} on {$dsn['dbhost']} as {$dsn['dbuser']}\n";
    $db = new PDO("{$dsn['dbtype']}:host={$dsn['dbhost']};dbname={$dsn['dbname']}", $dsn['dbuser'], $dsn['dbpass']);
	$dbInfo = $db->query("SELECT pg_catalog.shobj_description(d.oid, 'pg_database') FROM pg_catalog.pg_database d WHERE d.datname='{$dsn['dbname']}'")->fetchColumn();
	echo str_replace("\n", "; ", $dbInfo) . "\n";
} catch (PDOException $e) {
    die('Database connection faild: ' . $e->getMessage() . "\n");
}



function dirCheck($dir, array $opt=array()) {
	$opt = array_merge(array('fatal'=>false, 'create'=>false, 'writeable'=>false), $opt);
	try {
		if (!file_exists($dir)) {
			throw new exception("Directory \"{$dir}\" does not exist");
		}	
		if (!is_dir($dir)) {
			throw new exception("{$dir} is a file and not a directory");
		}
	} catch (Exception $e) {
		if ($opt['fatal']) {
			die("Fatal error: " . $e->getMessage() . "\n");
		}
		echo $e->getMessage() . "\n";
	}
	if (!file_exists($dir) && $opt['create']) {
		echo "Creating directory {$dir}\n";
		mkdir($dir);
	}
	if ($opt['writeable']) {
		chown($dir, 'root');
		chgrp($dir, 'apache');
		chmod($dir, 02770);
	}	
}

function fileCheck($file, array $opt=array()) {
	$opt = array_merge(array('fatal'=>false), $opt);
	try {
		if (!file_exists($file)) {
			throw new exception("File \"{$file}\" does not exist");
		}	
	} catch (Exception $e) {
		if ($opt['fatal']) {
			die("Fatal error: " . $e->getMessage() . "\n");
		}
		echo $e->getMessage() . "\n";
	}
}

