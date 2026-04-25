# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::UpsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("IDENTITY_SIGN_ORG_URL", "sign.org.localhost")
  end

  test "should get new" do
    get new_sign_org_up_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :success
    if ENV["DEBUG"]
      puts "BODY: #{response.body}"
      puts "TRANSLATION: #{I18n.t("sign.org.ups.new.recruit_prompt_html")}"
      puts "LOCALE: #{I18n.locale}"
    end
  end

  test "renders recruit contact and home links" do
    get new_sign_org_up_url(ri: "jp"), headers: { "Host" => @host }

    core_host = ENV["FOUNDATION_BASE_ORG_URL"].presence || "base.org.localhost"
    # Match the URL while allowing any order of query parameters
    assert_select "div a[href^=?]", "http://#{core_host}/contacts/new",
                  text: I18n.t("sign.org.ups.new.recruit_link_text")

    # Verify that the URL contains all required parameters
    link = css_select("div a").find { |a| a.text == I18n.t("sign.org.ups.new.recruit_link_text") }

    assert_not_nil link,
                   "Could not find link with text: #{I18n.t("sign.org.ups.new.recruit_link_text").inspect}"
    href = link["href"]

    assert_match(/category=recruit/, href)
    assert_match(/ri=jp/, href)
  end
end
