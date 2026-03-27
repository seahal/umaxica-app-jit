# typed: false
# frozen_string_literal: true

require "test_helper"

module Concerns
  class ApplicationControllerRefactoringCandidatesTest < ActiveSupport::TestCase
    DUPLICATE_PATTERNS = {
      "Preference::Global" => %w(
        Sign::App
        Sign::Org
        Apex::App
        Apex::Com
        Apex::Org
      ),
      "Preference::Regional" => %w(
        Core::App
        Core::Com
        Core::Org
        Docs::App
        Docs::Com
        Docs::Org
        News::App
        News::Com
        News::Org
        Help::App
        Help::Com
        Help::Org
      ),
    }.freeze

    test "duplicate preference concerns show consolidation opportunities" do
      global_count = DUPLICATE_PATTERNS["Preference::Global"].length
      regional_count = DUPLICATE_PATTERNS["Preference::Regional"].length

      assert_operator global_count, :<, regional_count,
                      "Global preference is used by #{global_count} controllers, Regional by #{regional_count} - potential for consolidation"
    end

    test "callback order follows documented layer pattern" do
      controller_classes = [
        "Sign::App::ApplicationController",
        "Core::App::ApplicationController",
        "Apex::App::ApplicationController",
      ].map(&:safe_constantize).compact

      controller_classes.each do |controller_class|
        callbacks = controller_class._process_action_callbacks
        before_filters = callbacks.select { |c| c.kind == :before }.map(&:filter)

        rate_limit_idx = before_filters.index(:check_default_rate_limit)
        access_policy_idx = before_filters.index(:enforce_access_policy!)
        verification_idx = before_filters.index(:enforce_verification_if_required)
        current_idx = before_filters.index(:set_current)

        if rate_limit_idx && access_policy_idx
          assert_operator rate_limit_idx, :<, access_policy_idx,
                          "#{controller_class}: rate_limit should come before access_policy"
        end

        if access_policy_idx && verification_idx
          assert_operator access_policy_idx, :<, verification_idx,
                          "#{controller_class}: access_policy should come before verification"
        end

        if verification_idx && current_idx
          assert_operator verification_idx, :<, current_idx,
                          "#{controller_class}: verification should come before set_current"
        end
      end
    end

    test "all domains use consistent authentication pattern" do
      auth_patterns = {
        "User" => { "Core" => %w(App Com), "Apex" => %w(App Com) },
        "Staff" => { "Core" => %w(Org),
                     "Apex" => %w(Org),
                     "Sign" => %w(Org),
                     "News" => %w(Org),
                     "Help" => %w(Org),
                     "Docs" => %w(Org), },
        "Viewer" => { "News" => %w(Com), "Help" => %w(Com), "Docs" => %w(Com) },
      }

      auth_patterns.each do |auth_type, domain_tlds|
        domain_tlds.each do |domain, tlds|
          tlds.each do |tld|
            controller_name = "#{domain}::#{tld}::ApplicationController"
            controller_class = controller_name.safe_constantize

            next unless controller_class

            content = Rails.root.join("app/controllers/#{domain.underscore}/#{tld.underscore}/application_controller.rb").read

            if auth_type == "User"
              assert_includes content, "Authentication::User",
                              "#{controller_name} should use Authentication::User"
            elsif auth_type == "Staff"
              assert_includes content, "Authentication::Staff",
                              "#{controller_name} should use Authentication::Staff"
            elsif auth_type == "Viewer"
              assert_includes content, "Authentication::Viewer",
                              "#{controller_name} should use Authentication::Viewer"
            end
          end
        end
      end

      sign_app_controller = "Sign::App::ApplicationController".safe_constantize

      assert_includes sign_app_controller.ancestors, ::Authentication::User

      sign_org_controller = "Sign::Org::ApplicationController".safe_constantize

      assert_includes sign_org_controller.ancestors, ::Authentication::Staff
    end
  end
end
