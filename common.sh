#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[37m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 |cut -d '.' -f1)
MONGODB_HOST=mongodb.naginenihariaws.store
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER
echo "Script started executed at:$(date)" |tee -a $LOG_FILE

check_root(){
if [ $USERID -ne 0 ]; then
    echo "ERROR:: please run the script with root privelege" |tee -a $LOG_FILE
    exit 1  #failure mean other then Zero
fi
}

VALIDATE() {
if [ $1 -ne 0 ]; then
    echo -e " $2 is $R FAILURE $N" |tee -a $LOG_FILE
    exit 1
else 
    echo -e " $2 is $G SUCCESS $N" |tee -a $LOG_FILE
fi
}
nodejs_setup(){
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installed NodeJS"

npm install &>>$LOG_FILE
VALIDATE $? "Install Dependencies"
}

app_setup(){
id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
 VALIDATE $? "Creating system user"
else
 echo -e "User is Already exist ..$Y SKIPPING $N"
fi
mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app directory"
curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading $app_name application source code"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/$app_name.zip &>>$LOG_FILE
VALIDATE $? "unzip the $app_name code" 
}

systemd_setup(){
cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOG_FILE
VALIDATE $? "copy systemctl service"
systemctl daemon-reload
systemctl enable $app_name &>>$LOG_FILE
VALIDATE $? "Enable $app_name Service"
}
app_restart(){
 systemctl restart $app_name &>>$LOG_FILE
VALIDATE $? "Restarted $app_name Service"   
}

redis_setup(){
dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling Deafult redis"
dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling redis 7"
dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing redis "
}
java_setup(){
 dnf install maven -y &>>$LOG_FILE
 VALIDATE $? "Installed Maven" 

 mvn clean package &>>$LOG_FILE
 VALIDATE $? "Dependences are downloading"
 
 mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
 VALIDATE $? "Rename the application sourcefile"  
}

python_setup(){
 dnf install python3 gcc python3-devel -y &>>$LOG_FILE   
 VALIDATE $? "Installing python3"
 pip3 install -r requirements.txt &>>$LOG_FILE
 VALIDATE $? "Dependences are downloading"
}

print_total_time(){
END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"

}