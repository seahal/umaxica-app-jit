# typed: false
# frozen_string_literal: true

require "test_helper"

# ---------------------------------------------------------------------------
# Dummy controllers for testing the EmailValidation concern
# ---------------------------------------------------------------------------

class EmailValidationDummyController < ApplicationController
  include ::EmailValidation

  def validate
    email = params[:email]
    normalized = validate_and_normalize_email(email)
    valid = valid_email_format?(email)

    render json: { email: email, normalized: normalized, valid: valid }
  end

  def find
    email = params[:email]
    record = find_email_with_timing_protection(email)

    if record
      render json: { found: true, email: record.address }
    else
      render json: { found: false }, status: :not_found
    end
  end
end

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

class EmailValidationConcernTest < ActionDispatch::IntegrationTest
  fixtures :user_emails

  # ---------------------------------------------------------------------------
  # A. validate_and_normalize_email
  # ---------------------------------------------------------------------------

  test "normalizes valid email address" do
    with_test_routes do
      get "/email_validation/validate", params: { email: "Test@Example.COM" }

      assert_response :success
      body = response.parsed_body

      assert_equal "test@example.com", body["normalized"]
    end
  end

  test "normalizes email with plus addressing" do
    with_test_routes do
      get "/email_validation/validate", params: { email: "user+tag@example.com" }

      assert_response :success
      body = response.parsed_body

      assert_equal "user+tag@example.com", body["normalized"]
    end
  end

  test "handles nil email" do
    with_test_routes do
      get "/email_validation/validate", params: { email: nil }

      assert_response :success
      body = response.parsed_body

      assert_nil body["normalized"]
    end
  end

  test "handles empty email" do
    with_test_routes do
      get "/email_validation/validate", params: { email: "" }

      assert_response :success
      body = response.parsed_body

      assert_nil body["normalized"]
    end
  end

  # ---------------------------------------------------------------------------
  # B. valid_email_format?
  # ---------------------------------------------------------------------------

  test "valid_email_format? returns true for valid email" do
    with_test_routes do
      valid_emails = [
        "user@example.com",
        "test.email@example.co.jp",
        "user+tag@example.com",
        "first.last@example.org",
      ]

      valid_emails.each do |email|
        get "/email_validation/validate", params: { email: email }

        assert_response :success
        body = response.parsed_body

        assert body["valid"], "Expected '#{email}' to be valid"
      end
    end
  end

  test "valid_email_format? returns false for invalid email" do
    with_test_routes do
      invalid_emails = [
        "not_an_email",
        "@example.com",
        "user@",
        "user@.com",
        "user name@example.com",
        "",
        nil,
      ]

      invalid_emails.each do |email|
        get "/email_validation/validate", params: { email: email }

        assert_response :success
        body = response.parsed_body

        assert_not body["valid"], "Expected '#{email}' to be invalid"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # C. find_email_with_timing_protection
  # ---------------------------------------------------------------------------

  test "finds existing email with timing protection" do
    with_test_routes do
      # Use an email from fixtures
      email = user_emails(:one).address

      get "/email_validation/find", params: { email: email }

      assert_response :success
      body = response.parsed_body

      assert body["found"]
      assert_equal email, body["email"]
    end
  end

  test "returns not found for non-existent email" do
    with_test_routes do
      get "/email_validation/find", params: { email: "nonexistent@example.com" }

      assert_response :not_found
      body = response.parsed_body

      assert_not body["found"]
    end
  end

  test "timing protection adds minimum delay" do
    with_test_routes do
      start_time = Time.current

      get "/email_validation/find", params: { email: "test@example.com" }

      elapsed = Time.current - start_time
      # Should take at least 0.05 seconds due to timing protection
      assert_operator elapsed, :>=, 0.04, "Timing protection should add minimum delay"
    end
  end

  test "handles nil email in find" do
    with_test_routes do
      get "/email_validation/find", params: { email: nil }

      assert_response :not_found
      body = response.parsed_body

      assert_not body["found"]
    end
  end

  test "handles empty email in find" do
    with_test_routes do
      get "/email_validation/find", params: { email: "" }

      assert_response :not_found
      body = response.parsed_body

      assert_not body["found"]
    end
  end

  private

  def with_test_routes
    with_routing do |set|
      set.draw do
        get("/email_validation/validate", to: "email_validation_dummy#validate")
        get("/email_validation/find", to: "email_validation_dummy#find")
      end

      yield
    end
  end
end
