#!/bin/bash

response=$(curl -s 'https://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/ermit/erm.pl' -X POST -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/118.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: https://forest.moscowfsl.wsu.edu' -H 'Connection: keep-alive' -H 'Referer: https://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/ermit/ermit.pl' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' --data-raw 'me=&units=ft&debug=&Climate=..%2Fclimates%2Fid106152&SoilType=sand&rfg=20&achtung=Run+WEPP&vegetation=forest&top_slope=0&avg_slope=50&toe_slope=30&length=300&severity=h&pct_shrub=&pct_grass=&pct_bare=&climate_name=&Units=m&actionw=Running+ERMiT...') 

#echo $response

js_unique=$(echo "$response" | grep -o -m 1 "wepp-[0-9]*" | awk '{print $1}')

cp ../../../working/$js_unique.* .
