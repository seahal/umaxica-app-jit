# frozen_string_literal: true

module Preference::Base
  extend ActiveSupport::Concern

  require "sha3"

  ACCESS_TOKEN_TTL = Preference::Token::ACCESS_TOKEN_TTL
  REFRESH_TOKEN_TTL = 400.days

  private

  def set_preferences_cookie
    return if load_access_token_payload

    # TODO: Prefer a dedicated refresh endpoint with CSRF checks and rate limiting.
    # TODO: For React Router, trigger refresh on 401/419 and fetch CSRF token via a dedicated endpoint.
    preference, created = load_preference_record_from_refresh_token!(create_if_missing: true)
    return if preference.blank?

    refresh_refresh_token_lifetime(preference) unless created
    issue_access_token_from(preference)
    nil
  end

  def set_color_theme
    theme =
      preference_payload_value("ct") ||
      @preferences&.public_send(preference_colortheme_association)&.option_id ||
      "system"

    session[:theme] = theme

    cookie_options = {
      value: theme,
      expires: REFRESH_TOKEN_TTL.from_now,
      secure: Rails.env.production?,
      same_site: :lax,
    }
    domain = cookie_domain
    cookie_options[:domain] = domain if domain.present?
    cookies[:ct] = cookie_options # NOTE: DO NOT READ at Ruby on Rails. THIS CODE FOR Frontend JavaScript ENV.
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

  def set_locale_from_params
    locale_param = params[:lx].presence
    locale_from_region = locale_from_region_param(params[:ri])
    locale = locale_param || locale_from_region || session[:language]&.downcase || I18n.default_locale
    I18n.locale = locale.to_s.downcase
  end

  def locale_from_region_param(region_param)
    region = region_param.to_s.downcase
    return if region.blank?

    {
      "jp" => "ja",
      "us" => "en",
    }[region]
  end

  def set_timezone_from_session
    Time.zone = session[:timezone] if session[:timezone].present?
  end

  # Get the preference class based on controller path
  # e.g., "core/app/v1/preferences" -> AppPreference
  def preference_class
    @preference_class ||=
      begin
        path_parts = controller_path.split("/")
        prefix = path_parts[1]&.capitalize
        "#{prefix}Preference".constantize
      end
  end

  # Get the audit class for the current preference type
  def audit_class
    @audit_class ||= "#{preference_class.name}Audit".constantize
  end

  # Create an audit log entry
  def create_audit_log(event_id:, context:, expires_at: nil)
    expires_at_value = expires_at || Preference::Core::COOKIE_EXPIRY.from_now

    AuditRecord.connected_to(role: :writing) do
      audit_class.create!(
        subject_id: @preferences.id.to_s,
        subject_type: @preferences.class.name,
        event_id: event_id,
        level_id: "INFO",
        occurred_at: Time.current,
        expires_at: expires_at_value,
        ip_address: request.remote_ip || "0.0.0.0",
        context: context,
      )
    end
  end

  # Get the preference model prefix (App, Com, Org)
  def preference_prefix
    @preference_prefix ||= preference_class.name.gsub("Preference", "")
  end

  # Get the underscored prefix for method names
  def preference_prefix_underscore
    @preference_prefix_underscore ||= preference_class.name.underscore
  end

  def preference_colortheme_association
    @preference_colortheme_association ||= "#{preference_prefix_underscore}_colortheme"
  end

  def association_name_for_region
    @association_name_for_region ||= :"#{preference_class.name.underscore}_region"
  end

  def association_name_for_language
    @association_name_for_language ||= :"#{preference_class.name.underscore}_language"
  end

  def preference_associations_to_preload
    [association_name_for_region, association_name_for_language]
  end

  # Load or create a preference child record (cookie, language, region, etc.)
  def load_or_create_preference_child(child_type, default_attributes = {})
    raise PreferenceOperationError if @preferences.blank?

    prefix = preference_prefix_underscore
    child_class = "#{@preferences.class.name}#{child_type}".constantize
    instance_var = "@preference_#{child_type.downcase}"

    # Always load from writing database to ensure fresh data
    child_record = child_class.find_by(preference_id: @preferences.id)

    if child_record.present?
      instance_variable_set(instance_var, child_record)
      return child_record
    end

    # Create new record if not found
    begin
      child_record = @preferences.public_send("create_#{prefix}_#{child_type.downcase}!", default_attributes)
      instance_variable_set(instance_var, child_record)
      child_record
    rescue ActiveRecord::RecordNotUnique
      # Race condition: record was created by another request
      child_record = child_class.find_by!(preference_id: @preferences.id)
      instance_variable_set(instance_var, child_record)
      child_record
    end
  end

  # Update a preference child record with audit logging
  def update_preference_child_with_audit(child_record, params, event_id)
    PreferenceRecord.transaction do
      child_record.assign_attributes(params)

      if child_record.changed?
        child_record.save!

        create_audit_log(
          event_id: event_id,
          context: child_record.previous_changes,
        )

        if @preferences.present?
          refresh_refresh_token_lifetime(@preferences)
          issue_access_token_from(@preferences)
        end
      end
    end
  end

  # Sanitize params: convert blank strings to nil
  def sanitize_option_id(params)
    params[:option_id] = nil if params[:option_id].blank?
    params
  end

  def load_access_token_payload
    token = cookies[access_token_cookie_name]
    return false if token.blank?

    payload = Preference::Token.decode(token, host: request.host)
    return false if payload.blank?
    return false if Preference::Token.extract_preference_type(payload) != preference_class.name

    @preference_payload = payload
    true
  end

  def load_preference_record_from_refresh_token!(create_if_missing: false)
    return [@preferences, false] if @preferences.present?

    token_value = refresh_token_value
    @refresh_token_value = token_value
    preference =
      if token_value.present?
        digest = refresh_token_digest(token_value)
        preference_class.includes(preference_associations_to_preload).find_by(token_digest: digest)
      end

    if valid_refresh_preference?(preference)
      @preferences = preference
      return [preference, false]
    end

    return [nil, false] unless create_if_missing

    preference = create_new_preference_record!
    [preference, true]
  end

  def create_new_preference_record!
    token = SecureRandom.urlsafe_base64(48)
    token_digest = refresh_token_digest(token)
    expires_at = refresh_token_expiry

    PreferenceRecord.connected_to(role: :writing) do
      ActiveRecord::Base.transaction do
        @preferences = preference_class.create!(
          token_digest: token_digest,
          expires_at: expires_at,
        )

        create_preference_options(@preferences)

        create_audit_log(
          event_id: "CREATE_NEW_PREFERENCE_TOKEN",
          context: { token_created: true },
          expires_at: expires_at,
        )
      rescue ActiveRecord::RecordInvalid => e
        @preferences&.destroy
        raise e
      end
    end

    @refresh_token_value = token
    set_refresh_token_cookie(token, expires_at)

    @preferences
  end

  def refresh_refresh_token_lifetime(preference)
    return if @refresh_token_value.blank? || preference.blank?

    new_token = SecureRandom.urlsafe_base64(48)
    new_digest = refresh_token_digest(new_token)
    new_expiry = refresh_token_expiry

    PreferenceRecord.connected_to(role: :writing) do
      preference.update!(
        token_digest: new_digest,
        expires_at: new_expiry,
      )
    end

    set_refresh_token_cookie(new_token, new_expiry)
    @refresh_token_value = new_token
  end

  def issue_access_token_from(preference)
    payload = build_preferences_payload(preference)
    token = Preference::Token.encode(
      payload,
      host: request.host,
      preference_type: preference.class.name,
      public_id: preference.public_id,
    )
    return if token.blank?

    cookie_options = {
      value: token,
      expires: ACCESS_TOKEN_TTL.from_now,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
    }
    domain = cookie_domain
    cookie_options[:domain] = domain if domain.present?
    cookies[access_token_cookie_name] = cookie_options

    @preference_payload = Preference::Token.decode(token, host: request.host)
  end

  def build_preferences_payload(preference)
    prefix = preference.class.name.underscore
    language = preference.public_send("#{prefix}_language")&.option_id
    region = preference.public_send("#{prefix}_region")&.option_id
    timezone = preference.public_send("#{prefix}_timezone")&.option_id
    colortheme = preference.public_send("#{prefix}_colortheme")&.option_id

    {
      "lx" => language.presence || "JA",
      "ri" => region.presence || "JP",
      "tz" => timezone.presence || "Asia/Tokyo",
      "ct" => colortheme.presence || "system",
    }
  end

  def preference_payload_preferences
    Preference::Token.extract_preferences(@preference_payload)
  end

  def preference_payload_value(key)
    preference_payload_preferences[key.to_s]
  end

  def preference_payload_public_id
    Preference::Token.extract_public_id(@preference_payload)
  end

  def ensure_preferences_record
    load_preference_record_from_refresh_token!(create_if_missing: true)
  end

  def refresh_token_expiry
    REFRESH_TOKEN_TTL.from_now
  end

  def refresh_token_cookie_name
    Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
  end

  def refresh_token_value
    cookies[refresh_token_cookie_name]
  end

  def refresh_token_digest(token)
    SHA3::Digest::SHA3_384.digest(token)
  end

  def set_refresh_token_cookie(token, expires_at)
    options = {
      value: token,
      expires: expires_at,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
    }
    domain = cookie_domain
    options[:domain] = domain if domain.present?
    cookies[refresh_token_cookie_name] = options
  end

  def access_token_cookie_name
    if Rails.env.production?
      Preference::Constants::PREFERENCE_COOKIE_KEY
    else
      :root_app_preferences
    end
  end

  def valid_refresh_preference?(preference)
    preference.present? &&
      preference.status_id != "DELETED" &&
      (preference.expires_at.nil? || preference.expires_at > Time.current)
  end

  def cookie_domain
    return :all unless Rails.env.development?

    # localhost does not support domain sharing in browsers
    nil
  end
end
