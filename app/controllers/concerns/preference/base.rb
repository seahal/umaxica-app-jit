# frozen_string_literal: true

module Preference::Base
  extend ActiveSupport::Concern

  require "sha3"

  private

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

    domain = cookie_domain
    cookie_options[:domain] = domain if domain.present?

    cookies[cookie_name] = cookie_options

    nil
  end

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
    @preference_prefix ||= @preferences.class.name.gsub("Preference", "")
  end

  # Get the underscored prefix for method names
  def preference_prefix_underscore
    @preference_prefix_underscore ||= @preferences.class.name.underscore
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
      end
    end
  end

  # Sanitize params: convert blank strings to nil
  def sanitize_option_id(params)
    params[:option_id] = nil if params[:option_id].blank?
    params
  end

  def cookie_domain
    return :all unless Rails.env.development?

    # localhost does not support domain sharing in browsers
    nil
  end
end
