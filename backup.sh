#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
cd $path

while IFS= read -r line1
do
     cp -r $line1
     echo $line1
done < backup
