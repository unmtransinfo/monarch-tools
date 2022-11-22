#!/bin/sh
#############################################################################
### https://monarchinitiative.org/page/services
#############################################################################
#
set -x
#
runsql_mysql.sh -n tcrd -h juniper.health.unm.edu \
	-t -f ../sql/targets_idg2.sql \
	>data/tcrd_targets_idg2.tsv
#
###
csv_utils.py \
	--i data/tcrd_targets_idg2.tsv --tsv \
	--coltag "geneid" --extractcol \
	|sort -nu \
	>data/tcrd_targets_idg2.geneid
#
n_genes=`cat data/tcrd_targets_idg2.geneid |wc -l`
#
printf "N_genes = %d\n" $n_genes
#
###
#
cat data/tcrd_targets_idg2.geneid \
	|sed -e 's/^/NCBIGene:/' \
	>data/tcrd_targets_idg2.monarch_ids
#
monarch_query.py \
	--vv \
	--get_gene \
	--idfile data/tcrd_targets_idg2.monarch_ids \
	--o data/tcrd_targets_idg2_monarch.csv
#
###
#Monarch-compare genes with diseases, via high-level EPO phenotypes.
#
#"HP:0005978","Type II diabetes mellitus"
#"HP:0003003","Colon cancer"
#"HP:0007302","Bipolar affective disorder"
#"HP:0100279","Ulcerative colitis"
#"HP:0001909","Leukemia"
#
dids="\
HP:0005978 \
HP:0003003 \
HP:0007302 \
HP:0100279 \
HP:0001909"
#
#Test:
monarch_query.py --vv --compare --id "NCBIGene:785" --idBs "HP:0005978"
#
ofile="data/tcrd_targets_idg2_monarch_compare.csv"
rm -f $ofile
touch $ofile
#
for did in $dids ; do
	monarch_query.py \
		--v \
		--compare \
		--idfile data/tcrd_targets_idg2.monarch_ids \
		--idBs "$did" \
		>>$ofile
done
#
