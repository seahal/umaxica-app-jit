# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceWebThemeActionsIncludedDoTest < ActiveSupport::TestCase
  test "included do includes Preference::WebThemeEndpoint module" do
    skip "Preference::WebThemeActions requires Authentication::Base with public_strict!"
  end
end
