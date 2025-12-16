require "test_helper"

class Authentication::StaffTest < ActiveSupport::TestCase
  class DummyClass
    include Authentication::Staff
  end

  setup do
    @obj = DummyClass.new
  end

  test "module can be included" do
    assert_kind_of Authentication::Staff, @obj
  end
end
