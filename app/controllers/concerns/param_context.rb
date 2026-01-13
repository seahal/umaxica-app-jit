# frozen_string_literal: true

module ParamContext
  extend ActiveSupport::Concern

  KEYS = %i(ri lx ct tz).freeze
  OPTIONAL_KEYS = %i(lx ct tz).freeze
  ALLOWED_REGION_VALUES = %w(jp us).freeze

  DEFAULT_CONTEXT =
    Preference::Constants::DEFAULT_PREFERENCES
      .transform_keys(&:to_sym)
      .transform_values { |value| value.to_s.downcase }
      .freeze

  included do
    helper_method :effective_context, :required_ri
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
      KEYS.each_with_object({}) do |key, memo|
        raw_value = params[key].presence
        next if raw_value.blank?

        normalized_value = raw_value.to_s.downcase
        next if key == :ri && !valid_ri_value?(normalized_value)

        memo[key] = normalized_value
      end
  end

  def cookie_context
    return {} if @preferences.blank?

    context = {
      ri: preference_option_value(association_name_for_region),
      lx: preference_option_value(association_name_for_language),
      tz: preference_option_value(association_name_for_timezone),
      ct: preference_option_value(preference_colortheme_association),
    }
    context.compact
  end

  def effective_context
    @effective_context ||= default_context.merge(cookie_context).merge(requested_context)
  end

  def request_has_optional_context_params?
    (requested_context.keys & OPTIONAL_KEYS).any?
  end

  def optional_context_params_for_urls
    return {} unless request_has_optional_context_params?

    effective_context.slice(*OPTIONAL_KEYS)
  end

  def required_ri
    effective_context[:ri]
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
end
