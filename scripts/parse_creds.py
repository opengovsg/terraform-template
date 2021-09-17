import json
import sys

# parse output and export credentials
creds = json.loads(''.join(sys.argv[1:]))
exportAccessKey = 'export AWS_ACCESS_KEY_ID=' + creds['Credentials']['AccessKeyId']
exportSecretKey = 'export AWS_SECRET_ACCESS_KEY=' + creds['Credentials']['SecretAccessKey']
exportSessionToken = 'export AWS_SESSION_TOKEN=' + creds['Credentials']['SessionToken']
print(exportAccessKey)
print(exportSecretKey)
print(exportSessionToken)
