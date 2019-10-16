#!/bin/bash

# get script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

content=`cat /mnt/c/Users/patri/.azure/principals.json`
len=`echo $content | jq '. | length'`

for (( i=0; i<$len; i++ ))
do
    element=`echo $content | jq --arg i $i '.[$i|tonumber]'`
    role=`echo $element | jq .role -r`
    if [[ $role != "Contributor" ]]; then
        continue
    fi
    export ARM_CLIENT_ID=`echo $element | jq .appId -r`
    export ARM_SUBSCRIPTION_ID=`echo $element | jq .subscriptionId -r`
    export ARM_CLIENT_SECRET=`echo $element | jq .password -r`
    export ARM_TENANT_ID=`echo $element | jq .tenant -r`    
    break
done