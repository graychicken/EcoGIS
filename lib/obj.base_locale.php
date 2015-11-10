<?php

/**
 * Local management
 */
class R3Locale {

    /**
     * @var class|null      The language ID (Eg: 0=EN, 1=IT, 2=DE, ...);
     * @TODO                Translation table needed?
     */
    static private $R3LangID = 0;

    /**
     * Get the current language ID
     * @return integer  The language ID
     */
    static public function getLanguageID() {
        return R3Locale::$R3LangID;
    }

    /**
     * Set the laguage ID
     * @return integer  The language ID
     */
    static public function setLanguageID($langID) {
        R3Locale::$R3LangID = (int) $langID;
        return R3Locale::$R3LangID;
    }

    /**
     * Get the language code
     * @return string  The language ID
     */
    static public function getLanguageCode() {
        global $languages;

        if (isset($languages[R3Locale::$R3LangID]))
            return $languages[R3Locale::$R3LangID];
        return null;
    }

    /**
     * Get the jquery date format
     * @return string  The php date format
     */
    static public function getJQueryDateFormat() {
        global $jQueryDateFormat;

        if (isset($jQueryDateFormat[R3Locale::getLanguageCode()]))
            return $jQueryDateFormat[R3Locale::getLanguageCode()];
        return null;
    }

    /**
     * Get the php date format
     * @return string  The php date format
     */
    static public function getPhpDateFormat() {
        global $phpDateFormat;

        if (isset($phpDateFormat[R3Locale::getLanguageCode()]))
            return $phpDateFormat[R3Locale::getLanguageCode()];
        return null;
    }

    /**
     * Get the php date format
     * @return string  The php date format
     */
    static public function getPhpDateTimeFormat() {
        global $phpDateTimeFormat;

        if (isset($phpDateTimeFormat[R3Locale::getLanguageCode()]))
            return $phpDateTimeFormat[R3Locale::getLanguageCode()];
        return null;
    }

    static public function getDateSeparator() {
        $fmt = R3Locale::getPhpDateFormat();
        if ($fmt == '')
            return null;
        return $fmt[1];
    }

    /**
     * Convert the given data (float and ineger) into php data
     */
    static function convert2PHP($data, $useThousandsSep = true) {
        if (is_array($data)) {
            foreach ($data as $key => $val)
                $data[$key] = R3Locale::convert2PHP($val, $useThousandsSep);
        } else {
            if (is_string($data) === true && is_numeric($data) === true) {
                if (strpos($data, '.') === false) {
                    $data = (int) $data;
                } else {
                    $data = (float) $data;
                }
            }
        }
        return $data;
    }

}
