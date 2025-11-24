#!/bin/sh

INPUT_FILE="$1"
OUTPUT_FILE="$2"

HEADER=$(head -n 1 "$INPUT_FILE")
IFS=',' read -r -a KEYS <<< "$HEADER"

{
echo "["

FIRST=1
tail -n +2 "$INPUT_FILE" | while IFS=',' read -r -a VALUES; do
  if [ $FIRST -eq 0 ]; then
    echo ","
  fi
  FIRST=0

  echo -n "  {"
  for i in "${!KEYS[@]}"; do
    KEY=$(echo "${KEYS[$i]}" | xargs)
    VAL=$(echo "${VALUES[$i]}" | xargs)

    if printf '%s' "$VAL" | grep -Eq '^[0-9]+(\.[0-9]+)?$'; then
      printf '"%s": %s' "$KEY" "$VAL"
    else
      printf '"%s": "%s"' "$KEY" "$VAL"
    fi

    if [ $i -lt $(( ${#KEYS[@]} - 1 )) ]; then
      echo -n ", "
    fi
  done
  echo -n "}"
done

echo
echo "]"
} > "$OUTPUT_FILE"
