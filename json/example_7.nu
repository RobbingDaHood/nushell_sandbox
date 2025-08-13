#! /bin/nu
let data = open ./test_data/first_data.json
let friends_groups = $data | get friends

print "Get all names"
for friend in ($friends_groups | flatten) {
  print $'Name of friend: ($friend.name)'
}

print "Remove duplicates and sort"
let uniq_sorted = $friends_groups | flatten | get name | uniq | sort
print $uniq_sorted

print "different formats"
print ($uniq_sorted | to json)
print ($friends_groups | flatten | flatten | to csv)
print ($friends_groups | flatten | flatten | to html)
