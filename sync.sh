#!/bin/bash

find . -name '.DS_Store' -delete

mkdir rendered
for template in $(find templates -name 'tpl_*'); do
  swig render $template > rendered/$(basename $template | sed 's/tpl_//')
done
minify style.css rendered/style.min.css

s3cmd sync --exclude=".git/*" --exclude="images/*" --exclude="lib/*" --exclude="sync.sh" --exclude="style.css" -P ./rendered/ s3://www.knut.mp/
rm -rf rendered

imgexpire=$(python -c "from datetime import *; print (datetime.utcnow() + timedelta(days=8)).strftime('%a, %d %b %Y %H:%M:%S GMT')")
s3cmd sync -P --add-header="Expires:$imgexpire" ./lib/ s3://www.knut.mp/lib/

imgexpire=$(python -c "from datetime import *; print (datetime.utcnow() + timedelta(days=8)).strftime('%a, %d %b %Y %H:%M:%S GMT')")
s3cmd sync -P --add-header="Expires:$imgexpire" ./images/ s3://www.knut.mp/images/
