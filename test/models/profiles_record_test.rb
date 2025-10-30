require "test_helper"

class ProfilesRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator ProfilesRecord, :<, ApplicationRecord
    assert_predicate ProfilesRecord, :abstract_class?
  end
end
