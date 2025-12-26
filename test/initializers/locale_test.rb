# frozen_string_literal: true

require "test_helper"

class LocaleInitializerTest < ActiveSupport::TestCase
  INITIALIZER_PATH = Rails.root.join("config/initializers/locale.rb")

  setup do
    @original_region_code = ENV["REGION_CODE"]
  end

  teardown do
    ENV["REGION_CODE"] = @original_region_code
    reload_locale_initializer if @original_region_code.present?
  end

  test "REGION_CODE is required - should fail when not set" do
    ENV.delete("REGION_CODE")

    assert_raises(KeyError) { reload_locale_initializer }
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "REGION_CODE=jp should load jp locale files" do
    ENV["REGION_CODE"] = "jp"

    assert_nothing_raised { reload_locale_initializer }
    assert_includes_locale_path("config/locales/jp")
    assert_equal [:en, :ja], I18n.available_locales.sort
    assert_equal :ja, I18n.default_locale
    assert_equal [:en, :ja], I18n.fallbacks[:en]
    assert_equal [:ja, :en], I18n.fallbacks[:ja]
  end
  # rubocop:enable Minitest/MultipleAssertions

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

  private

  def reload_locale_initializer
    load INITIALIZER_PATH
  end

  def assert_includes_locale_path(location)
    matched_paths = I18n.load_path.grep(/#{Regexp.escape(location)}/)

    assert_predicate matched_paths, :any?, "Expected I18n.load_path to include #{location}, but got #{I18n.load_path}"
  end
end
