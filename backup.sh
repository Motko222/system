#!/bin/bash

source ~/scripts/system/config/env

echo "Removing old backup..."
if [ -d $backup/scripts ] 
  then rm -r $backup/scripts 
  else  mkdir $backup/scripts
fi

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
cp ~/.bashrc $backup
echo "Done."
