# frozen_string_literal: true

require "test_helper"

module Net
  class TermsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get app_term_url
      assert_equal "text/plain; charset=utf-8", response.content_type
      assert_response :success
    end
  end
end
