# typed: false
# frozen_string_literal: true

module CurrentSupport
  extend ActiveSupport::Concern

  private

  def set_current
    Current.domain = resolved_current_domain
    Current.surface = resolved_current_surface
    Current.realm = resolved_current_realm
    Current.request_id = request.request_id if respond_to?(:request, true) && request.present?

    resource = safe_current_resource
    Current.actor = resource.presence || Unauthenticated.instance
    Current.actor_type = resolved_current_actor_type(resource)
    Current.session ||= resolved_current_session
    Current.token ||= resolved_current_token
    Current.preference = resolved_current_preference(resource)
  end

  def _reset_current_state
    Current.reset
  end

  def resolved_current_domain
    return Current.domain if Current.domain.present?
    return unless respond_to?(:request, true) && request.present?

    Core::Surface.current(request)
  end

  def safe_current_resource
    current_actor = Current.actor
    if current_actor.present?
      return current_actor unless current_actor.equal?(Unauthenticated.instance)
    end
    return unless respond_to?(:current_resource, true)

    current_resource
  rescue StandardError
    nil
  end

  def resolved_current_actor_type(resource)
    return Current.actor_type if Current.actor_type.present? && Current.actor_type != :unauthenticated
    return :unauthenticated if resource.blank?

    if resource.respond_to?(:staff?) && resource.staff?
      :staff
    elsif resource.respond_to?(:customer?) && resource.customer?
      :customer
    else
      :user
    end
  end

  def resolved_current_session
    return Current.session if Current.session.present?
    return @current_session_public_id if defined?(@current_session_public_id) && @current_session_public_id.present?

    resolved_current_token&.dig("sid")
  end

  def resolved_current_token
    return Current.token if Current.token.present?

    payload = nil
    payload = access_token_payload if respond_to?(:access_token_payload, true)
    payload ||= load_access_token_payload if respond_to?(:load_access_token_payload, true)
    payload if payload.is_a?(Hash)
  rescue StandardError
    nil
  end

  def resolved_current_preference(resource)
    cookie = resolved_current_cookie(resource)

    preference_record = resolved_resource_preference(resource)
    return preference_from_record(preference_record, cookie: cookie) if preference_record.present?

    prf_claim = resolved_current_token&.dig("prf")
    return Current::Preference.from_jwt(prf_claim, cookie: cookie) if prf_claim.is_a?(Hash)

    Current::Preference::NULL.with_cookie(cookie)
  end

  def resolved_current_cookie(resource)
    preference_record = resolved_resource_preference(resource)
    if preference_record.present?
      return Current::Preference.cookie_from(
        consented: preference_record.consented,
        functional: preference_record.functional,
        performant: preference_record.performant,
        targetable: preference_record.targetable,
        consent_version: preference_record.try(:consent_version),
        consented_at: preference_record.consented_at,
      )
    end

    if respond_to?(:preference_payload_preferences, true)
      payload_preferences = preference_payload_preferences
      if payload_preferences.is_a?(Hash)
        return Current::Preference.cookie_from(
          consented: payload_preferences["consented"],
          functional: payload_preferences["functional"],
          performant: payload_preferences["performant"],
          targetable: payload_preferences["targetable"],
          consent_version: payload_preferences["consent_version"],
          consented_at: payload_preferences["consented_at"],
        )
      end
    end

    Current::Preference::NULL_COOKIE
  end

  def resolved_resource_preference(resource)
    return if resource.blank?

    if resource.respond_to?(:staff?) && resource.staff?
      resource.try(:staff_preference)
    elsif resource.respond_to?(:customer?) && resource.customer?
      resource.try(:customer_preference)
    else
      resource.try(:user_preference)
    end
  end

  def preference_from_record(preference_record, cookie:)
    Current::Preference.new(
      language: preference_record.language.presence || Current::Preference::DEFAULTS[:language],
      region: preference_record.region.presence || Current::Preference::DEFAULTS[:region],
      timezone: preference_record.timezone.presence || Current::Preference::DEFAULTS[:timezone],
      theme: preference_record.theme.presence || Current::Preference::DEFAULTS[:theme],
      cookie: cookie,
    )
  end

  def set_current_observability
    return unless defined?(OpenTelemetry::Trace)
    return unless Current.preference.cookie.performant?

    span = OpenTelemetry::Trace.current_span
    context = span.context
    return unless context.valid?

    Current.trace_id = context.hex_trace_id
    Current.span_id = context.hex_span_id
  end

  def current_analytics_consent
    Current.preference.cookie
  end

  def current_optional_analytics_allowed?
    current_analytics_consent.performant?
  end

  def current_targeting_allowed?
    current_analytics_consent.targetable?
  end

  def resolved_current_surface
    return Current.surface if Current.surface.present? && Current.surface != :com
    return unless respond_to?(:request, true) && request.present?

    Core::Surface.current(request)
  end

  def resolved_current_realm
    return Current.realm if Current.realm.present? && Current.realm != :www
    return :www unless respond_to?(:params, true)

    # Derive realm from controller namespace: "sign/app/roots" -> :sign
    controller_path = params[:controller].to_s
    first_segment = controller_path.split("/").first
    case first_segment
    when "sign" then :sign
    when "core" then :core
    when "apex" then :apex
    when "docs" then :docs
    when "news" then :news
    when "help" then :help
    else :www
    end
  end
end
