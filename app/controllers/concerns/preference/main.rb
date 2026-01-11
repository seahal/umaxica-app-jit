# frozen_string_literal: true

module Preference::Main
  extend ActiveSupport::Concern
  include Preference::Base

  require "sha3"

  included do
    before_action :set_preferences_cookie
    before_action :set_color_theme
  end

  private

  def set_color_theme
    return if @preferences.blank?

    colortheme = @preferences.public_send(preference_colortheme_association)
    theme = colortheme&.option_id.presence || "system"
    session[:theme] = theme

    cookie_options = {
      value: theme,
      expires: Preference::Core::COOKIE_EXPIRY.from_now,
      secure: Rails.env.production?,
      same_site: :lax,
    }
    cookie_options[:domain] = :all unless Rails.env.development?
    cookies[:ct] = cookie_options # NOTE: DO NOT READ at Ruby on Rails. THIS CODE FOR Frontend JavaScript ENV.
  end

  def set_preferences_cookie
    # Return if preference already exists in database
    cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
    if cookies[cookie_name].present?
      token_digest = SHA3::Digest::SHA3_384.digest(cookies[cookie_name])
      @preferences = preference_class.includes(preference_associations_to_preload).find_by(token_digest: token_digest)

      # Return if valid preference found (not deleted and not expired)
      valid_preference = @preferences.present? &&
        @preferences.status_id != "DELETED" &&
        (@preferences.expires_at.nil? || @preferences.expires_at > Time.current)

      return if valid_preference
    end

    # Generate new token
    token = SecureRandom.urlsafe_base64(48)
    token_digest = SHA3::Digest::SHA3_384.digest(token)

    # Create preference and audit log in transaction
    ActiveRecord::Base.connected_to(role: :writing) do
      ActiveRecord::Base.transaction do
        @preferences = preference_class.create!(
          token_digest: token_digest,
          expires_at: 1.year.from_now,
        )

        # Create associated preference options
        create_preference_options(@preferences)

        # Register audit log using Base method
        create_audit_log(
          event_id: "CREATE_NEW_PREFERENCE_TOKEN",
          context: { token_created: true },
          expires_at: 1.year.from_now,
        )
      rescue ActiveRecord::RecordInvalid => e
        # Delete preference if audit registration fails
        @preferences&.destroy
        raise e
      end
    end

    # Store token in cookie (valid for 1 year)
    cookie_options = {
      value: token,
      expires: 1.year.from_now,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
    }

    # Only set domain in production (avoid .localhost issues in development)
    cookie_options[:domain] = :all unless Rails.env.development?

    cookies[cookie_name] = cookie_options

    nil
  end

  def create_preference_options(preference)
    prefix = preference.class.name.gsub("Preference", "")

    # Create cookie preference with default values
    "#{prefix}PreferenceCookie".constantize.create!(
      preference_id: preference.id,
      targetable: false,
      performant: false,
      functional: false,
    )

    # Create timezone preference (optional option_id)
    "#{prefix}PreferenceTimezone".constantize.create!(
      preference_id: preference.id,
      option_id: "Asia/Tokyo",
    )

    # Create language preference (optional option_id)
    "#{prefix}PreferenceLanguage".constantize.create!(
      preference_id: preference.id,
      option_id: "JA",
    )

    # Create region preference (optional option_id)
    "#{prefix}PreferenceRegion".constantize.create!(
      preference_id: preference.id,
      option_id: "JP", # TODO: Refactor this.
    )

    # Create colortheme preference (optional option_id)
    "#{prefix}PreferenceColortheme".constantize.create!(
      preference_id: preference.id,
      option_id: "system",
    )
  end
end
