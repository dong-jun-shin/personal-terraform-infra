#!/bin/bash
set -e # error handling

CONTAINER_NAME="morning-letter-be"

echo "Attempting to stop container ${CONTAINER_NAME}..."
RUNNING_CONTAINER_ID=$(docker ps -q -f name=^/${CONTAINER_NAME}$)
if [ -n "${RUNNING_CONTAINER_ID}" ]; then
    echo "Stopping container ${CONTAINER_NAME} (ID: ${RUNNING_CONTAINER_ID})..."
    docker stop "${RUNNING_CONTAINER_ID}"
    echo "Container stopped."
else
    echo "Container ${CONTAINER_NAME} is not running."
fi

exit 0 