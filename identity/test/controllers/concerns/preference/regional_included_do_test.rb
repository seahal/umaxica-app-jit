# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceRegionalIncludedDoTest < ActiveSupport::TestCase
  test "default_url_options method exists" do
    assert Preference::Regional.method_defined?(:default_url_options)
  end

  test "regional_context_requested? method exists" do
    assert Preference::Regional.method_defined?(:regional_context_requested?)
  end
end
