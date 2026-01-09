# frozen_string_literal: true

module Preference::Regional
  extend ActiveSupport::Concern
  include Preference::Base

  def default_url_options
    options = {}

    # Extract options from loaded preferences if available
    if @preferences.present?
      options[:ri] = @preferences.try(:preference_region)&.option_id&.downcase
      options[:lx] = @preferences.try(:preference_language)&.option_id&.downcase
      options[:tz] = @preferences.try(:preference_timezone)&.option_id&.downcase
      options[:ct] = @preferences.try(:preference_colortheme)&.option_id&.downcase
    end

    # Fallback to defaults
    options[:lx] ||= "ja"
    options[:ri] ||= "jp"
    options[:tz] ||= "jst"
    options[:ct] ||= "sy"

    super.merge(options.compact)
  end
end
