#!/usr/bin/env bash
set -euo pipefail

# Setup script for Nine27 Pharmacy Laravel backend
# - Installs composer deps (requires composer installed)
# - Prepares .env
# - Generates key
# - Runs migrations and seeders

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$PROJECT_DIR"

echo "[1/6] Checking composer..."
if ! command -v composer >/dev/null 2>&1; then
  echo "Composer not found. Please install composer first: https://getcomposer.org/download/" >&2
  exit 1
fi

echo "[2/6] Installing dependencies..."
composer install --no-interaction --prefer-dist --no-progress

echo "[3/6] Preparing .env..."
if [[ ! -f .env ]]; then
  cp .env.example .env
fi

echo "[4/6] Generating app key..."
php artisan key:generate --ansi

echo "[5/6] Running migrations..."
php artisan migrate --force

echo "[6/6] Seeding database..."
php artisan db:seed --force

echo "Setup complete. Start the server with: php artisan serve"
