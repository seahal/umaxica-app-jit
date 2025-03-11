# frozen_string_literal: true

require "test_helper"

module Com
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get com_root_url
      assert_response :redirect
    end
  end
end
