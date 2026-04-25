#!/bin/bash
set -e

apps=("zenith" "foundation" "distributor")
engines=("Zenith" "Foundation" "Distributor")

for i in "${!apps[@]}"; do
  app="${apps[$i]}"
  engine="${engines[$i]}"
  app_module="$(echo $app | sed 's/\b\(.\)/\u\1/g')App"
  
  echo "Initializing apps/$app..."
  
  mkdir -p "apps/$app/config/environments/"
  mkdir -p "apps/$app/config/initializers/"
  mkdir -p "apps/$app/config/credentials/"
  mkdir -p "apps/$app/bin/"
  mkdir -p "apps/$app/app/views/layouts/"
  mkdir -p "apps/$app/public/"
  mkdir -p "apps/$app/log/"
  mkdir -p "apps/$app/tmp/storage/"
  mkdir -p "apps/$app/tmp/cache/"
  mkdir -p "apps/$app/tmp/pids/"
  mkdir -p "apps/$app/tmp/sockets/"

  # bin/rails
  cp bin/rails "apps/$app/bin/"
  chmod +x "apps/$app/bin/rails"

  # config/boot.rb
  cat <<EOF > "apps/$app/config/boot.rb"
# typed: false
# frozen_string_literal: true

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

# Add root lib to LOAD_PATH
\$LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
EOF

  # config/application.rb
  # Copy identity's application.rb and replace IdentityApp with the current app module
  sed "s/IdentityApp/$app_module/g" apps/identity/config/application.rb > "apps/$app/config/application.rb"

  # config/environment.rb
  cp apps/identity/config/environment.rb "apps/$app/config/"

  # config/routes.rb
  cat <<EOF > "apps/$app/config/routes.rb"
# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # $engine engine
  mount Jit::${engine}::Engine => "/", :as => :${app}
end
EOF

  # Copy config files
  cp config/environments/*.rb "apps/$app/config/environments/"
  cp config/initializers/*.rb "apps/$app/config/initializers/"
  cp config/importmap.rb "apps/$app/config/"
  cp config/database.yml "apps/$app/config/"
  cp config/storage.yml "apps/$app/config/"
  cp config/cable.yml "apps/$app/config/"
  cp config/queue.yml "apps/$app/config/"
  cp config/cache.yml "apps/$app/config/"
  cp -r config/credentials/* "apps/$app/config/credentials/"
  
  # Copy layouts
  cp -r app/views/layouts/* "apps/$app/app/views/layouts/"

  # Fix relative paths
  sed -i 's|Rails.root.join("lib/|Rails.root.join("../../lib/|g' "apps/$app/config/environments/"*.rb
  sed -i 's|Rails.root.join("lib/|Rails.root.join("../../lib/|g' "apps/$app/config/initializers/"*.rb
  sed -i 's|require_relative "../../lib/|require_relative "../../../../lib/|g' "apps/$app/config/initializers/"*.rb
  sed -i 's|Rails.root.join("config/locales")|Rails.root.join("../../config/locales")|g' "apps/$app/config/initializers/locale.rb"

done

echo "All wrapper apps initialized."
