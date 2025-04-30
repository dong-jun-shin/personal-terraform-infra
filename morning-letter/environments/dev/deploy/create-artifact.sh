#!/bin/bash
set -e # error handling

ENVIRONMENT="dev"
APP_NAME="morning-letter"
VERSION=${VERSION:-${GITHUB_SHA:-latest}}
ARTIFACT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/artifacts"
ARTIFACT_NAME="${APP_NAME}-${ENVIRONMENT}-deploy-artifacts-${VERSION}.tgz"

S3_BUCKET="infra-files"
S3_KEY="morning-letter-infra/deployments/${ARTIFACT_NAME}"
AWS_REGION="ap-northeast-2"

echo "Starting tar creation for ${APP_NAME} (${ENVIRONMENT}) ${ARTIFACT_NAME}, version ${VERSION}..."
cd "${ARTIFACT_DIR}"
tar -czf "${ARTIFACT_NAME}" appspec.yml scripts/
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to create tar file." >&2
  exit 1
fi

echo "Uploading artifact to s3://${S3_BUCKET}/${S3_KEY}..."
aws s3 cp "${ARTIFACT_NAME}" "s3://${S3_BUCKET}/${S3_KEY}" --region "${AWS_REGION}"

echo "Removing local artifact file: ${ARTIFACT_NAME}"
rm "${ARTIFACT_NAME}"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to upload artifact to S3." >&2
  exit 1
fi

echo "Deployment artifact process finished successfully for version ${VERSION}."
echo "Artifact S3 Path: s3://${S3_BUCKET}/${S3_KEY}"
