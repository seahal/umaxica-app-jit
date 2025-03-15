# frozen_string_literal: true

require "test_helper"

module Com
  class HealthTest < ActionDispatch::IntegrationTest
    # NOTE: following tests are nothing to do with health check controller
    test "check default params" do
      get www_com_health_url, params: { tz: "jst", lang: "ja" }
      assert_select "a[href=?]", "/health"
    end

    test "check default params(ja,)" do
      get com_health_url, params: { lang: "ja", tz: "" }
      assert_select "a[href=?]", "/"
    end

    test "check default params(ja)" do
      get com_health_url, params: { lang: "ja" }
      assert_select "a[href=?]", "/"
    end

    test "check default params(jst)" do
      get com_health_url, params: { tz: "jst" }
      assert_select "a[href=?]", "/"
    end

    test "check default params(en)" do
      get com_health_url, params: { lang: "en" }
      assert_select "a[href=?]", "/?lang=en"
    end

    test "check default params(En)" do
      get com_health_url, params: { lang: "En" }
      assert_select "a[href=?]", "/?lang=en"
    end

    test "check default params(EN)" do
      get com_health_url, params: { lang: "EN" }
      assert_select "a[href=?]", "/?lang=en"
    end

    test "check default params(kr)" do
      get com_health_url, params: { lang: "kr" }
      assert_select "a[href=?]", "/"
    end

    test "check default params(utc)" do
      get com_health_url, params: { tz: "utc" }
      assert_select "a[href=?]", "/?tz=utc"
    end
    test "check default params(Utc)" do
      get com_health_url, params: { tz: "Utc" }
      assert_select "a[href=?]", "/?tz=utc"
    end
    test "check default params(UTC)" do
      get com_health_url, params: { tz: "UTC" }
      assert_select "a[href=?]", "/?tz=utc"
    end

    test "check default params(cst)" do
      get com_health_url, params: { tz: "cst" }
      assert_select "a[href=?]", "/"
    end

    test "check default params(en, utc)" do
      get com_health_url, params: { tz: "utc", lang: "en" }
      assert_select "a[href=?]", "/?lang=en&tz=utc"
    end

    test "check default params(ja, utc)" do
      get com_health_url, params: { tz: "utc", lang: "ja" }
      assert_select "a[href=?]", "/?tz=utc"
    end

    test "check default params(kr, utc)" do
      get com_health_url, params: { tz: "utc", lang: "kr" }
      assert_select "a[href=?]", "/?tz=utc"
    end
  end
end
