#################################################################################
### Template script to pull an image from a remote AWS ECR
### Risk Management: 2022-09-13 Initial Version 
###
### Interactive login:
###    echo $token | docker login --username AWS --password-stdin 162015117822.dkr.ecr.eu-west-1.amazonaws.com
#################################################################################

export awsEcrRegistry=162015117822.dkr.ecr.eu-west-1.amazonaws.com
export imageNameAndTag=162015117822.dkr.ecr.eu-west-1.amazonaws.com/aip/rafm-8.2.5_220913:0.3.2

echo "To generate a new token go to AIP DEV environment and run: `aws ecr get-login-password`"
export token=eyJwYXlsb2FkIjoiSFA1Y3ZhUkNNM1JVSnBoV3dLaW1KYy91TS91OVpBeWY0TDJIMDhVa3g2WThMMUNWSU9yTFRzeHN4czRUS1V4UTZQVGZ0aG95RHJJdStLUjNLM3d0QTFoRDhidmROQVdJOXFMc1B2RmxiWWpsNHNNM2x5NkZ5R1duc0g1T3FBM25FRldQdHRUR05JYndUenFrdGxyQVpqa0hPMkNBL3ZFbXRrY2N0OURBMDFQWmU0cUxQQWFFY25DSWVIL1ZRMnRkbGpTSDRkTXdqb3dwVkpZNHhsMlRQdTNqZTlQeXJWZC9EUkNoK3N1RFpNV2JJeGlHNDRtVFlxUUFabXJGdkFZV1llSzBMa09ORFU0MzhtempaQlNTajMvWjEwWjM4dkhvcTRPQ1NXd0tPNitQclY5UzNxRkZRWFV0NHQ1RndkaTlUOFRicTlvQXN6OUhNL1lVbGQvMWxUblAwWFQ0bTZyUzZsRVoxckc2Zm5PT3N1bFA3elZZOS9HTGFFcWN0UzNUdWNyeUtFVzMwYWlWWlNZbDFBVnZ6NkhXYlRpUElKdFNJOThtaUFsNGgzcjBKZmorM0ZtVkZISllYOTBTd2VOSHNOYU9VZ3BGS1RqN3hSMkhPQ3lCQ1ZRMllBRDY4OFpqeW9RM0NsalVYdS91S3JBWEtZNzZhd0lyc2k1OGxseENJQmZoZkk4SmhSaDFGV3ZoSXRyOXRUc0xPVGRDTmJjdDN1SHl3K3llWjU2YzJBTVRnWFpPQk1la1Nkbkx2S0hHWlhDSVdyYVVZcUlKU3Vvc1RlakZ0N0JpbzV3dGFZU1VMcEZobnNJRFR5aFlPSnM1MS9OUjM4WVlDbnk3NGo0KzlwT3dWajM0VU81VWpRL21RNVU1TnozNzgrUEpsampoV3JwaVRtdjJlVVlicDZiTWs5VDA3YVpLT3NXcWdsQThTZ0FrcEtMazZMcktiQXZ3V0lRaDJOZVFWREhQWUJQVUtoZ1VJby9QSTRBcWx3OU04VDdSZDJJMk1GRHB1Z2pFazlISkR0TVhtYUFxSmxHeG94dnhLSGduN25GYWVFUXRISkxUNW1FSGJvK05sQ011aVVHYnVrMGFDVTRFTjU4cndoMndBd3hUU3EwNSthQXVWUm1KdjNQTXdOL2drSXUvanBaRGNWeVFOT3hZT1VzSEZETnZBNXlMWklHbE9KRWN3NWowU1RGMVZkU3BGY2tnSDZLY1VvZTlWMUxtU05PUFBzTmx0eFRTSHFlR2NVOHdRM01adXlNUWRWSDdPTWh4bEtsN0Z5R2JFa1NDckt6dXBrdUlWU1Z3ZTU5NzdhUkwxVFBlNEprTE5pY2pBUm5odVZpZTEzY0lFUlROMVI0cnpWQVQ3S3FPam1xVnVaTzR6SlBPMnhYVDRWM0QyM1A1QUE9PSIsImRhdGFrZXkiOiJBUUVCQUhoK2RTK0JsTnUwTnhuWHdvd2JJTHMxMTV5amQrTE5BWmhCTFpzdW5PeGszQUFBQUg0d2ZBWUpLb1pJaHZjTkFRY0dvRzh3YlFJQkFEQm9CZ2txaGtpRzl3MEJCd0V3SGdZSllJWklBV1VEQkFFdU1CRUVERERlbjZjb1hicmFmWFJHa0FJQkVJQTdodER0ZkZvUFo2cXRDa0lJTVdLZ0pHai9GOFdiWDc5QkFpUHg3MThzWStBWjdkQ1ZJVTlrVEVRNENyT21QT2JFaEtnb0ZQdUlvR1VISFVNPSIsInZlcnNpb24iOiIyIiwidHlwZSI6IkRBVEFfS0VZIiwiZXhwaXJhdGlvbiI6MTY2MzQ4MTA4NH0=


# Alternative1 (direct login if tehre is alreadt an AWS profile for the remote ECR): aws ecr get-login-password --profile aip-dev | docker login --username AWS --password-stdin $awsEcrRegistry
# Alternative2: echo $token | docker login --username AWS --password-stdin 162015117822.dkr.ecr.eu-west-1.amazonaws.com

docker login --username AWS --password $token  $awsEcrRegistry

docker image pull $imageNameAndTag

