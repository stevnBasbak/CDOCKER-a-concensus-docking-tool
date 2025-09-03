#!/bin/bash

output_file="../DOCKING/Data_Analysis.txt"

# Delete the output file if it already exists
if [[ -f "$output_file" ]]; then
    rm "$output_file"
fi

echo "Comformer average affinity" >> "$output_file"

for i in {1..999}; do
    file_path="../DOCKING/Merged_Summary.txt"
    target_line_prefix="SMILE${i}_split"
    total_result=0
    total_count=0

    # Loop over each split
    for ((split_number=1; ; split_number++)); do
        # Formulate the target prefix for the current split
        target_line_prefix_current="${target_line_prefix}${split_number}"

        # Read the file and find the lines with the target prefix
        target_lines=$(grep "$target_line_prefix_current" "$file_path")

        if [[ -n $target_lines ]]; then
            # Variables for the current split
            split_result=0
            split_count=0

            # Loop over each line with the target prefix
            while IFS= read -r target_line; do
                # Extract the numbers from the target line and add them
                numbers=($(echo "$target_line" | awk '{ for (i=1; i<=NF; i++) { if ($i ~ /^-?[0-9]+(\.[0-9]+)?$/) { print $i } } }'))

                for number in "${numbers[@]}"; do
                    split_result=$(awk "BEGIN {print $split_result + $number}")
                    ((split_count++))
                done
            done <<< "$target_lines"

            # Calculate the average for the current split
            if [[ $split_count -gt 0 ]]; then
                split_average=$(awk "BEGIN {print $split_result / $split_count}")
                echo "Average for $target_line_prefix_current: $split_average" >> "$output_file"
                echo "Average for $target_line_prefix_current: $split_average"
            fi

            # Accumulate the total result and count
            total_result=$(awk "BEGIN {print $total_result + $split_result}")
            ((total_count+=split_count))
        else
            # Break the loop if no more target lines are found
            break
        fi
    done

done

echo "" >> "$output_file"
echo "MOST STABLE COMFORMERS" >> "$output_file"
echo "MOST STABLE"


#!/bin/bash

# Define the path to the file
file_path="../DOCKING/Data_Analysis.txt"

# Look for lines containing "Average for SMILE_*_split*:" and extract the number
grep -Eo "SMILE[0-9]+_split[0-9]+: [0-9.-]+" "$file_path" | awk -F ': ' '{print $1, $2}' | sort -k2,2n
grep -Eo "SMILE[0-9]+_split[0-9]+: [0-9.-]+" "$file_path" | awk -F ': ' '{print $1, $2}' | sort -k2,2n >> $file_path


echo "" >> "$output_file"
echo "LEAST STABLE"
echo "LEAST STABLE COMFORMERS" >> "$output_file"

# Look for lines containing "Average for SMILE_*_split*:" and extract the number
grep -Eo "SMILE[0-9]+_split[0-9]+: [0-9.-]+" "$file_path" | awk -F ': ' '{print $1, $2}' | sort -k2,2rn
grep -Eo "SMILE[0-9]+_split[0-9]+: [0-9.-]+" "$file_path" | awk -F ': ' '{print $1, $2}' | sort -k2,2rn >> $file_path

