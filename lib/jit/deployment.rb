# typed: false
# frozen_string_literal: true

module Jit
  module Deployment
    MODES = %w(global local development).freeze

    def self.mode
      ENV.fetch("DEPLOY_MODE", "development")
    end

    def self.global?
      mode.in?(%w(global development))
    end

    def self.local?
      mode.in?(%w(local development))
    end
  end
end
