#!/usr/bin/env bash

sed -n -e '/^\s*$/p' -e 's#export\(\s*\)\(.*\)#\2#p' .envrc | sed -n -e "H;$ {x;s/^\s*//p;}" > local.env
