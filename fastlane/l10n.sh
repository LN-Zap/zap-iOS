#!/bin/bash

project_name="Library"
development_file="../$project_name/en.lproj/Localizable.strings"

sed 's/^[^"]*"\([^"]*\)".*/\1/' $development_file |
sed '/^$/d' |
while read key; do
	exist=`grep -rl "\"$key\".localized" --include \*.swift --include \*.m ../$project_name/*`
	if [ -z "${exist}" ]; then
		echo "warning: \"$key\" is not used being used"
	fi
done

base_keys=`sed 's/^[^"]*"\([^"]*\)".*/\1/' $development_file`	
grep -r -o "\"[^\"]*\".localized" --include \*.swift --include \*.m ../$project_name/* --exclude ../$project_name/NSLocalizedString.swift | 
grep -v "%d" |
sed 's/^[^"]*"\([^"]*\)".*/\1/' | 
sort -u | 
while read key; do
	if [[ $base_keys != *$key* ]]; then
		echo "error: \"$key\" not defined"
	fi
done
