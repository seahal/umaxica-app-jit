# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceBaseIncludedDoTest < ActiveSupport::TestCase
  class Harness < ApplicationController
    include Preference::Base
  end

  test "show_cookie_banner? method exists" do
    assert Preference::Base.private_method_defined?(:show_cookie_banner?)
  end

  test "cookie_banner_endpoint_url method exists" do
    assert Preference::Base.private_method_defined?(:cookie_banner_endpoint_url)
  end

  test "set_preferences_cookie method exists (private)" do
    assert Preference::Base.private_method_defined?(:set_preferences_cookie)
  end

  test "ACCESS_TOKEN_TTL constant is defined" do
    assert_kind_of ActiveSupport::Duration, Preference::Base::ACCESS_TOKEN_TTL
  end

  test "REFRESH_TOKEN_TTL constant is defined" do
    assert_kind_of ActiveSupport::Duration, Preference::Base::REFRESH_TOKEN_TTL
  end
end
