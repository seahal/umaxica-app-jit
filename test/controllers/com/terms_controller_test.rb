# frozen_string_literal: true

require "test_helper"

module Com
  class TermsControllerTest < ActionDispatch::IntegrationTest
    test "should get show 2" do
      get com_term_url
      assert_equal "text/plain; charset=utf-8", response.content_type
      assert_response :success
    end
  end
end
