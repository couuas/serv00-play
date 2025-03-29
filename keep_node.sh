#!/bin/bash

toBase64() {
  echo -n "$1" | base64
}

AUTOUPDATE=${AUTOUPDATE:-Y}
SENDTYPE=${SENDTYPE:-null}
TELEGRAM_TOKEN=${TELEGRAM_TOKEN:-null}
TELEGRAM_USERID=${TELEGRAM_USERID:-null}
WXSENDKEY=${WXSENDKEY:-null}
BUTTON_URL=${BUTTON_URL:-null}
LOGININFO=${LOGININFO:-N}
TOKEN=${TOKEN:-""}

TOKEN=$(toBase64 $TOKEN)
base64_TELEGRAM_TOKEN=$(toBase64 $TELEGRAM_TOKEN)
Base64BUTTON_URL=$(toBase64 $BUTTON_URL)

export TELEGRAM_TOKEN TELEGRAM_USERID BUTTON_URL

# 使用 jq 提取 JSON 数组，并将其加载为 Bash 数组
hosts_info=($(echo "${HOSTS_JSON}" | jq -c ".info[]"))
summary=""
user="kaa"
host="https://serv00.us.kg"

echo "host: $host"
output=$(curl -s -o /dev/null -w "%{http_code}" "https://keep.serv00.us.kg/keep?token=$TOKEN&autoupdate=$AUTOUPDATE&sendtype=$SENDTYPE&telegramtoken=$base64_TELEGRAM_TOKEN&telegramuserid=$TELEGRAM_USERID&wxsendkey=$WXSENDKEY&buttonurl=$Base64BUTTON_URL&password=$bas64_pass")

if [ "$output" -eq 200 ]; then
  echo "连接成功，账号正常"
  msg="🟢主机 ${host}, 用户 ${user}， 连接成功，账号正常!\n"
elif [ "$output" -eq 403 ]; then
  echo "账号被封"
  msg="🔴主机 ${host}, 用户 ${user}， 账号被封!\n"
  chmod +x ./tgsend.sh
  ./tgsend.sh "Host:$host, user:$user, 账号被封，请检查!"
elif [ "$output" -eq 404 ]; then
  echo "keepalive服务不在线"
  msg="🔴主机 ${host}, 用户 ${user}， keepalive服务不在线!\n"
  chmod +x ./tgsend.sh
  ./tgsend.sh "Host:$host, user:$user, keepalive服务不在线，请检查!"
elif [ "$output" -eq 401 ]; then
  echo "授权码错误"
  msg="🔴主机 ${host}, 用户 ${user}， 授权码错误!\n"
  chmod +x ./tgsend.sh
  ./tgsend.sh "Host:$host, user:$user, 授权码错误，请检查!"
else
  echo "连接失败，可能网络问题!"
  msg="🔴主机 ${host}, 用户 ${user}， 连接失败，可能网络问题!\n"
  chmod +x ./tgsend.sh
  ./tgsend.sh "Host:$host, user:$user, 连接失败，可能网络问题，可直接访问主页查看: https://$user.serv00.net"
fi
summary=$summary$(echo -n $msg)

if [[ "$LOGININFO" == "Y" ]]; then
  chmod +x ./tgsend.sh
  ./tgsend.sh "$summary"
fi
