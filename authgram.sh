#!/bin/bash
# save it as /etc/profile.d/authgram.sh
# use jq to parse JSON from ipinfo.io
# get jq from here http://stedolan.github.io/jq/

#chat id
USERID=""

#bot key
KEY=""
URL=""

AUTH_LOG="/var/log/auth.log"
USER_INFO="$(ssh-keygen -l -f ~/.ssh/authorized_keys)"
DATE_EXEC="$(date "+%d/%m/%Y %H.%M.%I")"
TMP_INFO='/tmp/ipinfo-$DATE_EXEC.txt'

if [ -n "$SSH_CLIENT" ]; then
	IP=$(echo $SSH_CLIENT | awk '{printf $1}')
	SSH_PROCESS=$(echo $SSH_CLIENT | awk '{printf $2}')
	KEY_USED=$(cat $AUTH_LOG | grep $SSH_PROCESS | cut -f6- -d:)
	KEY_INFO=$(ssh-keygen -l -f ~/.ssh/authorized_keys | grep $KEY_USED)
	PORT=$(echo $SSH_CLIENT | awk '{printf $3}')
	HOSTNAME=$(hostname -f)
	IPADDR=$(hostname -I | awk '{printf $1}')
	curl https://ipinfo.io/$IP -s -o $TMP_INFO
	CITY=$(cat $TMP_INFO | jq '.city' | sed 's/"//g')
	REGION=$(cat $TMP_INFO | jq '.region' | sed 's/"//g')
	COUNTRY=$(cat $TMP_INFO | jq '.country' | sed 's/"//g')
	read -r -d '' msg << EOM
		<b>📅 $DATE_EXEC</b>
		💻 ${USER} logged into $HOSTNAME : $PORT
		From: $IP
		🌎 GeoIP: $CITY, $REGION, $COUNTRY
		🔑 Using Key:
		BITS: $KEY_INFO
	EOM
	curl --data chat_id="$USERID" --data-urlencode "text=${msg}" "https://api.telegram.org/bot$KEY/sendMessage?parse_mode=HTML$
	rm $TMP_INFO
fi
