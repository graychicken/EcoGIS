<?php

namespace EcogisBundle\Command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use ezcDbFactory;
use ezcDbInstance;

$autoinit = false;
require_once __DIR__.'/../../../etc/config.php';
require_once R3_LIB_DIR.'r3dbini.php';
require_once R3_LIB_DIR.'r3auth.php';
require_once R3_LIB_DIR.'r3auth_manager.php';
require_once R3_LIB_DIR.'r3export_paes.php';
require_once R3_LIB_DIR.'obj.base.php';
require_once R3_LIB_DIR.'r3locale.php';
require_once R3_LIB_DIR.'global_result_table_helper.php';
require_once R3_CLASS_DIR.'obj.global_plain_table.php';
require_once R3_CLASS_DIR.'obj.global_strategy.php';

//require_once R3_LIB_DIR.'obj.base_locale.php';
//require_once R3_CLASS_DIR . 'obj.global_result_table.php';
//        require_once R3_CLASS_DIR . 'obj.global_plain_table.php';

ExportSeapCommand::setDsn($dsn);
ExportSeapCommand::setAuthOptions($auth_options);
ExportSeapCommand::setLanguageSettings($languages, $jQueryDateFormat, $phpDateFormat, $phpDateTimeFormat);

class ExportSeapCommand extends Command
{
    static $dsn;
    static $authOptions;

    protected function configure()
    {
        $this
            ->setName('ecogis:export-seap')
            ->setDescription('Export a SEAP')
            ->setHelp("Export the SEAP")
            ->addOption('id', null, InputOption::VALUE_REQUIRED, 'Global strategy ID')
            ->addOption('domain', null, InputOption::VALUE_REQUIRED, 'Domain name')
            ->addOption('user', null, InputOption::VALUE_REQUIRED, 'User login')
            ->addOption('lang', null, InputOption::VALUE_REQUIRED, 'Language code')
            ;
    }

    public static function setDsn($dsn)
    {
        self::$dsn = $dsn;
    }

    public static function setAuthOptions($authOptions)
    {
        self::$authOptions = $authOptions;
    }

    public function setLanguageSettings($languages, $jQueryDateFormat, $phpDateFormat, $phpDateTimeFormat) {
        \R3Locale::setLanguages($languages);
        //echo "[$languages, $jQueryDateFormat, $phpDateFormat, $phpDateTimeFormat]";
        //die;
        /*\R3Locale::getLanguageCode();
        echo "[$langCode]";
        die;
        $languages = array(1 => 'it', 2 => 'de');
        $jQueryDateFormat = array('it' => 'dd/mm/yy', 'de' => 'dd.mm.yy');
        $phpDateFormat = array('it' => 'd/m/Y', 'de' => 'd.m.Y');
        $phpDateTimeFormat = array('it' => 'd/m/Y H:i:s', 'de' => 'd.m.Y H:i:s');*/
    }

    protected function dbConnect()
    {
        $txtDsn = self::$dsn['dbtype'].'://'.self::$dsn['dbuser'].':'.self::$dsn['dbpass'].'@'.self::$dsn['dbhost'].'/'.self::$dsn['dbname'];
        try {
            $db = ezcDbFactory::create($txtDsn);
            $db->setAttribute(\PDO::ATTR_ERRMODE, \PDO::ERRMODE_EXCEPTION);
            if (isset($dsn['charset'])) {
                $db->exec("SET client_encoding TO '{$dsn['charset']}'");
            }
            if (isset($dsn['search_path'])) {
                $db->exec("SET search_path TO {$dsn['search_path']}, public");
            }
            $db->exec("SET datestyle TO ISO");
            ezcDbInstance::set($db);
        } catch (\PDOException $e) {
            throw new \Exception("Error connecting to database {$dsn['dbname']} on  {$dsn['dbhost']} as  {$dsn['dbuser']}: {$e->getMessage()}");
        }
    }

