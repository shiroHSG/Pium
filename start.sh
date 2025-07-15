#!/bin/bash

sleep 10

APP_DIR=/home/ubuntu/app/pium/zip/backend_spring/build/libs
JAR_NAME=$(ls $APP_DIR | grep '.jar' | grep -v 'plain' | head -n 1)

# ✅ .env를 jar 옆으로 복사
cp /home/ubuntu/app/pium/zip/.env $APP_DIR

echo "> Starting $JAR_NAME"
cd $APP_DIR
nohup java -jar $JAR_NAME > /home/ubuntu/app/pium/zip/nohup.log 2>&1 &
