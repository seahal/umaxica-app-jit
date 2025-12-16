require "test_helper"

class Authentication::UserTest < ActiveSupport::TestCase
  class DummyClass
    include Authentication::User
  end

  setup do
    @obj = DummyClass.new
  end

  test "module can be included" do
    assert_kind_of Authentication::User, @obj
  end
end
