#!/bin/bash
set -e

echo "🔧 Setting up databases..."

# Wait for PostgreSQL to be ready
max_attempts=30
attempt=0

until PGPASSWORD=${POSTGRESQL_PASSWORD} psql -h primary -U ${POSTGRESQL_USER} -d postgres -c '\q' 2>/dev/null; do
  attempt=$((attempt + 1))
  if [ $attempt -ge $max_attempts ]; then
    echo "❌ PostgreSQL failed to become ready after $max_attempts attempts"
    exit 1
  fi
  echo "⏳ Waiting for PostgreSQL... (attempt $attempt/$max_attempts)"
  sleep 2
done

echo "✅ PostgreSQL is ready!"

# Create and migrate databases (idempotent)
# db:prepare will create databases if they don't exist and run migrations
echo "📦 Preparing all databases..."

# Set REGION_CODE for database operations
export REGION_CODE=${REGION_CODE:-jp}

# Run db:prepare which is idempotent (safe to run multiple times)
RAILS_ENV=development bin/rails db:prepare || {
  echo "⚠️  db:prepare failed, retrying once..."
  sleep 3
  RAILS_ENV=development bin/rails db:prepare
}

echo "✨ All databases are ready!"
echo "   You can now start developing without running db:create manually."
