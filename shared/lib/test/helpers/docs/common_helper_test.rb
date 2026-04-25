# typed: false
# frozen_string_literal: true

require "test_helper"

module Post
  class CommonHelperTest < ActionView::TestCase
    setup do
      extend Post::CommonHelper
    end

    test "to_localetime converts to UTC by default" do
      test_time = Time.parse("2024-06-15 10:30:00 UTC")
      result = to_localetime(test_time)

      assert_equal "UTC", result.zone
    end

    test "to_localetime converts to JST for jst timezone" do
      test_time = Time.parse("2024-06-15 10:30:00 UTC")
      result = to_localetime(test_time, "jst")

      assert_equal "JST", result.zone
    end

    test "to_localetime returns nil when time is nil" do
      assert_nil to_localetime(nil)
    end

    test "get_title returns brand name when title is blank" do
      with_brand("TestBrand") do
        assert_equal "TestBrand", get_title("")
        assert_equal "TestBrand", get_title(nil)
      end
    end

    test "get_title returns formatted title with brand" do
      with_brand("TestBrand") do
        assert_equal "My Page | TestBrand", get_title("My Page")
      end
    end

    test "get_timezone returns jst" do
      assert_equal "jst", get_timezone
    end

    test "get_language returns ja" do
      assert_equal "ja", get_language
    end

    test "get_region returns jp" do
      assert_equal "jp", get_region
    end

    test "get_colortheme returns sy" do
      assert_equal "sy", get_colortheme
    end

    test "safe_encrypted_text returns value when present" do
      record = Struct.new(:name).new("Test Value")

      assert_equal "Test Value", safe_encrypted_text(record, :name)
    end

    test "safe_encrypted_text returns fallback when value is blank" do
      record = Struct.new(:name).new("")

      assert_nil safe_encrypted_text(record, :name)
      assert_equal "N/A", safe_encrypted_text(record, :name, fallback: "N/A")
    end

    test "safe_encrypted_text returns fallback on decryption error" do
      record = Object.new
      record.define_singleton_method(:name) do
        raise ActiveRecord::Encryption::Errors::Decryption, "failed"
      end

      assert_nil safe_encrypted_text(record, :name)
      assert_equal "Fallback", safe_encrypted_text(record, :name, fallback: "Fallback")
    end

    private

    def with_brand(name)
      old = ENV["BRAND_NAME"]
      ENV["BRAND_NAME"] = name
      yield
    ensure
      ENV["BRAND_NAME"] = old
    end
  end
end
