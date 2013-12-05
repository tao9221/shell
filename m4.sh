#/bin/bash

string=abcde123

echo "len($string)" | m4                     #8
echo "substr($string,4)" | m4                #e123
echo "regexp($string,[0-9][0-9][0-9],\&Z)" | m4   #123Z

echo "incr(22)" | m4                         #23
echo "eval(99/3)" | m4                       #33

exit 0
