#!/bin/bash

response=$(curl -s 'https://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/wd/wd.pl' POST -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/118.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: https://forest.moscowfsl.wsu.edu' -H 'Connection: keep-alive' -H 'Referer: https://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/wd/weppdist.pl' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'TE: trailers' --data-raw 'me=&units=ft&description=&climyears=100&Climate=..%2Fworking%2F50_52_98_70_c&achtung=WEPP+run&SoilType=sand&UpSlopeType=HighFire&ofe1_top_slope=20&ofe1_length=500&ofe1_pcover=25&ofe1_rock=20&ofe1_mid_slope=40&LowSlopeType=HighFire&ofe2_top_slope=40&ofe2_length=50&ofe2_pcover=25&ofe2_rock=20&ofe2_bot_slope=15&climate_name=*FAIRFIELD++R+S+ID&Units=m&actionw=Run+WEPP')

#echo $response

js_unique=$(echo "$response" | grep -o -m 1 "wepp-[0-9]*" | awk '{print $1}')

cp ../../../working/$js_unique.* .
