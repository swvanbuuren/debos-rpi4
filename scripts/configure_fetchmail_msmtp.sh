#!/bin/sh

POL_INTERVAL=60
IMAP_PORT=993
SMTP_PORT=465

while [ $# -gt 0 ]; do
    case "$1" in
        --username)
            USERNAME="$2"; shift 2 ;;
        --pol-interval)
            POL_INTERVAL="$2"; shift 2 ;;
        --imap-host)
            IMAP_HOST="$2"; shift 2 ;;
        --imap-port)
            IMAP_PORT="$2"; shift 2 ;;
        --imap-username)
            IMAP_USERNAME="$2"; shift 2 ;;
        --imap-password)
            IMAP_PASSWORD="$2"; shift 2 ;;
        --smtp-host)
            SMTP_HOST="$2"; shift 2 ;;
        --smtp-port)
            SMTP_PORT="$2"; shift 2 ;;
        --smtp-username)
            SMTP_USERNAME="$2"; shift 2 ;;
        --smtp-password)
            SMTP_PASSWORD="$2"; shift 2 ;;
        --email-to)
            EMAIL_TO="$2"; shift 2 ;;
        --email-from)
            EMAIL_FROM="$2"; shift 2 ;;
        *)
            echo "Unknown option: $1"; exit 1 ;;
    esac
done

cat > /etc/fetchmailrc << EOL
set daemon 60
set logfile /home/$USER/fetchmail/fetchmail.log

poll $IMAP_HOST port $IMAP_PORT auth password with protocol IMAP
     user '$IMAP_USERNAME'
     password '$IMAP_PASSWORD'
     ssl
     keep
     no rewrite
     mda "/usr/bin/msmtp --file /etc/msmtprc -- $EMAIL_TO"

EOL

cat > /etc/msmtprc << EOL
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account default
host $SMTP_HOST
port $SMTP_PORT
tls_starttls off
from $EMAIL_FROM
user $SMTP_USERNAME
password $SMTP_PASSWORD

EOL

groupadd fetchmail
usermod -a -G fetchmail fetchmail
chown fetchmail:fetchmail /etc/fetchmailrc
chmod 0600 /etc/fetchmailrc
chown fetchmail:fetchmail /etc/msmtprc
chmod 0600 /etc/msmtprc
sed -i '/START_DAEMON=/c\START_DAEMON=yes' /etc/default/fetchmail
