#!/bin/bash
FLAG=${2}
for i in $(seq 0 ${1})
do
    L=$((32*2**$i))
    echo -n "${L} "
    ./test -L ${L} -s $((($L*$L)/4)) -n 1000 $FLAG  > L${L}.dat
done