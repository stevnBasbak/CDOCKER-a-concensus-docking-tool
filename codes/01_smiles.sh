#!/bin/bash

cd ..

input_file="INPUTS/*.txt"
output_dir="SMILES"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through each input file
for file in $input_file; do
  input=$(cat "$file")

  # Split the input by periods
  IFS='.' read -ra texts <<< "$input"

  # Create separate files for each text in the output directory
  for i in "${!texts[@]}"; do
    echo "${texts[$i]}" > "$output_dir/SMILE$((i+1)).smi"
  done

done
