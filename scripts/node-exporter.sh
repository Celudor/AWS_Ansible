#!/bin/sh
# Configuration
bucket="ls-poc-mon"
file="node_exporter-1.1.1.linux-amd64"
user="node-exp"
group="node-exp"

cd /tmp

# Requiments
which unzip
if [ $? -ne 0 ]; then 
    sudo yum -y install unzip
fi
which aws
if [ $? -ne 0 ]; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip /tmp/awscliv2.zip > /dev/null
    sudo /tmp/aws/install
fi

# Node exporter

sudo systemctl stop node_exporter

sudo groupadd -r ${group}
sudo useradd -r -g ${group} -M  -s /usr/sbin/nologin ${user}

aws s3 cp s3://${bucket}/${file}.tar.gz /tmp
tar zxf /tmp/${file}.tar.gz
sudo cp -r /tmp/${file}/node_exporter /usr/local/bin/
rm -rf /tmp/${file}*
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOT 
[Unit]
Description=Prometheus Node Exporter
After=network-online.target

[Service]
Type=simple
User=USER
Group=GROUP
ExecStart=/usr/local/bin/node_exporter \
    --collector.systemd \
--collector.textfile \
    --collector.textfile.directory=/var/lib/node_exporter \
    --web.listen-address=0.0.0.0:9100

SyslogIdentifier=node_exporter
Restart=always
RestartSec=1
StartLimitInterval=0

ProtectHome=yes
NoNewPrivileges=yes

ProtectSystem=strict
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelTunables=yes

[Install]
WantedBy=multi-user.target
EOT
sudo sed -i "s/USER/${user}/g" /etc/systemd/system/node_exporter.service
sudo sed -i "s/GROUP/${group}/g" /etc/systemd/system/node_exporter.service

sudo mkdir -p /var/lib/node_exporter
sudo chown ${user} /var/lib/node_exporter
sudo chgrp ${group} /var/lib/node_exporter
sudo chmod u=rwx,g=rwx,o=rx /var/lib/node_exporter
which semanage
if [ $? -eq 0 ]; then
    sudo semanage port -a -t http_port_t -p tcp 9100
fi
sudo systemctl daemon-reload
sudo systemctl start node_exporter
