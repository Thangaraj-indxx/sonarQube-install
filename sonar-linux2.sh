#!/bin/bash

# Install wget and unzip if not already installed
sudo yum install -y wget unzip

# Download the SonarQube installation script
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.6.1.59531.zip -O sonarqube.zip

# Unzip the downloaded file
sudo unzip sonarqube.zip -d /opt

# Rename the extracted directory for convenience
sudo mv /opt/sonarqube-9.6.1.59531 /opt/sonarqube

# Configure SonarQube to run as a service
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOF
[Unit]
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
WantedBy=multi-user.target
EOF

# Reload systemd to load the new service file
sudo systemctl daemon-reload

# Start SonarQube service
sudo systemctl start sonarqube

# Enable SonarQube service to start on boot
sudo systemctl enable sonarqube

# Check SonarQube service status
sudo systemctl status sonarqube
