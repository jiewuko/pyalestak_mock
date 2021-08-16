/home/jiewuko/PycharmProjects/bitnet/statistics/scripts#!/usr/bin/env bash

function finc_dependencies_files() {
  local path="$1"
  find "${path}" -type f \( -executable -o -iname "*.so" \) \
    -exec sh -c 'file -i "$1" | grep -Eq "(x-executable|x-sharedlib)"' _ {} \; -print0 | \
    xargs -0 -n1 ldd 2>&1 | \
    grep " => " | awk '{print $3}' | grep '^/' | sort -u
}


function get_packages() {
    local files=$1
    for fl in ${files}; do
      dpkg -S "${fl}" 2>/dev/null
    done
}

files=( "$(finc_dependencies_files "${1}")" )
get_packages "${files[@]}" | cut -d ":" -f 1 | sort -u
