# frozen_string_literal: true

require "test_helper"

class Root::Net::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should not get index of net" do
    assert_raise do
      get root_net_root_url
    end
  end
end
