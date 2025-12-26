# frozen_string_literal: true

require "test_helper"

class RotpTest < ActiveSupport::TestCase
  class DummyClass
    include Rotp
  end

  setup do
    @obj = DummyClass.new
  end

  test "generate_hotp_code returns valid secret" do
    secret, _counter, _pass_code = @obj.send(:generate_hotp_code)

    assert_not_nil secret
    # Secret should be base32 encoded
    assert_match(/\A[A-Z2-7]+\z/, secret)
  end

  test "generate_hotp_code returns valid counter" do
    _secret, counter, _pass_code = @obj.send(:generate_hotp_code)

    assert_not_nil counter
    # Counter should be even (as per implementation: rand * 2)
    assert_predicate counter, :even?

    # Counter should be within expected range
    assert_includes 2...2_000_000, counter
  end

  test "generate_hotp_code returns valid pass_code" do
    _secret, _counter, pass_code = @obj.send(:generate_hotp_code)

    assert_not_nil pass_code
    # Pass code should be 6 digits
    assert_match(/\A\d{6}\z/, pass_code)
  end

  test "verify_hotp_code returns true for valid code" do
    secret, counter, pass_code = @obj.send(:generate_hotp_code)

    result = @obj.send(:verify_hotp_code, secret: secret, counter: counter, pass_code: pass_code)

    assert result, "Expected verification to return true for valid pass_code"
  end

  test "verify_hotp_code returns false for invalid code" do
    secret, counter, _pass_code = @obj.send(:generate_hotp_code)
    invalid_code = "000000"

    result = @obj.send(:verify_hotp_code, secret: secret, counter: counter, pass_code: invalid_code)

    assert_not result, "Expected verification to return false for invalid pass_code"
  end

  test "verify_hotp_code returns false for wrong counter" do
    secret, counter, pass_code = @obj.send(:generate_hotp_code)
    wrong_counter = counter + 2

    result = @obj.send(:verify_hotp_code, secret: secret, counter: wrong_counter, pass_code: pass_code)

    assert_not result, "Expected verification to return false for wrong counter"
  end

  test "verify_hotp_code returns false for wrong secret" do
    _secret, counter, pass_code = @obj.send(:generate_hotp_code)
    wrong_secret = ROTP::Base32.random

    result = @obj.send(:verify_hotp_code, secret: wrong_secret, counter: counter, pass_code: pass_code)

    assert_not result, "Expected verification to return false for wrong secret"
  end

  test "generate_hotp_code creates unique codes on each call" do
    codes = 10.times.map { @obj.send(:generate_hotp_code) }

    # Check that we get different secrets
    secrets = codes.map(&:first)

    assert_equal secrets.size, secrets.uniq.size, "Expected all secrets to be unique"

    # Check that we get different counters
    counters = codes.map { |_, c, _| c }

    assert_operator counters.uniq.size, :>, 1, "Expected multiple different counters"
  end

  test "pass_code format is consistent" do
    100.times do
      _secret, _counter, pass_code = @obj.send(:generate_hotp_code)

      assert_equal 6, pass_code.length, "Pass code should be exactly 6 characters"
      assert_match(/\A\d{6}\z/, pass_code, "Pass code should contain only digits")
    end
  end
end
