# frozen_string_literal: true

module Preference::Global
  extend ActiveSupport::Concern
  include Preference::Base

  PARAM_CONTEXT_KEYS = %i(ri lx ct tz).freeze
  OPTIONAL_PARAM_KEYS = %i(lx ct tz).freeze
  ALLOWED_REGION_VALUES = %w(jp us).freeze

  DEFAULT_CONTEXT =
    Preference::Constants::DEFAULT_PREFERENCES
      .transform_keys(&:to_sym)
      .transform_values { |value| value.to_s.downcase }
      .freeze

  included do
    helper_method :get_language, :get_timezone, :get_region, :get_colortheme
    helper_method :effective_context, :required_ri

    before_action :set_preferences_cookie
    before_action :resolve_param_context
    before_action :set_region
    before_action :set_locale
    before_action :set_timezone
    before_action :set_color_theme
  end

  def resolve_param_context
    effective_context
  end

  def ensure_required_ri!
    return if performed?

    normalized_current = normalized_param_ri
    desired = required_ri
    return if desired.blank? || desired == normalized_current

    redirect_to build_ri_redirect_url(desired),
                allow_other_host: false,
                status: redirect_status_for_ri?
  end

  def default_context
    DEFAULT_CONTEXT
  end

  def requested_context
    @requested_context ||=
      PARAM_CONTEXT_KEYS.each_with_object({}) do |key, memo|
        raw_value = params[key].presence
        next if raw_value.blank?

        normalized_value = raw_value.to_s.downcase
        next if key == :ri && !valid_ri_value?(normalized_value)

        memo[key] = normalized_value
      end
  end

  def cookie_context
    preferences = preference_payload_preferences
    context =
      if preferences.present?
        {
          ri: preferences["ri"]&.to_s&.downcase,
          lx: preferences["lx"]&.to_s&.downcase,
          tz: preferences["tz"],
          ct: preferences["ct"]&.to_s&.downcase,
        }
      elsif @preferences.present?
        {
          ri: preference_option_value(association_name_for_region),
          lx: preference_option_value(association_name_for_language),
          tz: preference_option_value(association_name_for_timezone),
          ct: preference_option_value(preference_colortheme_association),
        }
      else
        {}
      end
    context.compact
  end

  def effective_context
    @effective_context ||= default_context.merge(cookie_context).merge(requested_context)
  end

  def optional_context_params_for_urls
    requested_context.slice(*OPTIONAL_PARAM_KEYS)
  end

  def required_ri
    effective_context[:ri]
  end

  def default_url_options
    base_options = super || {}
    base_options.merge(ri: required_ri).merge(optional_context_params_for_urls)
  end

  private

  def preference_option_value(association_name)
    return nil if @preferences.blank? || association_name.blank?

    record = @preferences.public_send(association_name)
    record&.option_id&.to_s&.downcase
  rescue NoMethodError
    nil
  end

  def association_name_for_timezone
    :"#{preference_prefix_underscore}_timezone"
  rescue NoMethodError
    nil
  end

  def normalized_param_ri
    params[:ri].presence&.to_s&.downcase
  end

  def valid_ri_value?(value)
    value.present? && allowed_region_values.include?(value)
  end

  def allowed_region_values
    return ALLOWED_REGION_VALUES if @preferences.blank?

    @allowed_region_values ||=
      begin
        region_option_class = "#{preference_prefix}PreferenceRegionOption".constantize
        values = region_option_class.pluck(:id).map(&:downcase).presence
        values || ALLOWED_REGION_VALUES
      rescue NameError
        ALLOWED_REGION_VALUES
      end
  end

  def build_ri_redirect_url(ri_value)
    query = request.query_parameters.merge("ri" => ri_value)
    base = "#{request.base_url}#{request.path}"
    query_string = query.to_query
    query_string.blank? ? base : "#{base}?#{query_string}"
  end

  def redirect_status_for_ri?
    (request.get? || request.head?) ? :found : :see_other
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

  def set_region
    return if params[:ri].present?

    redirect_params = request.query_parameters.merge(ri: get_region)

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
    timezone = preference_payload_value("tz")
    if timezone.blank? && @preferences.present?
      timezone_association = "#{@preferences.class.name.underscore}_timezone"
      timezone = @preferences.public_send(timezone_association)&.option_id
    end

    session[:timezone] = timezone if timezone.present?

    set_timezone_from_session
  end
end
