#! /usr/bin/env bash

apt-get -q -q update
apt-get -q -q install -y nginx
service nginx stop
echo ""
echo "  When prompted, enter 'asdf' for the PEM passphrase."
echo ""
nginx -c /nginx/nginx.conf
echo ""
echo "  When you're done, simply 'exit'."
echo ""
bash
