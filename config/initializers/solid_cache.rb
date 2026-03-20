# typed: false
# frozen_string_literal: true

# Solid Cache reads store_options from config/cache.yml.
# connects_to is set in each environment file (before engine initializers run)
# because SolidCache 1.0.x deep_symbolize_keys only converts hash keys, not values,
# and ActiveRecord connects_to requires symbol values (:cache, not "cache").
