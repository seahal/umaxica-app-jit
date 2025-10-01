# frozen_string_literal: true

module News
  module Org
    class ApplicationController < ActionController::Base
      allow_browser versions: :modern

      # Built-in Rails' rate limiting API
      RATE_LIMIT_STORE = ActiveSupport::Cache::RedisCacheStore.new(url: Rails.application.credentials.dig(:REDIS, :REDIS_RACK_ATTACK_URL))
      rate_limit to: 1000, within: 1.hour, store: RATE_LIMIT_STORE
    end
  end
end
