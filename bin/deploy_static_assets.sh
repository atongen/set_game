#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../public" && pwd )"
DST="mercury:/var/www/set_game/current/public"

FILES=$(
echo $(
cat <<EOF
assets/js/main-built.js
assets/js/require.js
assets/css/app-built.css
favicon.ico
assets/images/set.png
assets/images/card_sprite.png
assets/images/glyphicons-halflings-white.png
assets/images/glyphicons-halflings.png
EOF
) | xargs
)

for x in $FILES; do
  scp "$DIR/$x" "$DST/`dirname $x`"
done
