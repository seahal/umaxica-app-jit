# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceOperationErrorTest < ActiveSupport::TestCase
  test "initializes with default i18n key and status" do
    error = PreferenceOperationError.new

    assert_equal "errors.messages.preference_operation_failed", error.i18n_key
    assert_equal :unprocessable_entity, error.status_code
  end

  test "initializes with custom i18n key" do
    error = PreferenceOperationError.new("custom.key")

    assert_equal "custom.key", error.i18n_key
  end

  test "initializes with custom status code" do
    error = PreferenceOperationError.new("custom.key", :bad_request)

    assert_equal :bad_request, error.status_code
  end

  test "initializes with context" do
    error = PreferenceOperationError.new("custom.key", :unprocessable_entity, detail: "something failed")

    assert_equal({ detail: "something failed" }, error.context)
  end

  test "is a subclass of ApplicationError" do
    assert_kind_of ApplicationError, PreferenceOperationError.new
  end

  test "is a subclass of StandardError" do
    assert_kind_of StandardError, PreferenceOperationError.new
  end
end
