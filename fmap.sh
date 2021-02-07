#!/bin/bash
# Get optional path argument
path=$1
if ! [[ $selector =~ ^[/.] ]] || [[ ! -z "$selector" ]]; then selector="."$selector; fi
selector=".base"$(echo $path | /usr/bin/tr / .)
echo $selector

# Start at specified path
/usr/bin/cat $PWD/base.fmap | /usr/bin/jq $selector
# /dev/null 2>&1
