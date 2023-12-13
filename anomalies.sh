#!/bin/sh

# Script inteded to show all unique logged messages from nftables within dmesg
dmesg | cut -d " " -f 3- | cut -d " " -f 1-12,14- | sort -u
