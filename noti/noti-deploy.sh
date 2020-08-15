#!/bin/bash
enabled=0
DEPLOY_FILE=template/bemily-noti-deploy4.yaml
SERVICE_FILE=template/bemily-noti-service-node_port.yaml
AUTOSCALE_FILE=template/bemily-noti-autoscaling.yaml

OUT_FILE="bemily-noti-deploy.yaml"
if [enabled -eq 1]; then
  sed -e "s/HOSTIP/${HOSTIPS1[0]}/g" "${ORG_FILE}" > "${TMP_FILE}"
  sed -e "s/SYNCVERSION/${SYNCVERSION}/g" "${TMP_FILE}" > "${NEW_FILE}"
  echo ${NEW_FILE}' is created.'
  docker-compose up -d syncdaemon
fi