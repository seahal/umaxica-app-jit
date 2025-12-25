ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

Rails.root.glob("test/support/**/*.rb").each { |f| require f }

if ENV["RAILS_ENV"] == "test"
  require "simplecov"

  # Configure to allow coverage measurement even with parallelization
  SimpleCov.command_name "minitest_#{Process.pid}#{ENV['TEST_ENV_NUMBER']}"

  SimpleCov.start "rails" do
    # Reset filters if you want to include files that are filtered by default
    filters.clear
    # By default, only `.rb` files are tracked
    # Add this if you want to track `.rake` files etc.
    # track_files "lib/**/*.rake"

    # Filter out files that should not be measured
    add_filter ".bundle/"
    add_filter "vendor/"
    add_filter "app/views/"
    add_filter "test/"
    add_filter "config/"
    add_filter "db/"
    add_filter "tmp/"
    add_filter "bin/"
    add_filter "docs/"
    add_filter "log/"
    add_filter "docker/"

    # Exclude annotate configuration file as it is only for configuration
    add_filter "lib/tasks/auto_annotate_models.rake"
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    include ActiveJob::TestHelper

    setup do
      seed_identity_audit_reference_data
    end

    private

      def seed_identity_audit_reference_data
        seed_ids(StaffIdentityAuditLevel, %w[NONE INFO WARN ERROR])
        seed_ids(StaffIdentityAuditEvent, %w[LOGIN_SUCCESS LOGIN_FAILURE LOGGED_IN LOGGED_OUT LOGIN_FAILED AUTHORIZATION_FAILED])
        seed_ids(UserIdentityAuditLevel, %w[NONE INFO WARN ERROR])
        seed_ids(UserIdentityAuditEvent, %w[LOGIN_SUCCESS LOGIN_FAILURE LOGGED_IN LOGGED_OUT LOGIN_FAILED TOKEN_REFRESHED SIGNED_UP_WITH_EMAIL SIGNED_UP_WITH_TELEPHONE SIGNED_UP_WITH_APPLE AUTHORIZATION_FAILED])
      end

      def seed_ids(model, ids)
        return unless defined?(model) && model.respond_to?(:table_exists?)
        return unless model.table_exists?

        ids.each do |id|
          model.find_or_create_by!(id: id)
        end
      end
  end
end
