#!/bin/bash

for a in $(seq 0 255); do
    d0=$RANDOM;
    d1=$RANDOM;
    printf "%08x %08x %08x %08x\n" $d0 $d1 $(($d0 / $d1)) $(($d0 % $d1));
done

for a in $(seq 0 255); do
    d0=$RANDOM$RANDOM;
    d1=$RANDOM;
    printf "%08x %08x %08x %08x\n" $d0 $d1 $(($d0 / $d1)) $(($d0 % $d1));
done
