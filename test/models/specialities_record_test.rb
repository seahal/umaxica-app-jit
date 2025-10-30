require "test_helper"

class SpecialitiesRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator SpecialitiesRecord, :<, ApplicationRecord
    assert_predicate SpecialitiesRecord, :abstract_class?
  end
end
