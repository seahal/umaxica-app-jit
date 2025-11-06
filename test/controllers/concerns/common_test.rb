# frozen_string_literal: true

require "test_helper"

class CommonTest < ActiveSupport::TestCase
  class TestController < ApplicationController
    include Common
  end

  setup do
    @controller = TestController.new
  end

  test "gen_original_uuid generates a valid UUID v7" do
    uuid = @controller.send(:gen_original_uuid)

    assert_not_nil uuid
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i, uuid)
  end

  test "gen_original_uuid generates unique UUIDs" do
    uuid1 = @controller.send(:gen_original_uuid)
    uuid2 = @controller.send(:gen_original_uuid)

    assert_not_equal uuid1, uuid2
  end

  test "localize_time converts UTC time to Tokyo timezone" do
    utc_time = Time.utc(2024, 1, 1, 0, 0, 0)
    localized = @controller.send(:localize_time, utc_time)

    assert_equal "Tokyo", localized.time_zone.name
    assert_equal 9, localized.hour # UTC+9
  end

  test "localize_time ignores zone parameter and always uses Tokyo" do
    utc_time = Time.utc(2024, 1, 1, 0, 0, 0)
    localized = @controller.send(:localize_time, utc_time, "America/New_York")

    # Despite passing NY timezone, it should use Tokyo
    assert_equal "Tokyo", localized.time_zone.name
  end

  test "text_encryption encrypts text successfully" do
    original_text = "sensitive data"
    encrypted = @controller.send(:text_encryption, original_text)

    assert_not_nil encrypted
    assert_not_equal original_text, encrypted
  end

  test "text_encryption produces different output for same input" do
    text = "test data"
    encrypted1 = @controller.send(:text_encryption, text)
    encrypted2 = @controller.send(:text_encryption, text)

    # ActiveRecord encryption should produce different ciphertext each time
    assert_not_equal encrypted1, encrypted2
  end

  test "text_encryption handles empty string" do
    encrypted = @controller.send(:text_encryption, "")

    assert_not_nil encrypted
  end
end
