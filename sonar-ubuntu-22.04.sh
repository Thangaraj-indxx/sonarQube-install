#!/bin/bash

if [ "$1" != "" ]; then
  export MY_PWD="$1"
else
  export MY_PWD="changeme"
fi

if [ "$2" != "" ]; then
  export MY_BAK="$2"
fi

export MY_USER="sonarqube"
useradd $MY_USER
echo "$MY_USER:$MY_PWD" | chpasswd
usermod -aG sudo $MY_USER

# Switch to the sonarqube user
su - $MY_USER << EOF
cd ~

# Install Java and other dependencies
sudo apt update
sudo apt install -y openjdk-11-jdk wget unzip

# Install PostgreSQL 9.6
sudo apt install -y postgresql-9.6

# Initialize PostgreSQL database
sudo pg_ctlcluster 9.6 main start
sudo -u postgres psql -c "CREATE USER sonar WITH ENCRYPTED password '$MY_PWD';"
sudo -u postgres psql -c "CREATE DATABASE sonar OWNER sonar;"

# Download and configure SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-6.5.zip
unzip sonarqube-6.5.zip -d /opt
sudo mv /opt/sonarqube-6.5 /opt/sonarqube

sudo sed -i -e 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/g' /opt/sonarqube/conf/sonar.properties
sudo sed -i -e "s/#sonar.jdbc.password=/sonar.jdbc.password=$MY_PWD/g" /opt/sonarqube/conf/sonar.properties
sudo sed -i -e 's/#sonar.jdbc.url=jdbc:postgresql/sonar.jdbc.url=jdbc:postgresql/g' /opt/sonarqube/conf/sonar.properties

# Create a systemd service file for SonarQube
echo "[Unit]
Description=SonarQube service
After=syslog.target network.target
[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=root
Group=root
Restart=always
[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/sonar.service

# Start and enable SonarQube service
sudo systemctl daemon-reload
sudo systemctl enable sonar
sudo systemctl start sonar

EOF

# Reboot the system
sudo reboot
