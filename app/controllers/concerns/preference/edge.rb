# frozen_string_literal: true

module Preference::Edge
  extend ActiveSupport::Concern
  include Preference::Base

  def show
    # Raise error if preference cookie is not set
    raise PreferenceOperationError if @preferences.blank?

    # Determine prefix (app, com, or org)
    prefix = preference_prefix.downcase

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
        lx: language&.option_id || "JA",
        ct: colortheme&.option_id || "SYSTEM",
        ri: region&.option_id || "JP",
        tz: timezone&.option_id || "ASIA/TOKYO",
      },
    }
  end
end
