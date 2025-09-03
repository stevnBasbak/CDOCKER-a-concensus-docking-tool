#!/bin/bash

# First we need to add the ligand.pdbqt files to all AD4 files
cp ../COMFORMERS/*.pdbqt ../DOCKING/AD4_GA/Generated_files/
cp ../COMFORMERS/*.pdbqt ../DOCKING/AD4_LGA/Generated_files/
cp ../COMFORMERS/*.pdbqt ../DOCKING/AD4_LS/Generated_files/

count=0

# Set the path to the Autodock4 command
autodock4_cmd="../../../x86_64Linux2/autodock4"

# Set the directory containing the .dpf files in AD4_GA
directory_GA="../DOCKING/AD4_GA/Generated_files/"

cd ../DOCKING/AD4_GA/Generated_files/

# Loop through each .dpf file in the working directory
for dpf_file in *.dpf; do
    # Check if any .dpf files exist
    if [ -e "$dpf_file" ]; then
        echo "Running Autodock4 GA for file: $dpf_file"

        # Extract the base file name without extension
        base_file_name="${dpf_file%.dpf}"

        # Run the Autodock4 command for the current .dpf file
        "$autodock4_cmd" -p "$dpf_file" -l "$base_file_name".dlg | tee "$base_file_name".dlg

        # Check if the output file contains "FATAL ERROR"
        if grep -q "FATAL ERROR" "$base_file_name".dlg; then
            echo "FATAL ERROR (AD4_GA) encountered for file: $dpf_file"
            exit 1
        else
            mv "$base_file_name".dlg ..
        fi

        echo "Autodock4_GA finished for file: $dpf_file"
        echo "--------------------------------------------------"
    else
        echo "No .dpf files found in the working directory"
        exit 1
    fi
done


cd ../../AD4_LGA/Generated_files/

# Loop through each .dpf file in the working directory
for dpf_file in *.dpf; do
    # Check if any .dpf files exist
    if [ -e "$dpf_file" ]; then
        echo "Running Autodock4_LGA for file: $dpf_file"
        
        # Extract the base file name without extension
        base_file_name="${dpf_file%.dpf}"

        # Run the Autodock4 command for the current .dpf file
        "$autodock4_cmd" -p "$dpf_file" -l "$base_file_name".dlg | tee "$base_file_name".dlg

         # Check if the output file contains "FATAL ERROR"
        if grep -q "FATAL ERROR" "$base_file_name".dlg; then
            echo "FATAL ERROR (AD4_LGA) encountered for file: $dpf_file"
            exit 1
        else
            mv "$base_file_name".dlg ..
        fi
        
        echo "Autodock4_LGA finished for file: $dpf_file"
        echo "--------------------------------------------------"
    else
        echo "No .dpf files found in the working directory"
        exit 1
    fi
done

cd ../../AD4_LS/Generated_files/

# Loop through each .dpf file in the working directory
for dpf_file in *.dpf; do
    # Check if any .dpf files exist
    if [ -e "$dpf_file" ]; then
        echo "Running Autodock4_LS for file: $dpf_file"
        
        # Extract the base file name without extension
        base_file_name="${dpf_file%.dpf}"

        # Run the Autodock4 command for the current .dpf file
        "$autodock4_cmd" -p "$dpf_file" -l "$base_file_name".dlg | tee "$base_file_name".dlg

            # Check if the output file contains "FATAL ERROR"
        if grep -q "FATAL ERROR" "$base_file_name".dlg; then
            echo "FATAL ERROR (AD4_LS) encountered for file: $dpf_file"
            exit 1
        else
            mv "$base_file_name".dlg ..
        fi
        
        count=$((count + 1))

        echo "Autodock4_LS finished for file: $dpf_file"
        echo "--------------------------------------------------"
    else
        echo "No .dpf files found in the working directory"
        exit 1
    fi
done

# Count the number of docked conformers
docking_count=$(ls ../*.dlg | wc -l)

echo "$docking_count conformers were docked"
echo "AutoDock4 is done"
