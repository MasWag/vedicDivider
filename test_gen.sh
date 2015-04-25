#!/bin/bash

for a in $(seq 0 255); do
    for b in $(seq 8 15); do
        printf "%02x %01x %02x %01x\n" $a $b $(($a / $b)) $(($a % $b));
    done
done
