# typed: false
# frozen_string_literal: true

module Preference::Edge
  extend ActiveSupport::Concern
  include Preference::Base

  included do
    public_strict! # may be rewriten in future controllers
  end

  # POST endpoint for React Router 401/419 CSRF recovery.
  # Returns the same payload as show but is reachable via non-GET (CSRF-verified) request,
  # allowing the client to refresh preference state after an auth/CSRF failure.
  def create
    show
  end

  def show
    preference_data = resolved_preference_data
    render json: preference_response(preference_data[:preferences], preference_data[:public_id])
  end

  private

  def resolved_preference_data
    # Try preference JWT payload (SSOT for preferences)
    preferences = preference_payload_preferences
    public_id = preference_payload_public_id
    return { preferences:, public_id: } if preferences.present?

    # Fallback: DB query for guests without preference JWT
    fallback_data = load_preferences_from_record
    {
      preferences: fallback_data[:preferences],
      public_id: public_id || fallback_data[:public_id],
    }
  end

  def load_preferences_from_record
    raise PreferenceOperationError if @preferences.blank?

    prefix = preference_prefix.downcase
    preference = preference_with_associations(prefix)

    {
      preferences: preferences_from_record(preference, prefix),
      public_id: preference.public_id,
    }
  end

  def preference_with_associations(prefix)
    preference_class
      .includes(
        { "#{prefix}_preference_colortheme": :option },
        { "#{prefix}_preference_language": :option },
        { "#{prefix}_preference_timezone": :option },
        { "#{prefix}_preference_region": :option },
      )
      .find(@preferences.id)
  end

  def preferences_from_record(preference, prefix)
    colortheme = preference.send("#{prefix}_preference_colortheme")
    language = preference.send("#{prefix}_preference_language")
    timezone = preference.send("#{prefix}_preference_timezone")
    region = preference.send("#{prefix}_preference_region")

    {
      "lx" => language&.option&.name&.downcase || "ja",
      "ct" => colortheme_short_code(colortheme&.option&.name || "system"),
      "ri" => region&.option&.name&.downcase || "jp",
      "tz" => timezone&.option&.name || "Asia/Tokyo",
    }
  end

  def preference_response(preferences, public_id)
    {
      preference: {
        public_id:,
        lx: preferences["lx"] || "ja",
        ct: preferences["ct"] || colortheme_short_code("system"),
        ri: preferences["ri"] || "jp",
        tz: preferences["tz"] || "Asia/Tokyo",
      },
    }
  end
end
