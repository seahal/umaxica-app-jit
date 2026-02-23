# typed: false
# frozen_string_literal: true

module Fuse
  extend ActiveSupport::Concern

  included do
    before_action :check_fuse!
  end

  private

  def check_fuse!
    return if Rails.env.local?

    result = Fuse::ConfigService.evaluate(
      actor: current_actor_type,
      method: request.request_method_symbol,
      path: request.fullpath,
    )

    return if result.allowed?

    handle_fuse_violation(result)
  end

  def handle_fuse_violation(result)
    case result.reason
    when :hard_stop
      render plain: "Service Temporarily Unavailable", status: :service_unavailable
    when :read_only
      render plain: "Service is in read-only mode", status: :forbidden
    when :actor_blocked
      render plain: "Access restricted", status: :forbidden
    else
      render plain: "Unavailable", status: :service_unavailable
    end
  end

  def current_actor_type
    return :staff if defined?(Current) && Current.respond_to?(:staff) && Current.staff.present?
    return :user if defined?(Current) && Current.respond_to?(:user) && Current.user.present?

    :guest
  end
end
