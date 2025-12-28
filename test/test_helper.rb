# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

Rails.root.glob("test/support/**/*.rb").each { |f| require f }

if ENV["RAILS_ENV"] == "test"
  require "simplecov"

  # Configure to allow coverage measurement even with parallelization
  SimpleCov.command_name "minitest_#{Process.pid}#{ENV["TEST_ENV_NUMBER"]}"

  SimpleCov.start "rails" do
    # Reset filters if you want to include files that are filtered by default
    filters.clear

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
    # add_filter "lib/tasks/auto_annotate_models.rake"
  end
end

# module ActiveSupport
#   class TestCase
#     # Run tests in parallel with specified workers
#     # parallelize(workers: :number_of_processors)

#     # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
#     # fixtures :all
#     fixtures :users, :staffs

#     include ActiveJob::TestHelper

#     def before_setup
#       # Identity Seeds
#       begin
#         if StaffIdentityStatus.count == 0
#           require Rails.root.join("db/identities_migrate/20251228000005_seed_identity_statuses.rb")
#           migration = SeedIdentityStatuses.new
#           migration.instance_variable_set(:@connection, IdentityRecord.connection)
#           migration.up
#         end
#       rescue ActiveRecord::StatementInvalid
#         # Table might not exist if schema isn't loaded; ignore or let rails handle it?
#         # But commonly this means the test DB is empty/broken.
#         # We can try to proceed or log.
#       end

#       # Token Seeds
#       begin
#         if StaffTokenStatus.count == 0
#           require Rails.root.join("db/tokens_migrate/20251228000004_seed_token_statuses.rb")
#           migration = SeedTokenStatuses.new
#           migration.instance_variable_set(:@connection, TokenRecord.connection)
#           migration.up
#         end
#       rescue ActiveRecord::StatementInvalid, NameError
#         # Handle cases where model/table missing
#       end

#       # Document Seeds
#       begin
#         # Checking ComDocumentStatus as proxy for document DB seeds
#         if ComDocumentStatus.count == 0
#           require Rails.root.join("db/documents_migrate/20251228000002_seed_document_statuses.rb")
#           migration = SeedDocumentStatuses.new
#           migration.instance_variable_set(:@connection, DocumentRecord.connection)
#           migration.up
#         end
#       rescue ActiveRecord::StatementInvalid, NameError
#       end

#       # Check and seed Identity Statuses
#       begin
#         if StaffIdentityStatus.count == 0
#           require Rails.root.join("db/identities_migrate/20251228000005_seed_identity_statuses.rb")
#           migration = SeedIdentityStatuses.new
#           migration.instance_variable_set(:@connection, IdentityRecord.connection)
#           migration.up
#         end
#       rescue ActiveRecord::StatementInvalid
#         # Table doesn't exist yet, maintain_test_schema should handle creation soon?
#         # Or we are in a state where migration needed.
#       end

#       # Check and seed Token Statuses
#       begin
#         if StaffTokenStatus.count < 2
#           require Rails.root.join("db/tokens_migrate/20251228000004_seed_token_statuses.rb")
#           migration = SeedTokenStatuses.new
#           migration.instance_variable_set(:@connection, TokenRecord.connection)
#           migration.up
#         end
#       rescue ActiveRecord::StatementInvalid, NameError
#       end

#       # Check and seed Document Statuses (ComDocumentStatus as proxy)
#       begin
#         if ComDocumentStatus.count == 0
#           require Rails.root.join("db/documents_migrate/20251228000002_seed_document_statuses.rb")
#           migration = SeedDocumentStatuses.new
#           migration.instance_variable_set(:@connection, DocumentRecord.connection)
#           migration.up
#         end
#       rescue ActiveRecord::StatementInvalid, NameError
#       end

#       # Check and seed Guest Categories
#       begin
#         if AppContactCategory.count == 0
#           require Rails.root.join("db/guests_migrate/20251228000007_seed_guest_categories.rb")
#           migration = SeedGuestCategories.new
#           migration.instance_variable_set(:@connection, GuestRecord.connection)
#           migration.up
#         end
#       rescue ActiveRecord::StatementInvalid, NameError
#       end

#       super
#     end
#   end
# end

# module LayoutAssertions
#   def assert_layout_contract
#     assert_select "head", count: 1 do
#       assert_select "link[rel=?][href*=?]", "stylesheet", "application", count: 1
#       assert_select "link[rel=?][href*=?]", "stylesheet", "tailwind", count: 1
#     end

#     assert_select "header", minimum: 1
#     assert_select "main", count: 1
#     assert_select "footer", count: 1 do
#       assert_select "nav", count: 1
#       assert_select "small", text: /^©/
#     end
#   end
# end

# class ActionDispatch::IntegrationTest
#   include LayoutAssertions
# end
