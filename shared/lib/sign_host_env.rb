# typed: false
# frozen_string_literal: true

# FIXME: Is this really needed?
module SignHostEnv
  class MissingHostError < StandardError; end

  module_function

  def service_url
    ENV["IDENTITY_SIGN_APP_URL"].presence
  end

  def corporate_url
    ENV["IDENTITY_SIGN_COM_URL"].presence
  end

  def staff_url
    ENV["IDENTITY_SIGN_ORG_URL"].presence
  end

  def validate!
    missing = []
    missing << "IDENTITY_SIGN_APP_URL" if service_url.blank?
    missing << "IDENTITY_SIGN_COM_URL" if corporate_url.blank?
    missing << "IDENTITY_SIGN_ORG_URL" if staff_url.blank?
    return if missing.empty?

    raise MissingHostError, "Missing required sign host env: #{missing.join(", ")}"
  end
end
