#!/bin/bash

# Set execution permissions for necessary scripts and binaries
chmod +x ./codes/01_smiles.sh
chmod +x ./x86_64Linux2/balloon
chmod +x ./ADFRsuite-1.1dev/bin/prepare_ligand
chmod +x ./ADFRsuite-1.1dev/bin/archosv
chmod +x ./ADFRsuite-1.1dev/bin/python2


rm -rf ./DOCKING ./COMFORMERS ./SMILES ./vina_input.in

# Check wether the receptor is present in the INPUTS file
receptor_file=$(find ./INPUTS -name "*_receptor.pdbqt" ! -name "*_flex_receptor.pdbqt" -type f -print -quit)


if [ -z "$receptor_file" ]; then
    echo -e "\e[31mNo receptor file found in INPUTS. Script will not proceed.\e[0m"
    exit 1
fi

# Ask the user for the number of cores
read -p "How many cores? (0-99): " cores

# Check if the input is a valid number between 0 and 99
if [[ ! $cores =~ ^[0-9]{1,2}$ ]]; then
    echo "Invalid input. Please enter a number between 0 and 99."
    exit 1
fi

echo "And now lets pray together to the docking gods for no errors"

# Change directory to the codes directory
cd ./codes

# Run each script sequentially
bash ./01_smiles.sh && echo -e "\e[32m01_smiles.sh succeeded\e[0m"
wait

bash ./02_Comformers.sh && echo -e "\e[32m02_Comformers.sh succeeded\e[0m"
wait

bash ./03_split.sh && echo -e "\e[32m03_split.sh succeeded\e[0m"
wait

bash ./04_transformer.sh
transformer_exit_code=$?

if [ $transformer_exit_code -ne 0 ]; then
  echo -e "\e[31m04_transformer.sh failed. Are you sure that there is one and only one .txt file containing the smiles in INPUTS?\e[0m"
  exit 1
else
  echo -e "\e[32m04_gridtransformer.sh succeeded\e[0m"
fi

wait

bash ./05_gridtransformer.sh
grid_transformer_exit_code=$?

if [ $grid_transformer_exit_code -ne 0 ]; then
  echo -e "\e[31m05_gridtransformer.sh failed. Are you sure the gridsize_INPUT file is correctly spelled and in ./INPUTS?\e[0m"
  exit 1
else
  echo -e "\e[32m05_gridtransformer.sh succeeded\e[0m"
fi
wait

bash ./06_docking_autodockvina_vina.sh $cores
docking_autodockvina_vina=$?
if [ $docking_autodockvina_vina -ne 0 ]; then
  echo -e "\e[31m06_docking_autodockvina_vina.sh failed. Are you sure there are ligands .pdbqt files in COMFORMERS?\e[0m"
  exit 1
else
  echo -e "\e[06_docking_autodockvina_vina.sh succeeded\e[0m"
fi

wait

bash ./07_Summerizer_ADV_vina.sh $cores
summerizer_vina=$?
if [ $summerizer_vina -ne 0 ]; then
  echo -e "\e[31m07_Summerizer_ADV_vina.sh failed. Script will not continue\e[0m"
  exit 1
else
  echo -e "\e[07_Summerizer_ADV_vina.sh succeeded\e[0m"
fi

wait

bash ./08_docking_autodockvina_vinardo.sh $cores && echo -e "\e[32m08_docking_autodockvina_vinardo.sh succeeded\e[0m"
wait

bash ./09_Summerizer_ADV_vinardo.sh && echo -e "\e[32m09_Summerizer_ADV_vinardo.sh succeeded\e[0m"
wait

bash ./10_autogrid4.sh && echo -e "\e[32m10_autogrid4.sh\e[0m"
wait

bash ./11_GA_specifier.sh && echo -e "\e[32m11_GA_specifier.sh succeeded\e[0m"
wait

bash ./12_LGA_specifier.sh && echo -e "\e[32m12_LGA_specifier.sh succeeded\e[0m"
wait

bash ./13_LS_specifier.sh && echo -e "\e[32m13_LS_specifier.sh succeeded\e[0m"
wait

bash ./14_AD4_docker.sh
AD4_docker_exit_code=$?

if [ $AD4_docker_exit_code -ne 0 ]; then
  echo -e "\e[31m14_AD4_docker.sh failed. Script won't continue.\e[0m"
  exit 1
else
  echo -e "\e[32m14_AD4_docker.sh\e[0m"
fi
wait

bash ./15_AD4_Summerizer.sh && echo -e "\e[32m15_AD4_Summerizer.sh succeeded\e[0m"
wait

bash ./16_Organiser.sh && echo -e "\e[32m16_Organiser.sh succeeded\e[0m"
wait

bash ./17_Data_analyser.sh && echo -e "\e[32m17_Data_analyser.sh succeeded\e[0m"
wait

echo "amen"

