# frozen_string_literal: true

require "test_helper"

class PasskeyTest < ActiveSupport::TestCase
  test "can be included as a concern" do
    klass =
      Class.new do
        include Passkey
      end

    assert_includes klass.included_modules, Passkey
  end
end
