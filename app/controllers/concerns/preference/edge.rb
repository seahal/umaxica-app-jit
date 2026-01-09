# frozen_string_literal: true

module Preference::Edge
  extend ActiveSupport::Concern

  def show
    # Raise error if preference cookie is not set
    raise PreferenceOperationError if @preferences.blank?

    # Determine prefix (App, Com, or Org)
    prefix = preference_class.name.gsub("Preference", "").downcase

    # Fetch preference with all associated options
    preference = preference_class
      .includes(
        :"#{prefix}_preference_colortheme",
        :"#{prefix}_preference_language",
        :"#{prefix}_preference_timezone",
        :"#{prefix}_preference_region",
      )
      .find(@preferences.id)

    # Extract option_id values from each preference option
    colortheme = preference.send("#{prefix}_preference_colortheme")
    language = preference.send("#{prefix}_preference_language")
    timezone = preference.send("#{prefix}_preference_timezone")
    region = preference.send("#{prefix}_preference_region")

    render json: {
      preference: {
        public_id: preference.public_id,
        language: language&.option_id || "",
        color_theme: colortheme&.option_id || "",
        region: region&.option_id || "",
        timezone: timezone&.option_id || "",
      },
    }
  end
end
