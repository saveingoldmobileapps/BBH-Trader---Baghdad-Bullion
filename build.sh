#!/bin/bash

ENV="production" # Default environment

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --production) ENV="production" ;;
    --staging) ENV="staging" ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
  shift
done

echo "Building for \ $ENV \ environment..."
flutter build apk --dart-define=ENV=$ENV