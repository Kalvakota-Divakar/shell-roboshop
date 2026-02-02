#!/bin/bash
# Validate whether the root user is executing the script or not.
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log" # /var/log/shell-roboshop/mongodb.sh.log
# color codes given for outpit messages.
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
# check for root user.
if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER # create log folder if not exists.
# function to validate each command execution status.
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE # append the log file.
        exit 1 # exit without failure status.
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}
# installing mongodb.
echo "Setting up MongoDB Repository"
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongo Repo" 

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing MongoDB server"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable MongoDB"

systemctl start mongod
VALIDATE $? "Start MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"