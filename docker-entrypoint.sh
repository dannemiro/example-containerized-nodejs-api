#!/bin/sh

# Pre-flight checks
# Check if STAGE var is set
if [ ${STAGE:-} = "" ]; then 
    echo "run stage not set"
    return 1
# Run staging build in debug mode
elif [ ${STAGE} = "STG" ]; then
    # Start server with debug
    echo "starting services with debug flag"
    node server.js --debug
else 
    node server.js
fi


