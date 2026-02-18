# frozen_string_literal: true

require "test_helper"

class Sign::Org::LayoutTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses

  def default_headers
    { "Host" => ENV["SIGN_STAFF_URL"] || "sign.org.localhost" }
  end

  def login_headers(staff)
    default_headers.merge("X-TEST-CURRENT-STAFF" => staff.id.to_s)
  end

  test "placeholder test for layout" do
    skip "TODO: add assertions for org layout rendering"
  end
end
