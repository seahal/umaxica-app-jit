require "test_helper"

class IdentifierRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert IdentifierRecord < ApplicationRecord
    assert IdentifierRecord.abstract_class?
  end
end

