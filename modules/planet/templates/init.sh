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
cat <<'EOH' >> /usr/local/bin/httptiming.sh
#!/bin/bash

# Set the `errexit` option to make sure that
# if one command fails, all the script execution
# will also fail (see `man bash` for more
# information on the options that you can set).
set -o errexit

# This is the main routine of our bash program.
# It makes sure that we've supplied the necessary
# arguments, then it prints a CSV header and then
# keeps making requests and printing their responses.
#
# Note.: because we're calling `curl` each time in
#        the loop, a new `curl` process is created for
#        each request.
#
#        This means that a new connection will be made
#        each time.
#
#        Such property might be useful when you're testing
#        if a given load-balancer in the middle might be
#        messing up with some requests.
main () {
  local count=$1
  local url=$2

  if [[ -z "$url" ]]; then
    echo "ERROR:
  An URL must be provided.

  Usage: check-res <url>

Aborting.
    "
    exit 1
  fi

  print_header
  for i in `seq 1 $count`; do
    make_request $url
  done
}

# This method does nothing more that just print a CSV
# header to STDOUT so we can consume that later when
# looking at the results.
print_header () {
  echo "code,time_total,time_connect,time_appconnect,time_starttransfer"
}

# Make request performs the actual request using `curl`.
# It specifies those parameters that we've defined before,
# taking a given `url` as its parameter.
make_request () {
  local url=$1

  curl \
    --write-out "%{http_code},%{time_total},%{time_connect},%{time_appconnect},%{time_starttransfer}\n" \
    --silent \
    --output /dev/null \
    "$url"
}

main "$@"
EOH
chmod +x /usr/local/bin/httptiming.sh