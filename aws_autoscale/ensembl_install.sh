#!/bin/bash
aws s3 cp s3://ecsinfo/ensembl_docker_compose.yml /etc/docker-compose.yml
mkdir -p /data/ensembl
aws s3 cp s3://ecsinfo/ensembl/dockerData /data/ensembl
yum install -y docker
service docker start
usermod -a -G docker ec2-user
pip install docker-compose
/usr/local/bin/docker-compose -f /etc/docker-compose.yml up -d
