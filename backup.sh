#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
cd $path

while IFS= read -r line
do
     cp -r $line
     echo $line
done < backup
