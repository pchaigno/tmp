#!/bin/bash
issue=$1
src_col_name=$2
dst_col_name=$3
project=$(curl -su pchaigno:$TOKEN -H "Accept: application/vnd.github.inertia-preview+json" https://api.github.com/repos/pchaigno/tmp/projects | jq '.[] | select(.name=="Test").id')
src_column=$(curl -su pchaigno:$TOKEN -H "Accept: application/vnd.github.inertia-preview+json" https://api.github.com/projects/$project/columns | jq ".[] | select(.name==\"$src_col_name\").id")
dst_column=$(curl -su pchaigno:$TOKEN -H "Accept: application/vnd.github.inertia-preview+json" https://api.github.com/projects/$project/columns | jq ".[] | select(.name==\"$dst_col_name\").id")
card=$(curl -su pchaigno:$TOKEN -H "Accept: application/vnd.github.inertia-preview+json" https://api.github.com/projects/columns/$src_column/cards | jq ".[] | select(.content_url | endswith(\"/$issue\")).id")
curl -u pchaigno:$TOKEN -X POST -H "Accept: application/vnd.github.inertia-preview+json" https://api.github.com/projects/columns/cards/$card/moves -d "{\"position\":\"top\",\"column_id\":$dst_column}"
