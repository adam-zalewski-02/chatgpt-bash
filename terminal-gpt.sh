QUESTION_FILE="$1"
OUTPUT_FILE="$2"

if [ -z "$QUESTION_FILE" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: ./script.sh input.txt output.txt"
    exit 1
fi

# Use jq to correctly JSON-encode the input file content.
QUESTION_JSON=$(jq -Rs . < "$QUESTION_FILE")

# Build the JSON payload
JSON_PAYLOAD=$(jq -n --arg API_KEY "$API_KEY" --argjson question "$QUESTION_JSON" \
'{
  "model": "gpt-3.5-turbo",
  "messages": [{"role": "user", "content": $question}],
  "temperature": 0.7
}')

RESPONSE=$(curl -s -X POST https://api.openai.com/v1/chat/completions \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $API_KEY" \
-d "$JSON_PAYLOAD" | jq -r '.choices[0].message.content')

echo "$RESPONSE" >> "$OUTPUT_FILE"
