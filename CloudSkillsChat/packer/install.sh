#!/usr/bin/env bash

# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update

# Install the latest version of PostgreSQL.
# If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':
sudo apt-get -y install postgresql git

psql -U postgres << END_OF_SCRIPT

CREATE DATABASE messages;

CREATE USER msgsvc WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE messages to msgsvc;
ALTER USER msgsvc WITH SUPERUSER;

CREATE TABLE queue (
   ID SERIAL PRIMARY KEY     NOT NULL,
   NAME           TEXT    NOT NULL,
   MESSAGE           TEXT     NOT NULL
);

\d
INSERT INTO queue (name, message) VALUES ('CloudSkills', 'Welcome to the infrastructure development workshop!');
INSERT INTO queue (name, message) VALUES ('CloudSkills', 'Enter something in the chat.');




END_OF_SCRIPT

ls /app
sudo chmod +x /app/CloudSkillsChat
sudo chmod -R 777 /app


sudo tee -a /lib/systemd/system/CloudSkillsChat.service << END
[Unit]
Description=Go Server

[Service]
ExecStart=/bin/bash -c '/app/CloudSkillsChat'
WorkingDirectory=/app
Environment=POSTGRES_PASSWORD=SomePassWord
Environment=PORT=3001
User=root
Group=root
Restart=always

[Install]
WantedBy=multi-user.target
END

sudo systemctl enable CloudSkillsChat.service
sudo systemctl start CloudSkillsChat.service
sudo systemctl status CloudSkillsChat.service


