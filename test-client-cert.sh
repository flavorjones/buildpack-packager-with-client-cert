#! /usr/bin/env bash

# run from the host

echo "#"
echo "#  This request should fail to authenticate:"
echo "#"

`curl -s -k --output failure.html https://localhost:4443`
cat failure.html


echo "#"
echo "#  This request should successfully authenticate:"
echo "#"

`curl -s -k --output success.html --cert client.crt:asdf --key client.key https://localhost:4443`
cat success.html

echo "#"
if grep -q "No required SSL certificate" failure.html && grep -q "Authenticated page" success.html ; then
  echo "#  SUCCESS."
else
  echo "#  FAILURE."
fi
echo "#"
