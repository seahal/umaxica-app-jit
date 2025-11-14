#!/bin/bash
set -e

echo "🔧 Setting up databases..."

# Wait a moment for services to be ready
sleep 2

# Create and migrate databases (idempotent)
# db:prepare will create databases if they don't exist and run migrations
echo "📦 Preparing databases..."
bin/rails db:prepare 2>/dev/null || {
  echo "⚠️  Initial db:prepare failed, waiting for PostgreSQL..."
  sleep 5
  echo "🔄 Retrying db:prepare..."
  bin/rails db:prepare
}

echo "✨ Database setup complete!"
