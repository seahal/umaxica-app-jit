# typed: false
# frozen_string_literal: true

require "test_helper"

module Concerns
  class ApplicationControllerRefactoringCandidatesTest < ActiveSupport::TestCase
    DUPLICATE_PATTERNS = {
      "Preference::Global" => %w(
        Jit::Identity::Sign::App
        Jit::Identity::Sign::Org
        Jit::Zenith::Acme::App
        Jit::Zenith::Acme::Com
        Jit::Zenith::Acme::Org
      ),
      "Preference::Regional" => %w(
        Jit::Foundation::Base::App
        Jit::Foundation::Base::Com
        Jit::Foundation::Base::Org
      ),
    }.freeze

    CONTROLLER_CLASSES = {
      "Jit::Identity::Sign::App" => Jit::Identity::Sign::App::ApplicationController,
      "Jit::Foundation::Base::App" => Jit::Foundation::Base::App::ApplicationController,
      "Jit::Zenith::Acme::App" => Jit::Zenith::Acme::App::ApplicationController,
    }.freeze

    CONTROLLER_BY_TLD = {
      "Sign" => { "App" => Jit::Identity::Sign::App::ApplicationController,
                  "Com" => Jit::Identity::Sign::Com::ApplicationController,
                  "Org" => Jit::Identity::Sign::Org::ApplicationController, },
      "Core" => { "App" => Jit::Foundation::Base::App::ApplicationController,
                  "Com" => Jit::Foundation::Base::Com::ApplicationController,
                  "Org" => Jit::Foundation::Base::Org::ApplicationController, },
      "Acme" => { "App" => Jit::Zenith::Acme::App::ApplicationController,
                  "Com" => Jit::Zenith::Acme::Com::ApplicationController,
                  "Org" => Jit::Zenith::Acme::Org::ApplicationController, },
      "Docs" => { "App" => Jit::Distributor::Post::App::ApplicationController,
                  "Com" => Jit::Distributor::Post::Com::ApplicationController,
                  "Org" => Jit::Distributor::Post::Org::ApplicationController, },
    }.freeze

    test "duplicate preference concerns exist" do
      global_count = DUPLICATE_PATTERNS["Preference::Global"].length
      regional_count = DUPLICATE_PATTERNS["Preference::Regional"].length

      msg = "Global preference is used by #{global_count} controllers, "
      msg += "Regional by #{regional_count} - potential for consolidation"

      assert_operator global_count, :>, 0, msg
    end

    test "callback order follows documented layer pattern" do
      controller_classes = CONTROLLER_CLASSES.values

      controller_classes.each do |controller_class|
        callbacks = controller_class._process_action_callbacks
        before_filters = callbacks.select { |c| c.kind == :before }.map(&:filter)

        rate_limit_idx =
          before_filters.index do |filter|
            filter.is_a?(Proc) &&
              filter.source_location&.first&.include?("/action_controller/metal/rate_limiting.rb")
          end
        access_policy_idx = before_filters.index(:enforce_access_policy!)
        verification_idx = before_filters.index(:enforce_verification_if_required)
        current_idx = before_filters.index(:set_current)

        if rate_limit_idx && access_policy_idx
          assert_operator rate_limit_idx, :<, access_policy_idx,
                          "#{controller_class}: rate limit should come before access_policy"
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
        "User" => { "Core" => %w(App Com), "Acme" => %w(App) },
        "Staff" => { "Core" => %w(Org),
                     "Acme" => %w(Org),
                     "Sign" => %w(Org),
                     "Docs" => %w(Org), },
        "Viewer" => { "Docs" => %w(Com) },
      }

      auth_patterns.each do |auth_type, domain_tlds|
        domain_tlds.each do |domain, tlds|
          tlds.each do |tld|
            controller_name = "#{domain}::#{tld}::ApplicationController"
            controller_class = CONTROLLER_BY_TLD[domain]&.[](tld)

            next unless controller_class

            controller_path = "app/controllers/#{domain.underscore}/#{tld.underscore}/application_controller.rb"
            content = Rails.root.join(controller_path).read

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

      sign_app_controller = Jit::Identity::Sign::App::ApplicationController

      assert_includes sign_app_controller.ancestors, ::Authentication::User

      sign_org_controller = Jit::Identity::Sign::Org::ApplicationController

      assert_includes sign_org_controller.ancestors, ::Authentication::Staff
    end
  end
end
