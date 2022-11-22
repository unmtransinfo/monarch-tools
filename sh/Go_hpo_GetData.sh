#!/bin/sh
#############################################################################
### https://www.nlm.nih.gov/research/umls/knowledge_sources/metathesaurus/release/abbreviations.html
### Some UMLS term types:
### 
###  CE : Entry term for a Supplementary Concept
###  ET : Entry term
###  FN : Full form of descriptor
###  HG : High Level Group Term
###  HT : Hierarchical term
###  LLT : Lower Level Term
###  MH : Main heading
###  MTH_FN : MTH Full form of descriptor
###  MTH_HG : MTH High Level Group Term
###  MTH_HT : MTH Hierarchical term
###  MTH_LLT : MTH Lower Level Term
###  MTH_OS : MTH System-organ class
###  MTH_PT : Metathesaurus preferred term
###  MTH_SY : MTH Designated synonym
###  NM : Name of Supplementary Concept
###  OS : System-organ class
###  PCE : Preferred entry term for Supplementary Concept
###  PEP : Preferred entry term
###  PM : Machine permutation
###  PT : Designated preferred name
###  PTGB : British preferred term
###  SY : Designated synonym
###  SYGB : British synonym
#############################################################################
#
#
obo2csv.py \
	--i data/hp.obo \
	--o data/hp.csv
#
csv_utils.py \
	--i data/hp.csv \
	--coltag "id" \
	--extractcol \
	>data/hp.hpid
#
n_hpid=`cat data/hp.hpid |wc -l`
printf "n_hpid = %d\n" $n_hpid
###
#Slow, gets hung, requires restarts, due to
#UMLS REST API time outs and errors.
if [ ! "data/hp2umls.csv" ]; then \
	umls_utils.py \
		--idfile data/hp.hpid \
		--idsrc "HPO" \
		--o data/hp2umls.csv \
		getConcept
fi
#
n_hp2umls=`cat data/hp2umls.csv |sed -e '1d' |wc -l`
printf "n_hp2umls = %d\n" $n_hp2umls
#
csv_utils.py \
	--i data/hp2umls.csv \
	--coltag "concepts" \
	--extractcol \
	|perl -pe 's/;/\n/g' \
	|sort -u \
	>data/hp2umls.cui
#
n_cui=`cat data/hp2umls.cui |wc -l`
printf "n_cui = %d\n" $n_cui
#
srcs="HPO,ICD9CM,ICD10CM,MDR,MSH,OMIM,SNOMEDCT_US"
time umls_utils.py \
	--idfile data/hp2umls.cui \
	--srcs "${srcs}" \
	--o data/umls-atoms-selected.csv \
	getAtoms
#
csv_utils.py \
	--i data/umls-atoms-selected.csv \
	--coltag "rootSource" \
	--colvalcounts
#
csv_utils.py \
	--i data/umls-atoms-selected.csv \
	--coltags "concept,name" \
	--subsetcols \
	--o data/umls-atoms-concepts.csv
#
csv_utils.py \
	--i data/umls-atoms-concepts.csv \
	--coltag "concept" \
	--deduprows \
	--overwrite_input_file
#
for src in `echo $srcs |sed 's/,/ /g'` ; do
	#
	csv_utils.py \
		--i data/umls-atoms-selected.csv \
		--coltag "rootSource" \
		--filterbycol \
		--eqval "${src}" \
		--o data/umls-atoms-${src}.csv
	#
	csv_utils.py \
		--i data/umls-atoms-${src}.csv \
		--coltags "concept,ui" \
		--subsetcols \
		--o data/umls-atoms2ui-${src}.csv
done
