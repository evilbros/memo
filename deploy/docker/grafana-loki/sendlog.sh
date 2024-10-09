
t=$(date +%s)000000000
c=${1:-hello}

curl -X POST http://ip:3030 \
   -H "Content-Type: application/json" \
   -d "{
      \"streams\": [
         {
            \"stream\": {
               \"env\": \"test\"
            },
            \"values\": [
               [\"$t\", \"$c\"]
            ]
         }
      ]
   }"

