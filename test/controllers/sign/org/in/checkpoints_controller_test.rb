# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::Org::In::CheckpointsControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs

  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
  end

  test "show without login is rejected" do
    get sign_org_in_checkpoint_url(ri: "jp"), headers: host_headers(@host)

    assert_response :redirect
  end

  test "show without checkpoint redirects to default" do
    get sign_org_in_checkpoint_url(ri: "jp"),
        headers: as_staff_headers(@staff, host: @host)

    assert_redirected_to sign_org_root_path(ri: "jp")
  end

  test "show with checkpoint returns success" do
    get sign_org_in_checkpoint_url(ri: "jp"),
        headers: as_staff_headers(@staff, host: @host).merge(
          "X-TEST-CHECKPOINT" => checkpoint_json(issued_at: Time.current.to_i, state: "new"),
        )

    assert_response :success
  end

  test "update refreshes state and issued_at then redirects to show" do
    previous_issued_at = 10.minutes.ago.to_i

    patch sign_org_in_checkpoint_url(ri: "jp"),
          headers: as_staff_headers(@staff, host: @host).merge(
            "X-TEST-CHECKPOINT" => checkpoint_json(issued_at: previous_issued_at, state: "new"),
          )

    assert_redirected_to sign_org_in_checkpoint_path(ri: "jp")
    assert_equal "updated", session[:in_checkpoint]["state"]
    assert_operator session[:in_checkpoint]["issued_at"], :>, previous_issued_at
  end

  test "destroy consumes checkpoint and redirects to rd" do
    rd = Base64.urlsafe_encode64("/configuration")

    delete sign_org_in_checkpoint_url(ri: "jp", rd: rd),
           headers: as_staff_headers(@staff, host: @host).merge(
             "X-TEST-CHECKPOINT" => checkpoint_json(issued_at: Time.current.to_i, state: "updated"),
           )

    assert_nil session[:in_checkpoint]
    assert_redirected_to "/configuration"
  end

  test "destroy without rd redirects to default" do
    delete sign_org_in_checkpoint_url(ri: "jp"),
           headers: as_staff_headers(@staff, host: @host).merge(
             "X-TEST-CHECKPOINT" => checkpoint_json(issued_at: Time.current.to_i, state: "updated"),
           )

    assert_nil session[:in_checkpoint]
    assert_redirected_to sign_org_root_path(ri: "jp")
  end

  test "show and update return timeout when expired" do
    expired_at = 2.hours.ago.to_i - 1

    get sign_org_in_checkpoint_url(ri: "jp"),
        headers: as_staff_headers(@staff, host: @host).merge(
          "X-TEST-CHECKPOINT" => checkpoint_json(issued_at: expired_at, state: "new"),
        )

    assert_response :request_timeout

    patch sign_org_in_checkpoint_url(ri: "jp"),
          headers: as_staff_headers(@staff, host: @host)

    assert_response :request_timeout
  end

  test "destroy still redirects when expired" do
    rd = Base64.urlsafe_encode64("/configuration")

    delete sign_org_in_checkpoint_url(ri: "jp", rd: rd),
           headers: as_staff_headers(@staff, host: @host).merge(
             "X-TEST-CHECKPOINT" => checkpoint_json(issued_at: 2.hours.ago.to_i - 1, state: "updated"),
           )

    assert_redirected_to "/configuration"
  end

  private

  def checkpoint_json(issued_at:, state:)
    { "issued_at" => issued_at, "kind" => "mock", "state" => state }.to_json
  end
end
