#!/bin/bash

source ~/scripts/system/config/env

echo "Removing old backup..."
if [ -d $backup/scripts ] 
  then 
    rm -r $backup/scripts
fi
mkdir $backup/scripts

echo "Backing up scripts..."
for i in $(ls ~/scripts)
 do
  echo ~/scripts/$i
  mkdir $backup/scripts/$i
  cp ~/scripts/$i/*.sh $backup/scripts/$i
  if [ -d ~/scripts/$i/config ]
    then cp -r ~/scripts/$i/config $backup/scripts/$i
  fi
done

echo "Backing up profile..."
echo ".bashrc"
cp ~/.bashrc $backup
echo "Done."
