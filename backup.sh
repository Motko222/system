#!/bin/bash

source ~/scripts/system/config/env

echo "Backing up scripts..."
if [ -d $backup/scripts ]; then true else  mkdir $backup/scripts; fi

for i in $(ls ~/scripts)
 do
  echo ~/scripts/$i
  if [ -d $backup/scripts/$i ]
    then rm -r $backup/scripts/$i 
    else mkdir $backup/scripts/$i
  fi
  cp ~/scripts/$i/*.sh $backup/scripts/$i
  if [ -d ~/scripts/$i/config ]
    then cp -r ~/scripts/$i/config $backup/scripts/$i
  fi
done

echo "Backing up profile..."
cp ~/.bashrc $backup
echo "Done."
