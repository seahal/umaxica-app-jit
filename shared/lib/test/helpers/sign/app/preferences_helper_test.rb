# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  module App
    class PreferencesHelperTest < ActionView::TestCase
      setup do
        extend Sign::App::PreferencesHelper
      end

      test "module is defined and can be extended" do
        assert_kind_of Sign::App::PreferencesHelper, self
      end
    end
  end
end
