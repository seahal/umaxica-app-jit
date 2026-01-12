# frozen_string_literal: true

module Preference::Global
  extend ActiveSupport::Concern
  include Preference::Base

  included do
    helper_method :get_language, :get_timezone, :get_region, :get_colortheme
    before_action :set_preferences_cookie
    before_action :set_color_theme
    before_action :set_region
    before_action :set_locale
    before_action :set_timezone
  end

  private

  def normalized_locale_options
    ri = params[:ri].presence || "jp"
    lx = params[:lx].presence || I18n.locale.to_s

    options = {}
    options[:ri] = ri.to_s.downcase if ri.present?
    options[:lx] = lx.to_s.downcase if lx.present?
    options
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

  def set_region
    return if params[:ri].present?

    # Safely add ri parameter while preserving existing query params
    # Merge normalized_locale_options to preserve lx and other locale params
    # but ensure we don't double-add ri by removing it from normalized options
    locale_options = normalized_locale_options.except(:ri)
    redirect_params = request.query_parameters.merge(locale_options).merge(ri: get_region)

    # Use request attributes directly to avoid open redirect vulnerability
    redirect_url = url_for(
      protocol: request.protocol,
      host: request.host,
      port: request.port,
      controller: controller_path,
      action: action_name,
      **redirect_params.symbolize_keys,
      only_path: false,
    )

    redirect_to redirect_url
  end

  def set_locale
    set_locale_from_params
  end

  def set_timezone
    if @preferences.present?
      timezone_association = "#{@preferences.class.name.underscore}_timezone"
      timezone = @preferences.public_send(timezone_association)&.option_id

      if timezone.present?
        session[:timezone] = timezone
      end
    end

    set_timezone_from_session
  end
end
