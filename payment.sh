#!/bin/bash

source ./common.sh
app_name=payment

check_root
app_setup
python_setup
systemd_setup

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
systemctl daemon-reload
systemctl enable payment  &>>$LOG_FILE
ystemctl restart payment

print_total_time



systemd_setup(){
cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOG_FILE
VALIDATE $? "copy systemctl service"
systemctl daemon-reload
systemctl enable $app_name &>>$LOG_FILE
VALIDATE $? "Enable $app_name Service"
}

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
systemctl daemon-reload
systemctl enable payment  &>>$LOG_FILE

systemctl restart payment