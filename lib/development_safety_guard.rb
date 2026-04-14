# typed: false
# frozen_string_literal: true

require "active_model"

module DevelopmentSafetyGuard
  class UnsafeConfigurationError < StandardError; end

  LOCAL_HOSTS = %w(
    localhost
    app.localhost
    com.localhost
    org.localhost
    sign.app.localhost
    sign.com.localhost
    sign.org.localhost
    www.app.localhost
    www.com.localhost
    www.org.localhost
    docs.app.localhost
    docs.com.localhost
    docs.org.localhost
  ).freeze

  PUBLIC_HOSTS = %w(
    sign.umaxica.app
    sign.umaxica.com
    sign.umaxica.org
  ).freeze

  module_function

  def allowed_hosts(env: ENV)
    hosts = LOCAL_HOSTS.dup
    hosts.concat(PUBLIC_HOSTS) if allow_public_hosts?(env:)
    hosts
  end

  def mailer_delivery_method(env: ENV)
    allow_development_smtp?(env:) ? :smtp : :test
  end

  def perform_deliveries?(env: ENV)
    allow_development_smtp?(env:)
  end

  def validate_sms_provider!(sms_provider:, env: ENV)
    return if sms_provider == "test"
    return if allow_live_sms_in_development?(env:)

    raise UnsafeConfigurationError,
          "Development SMS provider must stay test unless ALLOW_LIVE_SMS_IN_DEVELOPMENT=1"
  end

  def allow_development_smtp?(env: ENV)
    boolean_env(env, "ALLOW_DEVELOPMENT_SMTP")
  end

  def allow_public_hosts?(env: ENV)
    boolean_env(env, "ALLOW_PUBLIC_DEV_HOSTS")
  end

  def allow_live_sms_in_development?(env: ENV)
    boolean_env(env, "ALLOW_LIVE_SMS_IN_DEVELOPMENT")
  end

  def boolean_env(env, key)
    ActiveModel::Type::Boolean.new.cast(env[key])
  end
end
