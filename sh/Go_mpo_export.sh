#!/bin/sh
#############################################################################
# Mammalian Phenotype Ontology
# http://www.obofoundry.org/cgi-bin/detail.cgi?id=mammalian_phenotype
#
#onturl="http://purl.obolibrary.org/obo/mp.owl"
#	-onturl "$onturl" \
#
# Jeremy Yang
# 5 Jun 2015
#############################################################################
#
ontfile="data/mp.owl"
#
#jena_utils.sh -ontfile "$ontfile" -list_classes -o data/mp_classes.csv
#jena_utils.sh -ontfile "$ontfile" -list_subclasses -o data/mp_subclasses.csv
#
jena_utils.sh -ontfile "$ontfile" -ont2graph -o data/mp.graphml
#
igraph_utils.py \
	--i data/mp.graphml \
	--node_select \
	--selectquery 'MP_' \
	--selectfield "id" \
	--o data/mp_lean.graphml \
	--v
#
igraph_utils.py \
	--i data/mp_lean.graphml \
	--connectednodes \
	--overwrite_input_file \
	--v
#
igraph_utils.py \
	--i data/mp_lean.graphml \
	--topnodes \
	--depth 2 \
	--o data/mp_top.graphml \
	--vv
#
