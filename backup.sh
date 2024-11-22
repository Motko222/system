#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
cd $path

while IFS= read -r line
do
     backup_path=$(echo $line | awk '{print $2}')
     [ -d $backup_path ] || mkdir $backup_path
     cp -r $line
     echo $line
done < backup
