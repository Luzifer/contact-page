#!/bin/bash

s3cmd sync --exclude=".git/*" --exclude="images/*" -P ./ s3://www.knut.mp/

imgexpire=$(python -c "from datetime import *; print (datetime.utcnow() + timedelta(days=1)).strftime('%a, %d %b %Y %H:%M:%S GMT')")
s3cmd sync -P --add-header="Expires:$imgexpire" ./images/ s3://www.knut.mp/images/
