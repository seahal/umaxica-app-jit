require "test_helper"

class SpecialitiesRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert SpecialitiesRecord < ApplicationRecord
    assert SpecialitiesRecord.abstract_class?
  end
end
