#!/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y  &>>$LOG_FILE
VALIDATE $? "Installing Mysql"
systemctl enable mysqld  &>>$LOG_FILE
VALIDATE $? "Enabling Mysql"
systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "Started Mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "Setting up Root password"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"

print_total_time