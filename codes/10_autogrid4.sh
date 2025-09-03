#!/bin/bash


# This script prepares the grid calculation of autogrid4 and eventualy also performs it. It generates .map files and other pre-calculations served for the 
# actual docking. These files all need to be present in the location of the docking 


#so we start by making a couple of directories
mkdir ../DOCKING/AD4_GA
mkdir ../DOCKING/AD4_GA/Generated_files
mkdir ../DOCKING/AD4_LGA
mkdir ../DOCKING/AD4_LS



#and now comes the madness
#Define the unique atom types. We scan through all the ligands present and only take the unique atom types for grid calculations.
ligand_types_split=$(grep ATOM ../COMFORMERS/*_split*.pdbqt | awk '{print $13}' | uniq)


ligand_types_flex=""
flex_files=$(find ../INPUTS -name "*_flex_receptor.pdbqt")
if [ -n "$flex_files" ]; then
  ligand_types_flex=$(grep ATOM $flex_files | sed 's/\s$//g' | rev | awk '{print $1}' | sort | uniq | rev)
fi

ligand_types="$ligand_types_split $ligand_types_flex"



receptor_types=$(grep -v "flex_receptor.pdbqt" ../INPUTS/*_receptor.pdbqt | grep ATOM | sed 's/\s$//g' | rev | awk '{print $1}' | sort | uniq | rev)


#.gpf creation (grid paramter file, needed as input for autogrid4. The template is included in this script where we add some variables depending on the receptor/ligand/box)
cat <<EOF > ../DOCKING/AD4_GA/Generated_files//GRID.gpf
npts 	GRIDPOINT_X GRIDPOINT_Y GRIDPOINT_Z
gridfld PDBid_receptor.maps.fld
spacing SPACING
EOF

echo "receptor_types" $receptor_types >> ../DOCKING/AD4_GA/Generated_files//GRID.gpf
echo "ligand_types" $ligand_types | tr ' ' '\n' | awk '!seen[$0]++' | tr '\n' ' ' >> ../DOCKING/AD4_GA/Generated_files//GRID.gpf
echo "" >> ../DOCKING/AD4_GA/Generated_files//GRID.gpf
echo "receptor PDBid_receptor.pdbqt" >> ../DOCKING/AD4_GA/Generated_files//GRID.gpf
echo "gridcenter GRIDCENTER_X GRIDCENTER_Y GRIDCENTER_Z" >> ../DOCKING/AD4_GA/Generated_files//GRID.gpf
echo "smooth 0.5" >> ../DOCKING/AD4_GA/Generated_files//GRID.gpf


for i in $ligand_types
do
  echo "map PDBid_receptor.$i.map" >> ../DOCKING/AD4_GA/Generated_files//GRID.gpf
done

{
    echo "elecmap PDBid_receptor.e.map"
    echo "dsolvmap PDBid_receptor.d.map"
    echo "dielectric -0.1465"
} >> "../DOCKING/AD4_GA/Generated_files//GRID.gpf"


awk '!seen[$0]++' ../DOCKING/AD4_GA/Generated_files//GRID.gpf > ../DOCKING/AD4_GA/Generated_files//GRID.tmp && mv ../DOCKING/AD4_GA/Generated_files//GRID.tmp ../DOCKING/AD4_GA/Generated_files//GRID.gpf


## Now to make some changes in the generated GRID.gpf file
# Read the first two lines from gridsize_INPUT
read -r PDBid < "../INPUTS/gridsize_INPUT"

npts_line=$(grep -E "^npts\s+" ../INPUTS/gridsize_INPUT)
npts_x=$(echo "$npts_line" | awk '{print $2}')
npts_y=$(echo "$npts_line" | awk '{print $3}')
npts_z=$(echo "$npts_line" | awk '{print $4}')

spacing_line=$(grep -E "^spacing\s+" ../INPUTS/gridsize_INPUT)
spacing=$(echo "$spacing_line" | awk '{print $2}')

gridcenter_line=$(grep -E "^center\s+" ../INPUTS/gridsize_INPUT)
gridcenter_x=$(echo "$gridcenter_line" | awk '{print $2}')
gridcenter_y=$(echo "$gridcenter_line" | awk '{print $3}')
gridcenter_z=$(echo "$gridcenter_line" | awk '{print $4}')


# Replace "PDBid" in the GRID.gpf file with the first line of the gridsize_INPUT file
sed "s/PDBid/$PDBid/g" ../DOCKING/AD4_GA/Generated_files//GRID.gpf > ../DOCKING/AD4_GA/Generated_files//GRID.tmp
mv ../DOCKING/AD4_GA/Generated_files//GRID.tmp ../DOCKING/AD4_GA/Generated_files//GRID.gpf

# Replace "GRIDPOINT_X", "GRIDPOINT_Y", and "GRIDPOINT_Z" in GRID.gpf
sed -i "s/GRIDPOINT_X/$npts_x/g" ../DOCKING/AD4_GA/Generated_files//GRID.gpf
sed -i "s/GRIDPOINT_Y/$npts_y/g" ../DOCKING/AD4_GA/Generated_files//GRID.gpf
sed -i "s/GRIDPOINT_Z/$npts_z/g" ../DOCKING/AD4_GA/Generated_files//GRID.gpf

sed -i "s/SPACING/$spacing/g" ../DOCKING/AD4_GA/Generated_files//GRID.gpf

sed -i "s/GRIDCENTER_X/$gridcenter_x/g" ../DOCKING/AD4_GA/Generated_files//GRID.gpf
sed -i "s/GRIDCENTER_Y/$gridcenter_y/g" ../DOCKING/AD4_GA/Generated_files//GRID.gpf
sed -i "s/GRIDCENTER_Z/$gridcenter_z/g" ../DOCKING/AD4_GA/Generated_files//GRID.gpf

echo "specified gpf created"

# this was difficult wawi
# total hours wasted: 20


# we add the receptor to AD4_GA. The point is that we make one search method completely ready, and then copy all the files to different search methods with other docking parameters.
# The grid calculation that we are performing now is independant of the search metghod later
cp ../INPUTS/*_receptor.pdbqt ../DOCKING/AD4_GA/Generated_files/
find ../INPUTS/ -name '*flex_receptor.pdbqt' -print -quit 2>/dev/null | xargs -r cp -t ../DOCKING/AD4_GA/Generated_files/
#if find ../INPUTS/ -name '*flex_receptor.pdbqt' -print -quit 2>/dev/null; then
#    cp  -f ../INPUTS/*flex_receptor.pdbqt ../DOCKING/AD4_GA/Generated_files/
#fi

# now the grid calculation can start for AD4_GA (no ligands need to be added to the files now, as only information about the atom types was necessary)
cd ../DOCKING/AD4_GA/Generated_files/
../../../x86_64Linux2/autogrid4 -p GRID.gpf -l autodock4.glg
cat autodock4.glg


# now copy these grid files to all ADV4 methods
cd ../../../codes
cp -r ../DOCKING/AD4_GA/Generated_files ../DOCKING/AD4_LGA/
cp -r ../DOCKING/AD4_GA/Generated_files ../DOCKING/AD4_LS/
