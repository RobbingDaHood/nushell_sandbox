#! /bin/nu

# Read data from files 
# Remove ASCII color codes 
# Split into rows pr. line 
# Extract important information 

grep -ir "'miningportal' contains" -A 20 ./test_data/ | 
sed -r 's/\^\[\[[0-9;]*[a-zA-Z]//g' | # remove all ASCII escape codes
split row -r '\n' |
wrap raw |
insert timestamp {|row| $row.raw | str substring 23..42 | str trim} |
insert message {|row| $row.raw | str substring 43..-1 | str trim} |
insert material {|row| $row.message | split column '(' material_raw amount_raw} |
flatten | flatten
