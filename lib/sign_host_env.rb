# typed: false
# frozen_string_literal: true

module SignHostEnv
  class MissingHostError < StandardError; end

  module_function

  def service_url
    ENV["SIGN_SERVICE_URL"].presence
  end

  def staff_url
    ENV["SIGN_STAFF_URL"].presence
  end

  def validate!
    missing = []
    missing << "SIGN_SERVICE_URL" if service_url.blank?
    missing << "SIGN_STAFF_URL" if staff_url.blank?
    return if missing.empty?

    raise MissingHostError, "Missing required sign host env: #{missing.join(", ")}"
  end
end
