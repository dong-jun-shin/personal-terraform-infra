#!/bin/bash
set -e # error handling

NODE_ENV="development"
AWS_REGION="ap-northeast-2"
CONTAINER_NAME="morning-letter-be"
HOST_ENV_FILE_PATH="/home/ec2-user/morning-letter/.env.${NODE_ENV}"

DOCKER_IMAGE_URI="ghcr.io/dong-jun-shin/morning-letter-be:latest"
GITHUB_PAT_USERNAME="dong-jun-shin"
S3_GITHUB_PAT_URI="s3://infra-morning-letter-files/morning-letter-infra/deployments/github_token_docker_registry.env"
HOST_GITHUB_PAT_TMP_FILE="/tmp/github_token_docker_registry"

echo "Set GitHub PAT from S3..."
aws s3 cp "${S3_GITHUB_PAT_URI}" "${HOST_GITHUB_PAT_TMP_FILE}" --region "${AWS_REGION}"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to download GitHub PAT from S3." >&2
  rm -f "${HOST_GITHUB_PAT_TMP_FILE}"
  exit 1
fi
if [ ! -s "${HOST_GITHUB_PAT_TMP_FILE}" ]; then
    echo "ERROR: Downloaded PAT file is empty." >&2
    rm -f "${HOST_GITHUB_PAT_TMP_FILE}"
    exit 1
fi
GITHUB_TOKEN=$(cat "${HOST_GITHUB_PAT_TMP_FILE}")
rm -f "${HOST_GITHUB_PAT_TMP_FILE}"

echo "Login GitHub Packages Docker Registry (ghcr.io)..."
if echo "${GITHUB_TOKEN}" | docker login ghcr.io -u "${GITHUB_PAT_USERNAME}" --password-stdin; then
  echo "Docker login successful."
else
  echo "ERROR: Docker login failed." >&2
  unset GITHUB_TOKEN
  exit 1
fi
unset GITHUB_TOKEN

echo "Pull Docker image: ${DOCKER_IMAGE_URI}..."
if docker pull "${DOCKER_IMAGE_URI}"; then
  echo "Docker image pull successful."
else
  echo "ERROR: Docker image pull failed." >&2
  exit 1
fi

echo "Start container ${CONTAINER_NAME}(${NODE_ENV}) from image ${DOCKER_IMAGE_URI}..."
docker run -d \
  -p 80:55001 \
  --restart on-failure:5 \
  --name "${CONTAINER_NAME}" \
  -v "${HOST_ENV_FILE_PATH}:/opt/app/.env.${NODE_ENV}" \
  -e "NODE_ENV=${NODE_ENV}" \
  "${DOCKER_IMAGE_URI}"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to start Docker container." >&2
    exit 1
fi

sleep 5
if ! docker ps -q -f name=^/"${CONTAINER_NAME}"$; then
    echo "ERROR: Container ${CONTAINER_NAME} does not seem to be running after start command." >&2
    docker logs "${CONTAINER_NAME}"
    exit 1
fi

echo "Container ${CONTAINER_NAME} started successfully."
exit 0 