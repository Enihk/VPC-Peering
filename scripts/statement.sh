#!/bin/bash
sudo apt update -y
sudo apt-get install net-tools zip curl jq tree unzip wget siege apt-transport-https ca-certificates software-properties-common gnupg lsb-release -y

sudo curl -L https://github.com/nicholasjackson/fake-service/releases/download/v0.26.2/fake_service_linux_amd64.zip -o statement-svc.zip
sudo unzip statement-svc.zip
sudo rm -rf statement-svc.zip
sudo mv fake-service /usr/bin/statement-svc
sudo chmod 755 /usr/bin/statement-svc
sudo chown ubuntu:ubuntu /usr/bin/statement-svc

sudo tee /usr/lib/systemd/system/statement.service > /dev/null << 'EOF'
[Unit]
Description=Statement Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment="LISTEN_ADDR=0.0.0.0:9093"
Environment="NAME=statement-svc"
Environment="MESSAGE=HelloCloudBank | Retail Banking | statement-svc"
ExecStart=/usr/bin/statement-svc
User=ubuntu
Group=ubuntu
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sleep 1
sudo systemctl enable statement.service
sudo systemctl start statement.service
sleep 2
sudo systemctl status statement.service
sudo lsof -i -P | grep statement-svc || true