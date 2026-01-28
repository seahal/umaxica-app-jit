# frozen_string_literal: true

require "test_helper"

class NoUnsafeRedirectHelpersTest < ActiveSupport::TestCase
  test "no controller references safe_external_url?" do
    offenders =
      Rails.root.glob("app/controllers/**/*.rb").select do |path|
        File.read(path).include?("safe_external_url?")
      end

    assert_empty offenders
  end
end
