# typed: false
# frozen_string_literal: true

module RouteHelpers
  extend ActiveSupport::Concern

  included do
    helper_method :sign_app_social_start_url if respond_to?(:helper_method)
  end

  def sign_app_social_start_url(options = {})
    host = "sign.app.localhost"
    Engine.routes.url_helpers.new_sign_app_social_session_url(options.reverse_merge(host: host))
  end
end

# ActionDispatch::IntegrationTest に RouteHelpers をインクルード
ActiveSupport.on_load(:action_dispatch_integration_test) { include RouteHelpers }
