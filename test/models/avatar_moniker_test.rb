require "test_helper"

class AvatarMonikerTest < ActiveSupport::TestCase
  test "validations" do
    moniker = AvatarMoniker.new
    assert_not moniker.valid?
  end
end
