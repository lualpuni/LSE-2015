#!/bin/bash

# Master test script
# This script call all other test scripts in the test directory.

for filename in ./test/*.sh; do
   echo "Executing: "$filename""
   bash $filename
   if [ $? -ne 0 ]; then
      echo "Traceback: \""$filename"\" exiting with failure status." >&2
      exit 1
   fi
done

exit 0
