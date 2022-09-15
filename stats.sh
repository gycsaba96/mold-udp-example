#!/bin/bash
# $1: P4RROT_TEMPLATE
# $2: P4RROT_CODE

P4RROT_TEMPLATE=$1
P4RROT_CODE=$2

echo "### Line-of-Code stats"
echo "Using $P4RROT_CODE and $P4RROT_TEMPLATE"

echo 
echo "# Python"

echo "P4RROT code:"
C1=$(cat $P4RROT_CODE | sed '/^\s*$/d' | wc -l)
echo $C1

echo "Plugins:"
C2=$(cat plugins.py | sed '/^\s*$/d' | wc -l )
echo $C2

echo "Total Python:"
echo $( expr $C1 + $C2 )

echo 
echo "# P4"

echo "Generated P4 code in total:"
find output_code | grep -e '\.p4$' | xargs cat | sed '/^\s*$/d' | wc -l

echo "Generated P4 code excluding template:"
find output_code | grep -e '\a_.*\.p4$' | xargs cat | sed '/^\s*$/d' | wc -l

echo "P4 code in template:"
find $P4RROT_TEMPLATE | grep -e '.*\.p4$' | xargs cat | sed '/^\s*$/d' | wc -l

