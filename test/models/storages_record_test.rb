require "test_helper"

class StoragesRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator StoragesRecord, :<, ApplicationRecord
    assert_predicate StoragesRecord, :abstract_class?
  end
end
