#!/usr/bin/env bash
set -euo pipefail

DEPLOY_DIR="/opt/student-grade-service"
BACKUP_ROOT="/opt/student-grade-service-backups"
SERVICE_NAME="student-grade-service"
RELEASE_DIR="$DEPLOY_DIR/current"
APP_NAME="student_grade_service"
APP_USER="ubuntu"
APP_GROUP="ubuntu"

LAST_BACKUP=$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d | sort -r | head -n 1 || true)

if [[ -z "$LAST_BACKUP" ]]; then
  echo "No backup found to rollback"
  exit 1
fi

echo "Rolling back using backup: $LAST_BACKUP"
rm -rf "$RELEASE_DIR"
install -d -m 755 -o "$APP_USER" -g "$APP_GROUP" "$RELEASE_DIR"
cp -a "$LAST_BACKUP/." "$RELEASE_DIR/"
chown -R "$APP_USER:$APP_GROUP" "$RELEASE_DIR"
chmod +x "$RELEASE_DIR/$APP_NAME"
systemctl daemon-reload
systemctl restart "$SERVICE_NAME"
