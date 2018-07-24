#!/bin/bash
# save it as /etc/profile.d/authgram.sh
# use jq to parse JSON from ipinfo.io
# get jq from here http://stedolan.github.io/jq/

#chat id
USERID=""

#bot key
KEY=""

TIMEOUT="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
AUTHLOG="/var/log/auth.log"
USER_INFO="$(ssh-keygen -l -f ~/.ssh/authorized_keys)"
DATE_EXEC="$(date "+%d/%m-%Y %H:%M")"
TMPINFO='/tmp/ipinfo-$DATE_EXEC.txt'
if [ -n "$SSH_CLIENT" ]; then
        IP=$(echo $SSH_CLIENT | awk '{printf $1}')
        PORT=$(echo $SSH_CLIENT | awk '{printf $3}')
        HOSTNAME=$(hostname -f)
        IPADDR=$(hostname -I | awk '{printf $1}')
        curl http://ipinfo.io/$IP -s -o $TMPINFO
        CITY=$(cat $TMPINFO | jq '.city' | sed 's/"//g')
        REGION=$(cat $TMPINFO | jq '.region' | sed 's/"//g')
        COUNTRY=$(cat $TMPINFO | jq '.country' | sed 's/"//g')
read -r -d '' msg << EOT
<b>$DATE_EXEC:</b>
${USER}@$HOSTNAME:$PORT 
$IP, $CITY, $REGION, $COUNTRY
[ $USER_INFO ]
EOT
		curl --data chat_id="$USERID" --data-urlencode "text=${msg}" "https://api.telegram.org/bot$KEY/sendMessage?parse_mode=HTML" > /dev/null
        rm $TMPINFO
fi
