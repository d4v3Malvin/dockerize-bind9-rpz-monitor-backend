#!/bin/bash

outputsfile=$1

extract () {
	file='/var/log/bind/temp_query.log'
	while read line; do
		sh -c "sed -i \"/$line/d\" /var/log/bind/query.log"
		date=$( echo $line | cut -d " " -f 1 )
		type_log=$( echo $line | cut -d " " -f 3 | cut -d ":" -f 1)
		client=$( echo $line | cut -d " " -f 7 | cut -d "#" -f 1 )
		times=$( echo $line | cut -d " " -f 2 | cut -d "." -f 1 )
		if [[ $line =~ "queries"  ]]; then
					query=$( echo $line | cut -d " " -f 10 )
					type=$( echo $line | cut -d " " -f 12 )
					echo $type_log,$date,$times,$client,$query,$type'|' >> $outputsfile
		elif [[ $line =~ "query-error"  ]]; then
			query=$( echo $line | cut -d " " -f 8 )
			echo $type_log,$date,$times,$client,$query,"error","Blocked By Client Filtering"'|' >> $outputsfile
		elif [[ $line =~ "rpz" ]]; then
			querys=$( echo $line | cut -d " " -f 8 | cut -d " " -f 1 | cut -d "(" -f 2)
			zone=$(echo $line | cut -d " " -f 15)
			echo $type_log,$date,$times,$client,$query,"RPZ","Rewrite via "$zone'|' >> $outputsfile
		fi
	done < $file
}

if [ ! -e "$outputsfile" ]; then 
	touch "$outputsfile"
fi

cp /var/log/bind/query.log /var/log/bind/temp_query.log

extract

rm /var/log/bind/temp_query.log

rndc reload