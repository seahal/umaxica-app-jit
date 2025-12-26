require "test_helper"

class GuestRecordTest < ActiveSupport::TestCase
  test "is abstract" do
    assert_predicate GuestRecord, :abstract_class?
  end

  test "connects to guest db" do
    assert_equal :guest, GuestRecord.connection_db_config.name.to_sym
  end
end
