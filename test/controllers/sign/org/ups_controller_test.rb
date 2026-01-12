# frozen_string_literal: true

require "test_helper"

class Sign::Org::UpsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
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

    help_host = ENV["HELP_STAFF_URL"].presence || "help.org.localhost"
    # Match the URL while allowing any order of query parameters
    assert_select "p a[href^=?]", "http://#{help_host}/contacts/new",
                  text: I18n.t("sign.org.ups.new.recruit_link_text")

    # Verify that the URL contains all required parameters
    link = css_select("p a").find { |a| a.text == I18n.t("sign.org.ups.new.recruit_link_text") }
    assert_not_nil link, "Could not find link with text: #{I18n.t("sign.org.ups.new.recruit_link_text").inspect}"
    href = link["href"]
    assert_match(/category=recruit/, href)
    assert_match(/ri=jp/, href)
  end
end
