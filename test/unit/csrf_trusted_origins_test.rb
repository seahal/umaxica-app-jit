# typed: false
# frozen_string_literal: true

require "test_helper"

class CsrfTrustedOriginsTest < ActiveSupport::TestCase
  test "parses env values and strips whitespace" do
    klass =
      Class.new do
        include CsrfTrustedOrigins
      end

    fetch =
      lambda do |key, default_value|
        if key == "TEST_TRUSTED_ORIGINS"
          " http://one.test, https://two.test "
        else
          default_value
        end
      end

    ENV.stub(:fetch, fetch) do
      assert_equal ["http://one.test", "https://two.test"], klass.csrf_trusted_origins(
        "TEST_TRUSTED_ORIGINS",
        "http://fallback.test,https://fallback.test",
      )
    end
  end

  test "uses default value when env is missing" do
    klass =
      Class.new do
        include CsrfTrustedOrigins
      end

    ENV.stub(:fetch, ->(_key, default_value) { default_value }) do
      assert_equal ["http://fallback.test", "https://fallback.test"], klass.csrf_trusted_origins(
        "TEST_TRUSTED_ORIGINS",
        "http://fallback.test,https://fallback.test",
      )
    end
  end
end
