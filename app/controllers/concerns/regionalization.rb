# frozen_string_literal: true

module Regionalization
  extend ActiveSupport::Concern

  included do
    helper_method :get_language, :get_timezone, :get_region, :get_colortheme
  end

  def get_colortheme
    "sy"
  end

  private

  def default_url_options
    options = super || {}

    tz = params[:tz].presence || params[:timezone] || "jst"
    lx = params[:lx].presence || params[:lang] || "ja"
    ri = params[:ri].presence || params[:region] || "jp"
    ct = params[:ct].presence || params[:colortheme] || "sy"

    options[:tz] = tz.to_s.downcase if tz.present?
    options[:lx] = lx.to_s.downcase if lx.present?
    options[:ri] = ri.to_s.downcase if ri.present?
    options[:ct] = ct.to_s.downcase if ct.present?

    options
  end

  public

  def get_language
    params[:lx].presence || params[:lang].presence || session[:language]&.downcase || "sys"
  end

  def get_timezone
    Time.zone
  end

  def get_region
    params[:ri].presence || params[:region] || "us"
  end

  private

  def set_locale
    locale_param = params[:lx].presence || params[:lang].presence
    locale = locale_param || session[:language]&.downcase || I18n.default_locale
    I18n.locale = locale.to_s.downcase
  end

  def set_timezone
    Time.zone = session[:timezone] if session[:timezone].present?
  end
end
