# typed: false
# frozen_string_literal: true

    require "test_helper"

    module Acme
      class DomainStructureTest < ActionDispatch::IntegrationTest
        test "acme/com uses Customer authentication pattern" do
          controller = Acme::Com::ApplicationController.new

          assert_includes controller.class, ::Authentication::Customer,
                          "Acme::Com should use Customer authentication"
          assert_includes controller.class, ::Authorization::Customer,
                          "Acme::Com should use Customer authorization"
          assert_includes controller.class, ::Verification::Customer,
                          "Acme::Com should use Customer verification"
        end

        test "acme/org has transparent_refresh_access_token callback" do
          callbacks = Acme::Org::ApplicationController._process_action_callbacks
          before_filters = callbacks.filter_map { |c| c.filter if c.kind == :before }

          assert_includes before_filters, :transparent_refresh_access_token,
                          "Acme::Org should have transparent_refresh_access_token callback"
        end

        test "acme/app has oidc_sign_host method" do
          controller = Acme::App::ApplicationController.new

          assert_respond_to controller, :oidc_sign_host,
                            "Acme::App should have oidc_sign_host method"
        end

        test "acme/com has oidc_sign_host method" do
          controller = Acme::Com::ApplicationController.new

          assert_respond_to controller, :oidc_sign_host,
                            "Acme::Com should have oidc_sign_host method"
        end
      end
    end
  end
end
