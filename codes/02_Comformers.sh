#!/bin/bash

# user defined stuff
mff_file="../x86_64Linux2/MMFF94.mff"


cd ../SMILES  # Change working directory to "SMILES"
mkdir -p ../COMFORMERS  # Create a new folder called "COMFORMERS"

for file in *.smi; do
    filename=$(basename "$file" .smi)
    output_file="../COMFORMERS/$filename".mol2  # Store the output file in the "COMFORMERS" folder
    #the following parameters is the product of many trial and errors. Flexible molecules will logicaly make more comformers, but not too mutch.
../x86_64Linux2/balloon -c 200 -b --writeMOL2 --output-file "$output_file" --input-file "$file" -f "$mff_file" -R 1.90 --pRingFlipMutation 0.10 --useRingAtomsForRMSD

done
