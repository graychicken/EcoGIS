<?php

class eco_building_statistic extends R3AppBaseObject
{

    public function __construct(array $request = array(), array $opt = array())
    {
        parent::__construct($request, $opt);

        $this->act = initVar('act', 'show');
        $this->tab_mode = initVar('tab_mode');
        $this->bu_id = PageVar('bu_id');
        $this->parent_act = PageVar('parent_act');
        $this->kind = strtoupper(PageVar('kind'));
        setLang(R3Locale::getLanguageCode());
        setLangInfo(array('thousands_sep' => "."));
    }

    public function getPageTitle()
    {
        
    }

    public function getListSQL()
    {
        
    }

    public function createListTableHeader(&$order)
    {
        
    }

    /**
     * Return the data for a single customer 
     */
    public function getData($id = null)
    {
        $id = (int) $this->bu_id;
        $db = ezcDbInstance::get();

        // Close session (to allow other tab to be loaded)
        session_write_close();

        // Has heating degree days
        $data = R3EcoGisHelper::getBuildingData($this->bu_id);
        $this->mu_id = $data['mu_id'];

        $heating2label = array();
        $sql = "SELECT COUNT(*)
                FROM ecogis.heating_degree_days WHERE mu_id={$this->mu_id}";
        $hasHeatingDegreeDay = $db->query($sql)->fetchColumn() > 0;

        $lang = R3Locale::getLanguageID();

        $sql = "SELECT array_to_string(array_agg(us_name_{$lang}),' / ') AS us_name_heating
                FROM ecogis.utility_supplier
                INNER JOIN ecogis.utility_supplier_municipality USING (us_id)
                INNER JOIN ecogis.utility_product ON utility_supplier.us_id=utility_product.us_id AND up_code='DISTRICT_HEATING'
                WHERE mu_id={$this->mu_id}";
        $heating2label = $db->query($sql)->fetchColumn();

        $sql = "SELECT co_year, ROUND(heating) AS heating, ROUND(heating_gg) AS heating_gg,
                       ROUND(heating_utility) AS heating_utility, ROUND(heating_utility_gg) AS heating_utility_gg,
                       ROUND(electricity) AS electricity, ROUND(electricity_utility) AS electricity_utility,
                       ROUND(co2) AS co2, ROUND(co2_gg) AS co2_gg
                FROM ecogis.building_statistic
                WHERE bu_id={$id}
                ORDER BY co_year DESC";
        $sql = "WITH q1 AS (
                    SELECT bu.bu_id, COALESCE(street.mu_id, fraction.mu_id) AS mu_id, co.co_year,
                           COALESCE(et1.et_code, (et2.et_code::text || '_UTILITY'::text)::character varying) AS et_code,
                           co.co_value, COALESCE(esu1.esu_kwh_factor, esu2.esu_kwh_factor) AS esu_kwh_factor,
                           COALESCE(esu1.esu_co2_factor, esu2.esu_co2_factor) AS esu_co2_factor
                    FROM ecogis.consumption_year co
                    INNER JOIN ecogis.energy_meter em ON em.em_id = co.em_id
                    INNER JOIN ecogis.energy_meter_object emo ON em.emo_id = emo.emo_id AND emo.emo_code::text = 'BUILDING'::text
                    INNER JOIN ecogis.building bu ON bu.bu_id = em.em_object_id
                    INNER JOIN ecogis.building_purpose_use bpu ON bu.bpu_id = bpu.bpu_id
                    LEFT JOIN common.street USING (st_id)
                    LEFT JOIN common.fraction USING (fr_id)
                    LEFT JOIN (ecogis.energy_source_udm esu1
                        INNER JOIN ecogis.energy_source es1 ON esu1.es_id = es1.es_id
                        INNER JOIN ecogis.energy_type et1 ON es1.et_id = et1.et_id) ON em.esu_id = esu1.esu_id
                    LEFT JOIN (ecogis.utility_product up
                        INNER JOIN ecogis.energy_source_udm esu2 ON up.esu_id = esu2.esu_id
                        INNER JOIN ecogis.energy_source es2 ON esu2.es_id = es2.es_id
                        INNER JOIN ecogis.utility_supplier us2 ON up.us_id = us2.us_id
                        INNER JOIN ecogis.energy_type et2 ON es2.et_id = et2.et_id) ON em.up_id = up.up_id
                    WHERE bu_id={$id})
                SELECT q1.co_year,
                       ROUND(SUM(CASE WHEN q1.et_code='HEATING' THEN q1.co_value * q1.esu_kwh_factor ELSE NULL END)) AS heating,
                       ROUND(SUM(CASE WHEN q1.et_code='HEATING' THEN q1.co_value * q1.esu_kwh_factor * COALESCE(hdd.hdd_factor, 1) ELSE NULL END)) AS heating_gg,
                       ROUND(SUM(CASE WHEN q1.et_code='HEATING_UTILITY' THEN q1.co_value*q1.esu_kwh_factor ELSE NULL END)) AS heating_utility,
                       ROUND(SUM(CASE WHEN q1.et_code='HEATING_UTILITY' THEN q1.co_value*q1.esu_kwh_factor*COALESCE(hdd.hdd_factor, 1) ELSE NULL END)) AS heating_utility_gg,
                       ROUND(SUM(CASE WHEN q1.et_code='ELECTRICITY' THEN q1.co_value*q1.esu_kwh_factor ELSE NULL END)) AS electricity,
                       ROUND(SUM(CASE WHEN q1.et_code='ELECTRICITY_UTILITY' THEN q1.co_value*q1.esu_kwh_factor ELSE NULL END)) AS electricity_utility,
                       ROUND(SUM(q1.co_value * q1.esu_co2_factor)) AS co2,
                       ROUND(SUM(q1.co_value * q1.esu_co2_factor * COALESCE(hdd.hdd_factor, 1::double precision))) AS co2_gg
                FROM q1
                LEFT JOIN ecogis.heating_degree_days hdd ON hdd.mu_id = q1.mu_id AND hdd.hdd_year::double precision = q1.co_year
                GROUP BY q1.bu_id, q1.co_year
                ORDER BY co_year DESC";
        $rows = array();
        foreach($db->query($sql, PDO::FETCH_ASSOC) as $row) {
            foreach(array('heating', 'heating_gg', 'heating_utility', 'heating_utility_gg', 'electricity',
                          'electricity_utility', 'co2', 'co2_gg') as $field) {
                $row["{$field}_fmt"] = R3NumberFormat($row[$field], null, true);
            }
            $rows[$row['co_year']] = $row;
        }
        $vlu = array('rows'=>$rows);
        $vlu['has_heating_degree_day'] = $hasHeatingDegreeDay;
        $vlu['heating2_label'] = $heating2label;
        return array('data' => $vlu, 'conversion_factor' => $conversionFactors, 'has_non_standard_factor' => $hasNonStandardFactor);
    }

    public function getPageVars()
    {
        return array(
            'tab_mode' => $this->tab_mode,
            'bu_id' => $this->bu_id,
            'parent_act' => $this->parent_act,
            'kind' => $this->kind,
        );
    }

    public function getJSFiles()
    {
        if (defined('R3_SINGLE_JS') && R3_SINGLE_JS === true) {
            return array();
        }
        return $this->includeJS($this->baseName.'.js', false); // inline js
    }

    public function getTemplateName()
    {
        return 'building_statistic.tpl';
    }

    public function checkPerm()
    {
        $act = 'SHOW';
        $name = 'STATISTIC';
        if (!$this->auth->hasPerm($act, $name)) {
            die(sprintf(_("PERMISSION DENIED [%s/%s]"), $act, $name));
        }
        R3Security::checkBuilding($this->bu_id);
    }
}