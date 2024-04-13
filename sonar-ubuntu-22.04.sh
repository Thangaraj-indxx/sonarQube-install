#!/bin/bash

# Download the SonarQube installation script
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.3.1.45104.zip

# Unzip the downloaded file
unzip sonarqube-9.3.1.45104.zip -d /opt

# Rename the extracted directory for convenience
mv /opt/sonarqube-9.3.1.45104 /opt/sonarqube

# Configure SonarQube to run as a service
cat <<EOF > /etc/systemd/system/sonarqube.service
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
systemctl daemon-reload

# Start SonarQube service
systemctl start sonarqube

# Enable SonarQube service to start on boot
systemctl enable sonarqube

# Check SonarQube service status
systemctl status sonarqube
