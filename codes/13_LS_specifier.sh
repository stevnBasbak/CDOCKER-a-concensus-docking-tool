#!/bin/bash

input_dir="../COMFORMERS"
output_dir="../DOCKING/AD4_LS/Generated_files"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Check if flex_receptor.pdbqt file exists
#flex_receptor_files=(../INPUTS/*flex_receptor.pdbqt)
flex_receptor_files=$(find ../INPUTS -name '*_flex_receptor.pdbqt' 2>/dev/null)

if [[ -n "$flex_receptor_files" ]]; then
    flex_receptor_file=$(basename "$flex_receptor_files")
    echo "$flex_receptor_file"
    echo "Flex receptor file present. Modifying DPF file."
    read -r PDBid < "../INPUTS/gridsize_INPUT"
    echo "$PDBid"

    gridcenter_line=$(grep -E "^center\s+" ../INPUTS/gridsize_INPUT)
    gridcenter_x=$(echo "$gridcenter_line" | awk '{print $2}')
    gridcenter_y=$(echo "$gridcenter_line" | awk '{print $3}')
    gridcenter_z=$(echo "$gridcenter_line" | awk '{print $4}')

for file in "$input_dir"/*_split*.pdbqt; do
        ligand_types_split=$(grep ATOM "$file" | awk '{print $13}' | sort | uniq | paste -sd " ")
        flex_files=$(find ../INPUTS -name "*_flex_receptor.pdbqt")
            if [ -n "$flex_files" ]; then
             ligand_types_flex=$(grep ATOM $flex_files | sed 's/\s$//g' | rev | awk '{print $1}' | sort | uniq | paste -sd " "| rev)
            fi
        ligand_types=$(echo "$ligand_types_split $ligand_types_flex" | tr ' ' '\n' | sort -u | paste -sd " ")
        filename=$(basename "$file")
        output_file="$output_dir/${filename%.*}.dpf"

        echo "$(basename "$file") $ligand_types"

        autodock_template=$(cat <<EOF
    
autodock_parameter_version 4.2       # used by autodock to validate parameter set
outlev 1                             # diagnostic output level
intelec                              # calculate internal electrostatics
ligand_types $ligand_types                  # atoms types in ligand
fld ${PDBid}_receptor.maps.fld           # grid_data_file
EOF
    )

    echo "$autodock_template" > "$output_file"

    for i in $ligand_types; do
        echo "map ${PDBid}_receptor.$i.map" >> "$output_file"
    done

    cat <<EOF >> "$output_file"
elecmap ${PDBid}_receptor.e.map          # electrostatics map
desolvmap ${PDBid}_receptor.d.map        # desolvation map
move $(basename "$file")                      # small molecule
flexres $flex_receptor_file                 # file containing flexible residues
torsdof 0                            # torsional degrees of freedom
sw_max_its 2000                       # iterations of Solis & Wets local search
sw_max_succ 2                        # consecutive successes before changing rho
sw_max_fail 2                        # consecutive failures before changing rho
sw_rho 0.5                           # size of local search space to sample
sw_lb_rho 0.001                       # lower bound on rho
set_psw1                             # set the above pseudo-Solis & Wets parameters
do_local_only 100                     # do this many LS runs
rmstol 2.0                           # cluster_tolerance/A
analysis                             # perform a ranked cluster analysis
EOF

done

else
    echo "Flex receptor file not present."
    modified_output_message=""
    # Read the first two lines from gridsize_INPUT
    read -r PDBid < "../INPUTS/gridsize_INPUT"
    echo "$PDBid"

    gridcenter_line=$(grep -E "^center\s+" ../INPUTS/gridsize_INPUT)
    gridcenter_x=$(echo "$gridcenter_line" | awk '{print $2}')
    gridcenter_y=$(echo "$gridcenter_line" | awk '{print $3}')
    gridcenter_z=$(echo "$gridcenter_line" | awk '{print $4}')

for file in "$input_dir"/*_split*.pdbqt; do
    ligand_types=$(grep ATOM "$file" | awk '{print $13}' | sort | uniq | paste -sd " ")
    echo "$(basename "$file") $ligand_types"
    
    filename=$(basename "$file")
    output_file="$output_dir/${filename%.*}.dpf"
    
    autodock_template=$(cat <<EOF
autodock_parameter_version 4.2       # used by autodock to validate parameter set
outlev 1                             # diagnostic output level
intelec                              # calculate internal electrostatics
ligand_types $ligand_types                  # atoms types in ligand
fld ${PDBid}_receptor.maps.fld           # grid_data_file
EOF
    )

    echo "$autodock_template" > "$output_file"

    for i in $ligand_types; do
        echo "map ${PDBid}_receptor.$i.map" >> "$output_file"
    done

    cat <<EOF >> "$output_file"
elecmap ${PDBid}_receptor.e.map          # electrostatics map
desolvmap ${PDBid}_receptor.d.map        # desolvation map
move $(basename "$file")                      # small molecule
torsdof 0                            # torsional degrees of freedom
sw_max_its 2000                       # iterations of Solis & Wets local search
sw_max_succ 2                        # consecutive successes before changing rho
sw_max_fail 2                        # consecutive failures before changing rho
sw_rho 0.5                           # size of local search space to sample
sw_lb_rho 0.001                       # lower bound on rho
set_psw1                             # set the above pseudo-Solis & Wets parameters
do_local_only 100                     # do this many LS runs
rmstol 2.0                           # cluster_tolerance/A
analysis                             # perform a ranked cluster analysis
EOF

done

fi





