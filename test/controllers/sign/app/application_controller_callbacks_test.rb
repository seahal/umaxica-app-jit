# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign::App
  class ApplicationControllerCallbacksTest < ActiveSupport::TestCase
    test "registers moved callbacks in expected order" do
      callbacks = ApplicationController._process_action_callbacks
      before_filters = callbacks.select { |callback| callback.kind == :before }.map(&:filter)

      expected_before_filters = %i(
        apply_rate_limit_rules
        enforce_withdrawal_gate!
        transparent_refresh_access_token
        enforce_access_policy!
        enforce_verification_if_required
        set_preferences_cookie
        resolve_param_context
        set_region
        set_locale
        set_timezone
        set_color_theme
      )

      expected_before_filters.each_cons(2) do |first, second|
        assert_operator before_filters.index(first), :<, before_filters.index(second)
      end
    end
  end
end
