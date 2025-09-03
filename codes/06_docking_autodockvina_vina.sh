#!/bin/bash

cores=$1
ligand_dir=../COMFORMERS
receptor_dir=../INPUTS
output_dir=../DOCKING/ADV_vina
working_dir=..
vina_input=../vina_input.in
vina="../x86_64Linux2/vina_1.2.3_linux_x86_64"

count=0

# Create a new directory for the output files
mkdir -p "$output_dir"

# Check if there are any ligand pdbqt files present
files=( "$ligand_dir"/*_split*.pdbqt )
if [ ${#files[@]} -eq 0 ]; then
    echo "No .pdbqt ligand files found in COMFORMERS. Script will not continue."
    exit 1
fi

# Check if flex_receptor.pdbqt file is present in INPUTS directory
flex_receptor_file=$(find "$receptor_dir" -name "*flex_receptor.pdbqt" -type f -print -quit)
if [ -f "$flex_receptor_file" ]; then
    echo "Performing flexible residue docking."

    for ligand in "$ligand_dir"/*_split*.pdbqt; do
        ligand_basename=$(basename "$ligand" .pdbqt)
        receptor=$(find "$receptor_dir" -name "*_receptor.pdbqt" -type f | grep -v "flex_receptor.pdbqt" | head -n 1)
        echo "Docking busy for $ligand_basename"
        output_file="$output_dir/${ligand_basename}_docked.pdbqt"
        log_file="$output_dir/${ligand_basename}_docking.log"
        ${vina} --ligand "$ligand" --receptor "$receptor" --flex "$flex_receptor_file" --config "$vina_input" --scoring vina --exhaustiveness 10 --cpu "$cores" --out "$output_file" > "$log_file"
        echo "Flexible docking completed for molecule: $ligand_basename"
        echo "----------------------------------------------------------"
        count=$((count + 1))
    done

else
    echo "No flex_receptor.pdbqt file found. Performing rigid receptor docking."

    for ligand in "$ligand_dir"/*_split*.pdbqt; do
        ligand_basename=$(basename "$ligand" .pdbqt)
        echo "Docking busy for $ligand_basename"
        receptor=$(find "$receptor_dir" -name "*_receptor.pdbqt" -type f -print -quit)
        output_file="$output_dir/${ligand_basename}_docked.pdbqt"
        log_file="$output_dir/${ligand_basename}_docking.log"
        ${vina} --ligand "$ligand" --receptor "$receptor" --config "$vina_input" --scoring vina --exhaustiveness 10 --cpu "$cores" --out "$output_file" > "$log_file"
        echo "Rigid docking completed for molecule: $ligand_basename"
        echo "-------------------------------------------------------"
        count=$((count + 1))
    done

fi

# Count the number of docked conformers
docking_count=$(ls "$output_dir"/*_docked.pdbqt | wc -l)

echo "$docking_count conformers were docked"
echo "AutoDock Vina (vina scoring) is completed"
