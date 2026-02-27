# typed: false
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
      reload_preferences_and_reissue_token!
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
      reload_preferences_and_reissue_token!
    end

    return if @preference_language.option_id.blank?

    language = option_id_to_language(@preference_language.option_id, preference_prefix)
    write_preference_cookie(Preference::Base::LANGUAGE_COOKIE_KEY, language) if language.present?
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
        reload_preferences_and_reissue_token!
      rescue ActiveRecord::RecordInvalid, ActiveRecord::InvalidForeignKey
        raise PreferenceOperationError
      end
    end

    return if @preference_timezone.option_id.blank?

    timezone = option_id_to_timezone(@preference_timezone.option_id, preference_prefix)
    write_preference_cookie(Preference::Base::TIMEZONE_COOKIE_KEY, timezone) if timezone.present?
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
      reload_preferences_and_reissue_token!
    end

    return if @preference_colortheme.option_id.blank?

    colortheme = option_id_to_colortheme(@preference_colortheme.option_id, preference_prefix)
    short_code = colortheme_short_code(colortheme)
    write_preference_cookie(Preference::Base::THEME_COOKIE_KEY, short_code) if short_code.present?
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
      reload_preferences_and_reissue_token!
    end
  end

  private

  def reload_preferences_and_reissue_token!
    @preferences.reload
    # Force reload all preference associations to ensure they reflect DB state
    %w(language region timezone colortheme).each do |type|
      assoc_name = "#{preference_prefix_underscore}_#{type}"
      @preferences.association(assoc_name.to_sym).reload if @preferences.respond_to?(assoc_name)
    end
    issue_access_token_from(@preferences)
  end

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
    preference = find_preference_for_delete
    delete_preference_record(preference) if preference.present?
    delete_preference_cookies
    reset_preference_state
    nil
  end

  private

  def find_preference_for_delete
    return @preferences if @preferences.present?

    token_value = refresh_token_value
    @refresh_token_value = token_value
    return nil if token_value.blank?

    token_digest = refresh_token_lookup_digest(token_value)
    return nil unless token_digest

    PreferenceRecord.connected_to(role: :writing) do
      preference_class.find_by(token_digest: token_digest)
    end
  end

  def delete_preference_record(preference)
    PreferenceRecord.connected_to(role: :writing) do
      PreferenceRecord.transaction do
        preference.update!(
          status_id: preference_status_class::DELETED,
          expires_at: Time.current,
        )

        @preferences = preference
        create_audit_log(
          event_id: preference_audit_event_class::RESET_BY_USER_DECISION,
          context: { preference_deleted: true },
        )
      rescue ActiveRecord::RecordInvalid, ActiveRecord::InvalidForeignKey => e
        Rails.logger.error("delete_preference_cookie failed: #{e.class} - #{e.message}")
        raise PreferenceOperationError
      end
    end
  end

  def delete_preference_cookies
    clear_preference_auth_cookies!

    cookie_names = [
      Preference::Base::THEME_COOKIE_KEY,
      Preference::Base::LEGACY_THEME_COOKIE_KEY,
      Preference::Base::LANGUAGE_COOKIE_KEY,
      Preference::Base::TIMEZONE_COOKIE_KEY,
    ].uniq
    cookie_names.each do |cookie_name|
      cookies.delete(cookie_name, **preference_cookie_deletion_options)
    end
  end

  def reset_preference_state
    @preferences = nil
    @preference_payload = nil
    @refresh_token_value = nil
  end
end
