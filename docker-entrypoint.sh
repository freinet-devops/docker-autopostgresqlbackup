#!/bin/bash

# Logic for Password file required
#  If PASSWORD_SECRET env var is defined, search for the /run/secrets/${PASSWORD_SECRET} and read the content
#  If PASSWORD_SECRET is not defined, use PASSWORD env variable
# The idea, as specified in the software:
#   create a file $HOME/.pgpass containing a line like this 
#           hostname:*:*:dbuser:dbpass
# replace hostname with the value of DBHOST and postgres with
# the value of USERNAME
PASSPHRASE=""
if [ "${PASSWORD_SECRET}" ]; then
    echo "Using docker secrets..."
    if [ -f "/run/secrets/${PASSWORD_SECRET}" ]; then
        PASSPHRASE=$(cat /run/secrets/${PASSWORD_SECRET})
    else
        echo "ERROR: Secret file not found in /run/secrets/${PASSWORD_SECRET}"
        echo "Please verify your docker secrets configuration."
        exit 1
    fi
else
    echo "Using environment password..."
    PASSPHRASE=${PASSWORD}
fi

# Logic for the CRON schedule
#  If CRON_SCHEDULE is defined, delete the script under cron.daily and copy this one to crontab
#  If CRON_SCHEDULE is not defined, don't do anything, use default cron.daily behaviour
if [ "${CRON_SCHEDULE}" ]; then
  echo "Configuring a CUSTOM SCHEDULE in /etc/crontab for ${CRON_SCHEDULE} ..."
    # Create the crontab file
cat <<-EOF > /etc/crontab

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# m h dom mon dow user command
${CRON_SCHEDULE} /usr/sbin/autopostgresqlbackup    
EOF
else
    echo "Using cron.daily schedule..."
fi

# Create the file
echo "Creating the password file..."
cat <<-EOF > ${HOME}/.pgpass

${DBHOST:-localhost}:*:*:${USERNAME:-postgres}:${PASSPHRASE}
EOF
# Permissions for this file shoudl be set to 0600
chmod 0600 ${HOME}/.pgpass

# Set timezone if set
if [ ! -z "${TZ}" ]; then
    echo "Setting timezone to ${TZ}"
    ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime
    echo "${TZ}" > /etc/timezone
fi

# set /etc/environment for cron
printenv > /etc/environment

# Execute cron with parameters (autopostgresql script is under /etc/cron.daily)
echo "Execute cron service..."
exec cron -f -l ${CRON_LOG_LEVEL:-8}
