#! /bin/nu 

let string_number = "123"
let int_number = 123 

if $string_number != $int_number {
    print "The string and integer are not equal."
}

if ($string_number | describe) != ($int_number | describe) {
    print "The types can be checked first."
}

print $"string_number describe: ($string_number | describe)"
print $"int_number describe: ($int_number | describe)"

if ($string_number | into int) == $int_number {
    print "Casting to integer works."
} 
