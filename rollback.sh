#!/bin/bash
# Usage:
#   ./rollback.sh               → rollback to last stable image
#   ./rollback.sh <short_sha>   → rollback to a specific image tag

DEPLOY_DIR=~/projectpy
IMAGE_NAME=projectpy
LOG_FILE="$DEPLOY_DIR/logs/rollback_$(date +%Y%m%d_%H%M%S).log"

mkdir -p $DEPLOY_DIR/logs

echo "========================================" | tee -a $LOG_FILE
echo "Rollback started at $(date)"              | tee -a $LOG_FILE
echo "========================================" | tee -a $LOG_FILE

if [ -n "$1" ]; then
  TARGET_IMAGE="${IMAGE_NAME}:$1"
  echo "Target: $TARGET_IMAGE (manual)" | tee -a $LOG_FILE
else
  ROLLBACK_FILE="$DEPLOY_DIR/.last_stable_image"
  if [ ! -f "$ROLLBACK_FILE" ]; then
    echo "No rollback point found at $ROLLBACK_FILE" | tee -a $LOG_FILE
    exit 1
  fi
  TARGET_IMAGE=$(cat $ROLLBACK_FILE)
  echo "Target: $TARGET_IMAGE (last stable)" | tee -a $LOG_FILE
fi

# List available images for reference
echo "" | tee -a $LOG_FILE
echo "Available images:" | tee -a $LOG_FILE
docker images $IMAGE_NAME --format "  {{.Tag}} — {{.CreatedAt}}" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE

cd $DEPLOY_DIR
docker compose down >> $LOG_FILE 2>&1 || true
IMAGE_TAG=$(echo $TARGET_IMAGE | cut -d: -f2) docker compose up -d >> $LOG_FILE 2>&1

echo "========================================" | tee -a $LOG_FILE
echo "Rollback DONE at $(date)"                 | tee -a $LOG_FILE
echo "Running image: $TARGET_IMAGE"             | tee -a $LOG_FILE
echo "========================================" | tee -a $LOG_FILE
