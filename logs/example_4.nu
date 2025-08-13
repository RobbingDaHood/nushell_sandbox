#! /bin/nu

# Same as example_3 but adding

let setup_parsed_columns = grep -ir "'miningportal' contains" -A 20 ./test_data/ | 
sed -r 's/\^\[\[[0-9;]*[a-zA-Z]//g' | # remove all ASCII escape codes
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

let calculate_diff_pr_status = $setup_parsed_columns |
window 2 | # Calcualate the duration
each {|pair| 
    $pair |
    last |
    insert duration {|row| ($pair.1.timestamp | into datetime) - ($pair.0.timestamp | into datetime)}
} |
window 2 | # group with row before if duration is less than 5 seconds, because a mining update could take more than one second to print 
each {|pair| 
    # This logic assumes that there are not more than two events in a row with less than 5 seconds distance
    if $pair.1.duration > 0sec and $pair.1.duration <= 5sec { # Merge because they each have a half of the result
    	let timestamp_raw = $pair.1.timestamp_raw
    	let timestamp = $pair.1.timestamp
      $pair | 
      math sum |
      insert timestamp $timestamp |
      insert timestamp_raw $timestamp_raw 
    } else if $pair.0.duration <= 5sec { # Ignored becase this row is already handled above
      {}
    } else { # This is a new row and it should not be merged with the second row
      $pair | first
    }
} |
where ($it | is-not-empty) | 
window 2 | # Get the diff from ther row before
each {|pair| 
    let timestamp_raw = $pair.1.timestamp_raw
    let timestamp = $pair.1.timestamp
    $pair.1 | items {|key, value|
        if $key == "timestamp_raw" or $key == "duration" or $key == "timestamp" {
                {$key: $value}
        } else if $key in ($pair.0 | columns) {
                {$key: ($value - ($pair.0 | get $key))}
        } else {
                {$key: 0}
        }
    } |
    math sum |
    insert timestamp $timestamp |
    insert timestamp_raw $timestamp_raw 
}

$calculate_diff_pr_status |
reduce -f [[]] {|row, acc| # If duration is more than 10 minutes then it would likely be a new session, because we log every 5 minutes
    let last = ($acc | last)
    if $row.duration < 10min {
        $acc | upsert (($acc | length) - 1) ($last ++ [$row]) # Add this row to the last inner table
    } else {
      $acc ++ [[ $row ]] # not same session so start new table
    }
} |
where ($it | length) > 0 | 
each {|group| # Merge all updates in each session 
    $group |
    reject timestamp_raw duration |
    math sum |
    flatten |
    insert start ($group | first | get timestamp_raw | into datetime | format date "%Y-%m-%d-%H:%M:%S") |
    insert end ($group | last | get timestamp_raw | into datetime | format date "%Y-%m-%d-%H:%M:%S")
} |
flatten |
each {|row| $row | insert duration (($row.end | into datetime) - ($row.start | into datetime))} | # Calculate new duration
reject end |
sort-by start |
move duration --first |
move start --first
