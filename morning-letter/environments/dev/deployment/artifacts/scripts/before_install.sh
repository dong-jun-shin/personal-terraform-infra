#!/bin/bash
set -e # error handling

NODE_ENV="development"
AWS_REGION="ap-northeast-2"
CONTAINER_NAME="morning-letter-be"
HOST_ENV_FILE_PATH="/home/ec2-user/morning-letter/.env.${NODE_ENV}"
S3_ENV_FILE_URI="s3://infra-files-2025/morning-letter-env/.env.${NODE_ENV}"

echo "Removing exited or created container..."
EXITED_CONTAINER_ID=$(docker ps -aq -f status=exited -f name=^/${CONTAINER_NAME}$)
CREATED_CONTAINER_ID=$(docker ps -aq -f status=created -f name=^/${CONTAINER_NAME}$)
if [ -n "$EXITED_CONTAINER_ID" ]; then
    echo "Removing exited container ${CONTAINER_NAME} ($EXITED_CONTAINER_ID)..."
    docker rm "$EXITED_CONTAINER_ID"
fi
if [ -n "$CREATED_CONTAINER_ID" ]; then
    echo "Removing created container ${CONTAINER_NAME} ($CREATED_CONTAINER_ID)..."
    docker rm "$CREATED_CONTAINER_ID"
fi

echo "Removing old environment file if exists: ${HOST_ENV_FILE_PATH}"
rm -f "${HOST_ENV_FILE_PATH}"
mkdir -p "$(dirname "${HOST_ENV_FILE_PATH}")"

echo "Downloading environment file from ${S3_ENV_FILE_URI} to ${HOST_ENV_FILE_PATH}..."
aws s3 cp "${S3_ENV_FILE_URI}" "${HOST_ENV_FILE_PATH}" --region "${AWS_REGION}"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to download environment file from S3." >&2
  exit 1
fi
echo "Environment file downloaded successfully."

chown ec2-user:ec2-user "${HOST_ENV_FILE_PATH}"
chmod 600 "${HOST_ENV_FILE_PATH}"

echo "Environment prepared."
exit 0 