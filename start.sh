#!/bin/bash

echo "Stopping application..."

APP_DIR=/home/ubuntu/app/pium/zip/backend_spring/build/libs
JAR_NAME=$(ls $APP_DIR | grep '.jar' | head -n 1)
PID=$(pgrep -f $JAR_NAME)

if [ -z "$PID" ]; then
  echo "No application is currently running."
else
  kill -15 $PID
  echo "Application stopped. PID: $PID"
fi
