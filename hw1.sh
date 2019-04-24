#!/bin/bash
if [[ $# -ne 2 ]]
then 
   echo "Not enough arguments passed"
else
    cat $1 |tr -d '[:punct:]' | tr ' ' '\n' | tr [:upper:] [:lower:] | sort -u | while read p; do
      if ! grep -Fq $p $2
      then
  	echo "$p:$(tre-agrep -s -w -i -B $p $2 | head -1)"
      fi
done
fi
