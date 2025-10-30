require "test_helper"

class IdentifierRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator IdentifierRecord, :<, ApplicationRecord
    assert_predicate IdentifierRecord, :abstract_class?
  end
end
