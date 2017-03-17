#!/bin/bash

set -e

function usage {
  echo "usage: ./process_crash.sh <crash_uid>"
}

if [ -z $1 ];
then
  usage;
  exit -1
fi

DUMP_UID="$1"

minidump_stackwalk='breakpad/src/processor/minidump_stackwalk'

ls -lt "$HOME/Library/Application Support/Google/Chrome/Crashpad/completed/"


OUTPUT_DIR=derived_dump_data

mkdir -p $OUTPUT_DIR
cp "$HOME/Library/Application Support/Google/Chrome/Crashpad/completed/${DUMP_UID}.dmp" $OUTPUT_DIR

$minidump_stackwalk $OUTPUT_DIR/${DUMP_UID}.dmp > $OUTPUT_DIR/${DUMP_UID}.stackwalk

echo ""
echo ""
echo "missing symbols:"
echo ""
$minidump_stackwalk $OUTPUT_DIR/${DUMP_UID}.dmp $OUTPUT_DIR/${DUMP_UID}.my_symbols 2>&1 | grep my_symbols | sed 's/^.*my_symbols\(.*\)/\1/g' | while read line
do
  IFS='/' read -a myarray <<< "$line"
  LIB=${myarray[1]}
  LIB_HASH=${myarray[2]}
  OUTPUT_SYMBOL=${myarray[3]}

  echo "$LIB, $LIB_HASH, $OUTPUT_SYMBOL"

  # call a function that looks up the symbols
  # build dump_syms over in `breakpad/src/tools/mac/dump_syms/`
  # then call:
  # breakpad/src/tools/mac/dump_syms/build/dump_syms/Build/Products/Debug/dump_syms

  # per the instructions over at: https://www.chromium.org/developers/decoding-crash-dumps
  # In order to get the symbol file for libfoo, one needs to have a copy of the exact libfoo binary from the system that generated the crash and its corresponding debugging symbols. Oftentimes, Linux distros provide libfoo and its debugging symbols as two separate packages. After obtaining and extracting the packages, use dump_syms to extract the symbols. Assuming the library in question is /lib/libfoo.so and its debugging symbol is /usr/debug/lib/libfoo.so, run:

  # dump_syms /lib/libfoo.so /usr/debug/lib > /tmp/libfoo.sym

  # To verify it's the correct version of libfoo, look at the hash from the
  # minidump_stackwalk output and compare it to the hash on the first line. If
  # they match, move /tmp/libfoo.sym to /tmp/my_symbols/libfoo/hash/libfoo.sym
  # and minidump_stackwalk will load it on future runs to give better
  # stacktraces.

done




