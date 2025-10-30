# frozen_string_literal: true

require "test_helper"

class LocaleInitializerTest < ActiveSupport::TestCase
  test "REGION_CODE is required - should fail when not set" do
    # Remove REGION_CODE from environment and try to start Rails
    result = system(
      { "REGION_CODE" => nil },
      "bundle exec rails runner 'puts \"OK\"'",
      out: File::NULL,
      err: File::NULL
    )

    assert_not result, "Rails should fail to start without REGION_CODE"
  end

  test "REGION_CODE=jp should work correctly" do
    result = system(
      { "REGION_CODE" => "jp" },
      "bundle exec rails runner 'puts \"OK\"'",
      out: File::NULL,
      err: File::NULL
    )

    assert result, "Rails should start successfully with REGION_CODE=jp"
  end

  # test "REGION_CODE=us should work correctly" do
  #   result = system(
  #     { "REGION_CODE" => "us" },
  #     "bundle exec rails runner 'puts \"OK\"'",
  #     out: File::NULL,
  #     err: File::NULL
  #   )
  #
  #   assert result, "Rails should start successfully with REGION_CODE=us"
  # end

  # test "invalid REGION_CODE should fail with descriptive error" do
  #   output = `REGION_CODE=invalid bundle exec rails runner 'puts "OK"' 2>&1`
  #   exit_status = $?.exitstatus
  #
  #   assert_not_equal 0, exit_status, "Rails should fail to start with invalid REGION_CODE"
  #   assert_match(/REGION_CODE='invalid' is invalid/, output, "Error message should mention invalid REGION_CODE")
  #   assert_match(/Directory not found/, output, "Error message should mention directory not found")
  # end

  # test "correct locale files are loaded based on REGION_CODE" do
  #   # Test that jp region loads jp locale files
  #   output = `REGION_CODE=jp bundle exec rails runner 'puts I18n.load_path.grep(/locales/).first' 2>&1`
  #   assert_match(/config\/locales\/jp/, output, "Should load locale files from jp directory")
  #
  #   # Test that us region loads us locale files
  #   output = `REGION_CODE=us bundle exec rails runner 'puts I18n.load_path.grep(/locales/).first' 2>&1`
  #   assert_match(/config\/locales\/us/, output, "Should load locale files from us directory")
  # end
end
