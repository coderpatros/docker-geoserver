#!/usr/bin/env bash

# first we give GeoServer some time to startup
STARTUP_TIME=30
echo Waiting $STARTUP_TIME seconds for GeoServer to startup...
sleep $STARTUP_TIME
echo Continuing...

total=0
failed=0
passed=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function run_test {
    test_name=$1
    url=$2
    assert_response_code=$3
    assert_content=$4
    test_passed=true

    echo -n "$test_name... "
    response=$(curl --write-out %{http_code} --silent --output /dev/null $url)
    if [ "$assert_response_code" != "$response" ]; then
        test_passed=false
    fi
    content=$(wget $url -q -O -)
    if [ "$assert_content" != "" ] && [[ $content != *"$assert_content"* ]]; then
        test_passed=false
    fi

    if [ "$test_passed" = true ]; then
        echo -e "${GREEN}PASSED${NC}"
        ((passed++))
    else
        echo -e "${RED}FAILED${NC}"
        ((failed++))
        echo $assert_response_code
        echo $response
        echo $content
    fi
    ((total++))

}

run_test "Sending a request to the base url should return the Jetty context not found page" "http://geoserver:8080" 404 ""
run_test "Sending a request to the web interface should work" "http://geoserver:8080/geoserver/web/" 200 "This GeoServer instance is running version <strong>2.14.5</strong>"

echo
if [ $failed -eq 0 ]; then
    echo -n -e "$GREEN"
else
    echo -n -e "$RED"
fi
echo -n "PASSED: $passed | FAILED: $failed | TOTAL: $total"
echo -e "$NC"

exit $failed