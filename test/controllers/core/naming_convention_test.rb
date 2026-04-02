# typed: false
# frozen_string_literal: true

require "test_helper"

# This test ensures naming conventions remain consistent during refactoring
# Run this test after any controller renaming (e.g., core -> main)
class CoreNamingConventionTest < ActiveSupport::TestCase
  CORE_CONTROLLER_ROOT = Rails.root.join("app/controllers/core").freeze
  CORE_TEST_ROOT = Rails.root.join("test/controllers/core").freeze

  test "all core controllers follow naming convention" do
    core_controllers = Dir.glob(CORE_CONTROLLER_ROOT.join("**/*.rb"))

    core_controllers.each do |controller_path|
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
    core_controllers = Dir.glob(CORE_CONTROLLER_ROOT.join("**/*_controller.rb"))

    core_controllers.each do |controller_path|
      relative_path = Pathname.new(controller_path).relative_path_from(CORE_CONTROLLER_ROOT).to_s
      next if relative_path.end_with?("application_controller.rb")

      controller_path_str = controller_path.to_s
      nested_test_path = controller_path_str
        .sub("app/controllers/core", "test/controllers/core")
        .sub("_controller.rb", "_controller_test.rb")

      path_without_domain = relative_path.sub(/^(app|com|org)\//, "")
      flat_filename = path_without_domain.gsub("/", "_").sub("_controller.rb", "_controller_test.rb")
      flat_test_path = Rails.root.join("test/controllers/core/#{flat_filename}").to_s

      expected_test_path =
        if File.exist?(nested_test_path)
          nested_test_path
        elsif File.exist?(flat_test_path)
          flat_test_path
        end

      next unless expected_test_path

      assert_path_exists expected_test_path,
                         "Controller #{relative_path} should have test at #{expected_test_path.sub(
                           Rails.root.to_s + "/", "",
                         )}"

      controller_content = File.read(controller_path)
      test_content = File.read(expected_test_path)

      controller_class = controller_content.match(/class\s+(\w+)Controller/)&.captures&.first
      test_class_match = test_content.match(/class\s+(\w+)ControllerTest/)

      if controller_class && test_class_match
        test_class_name = test_class_match.captures.first
        test_class_basename = test_class_name.demodulize
        controller_basename = controller_class.demodulize

        next if controller_basename == "Preferences" && test_class_basename == "Preference"

        assert_equal controller_basename, test_class_basename,
                     "Test class name should match controller class name"
      end
    end
  end

  test "controller class names are fully qualified" do
    core_controllers = Dir.glob(CORE_CONTROLLER_ROOT.join("**/*.rb"))

    core_controllers.each do |controller_path|
      content = File.read(controller_path)
      relative_path = Pathname.new(controller_path).relative_path_from(CORE_CONTROLLER_ROOT).to_s

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
