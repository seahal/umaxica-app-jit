require "test_helper"

class SocialAuthnTest < ActiveSupport::TestCase
  class DummyClass
    include SocialAuthn
  end

  test "can include SocialAuthn module" do
    assert DummyClass.new
  end
end
