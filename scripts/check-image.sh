#!/usr/bin/env bash
# Checks a built image against the runtime design in README.md.
# Usage: bash scripts/check-image.sh notes-web:dev
set -u
IMAGE="${1:-notes-web:dev}"
fail=0

user=$(docker image inspect "$IMAGE" --format '{{.Config.User}}') || exit 1
size=$(docker image inspect "$IMAGE" --format '{{.Size}}')
size_mb=$((size / 1000000))

echo "image: $IMAGE"
echo "user:  ${user:-<none, runs as root>}"
echo "size:  ${size_mb} MB"

if [ -z "$user" ] || [ "$user" = "root" ] || [ "$user" = "0" ]; then
  echo "FAIL  runtime user must be non-root"; fail=1
else
  echo "PASS  runtime user is non-root"
fi

if [ "$size_mb" -le 300 ]; then
  echo "PASS  image size is 300 MB or less"
else
  echo "FAIL  image size must be 300 MB or less"; fail=1
fi

if docker run --rm --entrypoint sh "$IMAGE" -c \
  'test ! -e /app/Dockerfile && test ! -e /app/compose.yaml && test ! -d /app/scripts'; then
  echo "PASS  runtime image holds only the app/ folder"
else
  echo "FAIL  runtime image contains repository files outside app/"; fail=1
fi

if [ "$fail" -eq 0 ]; then echo "RESULT: PASS"; else echo "RESULT: FAIL"; fi
exit "$fail"
