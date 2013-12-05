#!/bin/bash

pow=32
get.mask()
{
   (( ${1} <=1 )) && echo ${pow} || { ((--pow)); get.mask $(($1/2)); }
}

echo 223.255.252.0 512 | while read ip cnt; do
        echo -n "${ip}:${cnt} "
        echo $(get.mask ${cnt})
done