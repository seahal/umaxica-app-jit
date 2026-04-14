# typed: false
# frozen_string_literal: true

require "test_helper"

module Jit
  class DeploymentRoutesTest < ActionDispatch::IntegrationTest
    test "global mode loads only global routes" do
      with_deploy_mode("global") do
        Rails.application.reload_routes!

        controllers = loaded_controllers

        assert controllers.any? { |controller| controller.start_with?("sign/") }
        assert controllers.any? { |controller| controller.start_with?("apex/") }
        assert_not controllers.any? { |controller| controller.start_with?("core/") }
        assert_not controllers.any? { |controller| controller.start_with?("docs/") }
      end
    ensure
      Rails.application.reload_routes!
    end

    test "local mode loads only local routes" do
      with_deploy_mode("local") do
        Rails.application.reload_routes!

        controllers = loaded_controllers

        assert controllers.any? { |controller| controller.start_with?("core/") }
        assert controllers.any? { |controller| controller.start_with?("docs/") }
        assert_not controllers.any? { |controller| controller.start_with?("sign/") }
        assert_not controllers.any? { |controller| controller.start_with?("apex/") }
      end
    ensure
      Rails.application.reload_routes!
    end

    test "development mode loads both global and local routes" do
      with_deploy_mode("development") do
        Rails.application.reload_routes!

        controllers = loaded_controllers

        assert controllers.any? { |controller| controller.start_with?("sign/") }
        assert controllers.any? { |controller| controller.start_with?("apex/") }
        assert controllers.any? { |controller| controller.start_with?("core/") }
        assert controllers.any? { |controller| controller.start_with?("docs/") }
      end
    ensure
      Rails.application.reload_routes!
    end

    private

    def loaded_controllers
      Rails.application.routes.routes.map { |route| route.defaults[:controller] }.compact.uniq
    end

    def with_deploy_mode(value)
      original = ENV["DEPLOY_MODE"]
      value.nil? ? ENV.delete("DEPLOY_MODE") : ENV["DEPLOY_MODE"] = value
      yield
    ensure
      original.nil? ? ENV.delete("DEPLOY_MODE") : ENV["DEPLOY_MODE"] = original
    end
  end
end
