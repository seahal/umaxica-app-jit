# typed: false
# frozen_string_literal: true

module CsrfTrustedOrigins
  extend ActiveSupport::Concern

  class_methods do
    def csrf_trusted_origins(env_key, default_value)
      ENV.fetch(env_key, default_value).split(",").map(&:strip)
    end
  end
end
