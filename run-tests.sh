#!/bin/sh

# This variable has to be updated to point to the location of packetdrill binary.
packetdrill=/usr/home/zeebsd/packetdrill/gtests/net/packetdrill/packetdrill
directory=$1

file=tests_list

if [ -z "$packetdrill" ]
then
  printf "Please set the value of \$packetdrill variable to the path of packetdrill binary on your machine.\n"
  exit
fi

if [ ! -e $file ]
then
  `find . -type f -iname '*.pkt' | cut -f 2 -d '.' > tests_list`
fi

if [ ! -z "$directory" ]
then
  `find ./$directory/ -type f -iname '*.pkt' | cut -f 2 -d '.' > temp_list`
  file=temp_list
fi

delay=0.2
run=0
skipped=0
passed=0
failed=0

`rm -f error.log`
printf "\nScript Name                                             Result\n"
printf "==============================================================\n"

while IFS= read test
do
  printf "%-55.55s " .$test
  `sleep $delay`
  if [ -e .${test}.pkt ]
  then
    `rm -f temp.log`
    `$packetdrill -v --tolerance_usecs=1000000 .${test}.pkt >> temp.log 2>&1`
    result="`echo $?`"
    if [ $result = 1 ]
    then
      `printf "Test Name: ${test}\.pkt\n" >> error.log`
      `printf "\---------------------------------------------------------\n" >> error.log`
      `cat temp.log >> error.log`
      `printf "\n" >> error.log`
      printf "FAILED\n"
      printf "\--------------------------------------------------------------\n"
      failed=`expr $failed + 1`
      # set -- "$@" $test
    else
      printf "PASSED\n"
      printf "\--------------------------------------------------------------\n"
      passed=`expr $passed + 1`
    fi
    run=`expr $run + 1`
  else
    printf "SKIPPED\n"
    skipped=`expr $skipped + 1`
  fi
done< "$file"
`rm -f temp.log`
`rm -f temp_list`

printf "\nSummary\n"
printf "===========================\n"

printf "Number of tests run: %6d\n" $run
printf "Number of tests passed: %3d\n" $passed
printf "Number of tests failed: %3d\n" $failed
printf "Number of tests skipped: %2d\n" $skipped
if [ $failed -ne 0 ]
then
  printf "\nView the log file (error.log) for details\n"
fi

# printf "\nList of failed tests\n"
# printf "===========================\n"
# printf '%s\n' "$@"
