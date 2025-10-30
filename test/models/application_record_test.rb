require "test_helper"

class ApplicationRecordTest < ActiveSupport::TestCase
  test "should be abstract class" do
    assert_predicate ApplicationRecord, :abstract_class?
  end

  test "should be primary abstract class" do
    # ApplicationRecord should be the primary abstract class for Rails 7+
    assert ApplicationRecord.primary_abstract_class
  end

  test "should inherit from ActiveRecord::Base" do
    assert_operator ApplicationRecord, :<, ActiveRecord::Base
  end
end
