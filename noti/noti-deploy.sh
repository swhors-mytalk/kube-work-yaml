#!/bin/bash

ENABLED=1

SVC_NAME=bemily-noti

DEPLOY_FILE=template/bemily-noti-deploy4.yaml
SERVICE_FILE=template/bemily-noti-service-node_port.yaml
AUTOSCALE_FILE=template/bemily-noti-autoscaling.yaml
FILES=($DEPLOY_FILE $SERVICE_FILE $AUTOSCALE_FILE)
SVC_DEP_FILE="bemily-noti-svc-dep.yaml"


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


function change_color {
  for fileName in "${FILES[@]}"
  do
    echo $fileName ',' ${1} ',' ${2}
    sed -e "s/${1}/${2}/g" "${fileName}" > "${fileName}_new"
    mv "${fileName}_new" "${fileName}"
  done
}


function create_service {
  if [ -f "$DEPLOY_FILE" ]; then
    cat $DEPLOY_FILE > $SVC_DEP_FILE
    echo "" >> $SVC_DEP_FILE
    echo "---" >> $SVC_DEP_FILE
  fi

  if [ -f "$SERVICE_FILE" ]; then
    cat $SERVICE_FILE >> $SVC_DEP_FILE
    echo "" >> $SVC_DEP_FILE
    echo "---" >> $SVC_DEP_FILE
  fi

  if [ -f "$AUTOSCALE_FILE" ]; then
    cat $AUTOSCALE_FILE >> $SVC_DEP_FILE
  fi
}


COLOR=$(find_color)

NEXT_COLOR=$(get_next_color ${COLOR})

echo "CURRENT="$COLOR", NEXT="$NEXT_COLOR

change_color ${COLOR} ${NEXT_COLOR}
create_service


if [ "$ENABLED" -eq 1 ]; then
  echo "---------------------------"
  echo "| Start to deploy         |"
  echo "---------------------------"
  echo ""
  kubectl apply -f $SVC_DEP_FILE
  sleep 5
  kubectl delete deploy ${SVC_NAME}"-"${COLOR}
  sleep 10
  echo "completed to depoly from "${COLOR}" to "${NEXT_COLOR}
  echo ""
  echo ""
  kubectl describe svc ${SVC_NAME}
fi

