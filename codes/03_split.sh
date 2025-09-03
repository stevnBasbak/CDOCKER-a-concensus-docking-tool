#!/bin/bash

cd ../COMFORMERS 

for mol2_file in *.mol2; do
    base_name="${mol2_file%.*}"
    obabel -i mol2 "$mol2_file" -o mol2 -O "${base_name}_split.mol2" -m
done