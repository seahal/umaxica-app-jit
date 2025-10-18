# frozen_string_literal: true

# Shared assertions for health check endpoints across host-specific controllers.
module HealthEndpointAssertions
  def assert_health_html_variants(url_helper, headers: {})
    [ public_send(url_helper), public_send(url_helper, format: :html) ].each do |url|
      get url, headers: headers
      assert_response :success
      assert_equal 200, response.status
      assert_includes response.body, "OK"
    end
  end

  def assert_health_json(url_helper, headers: {})
    get public_send(url_helper, format: :json), headers: headers
    assert_response :success
    assert_equal 200, response.status
    assert_equal "OK", response.parsed_body["status"]
  end

  def assert_health_invalid_format(url_helper, format, headers: {})
    assert_raises(RuntimeError) do
      get public_send(url_helper, format:), headers: headers
    end
  end
end
