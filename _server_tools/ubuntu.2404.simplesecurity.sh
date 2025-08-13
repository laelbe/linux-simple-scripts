#!/bin/bash

# Lael's Simple Script (Ubuntu 24.04 LTS)
# https://blog.lael.be/post/12132

# Delete unnecessary accounts
userdel games
userdel lp
userdel uucp

# Turn off TCP FORWARDING
sed -i 's/#AllowTcpForwarding no/AllowTcpForwarding no/g' /etc/ssh/sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config
sed -i 's/AllowTcpForwarding yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config

# Change some permissions to be more strict
chmod 751 /var/log

chmod 600 /etc/ssh
chmod 600 /etc/ssh/sshd_config

chmod 0700 /bin/su
chmod 600 /etc/pam.d/su
chmod 700 /etc/pam.d
chmod 400 /etc/shadow

chmod 600 /etc/hosts.allow
chmod 600 /etc/hosts.deny

chmod o-rwx /bin/fusermount
chmod o-rwx /bin/mount
chmod o-rwx /bin/umount
chmod o-rwx /bin/ping

chmod o-rwx /usr/bin/w
chmod o-rwx /usr/bin/who

chmod o-rwx /sbin/pam_extrausers_chkpwd
chmod 700 /sbin/unix_chkpwd

chmod o-rwx /usr/bin/chage
chmod o-rwx /usr/bin/chfn
chmod o-rwx /usr/bin/chsh
chmod o-rwx /usr/bin/expiry
chmod o-rwx /usr/bin/gpasswd

chmod o-rwx /usr/bin/lsb_release
chmod 600 /etc/issue

chmod 700 /usr/bin/newgrp
chmod o-rwx /usr/bin/wall
chmod o-rwx /usr/lib/dbus-1.0/dbus-daemon-launch-helper
chmod o-rwx /usr/lib/policykit-1/polkit-agent-helper-1

chmod 701 /home
chmod 710 /home/*

# crontab 600 or 640
chmod 600 /etc/crontab
chmod 600 /etc/cron.hourly/*
chmod 600 /etc/cron.daily/*
chmod 600 /etc/cron.weekly/*
chmod 600 /etc/cron.monthly/*

chmod 600 /etc/login.defs
sed -i 's/#SULOG_FILE\s\/var\/log\/sulog/SULOG_FILE\t\/var\/log\/sulog/g' /etc/login.defs
echo "PASS_MIN_LEN 8" >> /etc/login.defs

# locked out for 120 seconds, when 5 fail
cd /usr/lib/x86_64-linux-gnu/security/ && ln -s pam_faillock.so pam_tally2.so
sed -i '1s/^/auth\trequired\t\t\tpam_tally2.so deny=5 unlock_time=120\n\n/' /etc/pam.d/common-auth

# rsyslog
chmod 600 /etc/rsyslog.conf
chmod 600 /etc/rsyslog.d/20-ufw.conf
chmod 600 /etc/rsyslog.d/21-cloudinit.conf
chmod 600 /etc/rsyslog.d/50-default.conf

sed -i '1i :programname, isequal, "CRON" ~' /etc/rsyslog.d/50-default.conf
sed -i 's/#daemon\./daemon\./g' /etc/rsyslog.d/50-default.conf
sed -i 's/#cron\./cron\./g' /etc/rsyslog.d/50-default.conf

echo "*.info /var/log/info.log" >> /etc/rsyslog.d/50-default.conf
echo "*.alert /var/log/alert.log" >> /etc/rsyslog.d/50-default.conf

echo "local6.debug /var/log/command.log" >> /etc/rsyslog.d/50-default.conf
touch /var/log/command.log
chown syslog:adm /var/log/command.log
chmod o-rwx /var/log/command.log

service rsyslog restart

# bash_securescript.txt START
cat << 'EOF' > /root/bash_securescript.txt
whoami="$(whoami)@$(echo $SSH_CONNECTION | awk '{print $1}')"
export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug "$whoami [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]"'
TMOUT=600
umask 022
EOF
# bash_securescript.txt END

cat /root/bash_securescript.txt >> /etc/profile
cat /root/bash_securescript.txt >> /root/.bashrc
