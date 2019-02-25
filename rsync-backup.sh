#!/bin/sh
# Usage: rsync-backup.sh <src>

if [ "$#" -ne 1 ]; then
    echo "$0: Expected 1 arguments, received $#: $@" >&2
    echo "Usage: rsync-backup.sh <src>"
    exit 1
fi

src=$1
user=root
dataset="$user"

host=`echo $src | awk -F. '{print $1}'`
path=`echo $src | awk -F: '{print $2}'`

if [ "$path" != "" ]; then
  first=${path:$i:1}

  if [ $first == "/" ]; then
    dataset="${dataset}_ROOT"
  else
    dataset="${dataset}_HOME"
  fi
  if [ $first != "" ]; then
    rest=`echo $path | tr \/ -`
    dataset="$dataset-$rest"
  fi
fi

dataset=`echo $dataset | sed s/--/-/g`
dataset=`echo $dataset | sed s/-$//g`

ts=`date +%Y-%m-%d-%H%M%S`

base="/share/CACHEDEV1_DATA/homes/ccaseiro/BACKUPS"
dst="$base/$host/$dataset"
latest="$dst/Latest"
final="$dst/$ts"
inProgress="$final.inProgress"

mkdir -p $dst

if [ -d $latest ]; then
  command="rsync -a --link-dest=$latest $user@$src $inProgress"
else
  command="rsync -a root@$src $inProgress"
fi

$command
code=$?

if [ $code -eq 0 ]; then
  command="mv $inProgress $final"
  $command

  if [ -L $latest ]; then
    rm $latest
  fi
  command="ln -s $final $latest"
  $command
fi

exit $code

