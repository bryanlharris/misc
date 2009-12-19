#!/bin/bash
echo "select ns_name,ticker from customer where ns_name regexp '$1';" | mysql doa | grep -v ticker
