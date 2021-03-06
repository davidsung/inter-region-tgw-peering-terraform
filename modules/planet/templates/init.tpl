#!/bin/bash
yum update -y
amazon-linux-extras install epel -y
yum install -y hping3
amazon-linux-extras install -y nginx1
systemctl start nginx.service
systemctl enable nginx.service