require "test_helper"
require_relative "../../app/models/concerns/accountably"
require_relative "../../app/models/user"
require_relative "../../app/models/staff"

class AccountablyTest < ActiveSupport::TestCase
  %w[User Staff].each do |klass|
    test "#{klass} is a ..." do
      assert_includes klass.constantize.included_modules, ::Accountably
    end
  end

  test "user and staff are different classes" do
    assert_not_equal ::User, ::Staff
  end

  test "should raise NotImplementedError for staff?" do
    dummy = Object.new
    dummy.extend(::Accountably)

    error = assert_raises(NotImplementedError) do
      dummy.staff?
    end
    assert_match(/must implement staff\? method/, error.message)
  end

  test "should raise NotImplementedError for user?" do
    dummy = Object.new
    dummy.extend(::Accountably)

    error = assert_raises(NotImplementedError) do
      dummy.user?
    end
    assert_match(/must implement user\? method/, error.message)
  end
end
