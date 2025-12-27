# frozen_string_literal: true

require "test_helper"

class PasskeyTest < ActiveSupport::TestCase
  class DummyPasskey
    include ActiveModel::Model
    include Passkey
  end

  test "can include passkey concern" do
    assert_includes DummyPasskey.included_modules, Passkey
  end

  test "is an ActiveSupport::Concern" do
    assert_includes Passkey.singleton_class.included_modules, ActiveSupport::Concern
  end
end
