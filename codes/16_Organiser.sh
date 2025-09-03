#!/bin/bash

# Define the paths of the input files
file1="../DOCKING/ADV_vinardo/Summarized_AutoDVina_vinardo.txt"
file2="../DOCKING/ADV_vina/Summarized_AutoDVina_vina.txt"
file3="../DOCKING/Summarized_AutoDock4.txt"

# Define the output directory and file
output_file="../DOCKING/Merged_Summary.txt"

# Merge the files into the output file and add column headers
(cat "$file1" "$file2" "$file3") >> "$output_file"

echo "Files merged successfully. Merged output file: $output_file"

# Add double line breaks to separate sections
echo "" >> "$output_file"
echo "" >> "$output_file"


