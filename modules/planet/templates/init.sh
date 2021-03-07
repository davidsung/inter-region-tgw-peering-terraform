#!/bin/bash
yum update -y
amazon-linux-extras install epel -y
yum install -y hping3
amazon-linux-extras install -y nginx1
systemctl start nginx.service
systemctl enable nginx.service
cat <<'EOH' >> /root/benchmark-tools-init.sh
#!/bin/bash
cat <<'EOF' >> /home/ssm-user/.curl-format.txt
     time_namelookup:  %{time_namelookup}s\n
        time_connect:  %{time_connect}s\n
     time_appconnect:  %{time_appconnect}s\n
    time_pretransfer:  %{time_pretransfer}s\n
       time_redirect:  %{time_redirect}s\n
  time_starttransfer:  %{time_starttransfer}s\n
                     ----------\n
          time_total:  %{time_total}s\n
EOF
cat <<'EOF' >> /home/ssm-user/.curl-format-csv.txt
namelookup,connect,appconnect,pretransfer,redirect,starttransfer,total\n
%{time_namelookup},%{time_connect},%{time_appconnect},%{time_pretransfer},%{time_redirect},%{time_starttransfer},%{time_total}\n
EOF
cat <<'EOF' >> /home/ssm-user/.bash_profile
alias curltime='curl -w "@/home/ssm-user/.curl-format-csv.txt" -o /dev/null -s'
alias mtr2='mtr -n -c 2 --report'
alias mtr200='mtr -n -c 200 --report'
alias hping3-p80-50='sudo hping3 -S -c 50 -V -p 80'
EOF
chown ssm-user. /home/ssm-user/.curl-format.txt
chown ssm-user. /home/ssm-user/.curl-format-csv.txt
EOH
chmod +x /root/benchmark-tools-init.sh