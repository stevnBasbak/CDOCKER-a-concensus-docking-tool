#!/bin/bash

# Define the directories containing the AD4 output .dlg files
log_directories=(
  "../DOCKING/AD4_GA/"
  "../DOCKING/AD4_LGA/"
  "../DOCKING/AD4_LS/"
)

# function that will eventualy remove the added text
remove_added_text() {
  local directory=$1

  # Find all .dlg files in the directory
  dlg_files=$(find "$directory" -type f -name "*.dlg")

  # Iterate over each .dlg file
  for dlg_file in $dlg_files; do
    # Remove the added text from the .dlg file
    sed -i '0,/The search algorithm is:.*/s// /' "$dlg_file"
  done
}

# Iterate over each directory
for directory in "${log_directories[@]}"; do
  # Find all .dlg files in the directory
  dlg_files=$(find "$directory" -type f -name "*.dlg")

  # Iterate over each .dlg file
  for dlg_file in $dlg_files; do
    # Determine the search algorithm based on the directory
    search_algorithm=""
    if [[ $directory == *"AD4_GA"* ]]; then
      search_algorithm="Genetic_Algorithm"
    elif [[ $directory == *"AD4_LGA"* ]]; then
      search_algorithm="Lamarckian_Generic_Algorithm"
    elif [[ $directory == *"AD4_LS"* ]]; then
      search_algorithm="Local_search_Genetic_Algorithm"
    fi

    # Add the search algorithm line at the end of the .dlg file
    echo "The search algorithm is: $search_algorithm" >> "$dlg_file"
  done
done


# Define the directory to create the summary file
output_directory="../DOCKING/"

# Create a new file to store the output
output_file="$output_directory/Summarized_AutoDock4.txt"
> "$output_file"  # Clear the file if it already exists

# Loop through each log directory
for log_directory in "${log_directories[@]}"; do
  # Loop through each dlg file in the directory
  for log_file in "$log_directory"/*.dlg; do
    # Read the contents of the log file
    input=$(cat "$log_file")

    # Extract the receptor and remove the extension
    receptor=$(echo "$input" | grep -oP '^Macromolecule file used to create Grid Maps =\s*\K[^\s/]+' | sed 's/_receptor\.pdbqt$//')

    # Extract the ligand and remove the extension
    ligand=$(echo "$input" | grep -oP 'Ligand PDBQT file = "\K[^"]+' | sed 's/\.pdbqt$//')

    # Extract the search algorithm and remove the extension
    search=$(echo "$input" | grep -oP 'The search algorithm is: \K[^"]+' | sed 's/\.pdbqt$//')

    # Extract the best binding affinity
    affinity=$(echo "$input" | grep -A1 "_____|___________|_____|___________|_____|____:____|____:____|____:____|____:___" | awk '{getline; print $7}')

# Print the extracted variables
    echo "Log File: $(basename "$log_file")"
    echo "Scoring function: AutoDock4 scoring function"
    echo "Search algorithm: $search"
    echo "Receptor: $receptor"
    echo "Ligand: $ligand"
    echo "Affinity: $affinity"
    echo "------------------------------"

    # Append the information to the output file
    printf "%-22s\t\tAutoDock4\t\tAutoDock4_scoring_function\t%-30s\t%-10s\t%-21s\t%-30s\n" \
      "$(basename "$log_file")" "$search" "$receptor" "$ligand" "$affinity" >> "$output_file"
  done
done


# Remove the added text from the .dlg files
for directory in "${log_directories[@]}"; do
  remove_added_text "$directory"
done

