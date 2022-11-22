#!/bin/sh
#############################################################################
# UI is the Atom ID.
#############################################################################
#
DB="hpo"
#
DATADIR="data"
#
#
srcs="ICD9CM ICD10CM MDR MSH SNOMEDCT_US"
#
#	(psql -qAF ',' -d $DB <<__EOF__
for src in $srcs ; do
	#
	csvfile="${DATADIR}/hp2umls_${src}.csv"
	echo "HPO_to_${src}: ${csvfile} ..."
	(psql -d $DB <<__EOF__
--
COPY (SELECT
	hp.id,
	hp.name AS "hp_name",
	uas.concept,
	uas.ui,
	uas.code,
	uas.termtype
FROM
	hp,
	hp2umls_cui hp2u,
	umls_atoms_selected uas
WHERE
	uas.rootsource = '${src}'
	AND hp.id = hp2u.hpo_id
	AND hp2u.umls_concept = uas.concept
ORDER BY
	hp.id
) TO STDOUT
WITH (FORMAT CSV, HEADER, DELIMITER ',', QUOTE '"', FORCE_QUOTE (hp_name))
__EOF__
	) \
	>${csvfile}
	#
	n_row=`cat $csvfile |sed -e '1d' |wc -l`
	printf "%s rows: %d\n" $csvfile $n_row
	#
done
#
