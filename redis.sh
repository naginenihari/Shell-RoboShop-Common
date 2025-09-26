#!/bin/bash

source ./common.sh
check_root

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "Allowing Remote connections to Redis"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling Redis"
systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting Redis"

print_total_time
