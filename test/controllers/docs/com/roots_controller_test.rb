# frozen_string_literal: true

require "test_helper"

module Docs
module Com
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get docs_com_root_url
      assert_response :success
    end
  end
end
end
