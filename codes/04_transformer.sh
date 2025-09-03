#!/bin/bash

cd ../COMFORMERS

files=( *.mol2 )
if [ ${#files[@]} -eq 0 ]; then
    echo "No .mol2 files found in COMFORMERS. Script will not proceed."
    exit 1
fi

for mol2_file in *.mol2; do
    base_name="${mol2_file%.*}"
    bash ../ADFRsuite-1.1dev/bin/prepare_ligand -l "$mol2_file" -o "${base_name}.pdbqt" -A hydrogens
done
