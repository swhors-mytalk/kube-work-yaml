#!/bin/bash

ENABLED=0

DEPLOY_FILE=template/bemily-noti-deploy4.yaml
SERVICE_FILE=template/bemily-noti-service-node_port.yaml
AUTOSCALE_FILE=template/bemily-noti-autoscaling.yaml

FILES=($DEPLOY_FILE $SERVICE_FILE $AUTOSCALE_FILE)

function find_color {
  line0=$(grep -m1 'color' $SERVICE_FILE)
  items=$(echo $line0 | tr ": " "\n")
  for item in $items
  do
    if [ $item != "color" ]
    then
      echo $item
    fi
  done
}


function get_next_color {
  if [ $1 == "blue" ]
  then
    echo "green"
  fi
  if [ $1 == "green" ]
  then
    echo "blue"
  fi
}


COLOR=$(find_color)

NEXT_COLOR=$(get_next_color ${COLOR})

echo "CURRENT="$COLOR", NEXT="$NEXT_COLOR


for fileName in "${FILES[@]}"
do
  echo 'file='$fileName
  sed -e "s/${COLOR}/${NEXT_COLOR}/g" "${fileName}" > "${fileName}_new"
  mv "${fileName}_new" "${fileName}"
done


OUT_FILE="bemily-noti-deploy.yaml"
if [ "$ENABLED" -eq 1 ]; then
  sed -e "s/SYNCVERSION/${SYNCVERSION}/g" "${TMP_FILE}" > "${NEW_FILE}"
  echo ${NEW_FILE}' is created.'
  docker-compose up -d syncdaemon
fi
