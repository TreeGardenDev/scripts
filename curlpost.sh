#!/bin/bash

#Goal - initialize with a curl --json command. accept a url in the first argument and a .json file in the second argument.

json=$1
url=$2
curl -X POST -H "Content-Type: application/json" -v -d @$json $url
