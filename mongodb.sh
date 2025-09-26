#!/bin/bash

source ./common.sh

check_root

cp $SCRIPT_DIR/mongo.repo  /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabled MondoDB"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Started MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections to mongodb"

systemctl restart mongod
VALIDATE $? "Restarted mongoDB"

print_total_time