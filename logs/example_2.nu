#! /bin/nu

# Same as example_1 but adding
# Some more text manipulation and typing
# Grouping data

grep -ir "'miningportal' contains" -A 20 ./test_data/ | 
sed -r 's/\^\[\[[0-9;]*[a-zA-Z]//g' | # remove all ASCII escape codes
# Try to comment this line out.
grep -E '\([0-9]+\)' | # Only get relevant lines
split row -r '\n' |
wrap raw |
insert timestamp {|row| $row.raw | str substring 23..42 | str trim} |
insert message {|row| $row.raw | str substring 43..-1 | str trim} |
insert material {|row| $row.message | split column '(' material_raw amount_raw} |
flatten | flatten |
insert material {|row| $row.material_raw | str trim} |
insert amount_first_paranthese {|row| $row.amount_raw | str index-of ')' } |
insert amount {|row| $row.amount_raw | str trim | str substring 0..($row.amount_first_paranthese - 1) | into int} |
reject material_raw amount_raw message amount_first_paranthese |
group-by --to-table timestamp |
each {|row| $row.items | reduce -f $row {|it, acc| $acc | insert $it.material $it.amount}} | # This takes every row in the inner items table and add them as columns in the outer table
reject items |
insert timestamp_raw {|row| $row.timestamp} |
update timestamp {|row| $row.timestamp | into datetime} |
sort-by timestamp

# If you get errors 
# Error: nu::shell::column_not_found
#  × Cannot find column 'amount_raw'
#    ╭─[entry #27:10:39]
#  9 │ insert material {|row| $row.material_raw | str trim} |
# 10 │ insert amount_first_paranthese {|row| $row.amount_raw | str index-of ')' }
#    ·                                       ──┬─ ─────┬────
#    ·                                         │       ╰── cannot find column 'amount_raw'
#    ·                                         ╰── value originates here
#    ╰────
#
# Then it is likely because some of the values are missing.
