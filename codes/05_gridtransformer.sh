#!/bin/bash

#Define where the grid box is
grid_size="../INPUTS/gridsize_INPUT"

if [ ! -f "$grid_size" ]; then
  echo "gridsize_INPUT file not found. Script will not proceed."
  exit 1
fi

dos2unix $grid_size

# Read the contents of the input file
input=$(cat $grid_size)

# Extract and define values from gridsize_INPUT.txt
spacing=$(echo "$input" | grep "^spacing " | awk '{print $2}')
center_x=$(echo "$input" | grep "^center " | awk '{print $2}')
center_y=$(echo "$input" | grep "^center " | awk '{print $3}')
center_z=$(echo "$input" | grep "^center " | awk '{print $4}')
npts_x=$(echo "$input" | grep "^npts " | awk '{print $2}')
npts_y=$(echo "$input" | grep "^npts " | awk '{print $3}')
npts_z=$(echo "$input" | grep "^npts " | awk '{print $4}')

## Calculate the size of the grid in each dimension
size_x=$(echo "$spacing * $npts_x" | bc)
size_y=$(echo "$spacing * $npts_y" | bc)
size_z=$(echo "$spacing * $npts_z" | bc)


# Write new updated grid file
cat > "vina_input.in" << EOL
center_x = $center_x
center_y = $center_y
center_z = $center_z
size_x = $size_x
size_y = $size_y
size_z = $size_z
EOL

mv vina_input.in ..

echo "grid box processed"