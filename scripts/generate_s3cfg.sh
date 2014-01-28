#!/bin/bash

printf "[default]\naccess_key = ${AWS_KEY}\nsecret_key = ${AWS_SECRET}\n" > ~/.s3cfg
