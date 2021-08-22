#!/bin/bash
issue=$1
label=$2

if [[ "$label" != status/* ]]; then
	exit 0
fi

project=$(curl -su pchaigno:$TOKEN -H "Accept: application/vnd.github.inertia-preview+json" https://api.github.com/repos/pchaigno/tmp/projects | jq '.[] | select(.name=="Test").id')
columns=$(curl -su pchaigno:$TOKEN -H "Accept: application/vnd.github.inertia-preview+json" https://api.github.com/projects/$project/columns | jq ".[].id")
dst_col_name=${label#"status/"}
for col in ${columns[@]}; do
	dst_column=$(curl -su pchaigno:$TOKEN -H "Accept: application/vnd.github.inertia-preview+json" https://api.github.com/projects/$project/columns | jq ".[] | select(.name|ascii_downcase==\"$dst_col_name\").id")
	if [ "$dst_column" == "" ]; then
		echo "No project column found for label $label."
		exit 1
	fi
	card=$(curl -su pchaigno:$TOKEN -H "Accept: application/vnd.github.inertia-preview+json" https://api.github.com/projects/columns/$col/cards | jq ".[] | select(.content_url | endswith(\"/$issue\")).id")
	if [ "$card" != "" ] && [ "$col" != "$dst_column" ]; then
		echo "Moving issue to appropriate column."
		curl -u pchaigno:$TOKEN -X POST -H "Accept: application/vnd.github.inertia-preview+json" https://api.github.com/projects/columns/cards/$card/moves -d "{\"position\":\"top\",\"column_id\":$dst_column}"
		break
	fi
done
