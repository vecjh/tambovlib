#!/bin/bash

if [ -z  "$1" ]; then
  echo  "usage: tambovlib.sh book-url"
  exit  1
fi

if [ "$#" -ne  1 ]; then
  echo  "usage: tambovlib.sh book-url"
  exit  1
fi

URL="$1"
BOOKID=${URL#h*=}
INDEXP="./tambovlib-$BOOKID/$BOOKID.index.html"
CLEANP="./tambovlib-$BOOKID/$BOOKID-image_list.txt"

mkdir -p "tambovlib-$BOOKID"

echo  "Loading root page ..."
wget --no-check-certificate --quiet -O  $INDEXP  $URL
if \[ "$?" -ne  0 \]; then
  echo  "Unable to load the page"
  exit  1
fi

awk  'BEGIN { RS = "{\"id\"" } ; { print $0 }' $INDEXP | grep -oG ':\"....................\"' | tr -d ':"' > $CLEANP

NPAGES=`wc -l < $CLEANP`
echo  Number  of  pages: $NPAGES

# available resolutions: 800x1200,1333x2000,1466x2200,1600x2400,1733x2600,1866x2800

PAGEIDS=`cat $CLEANP`
PAGE=1
for  ID  in  $PAGEIDS ; do
  echo  "Loading page $PAGE (of $NPAGES) ..."
  URL="https://elibrary.tambovlib.ru/?eimg=$ID.1866x2800&r=0"
  wget --no-check-certificate --quiet -O  ./tambovlib-$BOOKID/$BOOKID-$(printf '%04d' "$PAGE").jpg  $URL
  if [ "$?" -ne  0 ]; then
  echo  "Unable to load the page ($URL)"
  exit  1
  fi
  let  PAGE=PAGE+1
done

rm -f $CLEANP
rm -f $INDEXP
