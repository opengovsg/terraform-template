#! /bin/bash

creds=`aws sts get-session-token --serial-number $1 --token-code $2 --profile $3 --duration-seconds 129600`
python3 parse_creds.py $creds > ../temp_aws_credentials