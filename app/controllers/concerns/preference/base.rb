# frozen_string_literal: true

module Preference::Base
  extend ActiveSupport::Concern

  require "sha3"

  included do
    before_action :set_preferences_cookie
  end

  private

  def set_preferences_cookie
    # Return if preference already exists in database
    cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
    if cookies[cookie_name].present?
      token_digest = SHA3::Digest::SHA3_384.digest(cookies[cookie_name])
      @preferences = preference_class.find_by(token_digest: token_digest)

      # Return if valid preference found (not deleted and not expired)
      valid_preference = @preferences.present? &&
        @preferences.status_id != "DELETED" &&
        (@preferences.expires_at.nil? || @preferences.expires_at > Time.current)

      if valid_preference
        return
      end
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

        # Register audit log
        audit_class = "#{preference_class.name}Audit".constantize
        audit_class.create!(
          subject_id: @preferences.id.to_s,
          subject_type: preference_class.name,
          event_id: "CREATE_NEW_PREFERENCE_TOKEN",
          level_id: "INFO",
          occurred_at: Time.current,
          expires_at: 1.year.from_now,
          ip_address: request.remote_ip || "0.0.0.0",
          context: { token_created: true },
        )
      rescue ActiveRecord::RecordInvalid => e
        # Delete preference if audit registration fails
        @preferences&.destroy
        raise e
      end
    end

    # Store token in cookie (valid for 20 years)
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

  def preference_class
    @preference_class ||=
      begin
        # Extract prefix from controller_path
        # e.g., "core/app/v1/preferences" -> "App"
        path_parts = controller_path.split("/")
        prefix = path_parts[1]&.capitalize
        "#{prefix}Preference".constantize
      end
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
