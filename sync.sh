#!/bin/bash

minify style.css style.min.css
s3cmd sync --exclude=".git/*" --exclude="images/*" --exclude="lib/*" -P ./ s3://www.knut.mp/
rm style.min.css

imgexpire=$(python -c "from datetime import *; print (datetime.utcnow() + timedelta(days=8)).strftime('%a, %d %b %Y %H:%M:%S GMT')")
s3cmd sync -P --add-header="Expires:$imgexpire" ./lib/ s3://www.knut.mp/lib/

imgexpire=$(python -c "from datetime import *; print (datetime.utcnow() + timedelta(days=8)).strftime('%a, %d %b %Y %H:%M:%S GMT')")
s3cmd sync -P --add-header="Expires:$imgexpire" ./images/ s3://www.knut.mp/images/
