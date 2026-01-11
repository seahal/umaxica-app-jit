# frozen_string_literal: true

# TODO: i think this code merge to global or regional files.
module Preference::Base
  extend ActiveSupport::Concern

  # todo: remove this in futire
  def set_locale
  end

  # todo: remove this in futire
  def set_timezone
  end

  private

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
end
