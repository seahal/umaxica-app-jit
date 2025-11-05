# frozen_string_literal: true

require "test_helper"

module Top::Com
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should redirect to TOP_CORPORATE_URL" do
      get top_com_root_url

      assert_response :redirect
      assert_redirected_to "https://#{ENV['TOP_CORPORATE_URL']}"
    end
  end
end
