#! /bin/nu
open ./test_data/first_data.json | select friends | transpose
