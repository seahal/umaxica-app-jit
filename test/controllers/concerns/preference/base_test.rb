# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceSanitizeTestController < ::Core::App::ApplicationController
  include Preference::Base

  attr_accessor :test_params

  def initialize(*)
    super
    @test_params = {}
  end

  def controller_path
    "core/app/preferences"
  end

  def params
    @test_params.with_indifferent_access
  end

  def test_sanitize_option_id(params_hash, option_type:)
    sanitize_option_id(params_hash.dup.with_indifferent_access, option_type: option_type)
  end
end

module Preference
  class BaseTest < ActiveSupport::TestCase
    test "preference cookie key constants are stable" do
      assert_equal "jit_ct", Preference::Base::THEME_COOKIE_KEY
      assert_equal "ct", Preference::Base::LEGACY_THEME_COOKIE_KEY
      assert_equal "jit_lx", Preference::Base::LANGUAGE_COOKIE_KEY
      assert_equal "jit_tz", Preference::Base::TIMEZONE_COOKIE_KEY
    end
  end

  class SanitizeOptionIdTest < ActionDispatch::IntegrationTest
    setup do
      @controller = PreferenceSanitizeTestController.new
    end

    test "returns integer option_id as-is" do
      result = @controller.test_sanitize_option_id({ option_id: 1 }, option_type: :timezone)
      assert_equal 1, result[:option_id]
    end

    test "converts numeric string to integer" do
      result = @controller.test_sanitize_option_id({ option_id: "2" }, option_type: :timezone)
      assert_equal 2, result[:option_id]
    end

    test "resolves valid timezone constant name" do
      result = @controller.test_sanitize_option_id({ option_id: "ASIA_TOKYO" }, option_type: :timezone)
      assert_equal AppPreferenceTimezoneOption::ASIA_TOKYO, result[:option_id]
    end

    test "resolves valid timezone with slash notation" do
      result = @controller.test_sanitize_option_id({ option_id: "Asia/Tokyo" }, option_type: :timezone)
      assert_equal AppPreferenceTimezoneOption::ASIA_TOKYO, result[:option_id]
    end

    test "resolves valid language constant name" do
      result = @controller.test_sanitize_option_id({ option_id: "JA" }, option_type: :language)
      assert_equal AppPreferenceLanguageOption::JA, result[:option_id]
    end

    test "resolves valid region constant name" do
      result = @controller.test_sanitize_option_id({ option_id: "JP" }, option_type: :region)
      assert_equal AppPreferenceRegionOption::JP, result[:option_id]
    end

    test "resolves valid colortheme constant name" do
      result = @controller.test_sanitize_option_id({ option_id: "dark" }, option_type: :colortheme)
      assert_equal AppPreferenceColorthemeOption::DARK, result[:option_id]
    end

    test "ignores invalid constant name - returns unchanged" do
      result = @controller.test_sanitize_option_id({ option_id: "INVALID_CONST" }, option_type: :timezone)
      assert_equal "INVALID_CONST", result[:option_id]
    end

    test "ignores malicious input attempting to access arbitrary constant" do
      malicious_inputs = %w(
        RAILS_ENV
        SECRET_KEY_BASE
        ApplicationController
        Object
        Kernel
      )

      malicious_inputs.each do |input|
        result = @controller.test_sanitize_option_id({ option_id: input }, option_type: :timezone)
        assert_equal input, result[:option_id], "Expected malicious input '#{input}' to be returned unchanged"
      end
    end

    test "handles nil option_id" do
      result = @controller.test_sanitize_option_id({ option_id: nil }, option_type: :timezone)
      assert_nil result[:option_id]
    end

    test "handles empty string option_id" do
      result = @controller.test_sanitize_option_id({ option_id: "" }, option_type: :timezone)
      assert_nil result[:option_id]
    end

    test "normalizes lowercase input" do
      result = @controller.test_sanitize_option_id({ option_id: "asia_tokyo" }, option_type: :timezone)
      assert_equal AppPreferenceTimezoneOption::ASIA_TOKYO, result[:option_id]
    end

    test "normalizes hyphenated input" do
      result = @controller.test_sanitize_option_id({ option_id: "asia-tokyo" }, option_type: :timezone)
      assert_equal AppPreferenceTimezoneOption::ASIA_TOKYO, result[:option_id]
    end
  end
end
