# typed: false
# frozen_string_literal: true

require "test_helper"
require "nokogiri"

class SocialAuthUiTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
  end

  test "signup screen renders POST forms for social providers" do
    get new_sign_app_up_path(ri: "jp"), headers: { "Host" => @host }

    assert_response :success

    doc = Nokogiri::HTML(response.body)
    google_form = doc.at_css('form[action="/auth/google_oauth2"]')
    apple_form = doc.at_css('form[action="/auth/apple"]')

    assert google_form, "Google form should be present"
    assert apple_form, "Apple form should be present"

    assert_equal "post", google_form["method"].to_s.downcase
    assert_equal "false", google_form["data-turbo"].to_s
    assert_equal "post", apple_form["method"].to_s.downcase
    assert_equal "false", apple_form["data-turbo"].to_s

    assert_equal "signup", session[:social_intent]
  end

  test "signin screen renders POST forms for social providers" do
    get new_sign_app_in_path(ri: "jp"), headers: { "Host" => @host }

    assert_response :success

    doc = Nokogiri::HTML(response.body)
    google_form = doc.at_css('form[action="/auth/google_oauth2"]')
    apple_form = doc.at_css('form[action="/auth/apple"]')

    assert google_form, "Google form should be present"
    assert apple_form, "Apple form should be present"

    assert_equal "post", google_form["method"].to_s.downcase
    assert_equal "false", google_form["data-turbo"].to_s
    assert_equal "post", apple_form["method"].to_s.downcase
    assert_equal "false", apple_form["data-turbo"].to_s

    assert_equal "login", session[:social_intent]
  end
end
