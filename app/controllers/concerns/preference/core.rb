# frozen_string_literal: true

module Preference::Core
  extend ActiveSupport::Concern
  include Preference::Base

  included do
    before_action :ensure_preferences_record
  end

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
        sanitize_option_id(preference_region_params, option_type: :region),
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
        sanitize_option_id(preference_language_params, option_type: :language),
        "UPDATE_PREFERENCE_LANGUAGE",
      )
    end

    if @preference_language.option_id.present?
      language = option_id_to_language(@preference_language.option_id, preference_prefix)
      write_preference_cookie(Preference::Base::LANGUAGE_COOKIE_KEY, language) if language.present?
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
          sanitize_option_id(preference_timezone_params, option_type: :timezone),
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
        sanitize_option_id(preference_colortheme_params, option_type: :colortheme),
        "UPDATE_PREFERENCE_COLORTHEME",
      )
    end

    if @preference_colortheme.option_id.present?
      colortheme = option_id_to_colortheme(@preference_colortheme.option_id, preference_prefix)
      short_code = colortheme_short_code(colortheme)
      write_preference_cookie(Preference::Base::THEME_COOKIE_KEY, short_code) if short_code.present?
    end
  end

  def set_cookie_preferences_edit
    PreferenceRecord.connected_to(role: :writing) do
      @preference_cookie = load_or_create_preference_child(
        "Cookie",
        targetable: false, performant: false, functional: false, consented: false,
      )
    end
  end

  def set_cookie_preferences_update
    PreferenceRecord.connected_to(role: :writing) do
      @preference_cookie = load_or_create_preference_child(
        "Cookie",
        targetable: false, performant: false, functional: false, consented: false,
      )

      update_params = build_cookie_update_params(@preference_cookie, preference_cookie_params)

      update_preference_child_with_audit(
        @preference_cookie,
        update_params,
        "UPDATE_PREFERENCE_COOKIE",
      )
    end
  end

  private

  def preference_cookie_params
    params.expect(preference_cookie: %i(functional performant targetable consented consented_at))
  end

  def build_cookie_update_params(cookie, params)
    # Ensure nested params are a Hash with indifferent access for reliable key access.
    # Note: Rails 8 `expect` returns an ActionController::Parameters object,
    # which we want to convert to Hash with indifferent access after ensuring it's permitted.
    p_hash = params.to_h.with_indifferent_access
    return p_hash unless p_hash.has_key?(:consented)

    consent_value = ActiveModel::Type::Boolean.new.cast(p_hash[:consented])

    if consent_value && !cookie.consented?
      p_hash[:consented_at] = Time.current
    elsif !consent_value && cookie.consented?
      p_hash[:consented_at] = nil
    end
    p_hash
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
    preference = @preferences

    if preference.blank?
      token_value = refresh_token_value
      @refresh_token_value = token_value
      if token_value.present?
        token_digest = refresh_token_lookup_digest(token_value)
        PreferenceRecord.connected_to(role: :writing) do
          preference = preference_class.find_by(token_digest: token_digest) if token_digest
        end
      end
    end

    if preference.present?
      # Update preference status and create audit log in transaction
      PreferenceRecord.connected_to(role: :writing) do
        PreferenceRecord.transaction do
          # Update preference to deleted status
          preference.update!(
            status_id: preference_status_class::DELETED,
            expires_at: Time.current,
          )

          # Set @preferences temporarily for create_audit_log
          @preferences = preference
          create_audit_log(
            event_id: preference_audit_event_class::RESET_BY_USER_DECISION,
            context: { preference_deleted: true },
          )
        rescue ActiveRecord::RecordInvalid, ActiveRecord::InvalidForeignKey => e
          # Log the error for debugging
          Rails.logger.error("delete_preference_cookie failed: #{e.class} - #{e.message}")
          raise PreferenceOperationError
        end
      end
    end

    # Always delete preference cookies, even if the preference record is missing.
    delete_options = {
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
    }
    domain = cookie_domain
    delete_options[:domain] = domain if domain.present?

    cookie_names = [
      refresh_token_cookie_name,
      access_token_cookie_name,
      Preference::Base::THEME_COOKIE_KEY,
      Preference::Base::LEGACY_THEME_COOKIE_KEY,
      Preference::Base::LANGUAGE_COOKIE_KEY,
      Preference::Base::TIMEZONE_COOKIE_KEY,
    ].uniq
    cookie_names.each do |cookie_name|
      cookies.delete(cookie_name, **delete_options)
    end

    @preferences = nil
    @preference_payload = nil
    @refresh_token_value = nil

    nil
  end
end
