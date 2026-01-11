# frozen_string_literal: true

module Preference::Global
  extend ActiveSupport::Concern
  include Preference::Base

  included do
    helper_method :get_language, :get_timezone, :get_region, :get_colortheme
  end

  def get_colortheme
    "sy"
  end

  def get_language
    "ja"
  end

  def get_region
    "jp"
  end

  def get_timezone
    "ASIA/Tokyo"
  end

  def default_url_options
    options = {}

    # Extract options from loaded preferences if available
    if @preferences.present?
      region_association = association_name_for_region
      options[:ri] = @preferences.public_send(region_association)&.option_id&.downcase
    end

    # Fallback to defaults
    options[:ri] ||= "jp"

    base_options = super || {}
    base_options.merge(options.compact)
  end
end
