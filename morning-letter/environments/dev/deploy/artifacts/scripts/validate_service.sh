#!/bin/bash
set -e # error handling

HEALTH_CHECK_URL="http://localhost:80/health"
MAX_RETRIES=5
RETRY_INTERVAL=5

echo "Validating service at ${HEALTH_CHECK_URL}..."
for (( i=1; i<=${MAX_RETRIES}; i++ )); do
  if curl -fso /dev/null "${HEALTH_CHECK_URL}"; then
    echo "Validation successful after ${i} attempt(s)."
    exit 0
  fi
  
  if [ ${i} -lt ${MAX_RETRIES} ]; then
    echo "Validation attempt ${i} failed. Retrying in ${RETRY_INTERVAL} seconds..."
    sleep ${RETRY_INTERVAL}
  fi
done

echo "ERROR: Service validation failed after ${MAX_RETRIES} attempts." >&2
exit 1 