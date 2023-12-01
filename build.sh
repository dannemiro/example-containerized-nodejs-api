#!/bin/sh

# Start
echo "starting build with ${STAGE} parameter"

# Check if STAGE var is set
if [ ${STAGE:-} = "" ]; then 
    echo "Build STAGE not set"
    return 1
# Build per environment 
elif [ ${STAGE} = "DEV" ]; then 
    npm install 
elif [ ${STAGE} = "STG" ]; then
    npm install --production 
elif [ ${STAGE} = "PROD" ]; then 
    npm install imagemagick --production
else
    echo "Unknown stage. i.e. use DEV, STG, PROD"
    return 1
fi
