# typed: false
# frozen_string_literal: true

module Jit
  module Deployment
    # Four-engine deployment modes:
    # - signature: Auth/Passkey/OIDC endpoints (sign.* hosts)
    # - world: Global BFF/Dashboard (apex hosts)
    # - station: Regional operations (www.* hosts)
    # - press: Content delivery via closed network (docs/news/help)
    # - development: Loads all engines
    MODES = %w(signature world station press development).freeze

    def self.mode
      ENV.fetch("DEPLOY_MODE", "development")
    end

    def self.development?
      mode == "development"
    end

    def self.signature?
      mode == "signature" || mode == "development"
    end

    def self.world?
      mode == "world" || mode == "development"
    end

    def self.station?
      mode == "station" || mode == "development"
    end

    def self.press?
      mode == "press" || mode == "development"
    end

    # Legacy compatibility methods (deprecated)
    def self.global?
      signature? || world?
    end

    def self.local?
      station? || press?
    end
  end
end
