#!/bin/zsh

# Read apikey and secretapikey from .env file
apikey=$(grep -w 'apikey' .env | cut -d '=' -f2)
secretapikey=$(grep -w 'secretapikey' .env | cut -d '=' -f2)

# Set URL
URL="https://porkbun.com/api/json/v3/ssl/retrieve/simplestory.cyou"

# Create a JSON object for the request body
JSON_BODY=$(printf '{"secretapikey": "%s","apikey": "%s"}' "$secretapikey" "$apikey")

# Send POST request and get response
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$JSON_BODY" $URL)


# Get response status code
STATUS=$(printf "%s" "${RESPONSE}" | jq -r '.status')

if [[ $STATUS == "SUCCESS" ]]
then
    echo "Request Successful!"
    
    # Extracts response fields
    certificate_chain=$(printf "%s" "${RESPONSE}" | jq -r '.certificatechain')
    private_key=$(printf "%s" "${RESPONSE}" | jq -r '.privatekey')

    # Save data to respective files
    printf "%s" "$certificate_chain" > ./nginx/cert/full_chain.pem
    printf "%s" "$private_key" > ./nginx/cert/private.key

    echo "Certification saved to corresponding files!"
else
    echo "Request Failed with Status: $STATUS"
fi