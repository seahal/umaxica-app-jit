# typed: false
# frozen_string_literal: true

require "test_helper"

class CoreMessageEdgeV0Test < ActionDispatch::IntegrationTest
  setup do
    @app_host = ENV.fetch("CORE_SERVICE_URL", "ww.app.localhost")
    @com_host = ENV.fetch("CORE_CORPORATE_URL", "ww.com.localhost")
    @org_host = ENV.fetch("CORE_STAFF_URL", "ww.org.localhost")
    @message_id = "message-123"
    @user = users(:one)
    @staff = staffs(:one)
  end

  test "app messages respond with the shared json contract" do
    host! @app_host

    assert_message_contract(
      prefix: "/edge/v0/messages",
      headers: app_headers,
      expected_show_id: @message_id,
    )
  end

  test "com messages respond with the shared json contract" do
    host! @com_host

    assert_message_contract(
      prefix: "/edge/v0/messages",
      headers: app_headers,
      expected_show_id: @message_id,
    )
  end

  test "org messages respond with the shared json contract" do
    host! @org_host

    assert_message_contract(
      prefix: "/edge/v0/messages",
      headers: org_headers,
      expected_show_id: @message_id,
    )
  end

  test "messages reject non json requests" do
    [
      [@app_host, app_headers],
      [@com_host, app_headers],
      [@org_host, org_headers],
    ].each do |host, headers|
      host! host

      get("/edge/v0/messages", headers: headers.merge("Accept" => "text/html"))

      assert_response :not_acceptable
      assert_equal({ "error" => "not_acceptable" }, response.parsed_body)
    end
  end

  private

  def assert_message_contract(prefix:, headers:, expected_show_id:)
    get("#{prefix}.json", headers: headers)

    assert_response :success
    assert_equal({ "data" => [], "meta" => { "resource" => "messages" } }, response.parsed_body)

    get("#{prefix}/#{expected_show_id}.json", headers: headers)

    assert_response :success
    assert_equal(
      {
        "data" => {
          "id" => expected_show_id,
          "type" => "message",
          "attributes" => {},
        },
      },
      response.parsed_body,
    )

    post("#{prefix}.json", headers: headers)

    assert_response :created

    created = response.parsed_body

    assert_equal "message", created.dig("data", "type")
    assert_equal({}, created.dig("data", "attributes"))
    assert_not created.dig("meta", "persisted")
    assert_match(/\A[0-9a-f-]{36}\z/i, created.dig("data", "id"))

    patch("#{prefix}/#{expected_show_id}.json", headers: headers)

    assert_response :success
    assert_equal expected_show_id, response.parsed_body.dig("data", "id")

    delete("#{prefix}/#{expected_show_id}.json", headers: headers)

    assert_response :success
    assert_equal(
      {
        "data" => {
          "id" => expected_show_id,
          "type" => "message",
          "deleted" => true,
        },
      },
      response.parsed_body,
    )
  end

  def app_headers
    { "X-TEST-CURRENT-USER" => @user.id.to_s }
  end

  def org_headers
    { "X-TEST-CURRENT-STAFF" => @staff.id.to_s }
  end
end
