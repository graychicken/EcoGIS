-- Add statistic permission
INSERT INTO auth.acnames (ac_verb, ac_name, app_id, ac_mod_user) VALUES ('SHOW', 'STATISTIC', (SELECT app_id FROM auth.applications WHERE app_code='ECOGIS2'), 0);
INSERT INTO auth.groups_acl (gr_id, ac_id, ga_kind)
SELECT gr_id, (SELECT ac_id FROM auth.acnames WHERE ac_name = 'STATISTIC' AND ac_verb = 'SHOW' AND app_id=(SELECT app_id FROM auth.applications WHERE app_code='ECOGIS2')), 'A'
FROM (
	SELECT gr_id
	FROM auth.groups
	WHERE groups.app_id = (SELECT app_id FROM auth.applications WHERE app_code='ECOGIS2')
	
) AS foo;

-- Add heating degree days table
CREATE TABLE ecogis.heating_degree_days (
  hdd_id SERIAL,
  mu_id integer not null,
  hdd_year INTEGER NOT NULL,
  hdd_factor DOUBLE PRECISION NOT NULL,
  CONSTRAINT heating_degree_days_pkey PRIMARY KEY(hdd_id)
);
CREATE UNIQUE INDEX heating_degree_days_idx ON ecogis.heating_degree_days USING btree (mu_id, hdd_year);
ALTER TABLE ecogis.heating_degree_days ADD CONSTRAINT heating_degree_days_fk FOREIGN KEY (mu_id) REFERENCES ecogis.municipality(mu_id) ON DELETE NO ACTION ON UPDATE NO ACTION NOT DEFERRABLE;

