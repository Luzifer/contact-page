#!/bin/bash

find . -name '.DS_Store' -delete
npm install swig minify

mkdir rendered
for template in $(find templates -name 'tpl_*'); do
  outfilename=$(basename $template | sed 's/tpl_//')
  echo "Rendering ${outfilename}..."
  ./node_modules/.bin/swig render $template > rendered/$outfilename
done
./node_modules/.bin/minify style.css rendered/style.min.css

rm -rf node_modules

s3cmd sync --exclude=".git/*" --exclude="images/*" --exclude="lib/*" --exclude="sync.sh" --exclude="style.css" -P ./rendered/ s3://knut-ahlers.de/
rm -rf rendered

s3cmd sync -P ./files/ s3://knut-ahlers.de/files/

imgexpire=$(python -c "from datetime import *; print (datetime.utcnow() + timedelta(days=8)).strftime('%a, %d %b %Y %H:%M:%S GMT')")
s3cmd sync -P --add-header="Expires:$imgexpire" --delete-removed ./lib/ s3://knut-ahlers.de/lib/

imgexpire=$(python -c "from datetime import *; print (datetime.utcnow() + timedelta(days=8)).strftime('%a, %d %b %Y %H:%M:%S GMT')")
s3cmd sync -P --add-header="Expires:$imgexpire" --delete-removed ./images/ s3://knut-ahlers.de/images/
