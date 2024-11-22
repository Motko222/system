#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
cd $path

while IFS= read -r line1
do
  while IFS= read -r line2
   do
     cp -r $line1 $line2
     echo $line1   >   $line2
   done < backup-path
done < backup-list
