# frozen_string_literal: true

module Preference::Core
  extend ActiveSupport::Concern
  include Preference::Base

  COOKIE_EXPIRY = 400.days

  def set_region_preferences_edit
    PreferenceRecord.connected_to(role: :writing) do
      @preference_region = load_or_create_preference_child("Region", option_id: nil)
    end
  end

  def set_region_preferences_update
    PreferenceRecord.connected_to(role: :writing) do
      @preference_region = load_or_create_preference_child("Region", option_id: nil)

      update_preference_child_with_audit(
        @preference_region,
        sanitize_option_id(preference_region_params),
        "UPDATE_PREFERENCE_REGION",
      )
    end
  end

  def set_language_preferences_edit
    PreferenceRecord.connected_to(role: :writing) do
      @preference_language = load_or_create_preference_child("Language", option_id: nil)
    end
  end

  def set_language_preferences_update
    PreferenceRecord.connected_to(role: :writing) do
      @preference_language = load_or_create_preference_child("Language", option_id: nil)

      update_preference_child_with_audit(
        @preference_language,
        sanitize_option_id(preference_language_params),
        "UPDATE_PREFERENCE_LANGUAGE",
      )
    end
  end

  def set_timezone_preferences_edit
    PreferenceRecord.connected_to(role: :writing) do
      @preference_timezone = load_or_create_preference_child("Timezone", option_id: nil)
    end
  end

  def set_timezone_preferences_update
    raise PreferenceOperationError if @preferences.blank?

    PreferenceRecord.connected_to(role: :writing) do
      @preference_timezone = load_or_create_preference_child("Timezone", option_id: nil)

      begin
        update_preference_child_with_audit(
          @preference_timezone,
          sanitize_option_id(preference_timezone_params),
          "UPDATE_PREFERENCE_TIMEZONE",
        )
      rescue ActiveRecord::RecordInvalid, ActiveRecord::InvalidForeignKey
        raise PreferenceOperationError
      end
    end
  end

  def set_colortheme_preferences_edit
    PreferenceRecord.connected_to(role: :writing) do
      @preference_colortheme = load_or_create_preference_child("Colortheme", option_id: nil)
    end
  end

  def set_colortheme_preferences_update
    PreferenceRecord.connected_to(role: :writing) do
      @preference_colortheme = load_or_create_preference_child("Colortheme", option_id: nil)

      update_preference_child_with_audit(
        @preference_colortheme,
        sanitize_option_id(preference_colortheme_params),
        "UPDATE_PREFERENCE_COLORTHEME",
      )
    end
  end

  def set_cookie_preferences_edit
    PreferenceRecord.connected_to(role: :writing) do
      @preference_cookie = load_or_create_preference_child(
        "Cookie",
        targetable: false, performant: false, functional: false,
      )
    end
  end

  def set_cookie_preferences_update
    PreferenceRecord.connected_to(role: :writing) do
      @preference_cookie = load_or_create_preference_child(
        "Cookie",
        targetable: false, performant: false, functional: false,
      )

      update_preference_child_with_audit(
        @preference_cookie,
        preference_cookie_params,
        "UPDATE_PREFERENCE_COOKIE",
      )
    end
  end

  private

  def preference_cookie_params
    params.expect(preference_cookie: %i(functional performant targetable))
  end

  def preference_language_params
    params.expect(preference_language: [:option_id])
  end

  def preference_timezone_params
    params.expect(preference_timezone: [:option_id])
  end

  def preference_region_params
    params.expect(preference_region: [:option_id])
  end

  def preference_colortheme_params
    params.expect(preference_colortheme: [:option_id])
  end

  def delete_preference_cookie
    raise PreferenceOperationError if @preferences.blank?

    # Return early if no preference cookie exists
    cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
    return if cookies[cookie_name].blank?

    # Find existing preference
    require "sha3"
    token_digest = SHA3::Digest::SHA3_384.digest(cookies[cookie_name])
    preference = preference_class.find_by(token_digest: token_digest)
    return if preference.blank?

    # Store original values for rollback
    original_status_id = preference.status_id
    original_expires_at = preference.expires_at

    # Update preference status and create audit log in transaction
    ActiveRecord::Base.connected_to(role: :writing) do
      ActiveRecord::Base.transaction do
        # Update preference to deleted status
        preference.update!(
          status_id: "DELETED",
          expires_at: Time.current,
        )

        # Set @preferences temporarily for create_audit_log
        @preferences = preference
        create_audit_log(
          event_id: "RESET_BY_USER_DECISION",
          context: { preference_deleted: true },
        )
      rescue ActiveRecord::RecordInvalid
        # Rollback preference update if audit registration fails
        preference.update!(
          status_id: original_status_id,
          expires_at: original_expires_at,
        )
        raise PreferenceOperationError
      end
    end

    # Delete the preference cookie
    delete_options = {
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
    }
    domain = cookie_domain
    delete_options[:domain] = domain if domain.present?

    cookies.delete(cookie_name, **delete_options)

    nil
  end
end
