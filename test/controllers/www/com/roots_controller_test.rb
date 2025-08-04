# frozen_string_literal: true

require "test_helper"

module Www
  module Com
    class RootsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get www_com_root_url
        assert_response :success
      end
    end
  end
end
