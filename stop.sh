#!/bin/bash

echo "Starting application..."

APP_DIR=/home/ubuntu/app/pium/zip/backend_spring/build/libs
JAR_NAME=$(ls $APP_DIR | grep '.jar' | head -n 1)

cd $APP_DIR
nohup java -jar -Dspring.profiles.active=prod $JAR_NAME > /home/ubuntu/app/pium/zip/nohup.log 2>&1 &
