#! /bin/nu 

print "*** list, record and table"
let elements_list  = [element_one, element_two, element_three]
print $elements_list
let record = {name: "record_name", value: 42, nested_field: {nested_valie: true}, array_field: [1, 2, 3]}
print $record
# The ; is critical
let table = [[column_one, column_two]; [first_row_1, first_row_2] [second_row_1, second_row_2]]
print $table



print "*** Iterate over list"
for element in $elements_list {
  print $element
}
print "*** Iterate over record transposed"
$record | transpose key value | each {|row| print $'($row)'}
print "*** Iterate over table"
$table | each {|row| print $'($row)' }


print "*** list to json"
print ($elements_list | to json)
print "*** record to json"
print ($record | to json)
print "*** table to json"
print ($table | to json)

print "*** Tricky: table into record: Only last row is kept"
print ($table | into record)
