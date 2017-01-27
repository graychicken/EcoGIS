<?php

/**
 * View definition
 */
class R3EcoGisCustomerViewDef {

    static private $viewDef = array(
        'building' => array(
            'sql' => "SELECT bu_id, bu_code, bu_name_1, bu_name_2, bt_id, fr_id, st_id, bu_nr_civic, bu_nr_civic_crossed, bu_build_year,
                             bu_area, bu_area_heating, bu_descr_1, bu_descr_2, bu_sheet, bu_sub, bu_part, bu_audit_type,
                             bpu_id, bby_id, bry_id, bu_restructure_descr_1, bu_restructure_descr_2, ec_code, et_code, bu_survey_date, bu_glass_area,
                             bu_usage_h_from, bu_usage_h_to, bu_usage_days, bu_usage_weeks, ec_id, bu_persons, bu_sv_factor, bu_to_check,
                             mu_id, ST_SetSRID(the_geom, <SRID>) AS the_geom, ez_id, cm_id, cm_number, ecl_id
                      FROM <ECOGIS-SCHEMA>.building_data
                      WHERE do_id=<DOMAIN-ID>",
            'desc' => "Building standard table (Autogenerated)",
            'geo' => array('col' => 'the_geom', 'dim' => 2, 'type' => 'MULTIPOLYGON')),
        'street_lighting' => array(
            'sql' => "SELECT sl_id, mu_id, st_id, st_name_1, st_name_2, sl_descr_1, sl_descr_2, sl_full_name_1, sl_full_name_2, ST_SetSRID(sl.the_geom, <SRID>) AS the_geom
                      FROM <ECOGIS-SCHEMA>.street_lighting_data sl
                      WHERE has_geometry IS TRUE AND do_id=<DOMAIN-ID>",
            'desc' => "Street lighting standard table (Autogenerated)",
            'geo' => array('col' => 'the_geom', 'dim' => 2, 'type' => 'MULTIPOLYGON')),
        'global_subcategory' => array('sql' => "SELECT gs_id, ge_id, mu_id, ge_year, ge_name_1, ge_name_2,
                                                gc_code_main, gc_name_1_main, gc_name_2_main,
                                                gc_code, gc_name_1, gc_name_2,                                                 
                                                gs_name_1 || ' - ' || gc_name_1 AS gs_name_full_1, 
                                                gs_name_2 || ' - ' || gc_name_2 AS gs_name_full_2, 
                                                gs_name_1, gs_name_2, 
                                        ST_SetSRID(gs.the_geom, <SRID>) AS the_geom
                                      FROM <ECOGIS-SCHEMA>.global_subcategory_data gs
                                      WHERE has_geometry IS TRUE AND do_id=<DOMAIN-ID>",
            'desc' => "PAES standard table (Autogenerated)",
            'geo' => array('col' => 'the_geom', 'dim' => 2, 'type' => 'MULTIPOLYGON')),
        'fraction' => array('sql' => "SELECT fr_id, fr.mu_id, mu_istat, fr_code, fr_name_1, fr_name_2, CASE fr_visible WHEN TRUE THEN 'T' WHEN FALSE THEN 'F' END AS fr_visible, ST_SetSRID(fr.the_geom, <SRID>) AS the_geom
                                      FROM <COMMON-SCHEMA>.fraction fr 
                                      INNER JOIN <ECOGIS-SCHEMA>.municipality mu ON fr.mu_id=mu.mu_id 
                                      WHERE mu.do_id=<DOMAIN-ID>",
            'desc' => "Fraction standard table (Autogenerated)",
            'geo' => array('col' => 'the_geom', 'dim' => 2, 'type' => 'MULTILINESTRING')),
        'street' => array('sql' => "SELECT st_id, st.mu_id, mu_istat, st_code, st_name_1, st_name_2, st_lkp_name_1, st_lkp_name_2, CASE st_visible WHEN TRUE THEN 'T' WHEN FALSE THEN 'F' END AS st_visible, ST_SetSRID(st.the_geom, <SRID>) AS the_geom
                                      FROM <COMMON-SCHEMA>.street st
                                      INNER JOIN <ECOGIS-SCHEMA>.municipality mu ON st.mu_id=mu.mu_id
                                      WHERE mu.do_id=<DOMAIN-ID>",
            'desc' => "Street standard table (Autogenerated)",
            'geo' => array('col' => 'the_geom', 'dim' => 2, 'type' => 'MULTILINESTRING')),
        'municipality' => array('sql' => "SELECT mu_id, mu_istat, CASE WHEN do_id=<DOMAIN-ID> THEN TRUE ELSE FALSE END AS mu_selected,  mu_name_1, mu_name_2, st_transform(mu.the_geom, <SRID>) AS the_geom
                                  FROM <ECOGIS-SCHEMA>.municipality mu",
            'desc' => "Municipality-border standard table (Autogenerated)",
            'geo' => array('col' => 'the_geom', 'dim' => 2, 'type' => 'POLYGON')),
        'stat_grid' => array(
            'sql' => "SELECT gid, gr.mu_id, mu_istat, sg_size, sg_area, ST_SetSRID(gr.the_geom, <SRID>) AS the_geom
                      FROM <ECOGIS-SCHEMA>.stat_grid gr
                      INNER JOIN <ECOGIS-SCHEMA>.municipality mu ON gr.mu_id=mu.mu_id
                      WHERE do_id=<DOMAIN-ID>",
            'desc' => "Stat-grid table (Autogenerated)",
            'geo' => array('col' => 'the_geom', 'dim' => 2, 'type' => 'MULTIPOLYGON')),
        'consumption_year_stats' => array('sql' => "SELECT co_year, et_code, co_value_kwh, co_value_spec_kwh, co_value_tep, co_value_spec_tep, 
                                                       co_value_co2, co_value_spec_co2, em_is_production, emo_code, em_object_id, mu_id, 
                                                       ST_SetSRID(the_geom, <SRID>) AS the_geom
                                                FROM <ECOGIS-SCHEMA>.consumption_year_stats
                                                WHERE do_id=<DOMAIN-ID>",
            'desc' => "Statistics standard table (Autogenerated)",
            'geo' => array('col' => 'the_geom', 'dim' => 2, 'type' => 'MULTIPOLYGON')),
        '<ECOGIS-SCHEMA>.consumption_year' => array(
            'sql' => "SELECT consumption.co_id, consumption.em_id, date_part('year'::text, consumption.co_start_date) + nyear.nyear::double precision AS co_year, 
                             CASE WHEN nyear.nyear > 0 THEN to_date(((date_part('year'::text, consumption.co_start_date) + nyear.nyear::double precision)::text) || '-01-01'::text, 'YYYY-MM-DD'::text)
                             ELSE consumption.co_start_date END AS co_start_date, 
                             CASE WHEN (date_part('year'::text, consumption.co_start_date) + nyear.nyear::double precision) < date_part('year'::text, consumption.co_end_date) THEN to_date(((date_part('year'::text, consumption.co_start_date) + nyear.nyear::double precision)::text) || '-12-31'::text, 'YYYY-MM-DD'::text)
                             ELSE consumption.co_end_date END AS co_end_date, 
                             CASE WHEN (date_part('year'::text, consumption.co_start_date) + nyear.nyear::double precision) < date_part('year'::text, consumption.co_end_date) THEN to_date(((date_part('year'::text, consumption.co_start_date) + nyear.nyear::double precision)::text) || '-12-31'::text, 'YYYY-MM-DD'::text)
                             ELSE consumption.co_end_date END - 
                             CASE WHEN nyear.nyear > 0 THEN to_date(((date_part('year'::text, consumption.co_start_date) + nyear.nyear::double precision)::text) || '-01-01'::text, 'YYYY-MM-DD'::text)
                             ELSE consumption.co_start_date END + 1 AS co_days, 
                             consumption.co_end_date - consumption.co_start_date + 1 AS co_tot_days, consumption.co_value / (consumption.co_end_date - consumption.co_start_date + 1)::double precision * (
                             CASE WHEN (date_part('year'::text, consumption.co_start_date) + nyear.nyear::double precision) < date_part('year'::text, consumption.co_end_date) THEN to_date(((date_part('year'::text, consumption.co_start_date) + nyear.nyear::double precision)::text) || '-12-31'::text, 'YYYY-MM-DD'::text)
                             ELSE consumption.co_end_date END - 
                             CASE WHEN nyear.nyear > 0 THEN to_date(((date_part('year'::text, consumption.co_start_date) + nyear.nyear::double precision)::text) || '-01-01'::text, 'YYYY-MM-DD'::text)
                             ELSE consumption.co_start_date END + 1)::double precision AS co_value
                      FROM ecogis.consumption
                      CROSS JOIN generate_series(0, <CONSUMPTION-SEQUENCE-DURATION>) nyear(nyear)
                      WHERE (date_part('year'::text, consumption.co_start_date) + nyear.nyear::double precision) <= date_part('year'::text, consumption.co_end_date);",
            'desc' => "Consumption/year data (Autogenerated)",
            'dependency_view' => array('<ECOGIS-SCHEMA>.consumption_year_building', '<ECOGIS-SCHEMA>.consumption_year_street_lighting')),
        '<ECOGIS-SCHEMA>.consumption_year_building' => array(
            'sql' => "SELECT co_year_no_group.mu_id, co_year_no_group.bu_id, co_year_no_group.bu_name_1, co_year_no_group.bu_name_2, co_year_no_group.co_year, co_year_no_group.gc_id, co_year_no_group.ges_id, sum(co_year_no_group.co_value * co_year_no_group.esu_kwh_factor) AS co_value_kwh, sum(co_year_no_group.co_value * co_year_no_group.esu_co2_factor) AS co_value_co2, co_year_no_group.em_is_production, co_year_no_group.the_geom
                      FROM (
                        SELECT bu.mu_id, bu.bu_id, bu.bu_name_1, bu.bu_name_2, co.co_year, COALESCE(esu1.gc_id, bpu.gc_id, esu2.gc_id) AS gc_id, COALESCE(esu1.ges_id, esu2.ges_id) AS ges_id, co.co_value, COALESCE(esu1.esu_kwh_factor, esu2.esu_kwh_factor) AS esu_kwh_factor, COALESCE(esu1.esu_co2_factor, esu2.esu_co2_factor) AS esu_co2_factor, em.em_is_production, bu.the_geom
                        FROM ecogis.consumption_year co
                        JOIN ecogis.energy_meter em ON em.em_id = co.em_id
                        JOIN ecogis.energy_meter_object emo ON em.emo_id = emo.emo_id AND emo.emo_code::text = 'BUILDING'::text
                        JOIN ecogis.building bu ON bu.bu_id = em.em_object_id
                        JOIN ecogis.building_purpose_use bpu ON bu.bpu_id = bpu.bpu_id
                        LEFT JOIN ecogis.energy_source_udm esu1 ON em.esu_id = esu1.esu_id
                        LEFT JOIN (ecogis.utility_product up
                        JOIN ecogis.energy_source_udm esu2 ON up.esu_id = esu2.esu_id) ON em.up_id = up.up_id) co_year_no_group
                      GROUP BY co_year_no_group.mu_id, co_year_no_group.bu_id, co_year_no_group.bu_name_1, co_year_no_group.bu_name_2, co_year_no_group.co_year, co_year_no_group.gc_id, co_year_no_group.ges_id, co_year_no_group.em_is_production, co_year_no_group.the_geom",
            'desc' => "Building consumption/year data (Autogenerated)"),
        '<ECOGIS-SCHEMA>.consumption_year_street_lighting' => array(
            'sql' => "SELECT st.mu_id, sl.sl_id, 
                             CASE WHEN sl.sl_descr_1 IS NULL THEN st.st_name_1::text
                             ELSE (st.st_name_1::text || ' - '::text) || sl.sl_descr_1::text END AS sl_full_name_1, 
                             CASE WHEN sl.sl_descr_2 IS NULL THEN st.st_name_2::text
                             ELSE (st.st_name_2::text || ' - '::text) || sl.sl_descr_2::text END AS sl_full_name_2, 
                             co.co_year, gc.gc_id, esu.ges_id, sum(co.co_value * esu.esu_kwh_factor) AS co_value_kwh, sum(co.co_value * esu.esu_co2_factor) AS co_value_co2, em.em_is_production, sl.the_geom
                      FROM ecogis.consumption_year co
                      JOIN ecogis.energy_meter em ON em.em_id = co.em_id
                      JOIN ecogis.energy_source_udm esu ON em.esu_id = esu.esu_id
                      JOIN ecogis.energy_meter_object emo ON em.emo_id = emo.emo_id AND emo.emo_code::text = 'STREET_LIGHTING'::text
                      JOIN ecogis.street_lighting sl ON sl.sl_id = em.em_object_id
                      JOIN common.street st ON st.st_id = sl.st_id
                      JOIN ecogis.global_category gc ON gc.gc_is_street_lighting IS TRUE
                      GROUP BY st.mu_id, sl.sl_id, 
                               CASE WHEN sl.sl_descr_1 IS NULL THEN st.st_name_1::text
                               ELSE (st.st_name_1::text || ' - '::text) || sl.sl_descr_1::text END, 
                               CASE WHEN sl.sl_descr_2 IS NULL THEN st.st_name_2::text
                               ELSE (st.st_name_2::text || ' - '::text) || sl.sl_descr_2::text END, 
                               gc.gc_id, co.co_year, esu.ges_id, em.em_is_production, sl.the_geom",
            'desc' => "Street lighting consumption/year data (Autogenerated)"),
        '<ECOGIS-SCHEMA>.work_energy_source_electricity_data' => array('sql' => "SELECT esu.do_id, em.em_object_id AS bu_id, esu.esu_id, esu.es_id, es.es_name_1, es.es_name_2, esu.udm_id, udm.udm_name_1, udm.udm_name_2, ((es.es_name_1::text || ' ('::text) || udm.udm_name_1::text) || ')'::text AS esu_name_1, ((es.es_name_2::text || ' ('::text) || udm.udm_name_2::text) || ')'::text AS esu_name_2
																		 FROM <ECOGIS-SCHEMA>.energy_meter em
																		 JOIN <ECOGIS-SCHEMA>.energy_meter_object emo ON em.emo_id = emo.emo_id AND emo.emo_code::text = 'BUILDING'::text
																		 JOIN <ECOGIS-SCHEMA>.energy_source_udm esu ON em.esu_id = esu.esu_id
																		 JOIN <ECOGIS-SCHEMA>.energy_source es ON esu.es_id = es.es_id
																		 JOIN <ECOGIS-SCHEMA>.energy_type et ON es.et_id = et.et_id
																		 JOIN <ECOGIS-SCHEMA>.udm ON esu.udm_id = udm.udm_id
																		 WHERE esu.esu_is_production IS FALSE AND et.et_code::text = 'ELECTRICITY'::text
																		 GROUP BY esu.do_id, em.em_object_id, esu.esu_id, esu.es_id, es.es_name_1, es.es_name_2, esu.udm_id, udm.udm_name_1, udm.udm_name_2
																		 UNION
																		 SELECT us.do_id, em.em_object_id AS bu_id, up.esu_id, esu.es_id, us.us_name_1 AS es_name_1, us.us_name_2 AS es_name_2, esu.udm_id, udm.udm_name_1, udm.udm_name_2, ((us.us_name_1::text || ' ('::text) || udm.udm_name_1::text) || ')'::text AS esu_name_1, ((us.us_name_2::text || ' ('::text) || udm.udm_name_2::text) || ')'::text AS esu_name_2
																		 FROM <ECOGIS-SCHEMA>.energy_meter em
																		 JOIN <ECOGIS-SCHEMA>.energy_meter_object emo ON em.emo_id = emo.emo_id AND emo.emo_code::text = 'BUILDING'::text
																		 JOIN <ECOGIS-SCHEMA>.utility_product up ON em.up_id = up.up_id
																		 JOIN <ECOGIS-SCHEMA>.utility_supplier us ON up.us_id = us.us_id
																		 JOIN <ECOGIS-SCHEMA>.energy_source_udm esu ON up.esu_id = esu.esu_id
																		 JOIN <ECOGIS-SCHEMA>.energy_source es ON esu.es_id = es.es_id
																		 JOIN <ECOGIS-SCHEMA>.energy_type et ON es.et_id = et.et_id
																		 JOIN <ECOGIS-SCHEMA>.udm ON esu.udm_id = udm.udm_id
																		 WHERE esu.esu_is_production IS FALSE AND et.et_code::text = 'ELECTRICITY'::text
																		 GROUP BY us.do_id, em.em_object_id, up.esu_id, esu.es_id, us.us_name_1, us.us_name_2, esu.udm_id, udm.udm_name_1, udm.udm_name_2",
            'desc' => "Electricity energy soruce for work (Autogenerated)"),
        'edit_tmp_polygon' => array('sql' => "SELECT edit_tmp_polygon.gid, edit_tmp_polygon.session_id, ST_SetSRID(edit_tmp_polygon.the_geom, <SRID>) AS the_geom
                                              FROM <ECOGIS-SCHEMA>.edit_tmp_polygon",
            'desc' => "View to force srid on GisClient (Autogenerated)",
            'geo' => array('col' => 'the_geom', 'dim' => 2, 'type' => 'MULTIPOLYGON')),
        '<ECOGIS-SCHEMA>.global_plain_gauge_full_data' => array('sql' => "SELECT gpg.gpr_id, gpg.gpg_id, gpg_name_1, gpg_name_2, 
                                                                 gpgu_1.gpgu_name_1 AS gpgu_name_1_1, gpgu_1.gpgu_name_2 AS gpgu_name_1_2, 
                                                                 gpgu_2.gpgu_name_1 AS gpgu_name_2_1, gpgu_2.gpgu_name_1 AS gpgu_name_2_2, 
                                                                 gpg_value_1, gpg_value_2, gpg_value_3, 
                                                                 gpm_id, gpm_date, gpm_value_1, gpm_value_2,
                                                                 gpg_value_1 * (gpg_value_2 - gpm_value_2) * gpm_value_1 AS gpg_energy_variation,
                                                                 (gpg_value_1 * (gpg_value_2 - gpm_value_2) * gpm_value_1) * gpg_value_3 AS gpg_emission_variation
                                                          FROM <ECOGIS-SCHEMA>.global_plain_gauge gpg 
                                                          LEFT JOIN <ECOGIS-SCHEMA>.global_plain_gauge_udm gpgu_1 ON gpg.gpgu_id_1=gpgu_1.gpgu_id 
                                                          LEFT JOIN <ECOGIS-SCHEMA>.global_plain_gauge_udm gpgu_2 ON gpg.gpgu_id_2=gpgu_2.gpgu_id 
                                                          LEFT JOIN <ECOGIS-SCHEMA>.global_plain_monitor gpm ON gpg.gpg_id=gpm.gpg_id AND gpg.gpr_id=gpm.gpr_id",
            'desc' => "PAES monitor full data (Autogenerated)"),
        
        '<ECOGIS-SCHEMA>.heating_degree_days_data' => array(
            'sql' => "SELECT hdd_id, mu_id, mu_name_1, mu_name_2, do_id, hdd_year, hdd_factor
                      FROM <ECOGIS-SCHEMA>.heating_degree_days
                      INNER JOIN <ECOGIS-SCHEMA>.municipality USING(mu_id)",
            'desc' => "Heating degree days standard table (Autogenerated)"),
    );
    // View per multi-municipality
    static private $mmViewDef = array('toponimy' => array('sql' => "SELECT 1 AS to_priority, mu_id AS to_id, mu_istat AS to_code, 'Comune di ' || mu_name_1 AS to_name_1, 'Gemeinde ' || mu_name_2 AS to_name_2, st_boundary(st_transform(the_geom, <SRID>)) AS the_geom
                                      FROM <ECOGIS-SCHEMA>.municipality
                                      WHERE the_geom IS NOT NULL AND do_id=<DOMAIN-ID>
                                      UNION
                                      SELECT 2, fr_id, fr_code, fr_name_1 || ' - ' || mu_name_1, fr_name_2 || ' - ' || mu_name_2, st_multi(ST_SetSRID(fr.the_geom, <SRID>))
                                      FROM <COMMON-SCHEMA>.fraction fr
                                      INNER JOIN <ECOGIS-SCHEMA>.municipality mu ON fr.mu_id=mu.mu_id
                                      WHERE fr.the_geom IS NOT NULL AND mu.do_id=<DOMAIN-ID>
                                      UNION
                                      SELECT 3, st_id, st_code, COALESCE(st_lkp_name_1, st_name_1) || ' - ' || mu_name_1, COALESCE(st_lkp_name_2, st_name_2) || ' - ' || mu_name_2, st_multi(ST_SetSRID(st.the_geom, <SRID>))
                                      FROM <COMMON-SCHEMA>.street st
                                      INNER JOIN <ECOGIS-SCHEMA>.municipality mu ON st.mu_id=mu.mu_id
                                      WHERE st.the_geom IS NOT NULL AND mu.do_id=<DOMAIN-ID>
                                      ",
            'desc' => "Toponimy standard table (Autogenerated) (Municipality + fraction + street for multiple municipality installation)",
            'multimunicipality_only' => true, // Create the view only on multi-domain installation
            'geo' => array('col' => 'the_geom', 'dim' => 2, 'type' => 'MULTILINESTRING')));
    // View per single-municipality
    static private $smViewDef = array('toponimy' => array('sql' => "
                                      SELECT 2 AS to_priority, fr_id AS to_id, fr_code AS to_code, fr_name_1 AS to_name_1, fr_name_2 AS to_name_2, st_multi(ST_SetSRID(fr.the_geom, <SRID>)) AS the_geom
                                      FROM <COMMON-SCHEMA>.fraction fr
                                      INNER JOIN <ECOGIS-SCHEMA>.municipality mu ON fr.mu_id=mu.mu_id
                                      WHERE fr.the_geom IS NOT NULL AND mu.do_id=<DOMAIN-ID>
                                      UNION
                                      SELECT 3, st_id, st_code, COALESCE(st_lkp_name_1, st_name_1), COALESCE(st_lkp_name_2, st_name_2), st_multi(ST_SetSRID(st.the_geom, <SRID>))
                                      FROM <COMMON-SCHEMA>.street st
                                      INNER JOIN <ECOGIS-SCHEMA>.municipality mu ON st.mu_id=mu.mu_id
                                      WHERE st.the_geom IS NOT NULL AND mu.do_id=<DOMAIN-ID>
                                      ",
            'desc' => "Toponimy standard table (Autogenerated) (Fraction + street for single municipality installation)",
            'multimunicipality_only' => true, // Create the view only on multi-domain installation
            'geo' => array('col' => 'the_geom', 'dim' => 2, 'type' => 'MULTILINESTRING')));

    static public function getViewsDef() {
        return R3EcoGisCustomerViewDef::$viewDef;
    }

    static public function getMultiMunicipalityViewsDef() {
        return R3EcoGisCustomerViewDef::$mmViewDef;
    }

    static public function getSingleMunicipalityViewsDef() {
        return R3EcoGisCustomerViewDef::$smViewDef;
    }

}
