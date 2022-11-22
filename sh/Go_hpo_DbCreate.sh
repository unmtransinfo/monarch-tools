#!/bin/sh
#############################################################################
#
#set -e
#set -x
#
DB="hpo"
#
DATADIR="data"
#
#
echo "hpo_id,umls_concept" \
	>data/hp2umls_cui.csv
#
csv_utils.py \
	--i data/hp2umls.csv \
	--coltags "ui,concepts" \
	--subsetcols \
	|sed -e '1d' \
	|perl -ne 's/[\n\r]//g; @f=split(/,/,$_); @cs=split(/;/,$f[1]); foreach $c (@cs) { print "$f[0],$c\n" }' \
	|sort -u \
	|grep -v "NONE" \
	>>data/hp2umls_cui.csv
#
###
#Also get xrefs from hp.obo.
echo "hpo_id,src,xref" \
	>data/hp_xref.csv
csv_utils.py \
	--i data/hp.csv \
	--coltags 'id,xref' \
	--subsetcols \
	|sed -e '1d' \
	|perl -ne 's/[\n\r]//g; @f=split(/,/,$_); @cs=split(/;/,$f[1]); foreach $c (@cs) { $c=~s/"//g; $c=~s/^\s*(\S+)\s.*$/$1/; $c=~s/:/,/; print "$f[0],$c\n" }' \
	>>data/hp_xref.csv
#
#
#
createdb $DB
#
psql -d $DB -c "COMMENT ON DATABASE $DB IS 'IDG-KMC dev db: HPO (Human Phenotype Ontology)'"
#
csvfiles="\
${DATADIR}/hp.csv \
${DATADIR}/hp2umls_cui.csv \
${DATADIR}/hp_xref.csv \
${DATADIR}/umls-atoms-selected.csv"
#
for csvfile in $csvfiles ; do
	#
	csv2sql.py --i $csvfile --create --fixtags --maxchar 4096 |psql -d $DB
	csv2sql.py --i $csvfile --insert --fixtags --maxchar 4096 |psql -q -d $DB
	#
done
#
psql -d $DB -c "ALTER TABLE umls_atoms_selected RENAME TO umls_atoms"
#
