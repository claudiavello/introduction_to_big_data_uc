#!/bin/bash
# Raname PDB files 
#
# Author: Claudia Vello
# Date: 1stOct25

OUTDIR="renamed_pdb"

mkdir -p ${OUTDIR}

function get_formula(){
  fname=$1
  cat ${fname} | awk '/ATOM/ {print $3}' | sort | uniq -c | awk '{print $2 $1}' | tr -d '\r\n'
}

for filename in ./data/pdb/*.pdb
do
  formula=$(get_formula ${filename})
  outfile="${OUTDIR}/$(basename ${filename//.pdb/})_${formula}.pdb"
  cp ${filename} ${outfile}
done