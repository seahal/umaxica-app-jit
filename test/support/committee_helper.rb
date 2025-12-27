# frozen_string_literal: true

require "committee/rails/test/methods"

module CommitteeHelper
  include Committee::Rails::Test::Methods

  def committee_options
    @committee_options ||= {
      schema_path: Rails.public_path.join("openapi.yml").to_s,
      # prefix: nil means the full request path must match the OpenAPI path exactly
      # Since our OpenAPI defines "/v1/health", and our request is to "/v1/health",
      # we don't need a prefix
      prefix: nil,
      parse_response_by_content_type: true,
      strict_reference_validation: true,
    }
  end

  # Validate response against OpenAPI schema
  def assert_response_schema_confirm(expected_status = nil)
    # Remove format extension from path for schema validation if present
    original_path_info = request.env["PATH_INFO"]
    if original_path_info.match?(/\.\w+$/)
      new_path = original_path_info.sub(/\.\w+$/, "")
      request.env["PATH_INFO"] = new_path
      request.path_info = new_path if request.respond_to?(:path_info=)
    end

    super(expected_status || response.status)
  ensure
    # Restore original path
    if original_path_info
      request.env["PATH_INFO"] = original_path_info
      request.path_info = original_path_info if request.respond_to?(:path_info=)
    end
  end

  # Validate response with specific status code
  def assert_response_schema_confirm_with_status(status)
    assert_equal status, response.status
    assert_response_schema_confirm(status)
  end
end
