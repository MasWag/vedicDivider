#!/bin/bash

for a in $(seq 0 32767); do
    d0=$RANDOM;
    d1=$(($RANDOM + 1));
    printf "%08x %08x %08x %08x\n" $d0 $d1 $(($d0 / $d1)) $(($d0 % $d1));
done

for a in $(seq 0 32767); do
    d0=$RANDOM$RANDOM;
    d1=$(($RANDOM + 1));
    printf "%08x %08x %08x %08x\n" $d0 $d1 $(($d0 / $d1)) $(($d0 % $d1));
done
