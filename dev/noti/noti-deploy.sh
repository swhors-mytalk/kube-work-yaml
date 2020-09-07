#!/usr/bin/env bash
########################################################
#
# bemily-noti blue-green deploy scription
#
# v1 : 2020/08/15, initially created
#
########################################################

ENABLED=1

SVC_NAME=bemily-noti

DEPLOY_FILE=template/bemily-noti-deploy4.yaml
SERVICE_FILE=template/bemily-noti-service-node_port.yaml
AUTOSCALE_FILE=template/bemily-noti-autoscaling.yaml
FILES=($DEPLOY_FILE $SERVICE_FILE $AUTOSCALE_FILE)
SVC_DEP_FILE="bemily-noti-svc-dep.yaml"

function beginswith() {
  case $2 in "$1"*) true;; *) false;; esac;
}

function find_active_color {
  find_line=`kubectl describe svc bemily-noti | grep -m1 'color'`
  new_line=$(echo $find_line| cut -c11- | rev | cut -c1- | rev)

  delimiter=","
  items=$new_line$delimiter

  itemarray=()
  while [[ $items ]]; do
          itemarray+=( "${items%%"$delimiter"*}")
          items=${items#*"$delimiter"}
  done

  # shellcheck disable=SC2068
  for item in ${itemarray[@]}
  do
    if beginswith "color=" "$item"; then
      value=$(echo $item| cut -c7-)
      echo $value
    fi
  done
}

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


function delete_confirm() {
  echo "Delete previous zone? (yes/No)"
  read answer

  if [ "${answer}" == "yes" ]; then
    echo 1
  elif [ "${answer}" == "Yes" ]; then
    echo 1
  else
    echo 0
  fi
}


function deploy() {
  echo "---------------------------"
  echo "| Start to deploy         |"
  echo "---------------------------"
  echo ""
  kubectl apply -f $1
  echo "Wait 20 seconds......"
  sleep 20
  kubectl describe svc $2
}


function delete_previous_zone() {
  sleep 5
  kubectl delete deploy "$1""-""$2"
  echo "completed to depoly from ""$2"" to ""$3"
  echo ""
  echo ""

}


COLOR=$(find_active_color)

NEXT_COLOR=$(get_next_color ${COLOR})

echo "CURRENT =" $COLOR ",NEXT =" $NEXT_COLOR

change_color ${COLOR} ${NEXT_COLOR}
create_service

if [ "$ENABLE_CHANGE" -eq 1 ]; then
  deploy $SVC_DEP_FILE ${SVC_NAME}
fi

ENABLED_DELETE=`delete_confirm`

echo "Delete previous zone? (yes/No)"
read answer

if [ "${answer}" == "yes" ]; then
  ENABLED_DELETE=1
elif [ "${answer}" == "Yes" ]; then
  ENABLED_DELETE=1
fi

echo "Answer ="$ENABLED_DELETE

if [ "$ENABLED_DELETE" -eq 1 ]; then
  delete_previous_zone ${SVC_NAME} ${COLOR} ${NEXT_COLOR}
fi

echo "------------------------------"
echo "completed to deploy"
echo "------------------------------"


