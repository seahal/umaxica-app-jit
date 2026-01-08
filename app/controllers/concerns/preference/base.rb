# frozen_string_literal: true

module Preference::Base
  extend ActiveSupport::Concern

  require "sha3"

  included do
    before_action :set_preferences
  end

  private

  def set_preferences
    # Return if preference already exists in database
    @preferences = preference_class.find_by(public_id: params[:id])
    return if @preferences.present?

    # Generate new token
    token = SecureRandom.urlsafe_base64(48)
    token_digest = SHA3::Digest::SHA3_384.digest(token)

    # Create preference and audit log in transaction
    ActiveRecord::Base.connected_to(role: :writing) do
      ActiveRecord::Base.transaction do
        @preferences = preference_class.create!(
          token_digest: token_digest,
          expires_at: 20.years.from_now,
        )

        # Register audit log
        audit_class = "#{preference_class.name}Audit".constantize
        audit_class.create!(
          subject_id: @preferences.id.to_s,
          subject_type: preference_class.name,
          event_id: "CREATE_NEW_PREFERENCE_TOKEN",
          level_id: "INFO",
          occurred_at: Time.current,
          expires_at: 20.years.from_now,
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
    cookies.encrypted[:preference_token] = {
      value: token,
      expires: 20.years.from_now,
      httponly: true,
      secure: Rails.env.production?,
    }

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
end
