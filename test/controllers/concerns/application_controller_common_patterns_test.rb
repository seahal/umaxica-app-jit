# typed: false
# frozen_string_literal: true

require "test_helper"

module Concerns
  class ApplicationControllerCommonPatternsTest < ActiveSupport::TestCase
    ALL_CONTROLLER_FILES = Dir.glob(Rails.root.join("app/controllers/**/application_controller.rb").to_s)
      .reject { |f| f.include?("/vendor/") }
      .reject { |f| f.end_with?("/controllers/application_controller.rb") }
      .reject { |f| f.include?("/sign/com/") }
      .sort

    test "all application controllers include RateLimit" do
      ALL_CONTROLLER_FILES.each do |file|
        content = File.read(file)
        controller_name = file.gsub(Rails.root.join("app/controllers/").to_s, "")
          .gsub("/application_controller.rb", "")
          .gsub("/", "::")
          .gsub("_", " ")
          .split.map(&:capitalize).join("::")

        assert_includes content, "RateLimit",
                        "#{controller_name} should include RateLimit"
      end
    end

    test "all application controllers include CurrentSupport" do
      ALL_CONTROLLER_FILES.each do |file|
        content = File.read(file)
        controller_name = file.gsub(Rails.root.join("app/controllers/").to_s, "")
          .gsub("/application_controller.rb", "")
          .gsub("/", "::")
          .gsub("_", " ")
          .split.map(&:capitalize).join("::")

        assert_includes content, "CurrentSupport",
                        "#{controller_name} should include CurrentSupport"
      end
    end

    test "all application controllers include Finisher" do
      ALL_CONTROLLER_FILES.each do |file|
        content = File.read(file)
        controller_name = file.gsub(Rails.root.join("app/controllers/").to_s, "")
          .gsub("/application_controller.rb", "")
          .gsub("/", "::")
          .gsub("_", " ")
          .split.map(&:capitalize).join("::")

        assert_includes content, "Finisher",
                        "#{controller_name} should include Finisher"
      end
    end

    test "all application controllers have finish_request append_after_action" do
      ALL_CONTROLLER_FILES.each do |file|
        content = File.read(file)
        controller_name = file.gsub(Rails.root.join("app/controllers/").to_s, "")
          .gsub("/application_controller.rb", "")
          .gsub("/", "::")

        assert_includes content, "append_after_action :finish_request",
                        "#{controller_name} should have append_after_action :finish_request"
      end
    end

    test "all application controllers have check_default_rate_limit before_action" do
      ALL_CONTROLLER_FILES.each do |file|
        content = File.read(file)
        controller_name = file.gsub(Rails.root.join("app/controllers/").to_s, "")
          .gsub("/application_controller.rb", "")
          .gsub("/", "::")

        assert_includes content, "before_action :check_default_rate_limit",
                        "#{controller_name} should have before_action :check_default_rate_limit"
      end
    end

    test "application controllers with user auth include required concerns" do
      user_controllers =
        ALL_CONTROLLER_FILES.select do |file|
          content = File.read(file)
          content.include?("Authentication::User")
        end

      user_controllers.each do |file|
        content = File.read(file)
        controller_name = file.gsub(Rails.root.join("app/controllers/").to_s, "")
          .gsub("/application_controller.rb", "")
          .gsub("/", "::")

        assert_includes content, "Authorization::User",
                        "#{controller_name} should include Authorization::User when using Authentication::User"
        assert_includes content, "Verification::User",
                        "#{controller_name} should include Verification::User when using Authentication::User"
      end
    end

    test "application controllers with staff auth include required concerns" do
      staff_controllers =
        ALL_CONTROLLER_FILES.select do |file|
          content = File.read(file)
          content.include?("Authentication::Staff")
        end

      staff_controllers.each do |file|
        content = File.read(file)
        controller_name = file.gsub(Rails.root.join("app/controllers/").to_s, "")
          .gsub("/application_controller.rb", "")
          .gsub("/", "::")

        assert_includes content, "Authorization::Staff",
                        "#{controller_name} should include Authorization::Staff when using Authentication::Staff"
        assert_includes content, "Verification::Staff",
                        "#{controller_name} should include Verification::Staff when using Authentication::Staff"
      end
    end

    test "application controllers with viewer auth include required concerns" do
      viewer_controllers =
        ALL_CONTROLLER_FILES.select do |file|
          content = File.read(file)
          content.include?("Authentication::Viewer")
        end

      viewer_controllers.each do |file|
        content = File.read(file)
        controller_name = file.gsub(Rails.root.join("app/controllers/").to_s, "")
          .gsub("/application_controller.rb", "")
          .gsub("/", "::")

        assert_includes content, "Authorization::Viewer",
                        "#{controller_name} should include Authorization::Viewer when using Authentication::Viewer"
        assert_includes content, "Verification::Viewer",
                        "#{controller_name} should include Verification::Viewer when using Authentication::Viewer"
      end
    end

    test "application controllers with OIDC include Oidc::SsoInitiator" do
      ALL_CONTROLLER_FILES.each do |file|
        content = File.read(file)
        controller_name = file.gsub(Rails.root.join("app/controllers/").to_s, "")
          .gsub("/application_controller.rb", "")
          .gsub("/", "::")

        if content.include?("oidc_client_id")
          assert_includes content, "Oidc::SsoInitiator",
                          "#{controller_name} with oidc_client_id should include Oidc::SsoInitiator"
        end
      end
    end
  end
end
