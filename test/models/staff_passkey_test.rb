require "test_helper"

class StaffPasskeyTest < ActiveSupport::TestCase
  test "inherits from ApplicationRecord" do
    assert_operator StaffPasskey, :<, ApplicationRecord
  end

  test "belongs to staff" do
    association = StaffPasskey.reflect_on_association(:staff)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end
end
