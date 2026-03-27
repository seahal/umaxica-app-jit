# typed: false
# frozen_string_literal: true

require "test_helper"

module Docs::Com
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "includes expected concerns" do
      controller = ApplicationController.new

      assert_includes controller.class, Preference::Regional
      assert_includes controller.class, RateLimit
      assert_includes controller.class, ::Authentication::Viewer
      assert_includes controller.class, ::Authorization::Viewer
      assert_includes controller.class, ::Verification::Viewer
      assert_includes controller.class, Pundit::Authorization
      assert_includes controller.class, ::Oidc::SsoInitiator
      assert_includes controller.class, ::CurrentSupport
      assert_includes controller.class, ::Finisher
    end

    test "allows modern browsers" do
      controller = ApplicationController.new

      assert_not_nil controller
    end

    test "has correct callback order" do
      callbacks = ApplicationController._process_action_callbacks
      before_filters = callbacks.select { |c| c.kind == :before }.map(&:filter)

      assert_includes before_filters, :check_default_rate_limit
      assert_includes before_filters, :enforce_access_policy!
      assert_includes before_filters, :enforce_verification_if_required
      assert_includes before_filters, :set_current
    end

    test "has finish_request append_after_action" do
      callbacks = ApplicationController._process_action_callbacks
      after_filters = callbacks.select { |c| c.kind == :after }.map(&:filter)

      assert_includes after_filters, :finish_request
    end

    test "has oidc_client_id method" do
      controller = ApplicationController.new

      assert_respond_to controller, :oidc_client_id
      assert_equal "docs_com", controller.oidc_client_id
    end
  end
end
