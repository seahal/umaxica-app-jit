# typed: false
# frozen_string_literal: true

module Jit
  module Zenith
    require "test_helper"

    module Acme
      class DomainStructureTest < ActionDispatch::IntegrationTest
        test "acme/com uses Customer authentication pattern" do
          controller = Jit::Zenith::Acme::Com::ApplicationController.new

          assert_includes controller.class, ::Authentication::Customer,
                          "Jit::Zenith::Acme::Com should use Customer authentication"
          assert_includes controller.class, ::Authorization::Customer,
                          "Jit::Zenith::Acme::Com should use Customer authorization"
          assert_includes controller.class, ::Verification::Customer,
                          "Jit::Zenith::Acme::Com should use Customer verification"
        end

        test "acme/org has transparent_refresh_access_token callback" do
          callbacks = Jit::Zenith::Acme::Org::ApplicationController._process_action_callbacks
          before_filters = callbacks.filter_map { |c| c.filter if c.kind == :before }

          assert_includes before_filters, :transparent_refresh_access_token,
                          "Jit::Zenith::Acme::Org should have transparent_refresh_access_token callback"
        end

        test "acme/app has oidc_sign_host method" do
          controller = Jit::Zenith::Acme::App::ApplicationController.new

          assert_respond_to controller, :oidc_sign_host,
                            "Jit::Zenith::Acme::App should have oidc_sign_host method"
        end

        test "acme/com has oidc_sign_host method" do
          controller = Jit::Zenith::Acme::Com::ApplicationController.new

          assert_respond_to controller, :oidc_sign_host,
                            "Jit::Zenith::Acme::Com should have oidc_sign_host method"
        end
      end
    end
  end
end
