# typed: false
# frozen_string_literal: true

require "test_helper"

# This test ensures naming conventions remain consistent during refactoring
# Run this test after any controller renaming (e.g., core -> main)
class CoreNamingConventionTest < ActiveSupport::TestCase
  MAIN_CONTROLLER_ROOT = Rails.root.join("app/controllers/main").freeze
  MAIN_TEST_ROOT = Rails.root.join("test/controllers/main").freeze

  test "all core controllers follow naming convention" do
    main_controllers = Dir.glob(MAIN_CONTROLLER_ROOT.join("**/*.rb"))

    main_controllers.each do |controller_path|
      content = File.read(controller_path)

      # Extract class name from controller
      class_match = content.match(/class\s+(\w+)Controller/)
      next unless class_match

      class_name = class_match[1]
      file_name = File.basename(controller_path, ".rb")

      # File name should be snake_case of class name
      expected_file_name = class_name.underscore
      actual_file_name = file_name.gsub(/_controller$/, "")

      assert_equal expected_file_name, actual_file_name,
                   "Controller file #{controller_path} should be named #{expected_file_name}_controller.rb"
    end
  end

  test "all core controller tests match their controllers" do
    # Build mapping of controllers to expected test files
    controller_test_pairs = [
      # App domain
      ["app/controllers/main/app/roots_controller.rb", "test/controllers/main/app/roots_controller_test.rb"],
      ["app/controllers/main/app/healths_controller.rb", "test/controllers/main/app/healths_controller_test.rb"],
      ["app/controllers/main/app/sitemaps_controller.rb", "test/controllers/main/app/sitemaps_controller_test.rb"],
      ["app/controllers/main/app/contacts_controller.rb", "test/controllers/main/app/contacts_controller_test.rb"],
      ["app/controllers/main/app/configurations_controller.rb",
       "test/controllers/main/configurations_controller_test.rb",],
      ["app/controllers/main/app/auth/callbacks_controller.rb",
       "test/controllers/main/app/auth/callbacks_controller_test.rb",],
      # Com domain
      ["app/controllers/main/com/roots_controller.rb", "test/controllers/main/com/roots_controller_test.rb"],
      ["app/controllers/main/com/healths_controller.rb", "test/controllers/main/com/healths_controller_test.rb"],
      ["app/controllers/main/com/sitemaps_controller.rb", "test/controllers/main/com/sitemaps_controller_test.rb"],
      ["app/controllers/main/com/contacts_controller.rb", "test/controllers/main/com/contacts_controller_test.rb"],
      ["app/controllers/main/com/auth/callbacks_controller.rb",
       "test/controllers/main/com/auth/callbacks_controller_test.rb",],
      # Org domain
      ["app/controllers/main/org/roots_controller.rb", "test/controllers/main/org/roots_controller_test.rb"],
      ["app/controllers/main/org/healths_controller.rb", "test/controllers/main/org/healths_controller_test.rb"],
      ["app/controllers/main/org/sitemaps_controller.rb", "test/controllers/main/org/sitemaps_controller_test.rb"],
      ["app/controllers/main/org/contacts_controller.rb", "test/controllers/main/org/contacts_controller_test.rb"],
      ["app/controllers/main/org/auth/callbacks_controller.rb",
       "test/controllers/main/org/auth/callbacks_controller_test.rb",],
    ]

    controller_test_pairs.each do |controller_path, test_path|
      controller_full_path = Rails.root.join(controller_path)
      test_full_path = Rails.root.join(test_path)

      # Skip if controller doesn't exist (might have been moved)
      next unless controller_full_path.exist?

      # Check that test exists
      assert_predicate test_full_path, :exist?,
                       "Controller #{controller_path} should have corresponding test at #{test_path}"

      # Verify test class name matches
      test_content = File.read(test_full_path)
      controller_content = File.read(controller_full_path)

      controller_class = controller_content.match(/class\s+(\w+)Controller/)&.captures&.first
      test_class_match = test_content.match(/class\s+(\w+)ControllerTest/)

      if controller_class && test_class_match
        test_class_name = test_class_match.captures.first
        # Remove module namespace prefix from test class name for comparison
        test_class_basename = test_class_name.demodulize
        controller_basename = controller_class.demodulize

        assert_equal controller_basename, test_class_basename,
                     "Test class name in #{test_path} should match controller class name"
      end
    end
  end

  test "controller class names are fully qualified" do
    main_controllers = Dir.glob(MAIN_CONTROLLER_ROOT.join("**/*.rb"))

    main_controllers.each do |controller_path|
      content = File.read(controller_path)
      relative_path = Pathname.new(controller_path).relative_path_from(MAIN_CONTROLLER_ROOT).to_s

      # Skip base application controllers
      next if relative_path.end_with?("application_controller.rb")

      # Check that class is defined within proper module namespace
      path_parts = relative_path.gsub(/_controller\.rb$/, "").split("/")
      expected_modules = path_parts[0..-2].map(&:camelize)

      # The file should be within module declarations
      if expected_modules.any?
        module_chain = expected_modules.join("::")

        assert_includes content, "module #{expected_modules.first}",
                        "Controller #{controller_path} should be within #{module_chain} module"
      end
    end
  end
end
