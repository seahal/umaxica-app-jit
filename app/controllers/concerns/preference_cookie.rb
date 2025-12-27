# frozen_string_literal: true

require "json"

module PreferenceCookie
  extend ActiveSupport::Concern
  include PreferenceConstants

  private

  def preference_scope
    controller_path.to_s.split("/")[1] || "app"
  end

  def preference_cookie_key
    :"__Secure-root_#{preference_scope}_preferences"
  end

  def preference_token_host
    request&.host.to_s.presence || "unknown"
  end

  def preference_cookie_domain
    host = request&.host.to_s
    return nil if host.blank?

    parts = host.split(".")
    scope = preference_scope
    index = parts.index(scope)
    return nil unless index

    domain = parts[index..].join(".")
    return nil if domain.blank?

    ".#{domain}"
  end

  def read_preference_cookie
    token = cookies[preference_cookie_key]
    decoded = PreferenceToken.decode(token, host: preference_token_host)
    return PreferenceToken.extract_preferences(decoded) if decoded.is_a?(Hash)

    legacy = legacy_preference_cookie
    legacy.presence || {}
  end

  def write_preference_cookie(preferences)
    token = PreferenceToken.encode(preferences, host: preference_token_host)
    return if token.blank?

    cookies.permanent[preference_cookie_key] = {
      value: token,
      domain: preference_cookie_domain,
      httponly: true,
      secure: true,
      same_site: :lax,
    }
  end

  def delete_preference_cookie
    domain = preference_cookie_domain
    options = domain ? { domain: domain } : {}
    cookies.delete(preference_cookie_key, **options)
  end

  def legacy_preference_cookie
    raw = cookies.signed[preference_cookie_key]
    return {} if raw.blank?

    parsed = JSON.parse(raw)
    return {} unless parsed.is_a?(Hash)

    parsed.slice(*PREFERENCE_KEYS)
  rescue JSON::ParserError, TypeError => error
    Rails.event.notify("preference_cookie.legacy_parse_failed", error_message: error.message)
    {}
  end
end
