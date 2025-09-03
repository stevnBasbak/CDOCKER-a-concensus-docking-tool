#!/bin/bash

# Define the directory containing the log files
log_directory="../DOCKING/ADV_vinardo"

# Create a new directory to store the output file
output_directory="../DOCKING/ADV_vinardo"
mkdir -p "$output_directory"

# Check if any .log files exist in the directory
if ! ls "$log_directory"/*.log &> /dev/null; then
  echo "\e[31mNo .log files found in ADV_vinardo. Docking failed.\e[0m"
  exit 1
fi

# Create a new file to store the output
output_file="$output_directory/Summarized_AutoDVina_vinardo.txt"
> "$output_file"  # Clear the file if it already exists


if ls "../INPUTS"/*flex_receptor.pdbqt &> /dev/null; then
  # Loop through each log file in the directory
  for log_file in "$log_directory"/*.log; do
    # Read the contents of the log file
    input=$(cat "$log_file")

    # Extract the scoring function
    scoring_function=$(echo "$input" | grep "^Scoring function : " | awk '{print $4}')

    # Extract the rigid receptor and remove the extension
    receptor=$(echo "$input" | grep "^Rigid receptor: ../" | awk -F/ '{print $NF}' | awk -F_ '{print $1}')

    # Extract the ligand and remove the extension
    ligand=$(echo "$input" | grep "^Ligand: ../COMFORMERS/" | awk -F/ '{print $NF}' | awk -F. '{print $1}')

    # Extract the best binding affinity
    affinity=$(echo "$input" | sed -n '40p' | awk '{print $2}')

    # Print the extracted variables
    echo "FLEXIBLE DOCKING"
    echo "Log File: $(basename "$log_file")"
    echo "Program: AutoDock Vina v1.2.3"
    echo "Scoring function: $scoring_function"
    echo "Receptor: $receptor"
    echo "Ligand: $ligand"
    echo "Affinity: $affinity"
    echo "-----------------------------------"

    # Append the information to the output file
    printf "%-22s\tAutoDock_Vina_v1.2.3\tvinardo\t\t\t\tGeneric_Algorithm\t\t%-10s\t%-20s\t%-30s\n" \
      "$(basename "$log_file")" "$receptor" "$ligand" "$affinity" >> "$output_file"
  done


else
  # Loop through each log file in the directory
  for log_file in "$log_directory"/*.log; do
    # Read the contents of the log file
    input=$(cat "$log_file")

    # Extract the scoring function
    scoring_function=$(echo "$input" | grep "^Scoring function : " | awk '{print $4}')

    # Extract the receptor and remove the extension
    receptor=$(echo "$input" | grep "^Rigid receptor: ../" | awk -F/ '{print $NF}' | awk -F_ '{print $1}')

    # Extract the ligand and remove the extension
    ligand=$(echo "$input" | grep "^Ligand: ../COMFORMERS/" | awk -F/ '{print $NF}' | awk -F. '{print $1}')

    # Extract the best binding affinity
    affinity=$(echo "$input" | sed -n '39p' | awk '{print $2}')

    # Print the extracted variables
    echo "RIGID DOCKING"
    echo "Log File: $(basename "$log_file")"
    echo "Program: AutoDock Vina v1.2.3"
    echo "Scoring function: $scoring_function"
    echo "Receptor: $receptor"
    echo "Ligand: $ligand"
    echo "Affinity: $affinity"
    echo "-----------------------------------"

    # Append the information to the output file
    printf "%-22s\tAutoDock_Vina_v1.2.3\tvinardo\t\t\t\tGeneric_Algorithm\t\t%-10s\t%-20s\t%-30s\n" \
      "$(basename "$log_file")" "$receptor" "$ligand" "$affinity" >> "$output_file"
  done




fi







