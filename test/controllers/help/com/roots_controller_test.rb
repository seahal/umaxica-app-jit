# frozen_string_literal: true

require "test_helper"

module Help
  module Com
    class RootsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get help_com_root_url
        assert_response :success
      end
    end
  end
end
