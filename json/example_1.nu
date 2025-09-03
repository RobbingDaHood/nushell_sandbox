#! /bin/nu

print open ./test_data/first_data.json
print (open ./test_data/first_data.json | to json)
print (open ./test_data/first_data.json | columns)
print (open ./test_data/first_data.json | get friends)
print (open ./test_data/first_data.json | get 1.friends.0)
print (open ./test_data/first_data.json | select friends)
print (open ./test_data/first_data.json | select friends | transpose)
