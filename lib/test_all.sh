#!/usr/bin/env bash

for lib in $(ls lib/*.sh | grep -v test) ; do

  source $lib
  echo $lib

  for test in $(grep -E 'function\s+.*test' "$lib" | grep -o '\w*test\w*') ; do
    echo -ne "    $test ... "
    if $test ; then
      echo ok!
    else
      echo failed!
    fi
  done
done
