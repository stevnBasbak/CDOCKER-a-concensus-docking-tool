#!/bin/bash

## This code makes .dpf files. These files contain all the information needed to do the docking

input_dir="../COMFORMERS"
output_dir="../DOCKING/AD4_GA/Generated_files"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

flex_receptor_files=$(find ../INPUTS -name '*_flex_receptor.pdbqt' 2>/dev/null)

if [[ -n "$flex_receptor_files" ]]; then
    flex_receptor_file=$(basename "$flex_receptor_files")
    echo "$flex_receptor_file"
    echo "Flex receptor file present. Modifying DPF file."

    # Read the first two lines from gridsize_INPUT (information about where to dock / grid)
    read -r PDBid < "../INPUTS/gridsize_INPUT"
    echo "$PDBid"

    gridcenter_line=$(grep -E "^center\s+" ../INPUTS/gridsize_INPUT)
    gridcenter_x=$(echo "$gridcenter_line" | awk '{print $2}')
    gridcenter_y=$(echo "$gridcenter_line" | awk '{print $3}')
    gridcenter_z=$(echo "$gridcenter_line" | awk '{print $4}')

    # Now the .dpf files can be created. They depend on the ligand, receptor, and grid
    for file in "$input_dir"/*_split*.pdbqt; do
        ligand_types_split=$(grep ATOM "$file" | awk '{print $13}' | sort | uniq | paste -sd " ")
        flex_files=$(find ../INPUTS -name "*_flex_receptor.pdbqt")
            if [ -n "$flex_files" ]; then
             ligand_types_flex=$(grep ATOM $flex_files | sed 's/\s$//g' | rev | awk '{print $1}' | sort | uniq | paste -sd " " | rev)
            fi
        #ligand_types="$ligand_types_split $ligand_types_flex"
        ligand_types=$(echo "$ligand_types_split $ligand_types_flex" | tr ' ' '\n' | sort -u | paste -sd " ")


        filename=$(basename "$file")
        output_file="$output_dir/${filename%.*}.dpf"

        echo "$(basename "$file") $ligand_types"

        autodock_template=$(cat <<EOF
autodock_parameter_version 4.2       # used by autodock to validate parameter set
outlev 1                             # diagnostic output level
intelec                              # calculate internal electrostatics
seed pid time                        # seeds for random generator
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
tran0 random                         # initial coordinates/A or random
quaternion0 random                   # initial orientation
dihe0 random                         # initial dihedrals (relative) or random
torsdof 0                            # torsional degrees of freedom
rmstol 2.0                           # cluster_tolerance/A
extnrg 1000.0                        # external grid energy
e0max 0.0 10000                      # max initial energy; max number of retries
ga_pop_size 200                      # number of individuals in population
ga_num_evals 2400000                 # maximum number of energy evaluations
ga_num_generations 26000             # maximum number of generations
ga_elitism 1                         # number of top individuals to survive to next generation
ga_mutation_rate 0.02                # rate of gene mutation
ga_crossover_rate 0.8                # rate of crossover
ga_window_size 10                    # 
ga_cauchy_alpha 0.0                  # Alpha parameter of Cauchy distribution
ga_cauchy_beta 1.0                   # Beta parameter Cauchy distribution
set_ga                               # set the above parameters for GA or LGA
unbound_model bound                  # state of unbound ligand
do_global_only 5                    # do this many GA runs
analysis                             # perform a ranked cluster analysis
EOF
    done

else
    echo "Flex receptor file not present."
    # Read the first two lines from gridsize_INPUT (information about where to dock / grid)
    read -r PDBid < "../INPUTS/gridsize_INPUT"
    echo "$PDBid"

    gridcenter_line=$(grep -E "^center\s+" ../INPUTS/gridsize_INPUT)
    gridcenter_x=$(echo "$gridcenter_line" | awk '{print $2}')
    gridcenter_y=$(echo "$gridcenter_line" | awk '{print $3}')
    gridcenter_z=$(echo "$gridcenter_line" | awk '{print $4}')

    # Now the .dpf files can be created. They depend on the ligand, receptor, and grid
    for file in "$input_dir"/*_split*.pdbqt; do
        ligand_types=$(grep ATOM "$file" | awk '{print $13}' | sort | uniq | paste -sd " ")
        echo "$(basename "$file") $ligand_types"

        filename=$(basename "$file")
        output_file="$output_dir/${filename%.*}.dpf"

        autodock_template=$(cat <<EOF
autodock_parameter_version 4.2       # used by autodock to validate parameter set
outlev 1                             # diagnostic output level
intelec                              # calculate internal electrostatics
seed pid time                        # seeds for random generator
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
tran0 random                         # initial coordinates/A or random
quaternion0 random                   # initial orientation
dihe0 random                         # initial dihedrals (relative) or random
torsdof 0                            # torsional degrees of freedom
rmstol 2.0                           # cluster_tolerance/A
extnrg 1000.0                        # external grid energy
e0max 0.0 10000                      # max initial energy; max number of retries
ga_pop_size 200                      # number of individuals in population
ga_num_evals 2400000                 # maximum number of energy evaluations
ga_num_generations 26000             # maximum number of generations
ga_elitism 1                         # number of top individuals to survive to next generation
ga_mutation_rate 0.02                # rate of gene mutation
ga_crossover_rate 0.8                # rate of crossover
ga_window_size 10                    # 
ga_cauchy_alpha 0.0                  # Alpha parameter of Cauchy distribution
ga_cauchy_beta 1.0                   # Beta parameter Cauchy distribution
set_ga                               # set the above parameters for GA or LGA
unbound_model bound                  # state of unbound ligand
do_global_only 5                    # do this many GA runs
analysis                             # perform a ranked cluster analysis
EOF
    done

fi

