# frozen_string_literal: true

require "test_helper"

module Apex
  module Com
    class RootsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get apex_com_root_url
        assert_response :success
      end
    end
  end
end