    protected function authLogin($user, $domain) {
        $db = ezcDbInstance::get();
        $auth = new \R3AuthManager($db, self::$authOptions, APPLICATION_CODE);
        $somain = strtoupper($domain);
        $isAuth = $auth->performTrustLoginAsUser($user, $domain);
        if (!$isAuth) {
            throw new \Exception("Trust authentication error for user {$user}@{$domain} ");
        }

        $auth = \R3AuthInstance::set($auth);
    }

    protected function execute(InputInterface $input, OutputInterface $output)
    {
error_reporting(E_ALL);
        $this->dbConnect();
        $this->authLogin($input->getOption('user'), $input->getOption('domain'));
        $db = ezcDbInstance::get();
        $auth = \R3AuthInstance::get();
        $lang = $input->getOption('lang');
        \R3Locale::setLanguageIDFromCode($lang);
        $_SESSION['do_id'] = $auth->getDomainID();

        /* $db = ezcDbInstance::get();


          //$res1 = $auth->performLogin('admin', 'Fuck!', 'MERANO');
          $res1 = $auth->performTrustLoginAsUser('admin', 'MERANO');
          var_dump($res1);
          $res2 = $auth->isAuth();
          var_dump($res2);
          print_r($auth->getAllConfigValues());

          die; */




        //set_time_limit(5 * 60);
        //ini_set('memory_limit', '2G');
        //ignore_user_abort(true);


        $id = (int) $input->getOption('id');
        $driverInfo = $auth->getConfigValue('APPLICATION', 'EXPORT_PAES', array());
        if (!isset($driverInfo[$lang]['driver'])) {
            throw new \Exception(_("Invalid driver \"{$lang}\""));
        }
        $exportDriverName = $driverInfo[$lang]['driver'];

        $exportDriverParams = isset($driverInfo[$lang]['params']) ? $driverInfo[$lang]['params'] : null;
        $exportDriver = \R3ExportPAES::factory($exportDriverName, $auth, $exportDriverParams);

        $sql = "SELECT * FROM ecogis.global_strategy_data WHERE gst_id={$id}";
        $globalStrategyData['general'] = $db->query($sql)->fetch(\PDO::FETCH_ASSOC);
        if (empty($globalStrategyData['general'])) {
            throw new \Exception("Global strategy {$id} not found");
        }

        // SHEET 1: General data
        $globalStrategyData['general']['gst_reduction_target_text'] = $globalStrategyData['general']['gst_reduction_target_absolute'] ? _('Riduzione assoluta') : _('Riduzione "pro capite"');
        $budgetEuro = $globalStrategyData['general']['gst_budget'] == '' ? '' : '€' . R3NumberFormat($globalStrategyData['general']['gst_budget'], 2, true);
        if ($globalStrategyData['general']['gst_budget_text_1'] <> '' && $globalStrategyData['general']['gst_budget'] <> '') {
            $globalStrategyData['general']['gst_budget_text_1'] = sprintf('%s - %s', $budgetEuro, $globalStrategyData['general']['gst_budget_text_1']);
        } else {
            $globalStrategyData['general']['gst_budget_text_1'] = $budgetEuro . $globalStrategyData['general']['gst_budget_text_1'];
        }
        if ($globalStrategyData['general']['gst_budget_text_2'] <> '' && $globalStrategyData['general']['gst_budget'] <> '') {
            $globalStrategyData['general']['gst_budget_text_2'] = sprintf('%s - %s', $budgetEuro, $globalStrategyData['general']['gst_budget_text_2']);
        } else {
            $globalStrategyData['general']['gst_budget_text_2'] = $budgetEuro . $globalStrategyData['general']['gst_budget_text_2'];
        }

        // SHEET 4: Global plain data
        $gpId = (int)$globalStrategyData['general']['gp_id'];
        $sql = "SELECT *
                FROM ecogis.global_plain_data
                WHERE gp_id={$gpId}";
        $actionPlanData['general'] = $db->query($sql)->fetch(\PDO::FETCH_ASSOC);
        if (isset($actionPlanData['general']['gp_approval_date'])) {
            $actionPlanData['general']['gp_approval_date'] = ' ' . SQLDateToStr($actionPlanData['general']['gp_approval_date'], 'd/m/Y');
        }


        // SHEET 2 AND 3: EMISSION INVENTORY
        $udmDivider = 1000;  // MWh (in db data are stored in kWh)
        $inventoryTableKinds = array('CONSUMPTION', 'EMISSION', 'ENERGY_PRODUCTION', 'HEATH_PRODUCTION');
        $emissionInventoryData = array();
        for ($i = 1; $i <= 2; $i++) {
            $geId = $i == 1 ? (int)$globalStrategyData['general']['ge_id'] : (int)$globalStrategyData['general']['ge_id_2'];
            if ($geId > 0) {
                $sql = "SELECT *, ge_green_electricity_purchase/1000 AS ge_green_electricity_purchase
                        FROM ecogis.global_entry_data
                        WHERE ge_id={$geId}";
                $emissionInventoryData[$i]['general'] = $db->query($sql)->fetch(\PDO::FETCH_ASSOC);
                $emissionInventoryData[$i]['general']['gst_emission_factor_text'] = $globalStrategyData['general']['gst_emission_factor_type_ipcc'] ? _('Fattori di emissione standard in linea con i principi IPCC') : _('Fattori LCA (valutazione del ciclo di vita)');
                $emissionInventoryData[$i]['general']['gst_emission_unit_text'] = $globalStrategyData['general']['gst_emission_unit_co2'] ? _('Emissioni di CO2') : _('Emissioni equivalenti di CO2');
                foreach ($inventoryTableKinds as $kind) {
                    $emissionInventoryData[$i][$kind]['header'] = \R3EcoGisGlobalTableHelper::getParameterList($kind, array('show_udm' => true));
                    $emissionInventoryData[$i][$kind]['rows'] = \R3EcoGisGlobalTableHelper::getCategoriesData($geId, $kind, $udmDivider);
                }
            }
        }

        $opt = array();
        // Add template (if present)
        for ($i = 1; $i <= 2; $i++) {
            if (isset($emissionInventoryData[$i])) {
                $opt["EMISSION_INVENTORY_{$i}"] = $emissionInventoryData[$i];
            }
        }
        // Add global plain data 8if present)
        if ($globalStrategyData['general']['gp_id'] <> '') {
            $opt['GLOBAL_PLAN'] = \R3EcoGisGlobalPlainTableHelper::getData($auth->getDomainID(), $globalStrategyData['general']['gp_id']);
        }
        // Add metadata
        $opt['METADATA'] = array('creator' => $auth->getUserName(),
            'title' => _('TEMPLATE') . ' - ' . _('POWER BY R3-EcoGIS 2')
        );
        // Rename sheet names
        $opt['SHEET-NAME'] = array('GENERAL' => _('Strategia generale'),
            'EMISSION_INVENTORY_1' => _('Inventario base emissioni (1)'),
            'EMISSION_INVENTORY_2' => _('Inventario base emissioni (2)'),
            'ACTION_PLAN' => _("Piano d'azione SEAP")
        );

        $ext = '.' . (isset($driverInfo[$lang]['output_format']) ? $driverInfo[$lang]['output_format'] : 'xlsx');
        $fileName = R3_TMP_DIR . date('YmdHis') . '.' . md5(time()) . $ext;
        $opt['GENERAL'] = $globalStrategyData;
        $opt['ACTION_PLAN'] = $actionPlanData;
        $opt['logger'] = new \R3ExportLogger();

        $exportDriver->export($fileName, R3_SMARTY_TEMPLATE_DIR_DOC . $driverInfo[$lang]['template'], $opt);

        //$httpFileName = basename($fileName);
        //$url = "getfile.php?type=tmp&file={$httpFileName}&disposition=download&name=PAES_" . date('Y-m-d') . $ext;
        //return array('status' => R3_AJAX_NO_ERROR,
//            'url' => $url);



        /*
          https://ecogis-dev-ss.r3-gis.com/admin/edit.php?on=global_strategy&id=1005&driver=it&method=exportPAES


        

        

        

        


         */
    }
}