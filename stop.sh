#!/bin/bash

echo "Stopping application..."

APP_DIR=/home/ubuntu/app/pium/zip/backend_spring/build/libs
# 실행 가능한 jar만 대상으로
JAR_NAME=$(ls $APP_DIR | grep '.jar' | grep -v 'plain' | head -n 1)
PID=$(pgrep -f $JAR_NAME)

if [ -z "$PID" ]; then
  echo "No application is currently running."
else
  kill -15 $PID
  echo "Application stopped. PID: $PID"
fi
