#!/bin/bash

s3cmd sync --exclude=".git/*" --delete-removed -P ./ s3://www.knut.mp/
