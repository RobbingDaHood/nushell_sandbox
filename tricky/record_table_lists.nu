#! /bin/nu 

print "*** list, record and table"
let elements_list  = [element_one, element_two, element_three]
print $elements_list
let record = {name: "record_name", value: 42, nested_field: {nested_valie: true}, array_field: [1, 2, 3]}
print $record
# The ; is critical
let table = [[column_one, column_two]; [value_one, value_two]]
print $table

print "*** Iterate over list"
for element in $elements_list {
  print $element
}

print "*** Iterate over record transposed"
$record | transpose key value | each {|row| print $'($row.key):($row.value)' }

print "*** print record transposed"
print ($record | transpose)

print "*** Iterate over table"
$table | each {|row| print $'($row.column_one):($row.column_two)' }
