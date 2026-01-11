# frozen_string_literal: true

module Preference::Global
  extend ActiveSupport::Concern
  include Preference::Base

  included do
    helper_method :get_language, :get_timezone, :get_region, :get_colortheme
    before_action :set_locale
    before_action :set_timezone
  end

  def get_colortheme
    "sy"
  end

  def get_language
    I18n.locale.to_s
  end

  def get_region
    "jp"
  end

  def get_timezone
    "ASIA/Tokyo"
  end

  def default_url_options
    base_options = super || {}
    options = normalized_locale_options

    if @preferences.present?
      region_association = association_name_for_region
      options[:ri] = @preferences.public_send(region_association)&.option_id&.downcase
    end

    options[:ri] ||= "jp"

    base_options.merge(options.compact)
  end

  private

  def set_locale
    set_locale_from_params
  end

  def set_timezone
    set_timezone_from_session
  end
end
