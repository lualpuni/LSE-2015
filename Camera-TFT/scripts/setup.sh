#!/bin/bash

# Master setup script
# This script call all other setup scripts in the setup directory.

for filename in ./setup/*.sh; do
   echo "Executing: "$filename""
   bash $filename
   if [ $? -ne 0 ]; then
      echo "Traceback: \""$filename"\" exiting with failure status." >&2
      exit 1
   fi
done

exit 0
