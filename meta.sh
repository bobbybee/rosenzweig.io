#!/bin/sh

HTML=${1%.md}.html
TITLE=$(head -n 1 $1 | python -c 'import json,sys; print(json.dumps(sys.stdin.read().strip()))')
LEADER=$(head -n 5 $1 | tail -n 1 | pandoc -f markdown | head -c -1 | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

echo '{"title": '$TITLE', "href": "/'$HTML'", "leader": '$LEADER'},'
