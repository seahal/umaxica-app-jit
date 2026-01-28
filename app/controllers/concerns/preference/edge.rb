# frozen_string_literal: true

module Preference::Edge
  extend ActiveSupport::Concern
  include Preference::Base

  included do
    public_strict! # may be rewriten in future controllers
  end

  def show
    preferences = preference_payload_preferences
    public_id = preference_payload_public_id

    if preferences.blank?
      raise PreferenceOperationError if @preferences.blank?

      # Determine prefix (app, com, or org)
      prefix = preference_prefix.downcase

      preference = preference_class
                   .includes(
                     :"#{prefix}_preference_colortheme",
                     :"#{prefix}_preference_language",
                     :"#{prefix}_preference_timezone",
                     :"#{prefix}_preference_region",
                   )
                   .find(@preferences.id)

      colortheme = preference.send("#{prefix}_preference_colortheme")
      language = preference.send("#{prefix}_preference_language")
      timezone = preference.send("#{prefix}_preference_timezone")
      region = preference.send("#{prefix}_preference_region")

      preferences = {
        "lx" => language&.option_id&.downcase || "ja",
        "ct" => colortheme_short_code(colortheme&.option_id || "system"),
        "ri" => region&.option_id&.downcase || "jp",
        "tz" => timezone&.option_id || "Asia/Tokyo"
      }
      public_id ||= preference.public_id
    end

    render json: {
      preference: {
        public_id: public_id,
        lx: preferences["lx"] || "ja",
        ct: preferences["ct"] || colortheme_short_code("system"),
        ri: preferences["ri"] || "jp",
        tz: preferences["tz"] || "Asia/Tokyo"
      }
    }
  end
end
