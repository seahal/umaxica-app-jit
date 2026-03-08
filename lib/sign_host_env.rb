# typed: false
# frozen_string_literal: true

module SignHostEnv
  module_function

  def service_url
    first_present("SIGN_SERVICE_URL", "AUTH_SERVICE_URL")
  end

  def staff_url
    first_present("SIGN_STAFF_URL", "AUTH_STAFF_URL")
  end

  def apply_legacy_fallbacks!
    ENV["SIGN_SERVICE_URL"] ||= service_url
    ENV["SIGN_STAFF_URL"] ||= staff_url
  end

  def first_present(*keys)
    keys.filter_map { |key| ENV[key].presence }.first
  end
end
