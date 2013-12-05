#!/bin/bash
for i in {b..f}; do
    echo -e "n\np\n1\n\n\nw" | fdisk /dev/sd${i}
done
