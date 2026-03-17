# typed: false
# frozen_string_literal: true

require Rails.root.join("lib/sign_host_env").to_s

# config/initializers/session_store.rb
sign_service_host = SignHostEnv.service_url.to_s
non_local_host =
  sign_service_host.present? &&
  sign_service_host.exclude?("localhost") &&
  !sign_service_host.start_with?("127.") &&
  !sign_service_host.start_with?("0.0.0.0")

# Avoid secure-only cookies in test to keep session state across HTTP requests.
force_secure_cookies =
  (Rails.env.production? ||
    ENV["FORCE_SECURE_COOKIES"] == "1" ||
    non_local_host) &&
  !Rails.env.test?

Rails.application.config.session_store :cookie_store,
                                       expire_after: 14.days,
                                       key: force_secure_cookies ? "__Secure-session" : "session",
                                       secure: force_secure_cookies,
                                       httponly: true,
                                       same_site: :lax
