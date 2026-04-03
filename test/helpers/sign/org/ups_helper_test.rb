# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::UpsHelperTest < ActionView::TestCase
  include Rails.application.routes.url_helpers

  setup do
    extend Sign::Org::UpsHelper
  end

  def default_url_options
    { ct: "dr", lx: "en", ri: "jp", tz: "jst" }
  end

  test "sign_org_recruit_contact_link generates link with preference params" do
    old_host = ENV.fetch("MAIN_STAFF_URL", nil)
    ENV["MAIN_STAFF_URL"] = "staff.example.com"

    link = sign_org_recruit_contact_link

    assert_match(/href=/, link)
    assert_match(/staff\.example\.com/, link)
    assert_match(/category=recruit/, link)
    assert_match(/ct=dr/, link)
    assert_match(/lx=en/, link)
    assert_match(/ri=jp/, link)
    assert_match(/tz=jst/, link)
    assert_match(/font-semibold/, link)
  ensure
    ENV["MAIN_STAFF_URL"] = old_host if old_host
  end

  test "sign_org_recruit_contact_link uses default host when MAIN_STAFF_URL is unset" do
    old_host = ENV.delete("MAIN_STAFF_URL")

    link = sign_org_recruit_contact_link

    assert_match(/main\.org\.localhost/, link)
  ensure
    ENV["MAIN_STAFF_URL"] = old_host if old_host
  end
end
