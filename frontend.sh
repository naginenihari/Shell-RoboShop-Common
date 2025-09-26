#!/bin/bash
source ./common.sh

##Installing Nginx ##
dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling Nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nginx 24"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installed Nginx"

systemctl enable nginx 
VALIDATE $? "Enabled Nginx"

rm -rf /usr/share/nginx/html/* 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading user application sourcecode"

cd /usr/share/nginx/html
VALIDATE $? "Changing to app directory"
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzip the user code"

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "Removing default nginx config file"
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "copying nginx config file"
systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarted nginx Service"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"