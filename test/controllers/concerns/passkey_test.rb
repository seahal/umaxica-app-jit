# frozen_string_literal: true

require "test_helper"

class PasskeyTest < ActiveSupport::TestCase
  class DummyClass
    include Passkey
  end

  test "can include Passkey module" do
    assert DummyClass.new
  end
end
