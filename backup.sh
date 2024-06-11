#!/bin/bash

source ~/.bash_profile

echo "Removing old backup..."
if [ -d $BACKUP/scripts ] 
  then 
    rm -r $BACKUP/scripts
fi
mkdir $BACKUP/scripts

echo "Backing up scripts..."
for i in $(ls ~/scripts)
 do
  echo ~/scripts/$i
  mkdir $BACKUP/scripts/$i
  cp ~/scripts/$i/*.sh $BACKUP/scripts/$i
  if [ -d ~/scripts/$i/config ]
    then cp -r ~/scripts/$i/config $BACKUP/scripts/$i
  fi
done

echo "Backing up profile..."
echo ".bashrc"
cp ~/.bashrc $BACKUP
echo ".bash_profile"
cp ~/.bash_profile $BACKUP
echo "Done."
