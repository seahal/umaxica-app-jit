require "test_helper"

class BusinessesRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator BusinessesRecord, :<, ApplicationRecord
    assert_predicate BusinessesRecord, :abstract_class?
  end
end
