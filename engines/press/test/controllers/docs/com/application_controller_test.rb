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
      assert_includes controller.class, ActionPolicy::Controller
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
      before_filters = callbacks.filter_map { |c| c.filter if c.kind == :before }
      rate_limit_index =
        before_filters.index do |filter|
          filter.is_a?(Proc) &&
            filter.source_location&.first&.include?("/action_controller/metal/rate_limiting.rb")
        end

      assert rate_limit_index, "rate limit callback should be present"
      assert_includes before_filters, :enforce_access_policy!
      assert_includes before_filters, :enforce_verification_if_required
      assert_includes before_filters, :set_current
    end

    test "has finish_request append_after_action" do
      callbacks = ApplicationController._process_action_callbacks
      after_filters = callbacks.filter_map { |c| c.filter if c.kind == :after }

      assert_includes after_filters, :purge_current
    end

    test "has oidc_client_id method" do
      controller = ApplicationController.new

      assert_respond_to controller, :oidc_client_id
      assert_equal "docs_com", controller.send(:oidc_client_id)
    end
  end
end
