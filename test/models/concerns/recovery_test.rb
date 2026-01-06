# frozen_string_literal: true

require "test_helper"

class RecoveryTest < ActiveSupport::TestCase
  test "can be included as a concern" do
    klass =
      Class.new do
        include Recovery
      end

    assert_includes klass.included_modules, Recovery
  end
end
